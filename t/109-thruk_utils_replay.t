use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok 'Thruk::Utils::Replay';

my $hosts = [map { {name => 'host', peer_key => $_, peer_name => $_} } qw/a b/];
my $services = [{host_name => 'host', description => 'service', peer_key => 'a', max_check_attempts => 3}];
sub event {
    my($time, $peer, $service, $state, $output) = @_;
    return {time => $time, peer_key => $peer, host_name => 'host', service_description => $service,
            state => $state, state_type => 'HARD', plugin_output => $output};
}
my $data = Thruk::Utils::Replay::build($hosts, $services,
    [event(9, 'a', '', 1), event(2, 'a', '', 0), event(8, 'a', 'service', 2)],
    [event(20, 'a', 'service', 0, '<script>'), event(10, 'b', '', 2),
     event(11, 'unauthorized', '', 1), event(12, 'a', '', -1)]);
is(scalar @{$data->{'objects'}}, 3, 'include authorized objects without history');
is($data->{'objects'}->[0]->{'initial'}->{'state'}, 1, 'latest preceding state wins');
is($data->{'objects'}->[1]->{'initial'}->{'state'}, undef, 'missing state history stays unknown, not live state');
is($data->{'objects'}->[2]->{'initial'}->{'state'}, 2, 'service starting state');
is_deeply([map { $_->{'time'} } @{$data->{'events'}}], [10, 20], 'events sorted and unauthorized/invalid entries omitted');
is($data->{'events'}->[0]->{'object'}, 1, 'same host on different sites stays separate');
is($data->{'events'}->[1]->{'object'}, 2, 'service state separate from host');
is($data->{'events'}->[1]->{'output'}, '<script>', 'output kept as text');
is_deeply(Thruk::Utils::Replay::build([], [], [], []), {objects => [], events => []}, 'empty result');
my $filtered = {events => [
    {log => 'HOST ALERT: host;DOWN;SOFT;2;down'},
    {log => 'SERVICE ALERT: host;service;CRITICAL;HARD;3;critical'},
    {log => 'SERVICE NOTIFICATION: admin;host;service;CRITICAL;mail;critical'},
    {log => 'EXTERNAL COMMAND: DISABLE_SVC_CHECK;host;service'},
]};
Thruk::Utils::Replay::filter_logs($filtered, 'alert|notification', 'soft');
is_deeply($filtered->{'log_indices'}, [1, 2], 'include and exclude patterns are case insensitive');
is(scalar @{$filtered->{'events'}}, 4, 'log filtering preserves all state changes');
Thruk::Utils::Replay::filter_logs($filtered, 'SERVICE ALERT', '');
is_deeply($filtered->{'log_indices'}, [1], 'spaces in a search pattern are literal');
Thruk::Utils::Replay::filter_logs($filtered, '', 'NOTIFICATION');
is_deeply($filtered->{'log_indices'}, [0, 1, 3], 'exclude pattern works independently');
Thruk::Utils::Replay::filter_logs($filtered, 'not present', '');
is_deeply($filtered->{'log_indices'}, [], 'unmatched search selects no log entries');
my $unfiltered = {events => $filtered->{'events'}};
Thruk::Utils::Replay::filter_logs($unfiltered, ' ', '');
ok(!exists $unfiltered->{'log_indices'}, 'blank patterns do not filter logs');

sub downtime {
    my($time, $service, $transition) = @_;
    return {time => $time, peer_key => 'a', host_name => 'host', service_description => $service,
            type => $service ? 'SERVICE DOWNTIME ALERT' : 'HOST DOWNTIME ALERT',
            message => ($service ? 'SERVICE DOWNTIME ALERT: host;service;' : 'HOST DOWNTIME ALERT: host;').$transition.';Downtime'};
}
my $checked = event(5, 'a', 'service', 2, 'critical');
$checked->{'options'} = 'host;service;CRITICAL;SOFT;2;critical';
my $history = Thruk::Utils::Replay::build($hosts, $services,
    [$checked, downtime(4, 'service', 'STARTED'), downtime(3, '', 'STARTED')],
    [downtime(10, 'service', 'STOPPED'), event(12, 'a', 'service', 0), downtime(15, '', 'CANCELLED')]);
is($history->{'objects'}->[2]->{'initial'}->{'check_attempts'}, 2, 'attempts parsed from service log options');
is($history->{'objects'}->[2]->{'initial'}->{'downtime'}, 1, 'state record preserves preceding downtime');
is($history->{'objects'}->[2]->{'host_object'}, 0, 'service references host downtime on the same backend');
is($history->{'objects'}->[2]->{'backend'}, 'a', 'retain backend for object links');
is($history->{'objects'}->[2]->{'max_attempts'}, 3, 'retain configured maximum check attempts');
is($history->{'events'}->[0]->{'downtime'}, 0, 'STOPPED clears downtime');
is($history->{'events'}->[0]->{'state'}, 2, 'downtime does not overwrite check status');
is($history->{'events'}->[0]->{'last_check'}, 5, 'downtime does not overwrite check time');
is($history->{'events'}->[1]->{'downtime'}, 0, 'subsequent checks retain downtime state');
is($history->{'events'}->[2]->{'downtime'}, 0, 'CANCELLED clears downtime');
my $host_check = event(9, 'a', '', 1);
$host_check->{'message'} = '[9] HOST ALERT: host;DOWN;SOFT;3;down';
my $host_history = Thruk::Utils::Replay::build($hosts, [], [], [$host_check]);
is($host_history->{'events'}->[0]->{'check_attempts'}, 3, 'host attempts parsed from full cached message');
is($host_history->{'events'}->[0]->{'output'}, 'down', 'cached messages supply plugin output');
for my $service ('', 'service') {
    my $problem = event(10, 'a', $service, 1, 'problem');
    $problem->{'state_type'} = 'SOFT';
    $problem->{'options'} = $service ? 'host;service;WARNING;SOFT;2;problem' : 'host;DOWN;SOFT;2;problem';
    my $recovery = event(20, 'a', $service, 0, 'recovered');
    $recovery->{'state_type'} = 'SOFT';
    $recovery->{'message'} = $service ? 'SERVICE ALERT: host;service;OK;SOFT;3;recovered' : 'HOST ALERT: host;UP;SOFT;3;recovered';
    my $replayed = Thruk::Utils::Replay::build($hosts, $services, [$problem], [$recovery]);
    my $id = $service ? 2 : 0;
    is($replayed->{'objects'}->[$id]->{'initial'}->{'state_type'}, 'SOFT', 'problem state type is unchanged');
    is($replayed->{'objects'}->[$id]->{'initial'}->{'check_attempts'}, 2, 'problem attempts are unchanged');
    is($replayed->{'events'}->[0]->{'state_type'}, 'HARD', 'recovery persists a hard state');
    is($replayed->{'events'}->[0]->{'check_attempts'}, 1, 'recovery resets attempt to one');
    like($replayed->{'events'}->[0]->{'log'}, qr/;SOFT;3;/, 'original recovery log is preserved');
    my $seeded = Thruk::Utils::Replay::build($hosts, $services, [$recovery], []);
    is($seeded->{'objects'}->[$id]->{'initial'}->{'state_type'}, 'HARD', 'preceding recovery also seeds a hard state');
    is($seeded->{'objects'}->[$id]->{'initial'}->{'check_attempts'}, 1, 'preceding recovery seeds attempt one');
}
my $notification = Thruk::Utils::Replay::build($hosts, $services, [$checked], [{
    time => 10, peer_key => 'a', type => 'SERVICE NOTIFICATION', host_name => 'host', service_description => 'service',
    state => 0, plugin_output => 'notification output', message => '[10] SERVICE NOTIFICATION: admin;host;service;CRITICAL;mail;notification output',
}, {
    time => 11, peer_key => 'a', type => 'SERVICE NOTIFICATION', host_name => 'host', service_description => 'service',
    message => '[11] SERVICE NOTIFICATION: other;host;service;CRITICAL;mail;notification output',
}, event(12, 'a', 'service', 0)]);
like($notification->{'events'}->[0]->{'log'}, qr/SERVICE NOTIFICATION/, 'notifications appear in replay events');
is($notification->{'events'}->[0]->{'type'}, 'SERVICE NOTIFICATION', 'retain event type for chart colors');
is($notification->{'events'}->[0]->{'state'}, 2, 'notification does not change check state');
is($notification->{'events'}->[0]->{'last_check'}, 5, 'notification does not change check time');
is($notification->{'events'}->[0]->{'check_attempts'}, 2, 'notification does not change check attempts');
is($notification->{'events'}->[0]->{'output'}, 'critical', 'notification does not replace check output');
is($notification->{'objects'}->[2]->{'initial'}->{'notification_count'}, 0, 'notification counter starts at range beginning');
is($notification->{'events'}->[0]->{'notification_count'}, 1, 'first notification increments counter');
is($notification->{'events'}->[1]->{'notification_count'}, 2, 'separate contact notification increments counter');
is($notification->{'events'}->[2]->{'notification_count'}, 2, 'check state changes preserve range notification count');

sub command {
    my($time, $text) = @_;
    return {time => $time, peer_key => 'a', type => 'EXTERNAL COMMAND', message => 'EXTERNAL COMMAND: '.$text};
}
my $flags = Thruk::Utils::Replay::build($hosts, $services,
    [event(5, 'a', 'service', 2), command(6, 'DISABLE_SVC_CHECK;host;service')],
    [command(10, 'ACKNOWLEDGE_SVC_PROBLEM;host;service;0;1;0;author;ack'),
     event(11, 'a', 'service', 1), command(12, 'ENABLE_SVC_CHECK;host;service'),
     command(13, 'ACKNOWLEDGE_SVC_PROBLEM_EXPIRE;host;service;1;1;0;20;author;ack'),
     event(14, 'a', 'service', 2), event(21, 'a', 'service', 0),
     command(22, 'ACKNOWLEDGE_HOST_PROBLEM;host;1;1;0;author;ack'),
     command(23, 'REMOVE_HOST_ACKNOWLEDGEMENT;host'),
     command(24, 'DISABLE_HOST_CHECK;host'),
     command(25, 'DISABLE_SVC_CHECK;unrelated;service'),
     command(26, 'UNSUPPORTED_COMMAND;host')]);
is($flags->{'objects'}->[2]->{'initial'}->{'active_checks_enabled'}, 0, 'preceding disable command seeds active-check flags');
is($flags->{'objects'}->[2]->{'initial'}->{'acknowledged'}, 0, 'future acknowledgement is not shown at range start');
is($flags->{'events'}->[0]->{'acknowledged'}, 1, 'acknowledgement command sets flag');
is($flags->{'events'}->[1]->{'acknowledged'}, 0, 'normal acknowledgement clears on state change');
is($flags->{'events'}->[2]->{'active_checks_enabled'}, 1, 'enable command clears disabled checks');
is($flags->{'events'}->[3]->{'ack_expire'}, 20, 'acknowledgement expiry retained');
is($flags->{'events'}->[4]->{'acknowledged'}, 1, 'sticky acknowledgement survives problem state change');
is($flags->{'events'}->[5]->{'acknowledged'}, 0, 'recovery clears sticky acknowledgement');
is($flags->{'events'}->[6]->{'object'}, 0, 'host acknowledgement targets host on matching backend');
is($flags->{'events'}->[7]->{'acknowledged'}, 0, 'explicit removal clears acknowledgement');
is($flags->{'events'}->[8]->{'active_checks_enabled'}, 0, 'host checks can be disabled');
is(scalar @{$flags->{'events'}}, 9, 'ignore unrelated and unsupported commands');
like($flags->{'events'}->[0]->{'log'}, qr/ACKNOWLEDGE_SVC_PROBLEM/, 'retain raw current log entry');
my $fallback = Thruk::Utils::Replay::build([{name => 'host', peer_key => 'a', acknowledged => 1, active_checks_enabled => 0}], [], [], []);
is($fallback->{'objects'}->[0]->{'initial'}->{'acknowledged'}, 1, 'current acknowledgement fills missing command history');
is($fallback->{'objects'}->[0]->{'initial'}->{'active_checks_enabled'}, 0, 'currently disabled checks fill missing command history');

{
    no warnings qw/redefine once/;
    local *Thruk::Utils::Auth::get_auth_filter = sub { return {auth => $_[1]}; };
    my $db = bless {hosts => $hosts, events => [], queries => []}, 'ReplayTestDB';
    my $c = bless {db => $db, stash => {has_service_filter => 0}}, 'ReplayTestContext';
    my $result = Thruk::Utils::Replay::load($c, 10, 30, {name => 'host'}, {host_name => 'host'});
    is($result->{'start'}, 10, 'range start preserved');
    is($result->{'end'}, 30, 'range end preserved');
    is_deeply($db->{'host_options'}->{'filter'}->[1], {name => 'host'}, 'status host filter is reused');
    is_deeply($db->{'service_options'}->{'filter'}->[1], {host_name => 'host'}, 'status service filter is reused');
    is_deeply($db->{'queries'}->[0]->{'filter'}->[1]->{'-or'}->[0]->{'-and'}->[1],
              {-or => [{host_name => 'host', service_description => undef}, {host_name => 'host', service_description => undef}]},
              'log queries are scoped to selected objects');
    is_deeply($db->{'queries'}->[0]->{'filter'}->[0], {auth => 'log'}, 'log queries use authorization filter');
    is_deeply([@{$db->{'queries'}->[0]->{'filter'}}[-2, -1]],
              [{time => {'>=' => 10}}, {time => {'<' => 30}}], 'range includes start but excludes end');
    is_deeply($db->{'queries'}->[1]->{'sort'}, {DESC => 'time'}, 'starting states query newest records first');
    $db->{'events'} = [({}) x 50001];
    like(Thruk::Utils::Replay::load($c, 10, 30, '', '')->{'error'}, qr/50000 events/, 'refuse truncated replay');
    $db->{'hosts'} = [({}) x 5001];
    like(Thruk::Utils::Replay::load($c, 10, 30, '', '')->{'error'}, qr/5000 objects/, 'bound object count');
    $c->{'stash'}->{'has_service_filter'} = 1;
    $db->{'hosts'} = $hosts;
    $db->{'events'} = [];
    $db->{'services'} = $services;
    my $service_only = Thruk::Utils::Replay::load($c, 10, 30, undef, {description => 'service'});
    is(scalar(grep { !$_->{'hidden'} } @{$service_only->{'objects'}}), 1, 'service-only filters do not display host dependencies');
}

done_testing();


package ReplayTestContext;

use warnings;
use strict;

sub db { return $_[0]->{'db'}; }
sub stash { return $_[0]->{'stash'}; }


package ReplayTestDB;

use warnings;
use strict;

sub get_hosts {
    my($self, %options) = @_;
    $self->{'host_options'} = \%options;
    return $self->{'hosts'};
}
sub get_services {
    my($self, %options) = @_;
    $self->{'service_options'} = \%options;
    return $self->{'services'} // [];
}
sub get_logs {
    my($self, %options) = @_;
    push @{$self->{'queries'}}, \%options;
    return $self->{'events'};
}
