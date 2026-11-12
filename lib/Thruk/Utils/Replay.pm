package Thruk::Utils::Replay;

use warnings;
use strict;
use Cpanel::JSON::XS qw/encode_json/;

use Thruk::Utils::Auth ();

=head1 NAME

Thruk::Utils::Replay - reconstruct status from recorded state changes

=head1 METHODS

=head2 load

Load authorized objects, starting states and events for a replay.

=cut

sub load {
    my($c, $start, $end, $hostfilter, $servicefilter) = @_;
    my $services = $c->db->get_services(
        filter => [Thruk::Utils::Auth::get_auth_filter($c, 'services'), $servicefilter],
        columns => [qw/host_name description max_check_attempts acknowledged active_checks_enabled accept_passive_checks/], limit => 5001,
    );
    my $service_only = $c->stash->{'has_service_filter'};
    # Service-only views still need host history for the host downtime indicators.
    my %names = map { $_->{'host_name'} => 1 } @{$services};
    my $hosts = $service_only && !%names ? [] : $c->db->get_hosts(
        filter => [Thruk::Utils::Auth::get_auth_filter($c, 'hosts'),
                   $service_only ? {-or => [map { {name => $_} } sort keys %names]} : $hostfilter],
        columns => [qw/name max_check_attempts acknowledged active_checks_enabled accept_passive_checks/], limit => 5001,
    );
    $_->{'replay_hidden'} = 1 for $service_only ? @{$hosts} : ();
    if(@{$hosts} + @{$services} > 5000) {
        return {error => 'More than 5000 objects match. Please narrow the display filter.'};
    }
    my $data = {objects => [], events => [], start => $start, end => $end};
    return $data unless @{$hosts} || @{$services};
    my @objects = (
        (map { {host_name => $_->{'name'}, service_description => undef} } @{$hosts}),
        (map { {host_name => $_->{'host_name'}, service_description => $_->{'description'}} } @{$services}),
    );
    my $types = {-or => [map { {type => $_} } ('HOST ALERT', 'SERVICE ALERT',
            'INITIAL HOST STATE', 'INITIAL SERVICE STATE', 'CURRENT HOST STATE', 'CURRENT SERVICE STATE',
            'HOST DOWNTIME ALERT', 'SERVICE DOWNTIME ALERT', 'HOST NOTIFICATION', 'SERVICE NOTIFICATION')]};
    my %command_hosts = map { ($_->{'host_name'} // $_->{'name'}) => 1 } (@{$hosts}, @{$services});
    my $commands = '(ACKNOWLEDGE_(HOST|SVC)_PROBLEM(_EXPIRE)?|REMOVE_(HOST|SVC)_ACKNOWLEDGEMENT|(ENABLE|DISABLE)_(HOST|SVC)_CHECK);('
                   .join('|', map { quotemeta($_) } sort keys %command_hosts).');';
    my @filter = (
        Thruk::Utils::Auth::get_auth_filter($c, 'log'),
        {-or => [{-and => [$types, {-or => \@objects}]},
                 {-and => [{type => 'EXTERNAL COMMAND'}, {message => {'~~' => $commands}}]}]},
    );
    my $columns = [qw/time type host_name service_description state state_type plugin_output options message/];
    my $events = $c->db->get_logs(
        filter => [@filter, {time => {'>=' => $start}}, {time => {'<' => $end}}],
        columns => $columns, sort => {ASC => 'time'}, limit => 50001,
    );
    if(@{$events} > 50000) {
        return {error => 'More than 50000 events match. Please narrow the time range or select a host or service.'};
    }
    # shortcut: scan 50000 preceding records per backend; use per-object lookups if this leaves too many gaps.
    my $before = $c->db->get_logs(
        filter => [@filter, {type => {'!=' => 'HOST NOTIFICATION'}}, {type => {'!=' => 'SERVICE NOTIFICATION'}}, {time => {'<' => $start}}],
        columns => $columns, sort => {DESC => 'time'}, limit => 50000,
    );
    $data = build($hosts, $services, $before, $events);
    $data->{'start'} = $start;
    $data->{'end'} = $end;
    return $data;
}

=head2 build

Map log entries onto authorized objects, keeping backend identities separate.

=cut

sub build {
    my($hosts, $services, $before, $events) = @_;
    my(@objects, %index, @states);
    for my $row (@{$hosts}, @{$services}) {
        my $host = $row->{'host_name'} // $row->{'name'};
        my $service = $row->{'description'} // '';
        my $key = encode_json([$row->{'peer_key'}, $host, $service]);
        $index{$key} = scalar @objects;
        push @objects, {host => $host, service => $service, backend => $row->{'peer_key'},
                        max_attempts => $row->{'max_check_attempts'},
                        accept_passive_checks => $row->{'accept_passive_checks'} ? 1 : 0,
                        hidden => $row->{'replay_hidden'} || 0,
                        site => $row->{'peer_name'} // $row->{'peer_key'}, initial => undef};
    }
    for my $object (@objects) {
        $object->{'host_object'} = $index{encode_json([$object->{'backend'}, $object->{'host'}, ''])};
    }
    # shortcut: current flags seed gaps without command history; use archived status snapshots for exact historical flags.
    for my $row (@{$hosts}, @{$services}) {
        push @states, {acknowledged => $row->{'acknowledged'} ? 1 : 0,
                       active_checks_enabled => defined $row->{'active_checks_enabled'} ? 0 + $row->{'active_checks_enabled'} : 1,
                       ack_sticky => 1, notification_count => 0};
    }
    my @sets;
    my %seen;
    for my $set ($before, $events) {
        my @logs;
        for my $entry (sort { $a->{'time'} <=> $b->{'time'} } @{$set}) {
            my $log = $entry;
            if(($log->{'type'} // '') eq 'EXTERNAL COMMAND') {
                $log = _command($log);
                next unless $log;
                my $id = $index{encode_json([$log->{'peer_key'}, $log->{'host_name'}, $log->{'service_description'}])};
                next unless defined $id;
                for my $flag (qw/acknowledged active_checks_enabled/) {
                    next unless exists $log->{'replay_flags'}->{$flag};
                    $states[$id]->{$flag} = !$log->{'replay_flags'}->{$flag} ? 1 : 0 unless $seen{$id}{$flag}++;
                }
            }
            push @logs, $log;
        }
        push @sets, \@logs;
    }
    $objects[$_]->{'initial'} = {%{$states[$_]}} for 0..$#objects;
    my @changes;
    for my $set (@sets) {
        for my $log (@{$set}) {
            my $service = $log->{'service_description'} // '';
            my $key = encode_json([$log->{'peer_key'}, $log->{'host_name'}, $service]);
            next unless exists $index{$key};
            my $id = $index{$key};
            my $options = $log->{'options'} // $log->{'message'} // '';
            $options =~ s/^(?:\[\d+\]\s*)?[^:]+:\s*//mx if !defined $log->{'options'};
            my @parts = split /;/mx, $options, $service ? 6 : 5;
            my $change = {%{$states[$id] || {}}, object => $id, time => 0 + $log->{'time'}};
            if($log->{'replay_flags'}) {
                @{$change}{keys %{$log->{'replay_flags'}}} = values %{$log->{'replay_flags'}};
            } elsif(($log->{'type'} // '') =~ m/^(?:HOST|SERVICE)\ DOWNTIME\ ALERT$/mx) {
                my $transition = $parts[$service ? 2 : 1] // '';
                next unless $transition =~ m/^(?:STARTED|STOPPED|CANCELLED)$/mx;
                $change->{'downtime'} = $transition eq 'STARTED' ? 1 : 0;
            } elsif(($log->{'type'} // '') =~ m/^(?:HOST|SERVICE)\ NOTIFICATION$/mx) {
                $change->{'notification_count'}++;
            } else {
                next unless defined $log->{'state'} && $log->{'state'} =~ m/^[0-3]$/mx;
                next if !$service && $log->{'state'} > 2;
                if($log->{'state'} == 0 || (!$change->{'ack_sticky'} && defined $change->{'state'} && $change->{'state'} != $log->{'state'})) {
                    $change->{'acknowledged'} = 0;
                }
                $change->{'state'} = 0 + $log->{'state'};
                $change->{'last_check'} = 0 + $log->{'time'};
                $change->{'state_type'} = $log->{'state_type'} // '';
                $change->{'output'} = $log->{'plugin_output'} // $parts[$service ? 5 : 4] // '';
                my $attempt = $parts[$service ? 4 : 3] // '';
                $change->{'check_attempts'} = $attempt =~ m/^\d+$/mx ? 0 + $attempt : undef;
                # Recovery is logged before the core resets its persisted check state.
                if($change->{'state'} == 0) {
                    $change->{'state_type'} = 'HARD';
                    $change->{'check_attempts'} = 1;
                }
            }
            $change->{'log'} = $log->{'message'} // (($log->{'type'} // 'STATE').': '.$options);
            $change->{'type'} = $log->{'type'} // 'STATE';
            $states[$id] = $change;
            if($set == $sets[0]) {
                $objects[$index{$key}]->{'initial'} = $change;
            } else {
                push @changes, $change;
            }
        }
    }
    return {objects => \@objects, events => \@changes};
}

=head2 filter_logs

Select displayed log indices without discarding state changes needed by replay.

=cut

sub filter_logs {
    my($data, $pattern, $exclude_pattern) = @_;
    # Keep literal spaces and anchor semantics in user-entered patterns.
    my $include = $pattern =~ m/\S/mx ? qr/(?-mx)$pattern/imx : undef;
    my $exclude = $exclude_pattern =~ m/\S/mx ? qr/(?-mx)$exclude_pattern/imx : undef;
    return $data unless $include || $exclude;
    my $events = $data->{'events'};
    $data->{'log_indices'} = [grep {
        my $message = $events->[$_]->{'log'} // '';
        (!$include || $message =~ $include) && (!$exclude || $message !~ $exclude)
    } 0..$#{$events}];
    return $data;
}

sub _command {
    my($log) = @_;
    my $options = $log->{'options'} // $log->{'message'} // '';
    $options =~ s/^(?:\[\d+\]\s*)?EXTERNAL\ COMMAND:\s*//mx;
    my($command, $host, @args) = split /;/mx, $options;
    return unless defined $host && $command =~ m/^(?:ACKNOWLEDGE_(?:HOST|SVC)_PROBLEM(?:_EXPIRE)?|REMOVE_(?:HOST|SVC)_ACKNOWLEDGEMENT|(?:ENABLE|DISABLE)_(?:HOST|SVC)_CHECK)$/mx;
    my $service = $command =~ m/_SVC_/mx ? shift @args : '';
    return unless defined $service;
    my $flags;
    if($command =~ m/^ACKNOWLEDGE_/mx) {
        $flags = {acknowledged => 1, ack_sticky => ($args[0] // '') eq '1' ? 1 : 0,
                  ack_expire => $command =~ m/_EXPIRE$/mx && ($args[3] // '') =~ m/^\d+$/mx ? 0 + $args[3] : 0};
    } elsif($command =~ m/^REMOVE_/mx) {
        $flags = {acknowledged => 0};
    } else {
        $flags = {active_checks_enabled => $command =~ m/^ENABLE_/mx ? 1 : 0};
    }
    return {%{$log}, host_name => $host, service_description => $service, replay_flags => $flags};
}

1;
