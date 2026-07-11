package Thruk::Backend::Provider::DBcommon;

use warnings;
use strict;
use Carp qw/confess/;
use Data::Dumper qw/Dumper/;
use Module::Load qw/load/;
use POSIX ();
use Time::HiRes qw/gettimeofday tv_interval/;

use Thruk::Timer qw/timing_breakpoint/;
use Thruk::Utils ();
use Thruk::Utils::Log qw/:all/;

use parent 'Thruk::Backend::Provider::Base';

$Thruk::Backend::Provider::DBcommon::cache_version = 6;

$Thruk::Backend::Provider::DBcommon::db_types = {
    'INITIAL HOST STATE'      => 6, # LOGCLASS_STATE
    'CURRENT HOST STATE'      => 6, # LOGCLASS_STATE
    'HOST ALERT'              => 1, # LOGCLASS_ALERT
    'HOST DOWNTIME ALERT'     => 1, # LOGCLASS_ALERT
    'HOST FLAPPING ALERT'     => 1, # LOGCLASS_ALERT

    'INITIAL SERVICE STATE'   => 6, # LOGCLASS_STATE
    'CURRENT SERVICE STATE'   => 6, # LOGCLASS_STATE
    'SERVICE ALERT'           => 1, # LOGCLASS_ALERT
    'SERVICE DOWNTIME ALERT'  => 1, # LOGCLASS_ALERT
    'SERVICE FLAPPING ALERT'  => 1, # LOGCLASS_ALERT

    'TIMEPERIOD TRANSITION'   => 6, # LOGCLASS_STATE

    'HOST NOTIFICATION'       => 3, # LOGCLASS_NOTIFICATION
    'SERVICE NOTIFICATION'    => 3, # LOGCLASS_NOTIFICATION

    'PASSIVE SERVICE CHECK'   => 4, # LOGCLASS_PASSIVECHECK
    'PASSIVE HOST CHECK'      => 4, # LOGCLASS_PASSIVECHECK

    'SERVICE EVENT HANDLER'   => 0, # INFO
    'HOST EVENT HANDLER'      => 0, # INFO

    'EXTERNAL COMMAND'        => 5, # LOGCLASS_COMMAND
    'LOG ROTATION'            => 0, # INFO
};

$Thruk::Backend::Provider::DBcommon::db_classes = {
    'INFO'          => 0,
    'ALERT'         => 1,
    'PROGRAMM'      => 2,
    'NOTIFICATION'  => 3,
    'PASSIVE'       => 4,
    'COMMAND'       => 5,
    'STATE'         => 6,
};

use constant {
    MODE_IMPORT         => 1,
    MODE_UPDATE         => 2,
};

@Thruk::Backend::Provider::DBcommon::tables = (qw/contact contact_host_rel contact_service_rel host log service status/);

END {
    # close all connections at the end
    return unless $INC{"DBI.pm"};
    DBI->visit_handles(sub {
        my($dbh) = @_;
        if($dbh->{'Type'} eq 'db') {
            $dbh->disconnect;
        }
        return 1;
    });
}

sub cache_version {
    return $Thruk::Backend::Provider::DBcommon::cache_version;
}

sub db_types {
    return $Thruk::Backend::Provider::DBcommon::db_types;
}

sub db_classes {
    return $Thruk::Backend::Provider::DBcommon::db_classes;
}

sub tables {
    return \@Thruk::Backend::Provider::DBcommon::tables;
}

sub reconnect {
    my($self) = @_;
    $self->_disconnect();
    return;
}

sub _disconnect {
    my($self) = @_;
    my $db_handle_name = $self->_db_handle_name();
    if(defined $self->{$db_handle_name}) {
        &timing_breakpoint('disconnect');
        $self->{$db_handle_name}->disconnect();
        delete $self->{$db_handle_name};
    }
    return;
}

sub peer_key {
    my($self, $new_val) = @_;
    if(defined $new_val) {
        $self->{'peer_config'}->{'peer_key'} = $new_val;
    }
    return $self->{'peer_config'}->{'peer_key'};
}

sub peer_addr {
    my $self = shift;
    return $self->{'peer_config'}->{'peer'};
}

sub peer_name {
    my $self = shift;
    return $self->{'peer_config'}->{'name'};
}

sub set_verbose {
    my($self, $val) = @_;
    my $old = $self->{'verbose'};
    $self->{'verbose'} = $val;
    return($old);
}

sub renew_logcache {
    return;
}

sub _add_peer_data {
    my($self, $data) = @_;
    for my $d (@{$data}) {
        $d->{'peer_name'} = $self->peer_name;
        $d->{'peer_addr'} = $self->peer_addr;
        $d->{'peer_key'}  = $self->peer_key;
    }
    return $data;
}

# Unimplemented backend provider interface methods
sub send_command { confess("not implemented"); }
sub get_processinfo { confess("not implemented"); }
sub get_sites { confess("unimplemented"); }
sub get_can_submit_commands { confess("not implemented"); }
sub get_contactgroups_by_contact { confess("not implemented"); }
sub get_hosts { confess("not implemented"); }
sub get_hosts_by_servicequery { confess("not implemented"); }
sub get_host_names { confess("not implemented"); }
sub get_hostgroups { confess("not implemented"); }
sub get_hostgroup_names { confess("not implemented"); }
sub get_services { confess("not implemented"); }
sub get_service_names { confess("not implemented"); }
sub get_servicegroups { confess("not implemented"); }
sub get_servicegroup_names { confess("not implemented"); }
sub get_comments { confess("not implemented"); }
sub get_downtimes { confess("not implemented"); }
sub get_contactgroups { confess("not implemented"); }
sub get_contactgroup_names { confess("not implemented"); }
sub get_timeperiods { confess("not implemented"); }
sub get_timeperiod_names { confess("not implemented"); }
sub get_commands { confess("not implemented"); }
sub get_contacts { confess("not implemented"); }
sub get_contact_names { confess("not implemented"); }
sub get_host_stats { confess("not implemented"); }
sub get_host_totals_stats { confess("not implemented"); }
sub get_host_less_stats { confess("not implemented"); }
sub get_service_stats { confess("not implemented"); }
sub get_service_totals_stats { confess("not implemented"); }
sub get_service_less_stats { confess("not implemented"); }
sub get_performance_stats { confess("not implemented"); }
sub get_extra_perf_stats { confess("not implemented"); }
sub get_contact_totals_stats { confess("not implemented"); }

# Common database helper methods
sub _tables_exist {
    my($self, $dbh, $prefix) = @_;
    my($sql, $args) = $self->_sql_tables_exist($prefix);
    my @tables = @{$dbh->selectcol_arrayref($sql, undef, @{$args})};
    return scalar @tables >= 5 ? 1 : 0;
}

sub _quote_table {
    my($self, $table) = @_;
    my $quote = $self->_quote_char();
    return $quote . $table . $quote;
}

sub _sql_debug {
    my($self, $sql, $dbh) = @_;
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    my $data = $sth->fetchall_arrayref({});
    return(Thruk::Utils::text_table(
        keys => $sth->{'NAME'},
        data => $data,
    ));
}

sub _get_exclude_filter {
    my($self, $config) = @_;
    my $exclude_filter = [];
    if($config->{'logcache_exclude_pattern'}) {
        my $ref = ref $config->{'logcache_exclude_pattern'};
        if(!$ref) {
            push @{$exclude_filter}, $config->{'logcache_exclude_pattern'};
        }
        elsif($ref eq 'ARRAY') {
            push @{$exclude_filter}, @{$config->{'logcache_exclude_pattern'}};
        }
    }
    return $exclude_filter;
}

sub get_logs {
    my($self, %options) = @_;

    my $orderby = '';
    my $sorted  = 0;
    if(defined $options{'sort'}->{'DESC'} and $options{'sort'}->{'DESC'} eq 'time') {
        $orderby = ' ORDER BY l.time DESC';
        $sorted  = 1;
    }
    if(defined $options{'sort'}->{'ASC'} and $options{'sort'}->{'ASC'} eq 'time') {
        $orderby = ' ORDER BY l.time ASC';
        $sorted  = 1;
    }

    my $limit = '';
    my $pager_limit;
    if(defined $options{'options'} && $options{'options'}->{'limit'}) {
        $limit = ' LIMIT '.$options{'options'}->{'limit'};
    } else {
        if($options{'pager'}) {
            $pager_limit = $options{'pager'}->{'entries'} * $options{'pager'}->{'page'};
            $limit = ' LIMIT '.$pager_limit if $pager_limit > 0;
        }
    }
    $limit = ' LIMIT 10000000' unless $limit;

    my $prefix = $options{'collection'};
    $prefix    =~ s/^logs_//gmx;
    my $dbh = $self->_dbh;

    $self->{'query_meta'} = {
        dbh     => $dbh,
        prefix  => $prefix,
    };
    my($where,$auth_data) = $self->_get_filter($options{'filter'});

    return unless $self->_tables_exist($dbh, $prefix);

    # check logcache version
    my $table_status = $self->_quote_table($prefix.'_status');
    my @versions = @{$dbh->selectcol_arrayref('SELECT value FROM '.$table_status.' WHERE status_id = 4 LIMIT 1')};
    my $cache_ver = $self->cache_version();
    if(scalar @versions < 1 || $versions[0] != $cache_ver) {
        confess(sprintf("Logcache too old, required version %s but got %s. Run 'thruk logcache update' to upgrade.", $cache_ver, $versions[0] // '0'));
    }

    # check compact timerange and set a warning flag
    my $c =$Thruk::Globals::c;
    if($c) {
        my $compact_start_data = Thruk::Utils::get_expanded_start_date($c, $c->config->{'logcache_compact_duration'});
        # get time filter
        my($start, $end) = Thruk::Utils::extract_time_filter($options{'filter'});
        if($start && $start < $compact_start_data) {
            $c->stash->{'logs_from_compacted_zone'} = 1;
        }
        elsif($end && $end < $compact_start_data) {
            $c->stash->{'logs_from_compacted_zone'} = 1;
        }
    }

    my $extra_columns = '';
    if($options{'extra_columns'}) {
        $extra_columns = $self->_sql_extra_columns();
    }

    my $sql = '
    SELECT
        l.time as time,
        l.class as class,
        l.type as type,
        l.state as state,
        l.state_type as state_type,
        ' . $self->_sql_coalesce('h.host_name', "''") . ' as host_name,
        ' . $self->_sql_coalesce('s.service_description', "''") . ' as service_description,
        ' . $self->_sql_coalesce('c.name', "''") . ' as contact_name,
        l.message as message,
        \'' . $prefix . '\' as peer_key
        ' . $extra_columns . '
    FROM
        ' . $self->_quote_table($prefix.'_log') . ' l
        LEFT JOIN ' . $self->_quote_table($prefix.'_host') . ' h ON l.host_id = h.host_id
        LEFT JOIN ' . $self->_quote_table($prefix.'_service') . ' s ON l.service_id = s.service_id
        LEFT JOIN ' . $self->_quote_table($prefix.'_contact') . ' c ON l.contact_id = c.contact_id
    '.$where.'
    '.$orderby.'
    '.$limit.'
    ';
    confess($sql) if $sql =~ m/(ARRAY|HASH)/mx;

    ## no critic
    $ENV{'THRUK_DB_LAST_QUERY'} = $sql;
    ## use critic

    # logfiles into tmp file
    my($fh, $filename);
    if($options{'file'}) {
        load File::Temp, qw/tempfile/;
        ($fh, $filename) = tempfile();
        open($fh, '>', $filename) or die('open '.$filename.' failed: '.$!);
    }

    # add performance related debug output
    if(Thruk::Base->verbose >= 3) {
        _trace($sql);

        _trace("EXPLAIN:");
        _trace($self->_sql_debug("EXPLAIN\n".$sql, $dbh));

        my $debug_sql = $self->_sql_show_indexes($prefix);
        _trace($debug_sql.":");
        _trace($self->_sql_debug($debug_sql, $dbh));
    }

    # queries with authorization
    my $data = [];
    if($auth_data->{'username'}) {
        my($contact,$strict,$authorized_for_all_services,$authorized_for_all_hosts,$authorized_for_system_information) = ($auth_data->{'username'},$auth_data->{'strict'},$auth_data->{'authorized_for_all_services'},$auth_data->{'authorized_for_all_hosts'},$auth_data->{'authorized_for_system_information'});
        my $sth = $dbh->prepare($sql);
        $sth->execute;

        my $hosts_lookup    = $self->_get_log_host_auth($dbh, $prefix, $contact);
        my $services_lookup = $self->_get_log_service_auth($dbh, $prefix, $contact);

        while(my $r = $sth->fetchrow_hashref()) {
            if($r->{'service_description'}) {
                if($authorized_for_all_services) {
                }
                elsif($strict) {
                    next if(!defined $services_lookup->{$r->{'host_name'}}->{$r->{'service_description'}});
                } else {
                    next if(!defined $hosts_lookup->{$r->{'host_name'}} && !defined $services_lookup->{$r->{'host_name'}}->{$r->{'service_description'}});
                }
            }
            elsif($r->{'host_name'}) {
                if($authorized_for_all_hosts) {
                } else {
                    next if !defined $hosts_lookup->{$r->{'host_name'}};
                }
            }
            else {
                next if !$authorized_for_system_information;
            }
            if($fh) {
                load Encode, qw/encode_utf8/;
                print $fh encode_utf8($r->{'message'}),"\n";
            } else {
                push @{$data}, $r;
            }
        }
    }
    else {
        if($fh) {
            load Encode, qw/encode_utf8/;
            my $sth = $dbh->prepare($sql);
            $sth->execute;
            while(my $r = $sth->fetchrow_arrayref()) {
                print $fh encode_utf8($r->[8]),"\n";
            }
        } else {
            $data = $dbh->selectall_arrayref($sql, { Slice => {} });
        }
    }

    my $total_size;
    if($pager_limit && scalar @{$data} >= $pager_limit) {
        # fetch real number of entries here
        my $sql = '
        SELECT
            count(*)
        FROM
            ' . $self->_quote_table($prefix.'_log') . ' l
            LEFT JOIN ' . $self->_quote_table($prefix.'_host') . ' h ON l.host_id = h.host_id
            LEFT JOIN ' . $self->_quote_table($prefix.'_service') . ' s ON l.service_id = s.service_id
            LEFT JOIN ' . $self->_quote_table($prefix.'_contact') . ' c ON l.contact_id = c.contact_id
        '.$where.'
        '.$limit.'
        ';
        my $counts = $dbh->selectall_arrayref($sql);
        $total_size = $counts->[0]->[0];
    }

    if($fh) {
        my $rc = Thruk::Utils::IO::close($fh, $filename);
        if(!$rc) {
            unlink($filename);
            confess("writing logs to $filename failed: $!");
        }
        return($filename, 'file');
    } else {
        return($data, ($sorted ? 'sorted' : ''), $total_size);
    }
}

sub _get_filter {
    my($self, $inp) = @_;
    my $auth_data = {};
    if($inp && ref $inp eq 'ARRAY') {
        for my $f (@{$inp}) {
            if(ref $f eq 'HASH' && $f->{'auth_filter'}) {
                $auth_data = $f->{'auth_filter'};
                $f = undef;
            }
        }
    }
    my $filter = $self->_get_subfilter($inp);
    if($filter and ref $filter) {
        $filter = '('.join(' AND ', @{$filter}).')';
    }
    $filter = " WHERE ".$filter if $filter;

    $filter =~ s/WHERE\ \(\((.*)\)\ AND\ \)/WHERE ($1)/gmx;
    $filter =~ s/\ AND\ \)/)/gmx;
    $filter =~ s/\(\ AND\ \(/((/gmx;
    $filter =~ s/AND\s+AND/AND/gmx;
    $filter = '' if $filter eq ' WHERE ';

    return($filter, $auth_data);
}

sub _get_subfilter {
    my($self, $inp, $f) = @_;
    return '' unless defined $inp;
    if(ref $inp eq 'ARRAY') {
        # empty lists
        return '' if scalar @{$inp} == 0;

        # single array items will be stripped from array
        if(scalar @{$inp} == 1) {
            return $self->_get_subfilter($inp->[0]);
        }

        my $x   = 0;
        my $num = scalar @{$inp};
        my $filter = [];
        while($x < $num) {
            # [ 'key', { 'op' => 'value' } ]
            if(exists $inp->[$x+1] and ref $inp->[$x] eq '' and ref $inp->[$x+1] eq 'HASH') {
                my $key = $inp->[$x];
                my $val = $inp->[$x+1];
                if(!defined $key) {
                    $x=$x+1;
                    next;
                }
                push @{$filter}, $self->_get_subfilter({$key => $val});
                $x=$x+2;
                next;
            }
            # [ '-or', [ 'key' => 'value' ] ]
            if(exists $inp->[$x+1] and ref $inp->[$x] eq '' and ref $inp->[$x+1] eq 'ARRAY') {
                my $key = $inp->[$x];
                my $val = $inp->[$x+1];
                if(!defined $key) {
                    $x=$x+1;
                    next;
                }
                push @{$filter}, $self->_get_subfilter({$key => $val});
                $x=$x+2;
                next;
            }

            # [ 'key', 'value' ] => { 'key' => 'value' }
            if(exists $inp->[$x+1] and ref $inp->[$x] eq '' and ref $inp->[$x+1] eq '') {
                my $key = $inp->[$x];
                my $val = $inp->[$x+1];
                push @{$filter}, $self->_get_subfilter({$key => $val});
                $x=$x+2;
                next;
            }

            if(defined $inp->[$x]) {
                my $f =  $self->_get_subfilter($inp->[$x]);
                if($f and ref $f) {
                    $f= '('.join(' AND ', @{$f}).')';
                }
                push @{$filter}, $f;
            }
            $x++;
        }
        if(scalar @{$filter} == 1) {
            return $filter->[0];
        }
        return $filter;
    }
    if(ref $inp eq 'HASH') {
        # single hash elements with an operator
        if(scalar keys %{$inp} == 1) {
            my $k = [keys   %{$inp}]->[0];
            my $v = [values %{$inp}]->[0];
            ($k, $v) = $self->_replace_column_name($k, $v);
            if($k eq 'IS NULL')                     { return $v.' '.$k; }
            if($k eq 'IS NOT NULL')                 { return $v.' '.$k; }
            if($k eq '=')                           { return '= '.$self->_quote($v); }
            if($k eq '!=')                          { return '!= '.$self->_quote($v); }
            if($k eq '~' || $k eq '~~' || $k eq '!~~') { return $self->_sql_regex_operator($k, $v); }
            if($k eq '>='  and ref $v eq 'ARRAY')   { confess("whuus") unless defined $f; return '= '.join(' OR '.$f.' = ', @{$self->_quote($v)}); }
            if($k eq '!>=' and ref $v eq 'ARRAY')   { confess("whuus") unless defined $f; return '!= '.join(' OR '.$f.' != ', @{$self->_quote($v)}); }
            if($k eq '!>=')                         { return '!= '.$self->_quote($v); }
            if($k eq '>=' and $v !~ m/^[\d\.]+$/mx) { return 'IN ('.join(',', @{$self->_quote($v)}).')'; }
            if($k eq '>=')                          { return '>= '.$self->_quote($v); }
            if($k eq '<=')                          { return '<= '.$self->_quote($v); }
            if($k eq '>')                           { return '> '.$self->_quote($v); }
            if($k eq '<')                           { return '< '.$self->_quote($v); }
            if($k eq '-or') {
                my $list = $self->_get_subfilter($v);
                if(ref $list) {
                    # remove empty elements
                    @{$list} = grep(!/^$/mx, @{$list});
                    for my $l (@{$list}) {
                        if(ref $l eq 'ARRAY') {
                            $l = '('.join(' AND ', @{$l}).')';
                        }
                    }
                    return('('.join(' OR ', @{$list}).')');
                }
                return $list;
            }
            if($k eq '-and') {
                my $list = $self->_get_subfilter($v);
                if(ref $list) {
                    @{$list} = grep(!/^$/mx, @{$list});
                    for my $l (@{$list}) {
                        if(ref $l eq 'ARRAY') {
                            $l = '('.join(' AND ', @{$l}).')';
                        }
                    }
                    return('('.join(' AND ', @{$list}).')');
                }
                return $list;
            }
            if(ref $v) {
                $v = $self->_get_subfilter($v, $k);
                if($v =~ m/\ OR\ $k\ /mx) {
                    return '('.$k.' '.$v.')';
                }
                return $k.' '.$v;
            }
            ($k, $v) = $self->_replace_column_name($k, $v);
            return $k.' = '.$self->_quote($v);
        }

        # multiple keys will be converted to list
        # { 'key' => 'v', 'key2' => v }
        my $list = [];
        for my $k (sort keys %{$inp}) {
            push @{$list}, {$k => $inp->{$k}};
        }
        return $self->_get_subfilter({'-and' => $list});
    }
    return $inp;
}

sub _replace_column_name {
    my($self, $col, $val, $op) = @_;
    $op = '=' unless defined $op;
    if($col eq 'contact_name') {
        return("c.name", $val);
    }

    if($col eq 'service_description' || $col eq 'type') {
        my @keys;
        if(ref $val eq 'HASH') {
            @keys = keys %{$val};
            if(scalar @keys == 1) {
                $op = $keys[0];
                if($op eq '=' || $op eq '!=') {
                    $val = $val->{$op};
                }
            }
        }
        if(!defined $val) {
            if($op eq '=') {
                return("IS NULL", $col);
            }
            if($op eq '!=') {
                return("IS NOT NULL", $col);
            }
        }
    }

    # using ids makes mysql prefer index
    if($col eq 'host_name' && $self->{'query_meta'}->{'prefix'}) {
        # val can be scalar or hash
        if(ref $val eq 'HASH') {
            my @keys = keys %{$val};
            if(scalar @keys == 1) {
                my $op = $keys[0];
                $val = $val->{$op};
                my($col, $id) = $self->_replace_column_name($col, $val, $op);
                return($col, { $op => $id });
            }
            # no replacement possible
            return($col, $val);
        }
        $self->{'query_meta'}->{'host_lookup'} = $self->_get_host_lookup($self->{'query_meta'}->{'dbh'},undef,$self->{'query_meta'}->{'prefix'}, 1) unless defined $self->{'query_meta'}->{'host_lookup'};
        my $id = $self->{'query_meta'}->{'host_lookup'}->{$val} // -1; # always replace host_name. Using the name leads to zero results but skips the index
        if($id == -1 && ($op ne '==' && $op ne '!=')) {
            return($col, $val); # in case of regex matches, fallback to host_name again
        }
        return('l.host_id', $id);
    }
    return($col, $val);
}

sub get_logs_start_end {
    my($self, @args) = @_;
    return $self->_get_logs_start_end(@args);
}

sub _get_logs_start_end {
    my($self, %options) = @_;
    my($start, $end);
    my $prefix = $options{'collection'} || $self->{'peer_config'}->{'peer_key'};
    $prefix    =~ s/^logs_//gmx;
    my $dbh  = $options{'dbh'} || $self->_dbh();
    return([$start, $end]) unless $self->_tables_exist($dbh, $prefix);
    my $where = "";
    ($where) = $self->_get_filter($options{'filter'}) if $options{'filter'};
    my $table = $self->_quote_table($prefix.'_log');
    my @data = @{$dbh->selectall_arrayref('SELECT MIN(l.time) as mi, MAX(l.time) as ma FROM '.$table.' l '.$where.' LIMIT 1', { Slice => {} })};
    $start   = $data[0]->{'mi'} if defined $data[0];
    $end     = $data[0]->{'ma'} if defined $data[0];
    return([$start, $end]);
}

sub get_existing_caches {
    my($self, $c) = @_;

    # use first logcache connection
    my $dbh;
    for my $peer ( @{ $c->db->get_peers() } ) {
        next unless $peer->{'logcache'};
        $peer->logcache->reconnect();
        $dbh = $peer->logcache->_dbh();
        last;
    }

    return unless $dbh;

    my @list;
    # check if our tables exist
    my @tables = @{$dbh->selectcol_arrayref($self->_sql_show_tables())};
    for my $table (@tables) {
        if($table =~ m/^(.*?)_log$/mx) {
            push @list, $1;
        }
    }

    return(\@list);
}

sub _log_stats {
    my($self, $c, $backends) = @_;
    my $driver = $self->_driver_name();
    $c->stats->profile(begin => $driver."::_log_stats");

    ($backends) = $c->db->select_backends('get_logs') unless defined $backends;
    $backends  = Thruk::Base::list($backends);
    push @{$backends}, keys %{$c->stash->{'failed_backends'}} if $c->stash->{'failed_backends'};

    my @result;
    for my $key (@{$backends}) {
        my $peer = $c->db->get_peer_by_key($key);
        my $msg = "OK";
        my($index_size, $data_size, $items, $last_entry);
        my $status  = {};
        if(!$peer->{'logcache'}) {
            $msg = "logcache is disabled";
        } else {
            $peer->logcache->reconnect();
            my $dbh  = $peer->logcache->_dbh();
            ($index_size, $data_size, $items, $status, $msg) = $self->_db_table_stats($dbh, $key);
            if(!$msg) {
                (undef, $last_entry) = @{$self->_get_logs_start_end(collection => $key, dbh => $dbh)};
                if($status->{'lock_mode'}->{'value'}) {
                    $msg = sprintf("running %s since %s (pid: %s)", $status->{'lock_mode'}->{'value'}, $status->{'last_update'}->{'value'} ? scalar localtime($status->{'last_update'}->{'value'}) : '?', $status->{'update_pid'}->{'value'}//'?');
                } else {
                    $msg = "OK";
                }
            }
        }
        push @result, {
            key              => $key,
            name             => $peer->{'name'},
            enabled          => $peer->{'logcache'} ? 1 : 0,
            index_size       => $index_size     // 0,
            data_size        => $data_size      // 0,
            items            => $items          // 0,
            cache_version    => $status->{'cache_version'}->{'value'}       // '',
            last_update      => $status->{'last_update'}->{'value'}         // '',
            last_reorder     => $status->{'last_reorder'}->{'value'}        // '',
            last_compact     => $status->{'last_compact'}->{'value'}        // '',
            reorder_duration => $status->{'reorder_duration'}->{'value'}    // '',
            update_duration  => $status->{'update_duration'}->{'value'}     // '',
            compact_duration => $status->{'compact_duration'}->{'value'}    // '',
            compact_till     => $status->{'compact_till'}->{'value'}        // '',
            last_entry       => $last_entry                                 // '',
            mode             => $status->{'lock_mode'}->{'value'}           // '',
            status           => $msg,
        };
    }

    $c->stats->profile(end => $driver."::_log_stats");
    return @result if wantarray;
    return Thruk::Utils::text_table(
        keys => [['Backend', 'name'],
                 { name => 'Data Size',   key => 'data_size',  type => 'bytes', format => "%.1f" },
                 { name => 'Index Size',  key => 'index_size', type => 'bytes', format => "%.1f" },
                 ['Items', 'items'],
                 { name => 'Last Update', key => 'last_update', type => 'date', format => '%Y-%m-%d %H:%M:%S' },
                 { name => 'Last Item',   key => 'last_entry',  type => 'date', format => '%Y-%m-%d %H:%M:%S' },
                 { name => 'Status',      key => 'status' },
                ],
        data => \@result,
    );
}

sub _logcache_stats_types {
    my($self, $c, $groupby, $backends) = @_;
    my $driver = $self->_driver_name();
    $c->stats->profile(begin => $driver."::_logcache_stats_types: ".$groupby);

    ($backends) = $c->db->select_backends('get_logs') unless defined $backends;
    $backends  = Thruk::Base::list($backends);

    my @result;
    for my $key (@{$backends}) {
        my $peer = $c->db->get_peer_by_key($key);
        next unless $peer->{'logcache'};
        $peer->logcache->reconnect();
        my $dbh  = $peer->logcache->_dbh();
        next unless $self->_has_log_table($dbh, $key);
        my $table = $self->_quote_table($key."_log");
        my $types  = [values %{$dbh->selectall_hashref("SELECT " . $self->_sql_coalesce($groupby, "''") . " as ".$groupby.", count(*) as total FROM ".$table." GROUP BY " . $groupby, $groupby)}];
        $types     = [reverse sort { $a->{'total'} <=> $b->{'total'} } @{$types}];
        my $total = 0;
        for my $t (@{$types}) {
            $total += $t->{'total'};
        }
        push @result, {
            key    => $key,
            name   => $peer->{'name'},
            total  => $total,
            types  => $types,
        };
    }
    $c->stats->profile(end => $driver."::_logcache_stats_types: ".$groupby);
    return @result;
}

sub _log_removeunused {
    my($self, $c, $print_only) = @_;
    my $driver = $self->_driver_name();
    $c->stats->profile(begin => $driver."::_log_removeunused");

    my $backends = $self->_log_stats($c);
    # get first logcache dbh
    my $peer;
    for my $b (@{$backends}) {
        next unless $b->{'enabled'};
        $peer = $c->db->get_peer_by_key($b->{'key'});
        last;
    }
    return "no logcache backends enabled" unless $peer;

    $peer->logcache->reconnect();
    my $dbh  = $peer->logcache->_dbh();
    my $table_names = $self->_get_all_table_names($dbh);
    my $res = {};
    for my $t (@{$table_names}) { $res->{$t} = {}; }

    # gather backend ids
    my $backends_hash = {};
    for my $b (@{$backends}) {
        next unless $b->{'enabled'};
        $backends_hash->{$b->{'key'}} = 1;
    }
    # find tables without a backend
    for my $tbl (keys %{$res}) {
        my $key = $tbl;
        $key =~ s/_.*$//gmx;
        delete $backends_hash->{$key};
    }
    if($print_only) {
        $c->stats->profile(end => $driver."::_log_removeunused");
        return($backends_hash);
    }

    my $removed = 0;
    my $tables_count  = 0;
    my $cascade = $self->_sql_drop_table_cascade();
    for my $key (keys %{$backends_hash}) {
        for my $tbl (keys %{$res}) {
            next unless $tbl =~ m/^${key}_/mx;
            $tables_count++;
            $dbh->do("DROP TABLE " . $self->_quote_table($tbl) . $cascade);
        }
        $removed++;
    }
    $dbh->commit || confess $dbh->errstr;

    $c->stats->profile(end => $driver."::_log_removeunused");
    return "no old tables found in logcache" if $removed == 0;

    return $removed." old backends removed (".$tables_count." tables) from logcache";
}

sub _log_check_inconsistency {
    my($self, $c, $backends) = @_;
    my $driver = $self->_driver_name();
    $c->stats->profile(begin => $driver."::_log_check_inconsistency()");

    ($backends) = $c->db->select_backends('get_logs') unless defined $backends;
    $backends  = Thruk::Base::list($backends);

    my $errors = {};
    for my $prefix (@{$backends}) {
        my $key = "check_inconsistency $prefix";
        $c->stats->profile(begin => "$key");
        my $peer = $c->db->get_peer_by_key($prefix);
        next unless $peer->{'logcache'};
        $peer->logcache->reconnect();
        my $dbh = $peer->logcache->_dbh;

        my $table = $self->_quote_table($prefix."_host");
        my $sth = $dbh->prepare("select count(host_id) as count, host_name from ".$table." group by host_name having count > 1");
        $sth->execute;
        my $num = 0;
        for my $r (@{$sth->fetchall_arrayref()}) {
            $num += $r->[0];
            push @{$errors->{$prefix}->{'hosts'}}, $r->[1];
        }
        $c->stats->profile(end => "$key");
    }

    $c->stats->profile(end => $driver."::_log_check_inconsistency()");

    return $errors;
}

sub _log_repair_inconsistency {
    my($self, $c, $prefix, $total) = @_;
    my $peer = $c->db->get_peer_by_key($prefix);
    my $dbh  = $peer->logcache->_dbh;

    my $table_host = $self->_quote_table($prefix."_host");
    my $sth = $dbh->prepare("select count(host_id) as count, host_name from ".$table_host." group by host_name having count > 1");
    $sth->execute;

    my $sp  = length("$total");
    my $num = 0;
    while(my $r = $sth->fetchrow_arrayref()) {
        my $hostname = $r->[1];
        $num++;

        _infos("[%0".$sp."d/%0".$sp."d] %s ", $num, $total, $hostname);

        my $sth2 = $dbh->prepare("select host_id from ".$table_host." WHERE host_name = ?");
        $sth2->execute($hostname);
        my $keepId;
        while(my $r = $sth2->fetchrow_arrayref()) {
            _infoc(".");
            my $id = $r->[0];
            if(!defined $keepId) {
                $keepId = $id;
                next;
            }
            $dbh->do("UPDATE " . $self->_quote_table($prefix."_log") . " SET host_id = ? WHERE host_id = ?", undef, $keepId, $id);
            $dbh->do("UPDATE " . $self->_quote_table($prefix."_service") . " SET host_id = ? WHERE host_id = ?", undef, $keepId, $id);
            $dbh->do("DELETE FROM " . $self->_quote_table($prefix."_contact_host_rel") . " WHERE host_id = ?", undef, $id);
            $dbh->do("DELETE FROM " . $self->_quote_table($prefix."_host") . " WHERE host_id = ?", undef, $id);
        }
        _info("OK");
    }
    $dbh->commit || confess $dbh->errstr;
    return;
}

sub _import_logs {
    my($self, $c, $mode, $backends, $blocksize, $options) = @_;
    my $files = $options->{'files'} || [];
    my $driver = $self->_driver_name();
    $c->stats->profile(begin => $driver."::_import_logs($mode)");

    my $forcestart;
    if($options->{'start'}) {
        require Thruk::Utils::DateTime;
        $forcestart = Thruk::Utils::DateTime::parse_date($c, $options->{'start'});
    }

    # do this in a single transaction if blocksize is undef/0
    my $log_count = 0;
    my $log_clear = 0;
    my $errors    = 0;
    ($backends)   = $c->db->select_backends('get_logs') unless defined $backends;
    $backends     = Thruk::Base::list($backends);
    my $total     = scalar @{$backends};
    my $num       = 0;
    my $sp        = length("$total");
    my $reordered = 0;

    my $backends_todo = [];
    my $c_backends = $c->config->{'default_backends'} // [];
    for my $prefix (@{$backends}) {
        # only update default backends in cron mode
        if($ENV{'THRUK_CRON'} && scalar @{$c_backends} > 0 && !grep(/^\Q$prefix\E$/mx, @{$c_backends})) {
            _debug("cron mode: skipping non-default backend: ".$prefix);
            next;
        }
        push @{$backends_todo}, $prefix;
    }

    $total = scalar @{$backends_todo};
    $sp    = length("$total");
    for my $prefix (@{$backends_todo}) {
        $num++;
        my $peer = $c->db->get_peer_by_key($prefix);
        if(!$peer) {
            _error("error: no such backend: %s", $prefix);
            $errors++;
            next;
        }
        if(!$peer->{'logcache'}) {
            _debug("skipping backend: ".$prefix." (logcache is disabled)");
            next;
        }
        $peer->logcache->reconnect();
        my $dbh = $peer->logcache->_dbh;

        # skip updates if a thruk process has no logcache update lock
        if($mode eq 'update' && !$c->config->{'logcache_update_lock'} && !$c->config->{'logcache_pxc_strict_mode'}) {
            my $active_thruk_pids = $self->_get_running_thruk_pids($c);
            # check lock pid in db status
            if($self->_tables_exist($dbh, $prefix)) {
                my $table_status = $self->_quote_table($prefix."_status");
                my @pids = @{$dbh->selectcol_arrayref('SELECT value FROM '.$table_status.' WHERE status_id = 2 LIMIT 1')};
                if(scalar @pids > 0 and $pids[0]) {
                    # is that lock from an active local process?
                    if(exists $active_thruk_pids->{$pids[0]}) {
                        _info("WARNING: skipping update on %s, thruk gui process %s is running update...", $prefix, $pids[0]);
                        next;
                    }
                }
            }
        }

        # clean logs
        if($mode eq 'clean') {
            _infos("[%0".$sp."d/%0".$sp."d] cleaning %s logcache... ", $num, $total, $prefix);
            my $res = $self->_update_logcache_clean($c, $dbh, $prefix, $blocksize);
            $log_count += $res->[0];
            $log_clear += $res->[1];
            _info("done. (cleaned %s log entries)", $res->[0]);
            next;
        }

        # compact logs
        if($mode eq 'compact') {
            _infos("[%0".$sp."d/%0".$sp."d] compacting %s logcache... ", $num, $total, $prefix);
            my $res = $self->_update_logcache_compact($c, $dbh, $prefix, $blocksize, $options->{'force'});
            $log_count += $res->[0];
            $log_clear += $res->[1];
            _info("done. (processed %s, removed %s log entries)", $res->[0], $res->[1]);
            next;
        }

        # optimize logs
        if($mode eq 'optimize') {
            _infos("[%0".$sp."d/%0".$sp."d] reordering %s logs... ", $num, $total, $prefix);
            my $rc = $self->_update_logcache_optimize($c, $peer, $prefix, $options);
            if($rc != -1) {
                _info("done.");
            }
            next;
        }

        # check structure
        my $recreated = 0;
        my $tables_exist = $self->_tables_exist($dbh, $prefix);
        if($mode eq 'import' || !$tables_exist || $options->{'force'}) {
            _infos("[%0".$sp."d/%0".$sp."d] creating %s tables... ", $num, $total, $prefix);
            $self->_drop_tables($dbh, $prefix);
            my $statements = $self->_get_create_schema($prefix);
            for my $stm (@{$statements}) {
                $dbh->do($stm);
            }
            $dbh->commit || confess $dbh->errstr;
            $recreated = 1;
            _info("done");
        } else {
            # check structure / update to latest
            my $rc = $self->_check_cache_structure($c, $dbh, $prefix);
            if($rc) {
                # recreate
                return $self->_import_logs($c, $mode, [$prefix], $blocksize, { %{$options}, force => 1 });
            }
        }

        # get start date from existing logs
        my $start;
        my $end;
        if($mode eq 'update' && !$recreated) {
            ($start, $end) = $self->get_logs_start_end_no_filter($peer, $forcestart);
        }

        # lock db
        my $lock_rc = $self->_db_lock_tables($c, $dbh, $prefix, $mode);
        if(!$lock_rc) {
            $errors++;
            next;
        }

        my $t1 = time();
        _infos("[%0".$sp."d/%0".$sp."d] %sing %s logcache... ", $num, $total, $mode, $prefix);

        # clean logfiles older than clean_duration before import
        if($mode eq 'import' && $c->config->{'logcache_clean_duration'}) {
            $self->_update_logcache_clean($c, $dbh, $prefix, $c->config->{'logcache_clean_duration'});
        }

        my($cnt, $reord) = $self->_import_peer_logfiles($c, $dbh, $prefix, $peer, $start, $end, $mode, $files, $options);
        $log_count += $cnt;
        $reordered += $reord;
        my $duration = time() - $t1;
        $self->_finish_update($c, $dbh, $prefix, $duration);
        _info("done. (duration: %s, %s log entries imported)", Thruk::Utils::Filter::duration($duration), $cnt);

        if($mode eq 'import' && $c->config->{'logcache_clean_duration'}) {
            $self->_update_logcache_clean($c, $dbh, $prefix, $c->config->{'logcache_clean_duration'});
        }
    }

    $c->stats->profile(end => $driver."::_import_logs($mode)");
    return($total, $log_count, $errors, $reordered);
}

sub _get_running_thruk_pids {
    my($self, $c) = @_;
    my $active_thruk_pids = {};
    my $pids = Thruk::Utils::IO::cmd("pgrep -f 'thruk_server.pl|thruk_fastcgi|fcgi-pm' 2>/dev/null");
    if($pids) {
        for my $pid (split(/\n/mx, $pids)) {
            $active_thruk_pids->{$pid} = 1;
        }
    }
    return $active_thruk_pids;
}

sub _check_cache_structure {
    my($self, $c, $dbh, $prefix) = @_;
    return 1 unless $self->_tables_exist($dbh, $prefix);

    my $cache_version = 1;
    my $table_status = $self->_quote_table($prefix.'_status');
    my @versions = @{$dbh->selectcol_arrayref('SELECT value FROM '.$table_status.' WHERE status_id = 4 LIMIT 1')};
    if(scalar @versions > 0 and $versions[0]) {
        $cache_version = $versions[0];
    }

    my $cache_ver = $self->cache_version();
    if($cache_version < $cache_ver) {
        # only log message if not importing already
        my $msg = 'logcache version too old: '.$cache_version.', recreating with version '.$cache_ver.'...';
        _warn($msg);
        return 1;
    }
    return 0;
}

sub _update_logcache_optimize {
    my($self, $c, $peer, $prefix, $options) = @_;
    my $dbh = $peer->logcache->_dbh;
    return(-1) unless $self->_tables_exist($dbh, $prefix);

    # update sort order / optimize every day
    my $table_status = $self->_quote_table($prefix.'_status');
    my @times = @{$dbh->selectcol_arrayref('SELECT value FROM '.$table_status.' WHERE status_id = 3 LIMIT 1')};
    if(!$options->{'force'} && scalar @times > 0 && $times[0] && $times[0] > time()-86400) {
        _info("no optimize necessary, last optimize: ".(scalar localtime $times[0]).", use -f to force");
        return(-1);
    }
    my $start = time();

    # start logcache self heal
    $self->_log_check_inconsistency($c, [$prefix], 1);

    my $disk_space_ok = $self->_check_db_fs($c, $peer, $prefix);
    $self->_db_optimize_tables($c, $peer, $prefix, $disk_space_ok);

    my $duration = time() - $start;
    $self->_update_status($dbh, $prefix, 3, 'last_reorder', time());
    $self->_update_status($dbh, $prefix, 5, 'reorder_duration', $duration);
    $dbh->commit || confess $dbh->errstr;
    return(-1);
}

sub _db_lock_tables {
    my($self, $c, $dbh, $prefix, $mode) = @_;

    my $table_status = $self->_quote_table($prefix."_status");
    # check if there is already a update / import running
    my $skip          = 0;
    eval {
        $self->_lock_table_share($dbh, $prefix);
        my @pids = @{$dbh->selectcol_arrayref('SELECT value FROM '.$table_status.' WHERE status_id = 2 LIMIT 1')};
        if(scalar @pids > 0 and $pids[0]) {
            if(kill(0, $pids[0])) {
                _info("WARNING: logcache update already running with pid ".$pids[0]);
                $skip = 1;
            }
        }
    };
    $self->_release_write_locks($dbh) unless $c->config->{'logcache_pxc_strict_mode'};
    if($@) {
        _debug($@);
        return;
    }
    if($skip) {
        return;
    }

    $self->_lock_table_exclusive($dbh, $prefix);
    my $now = time();
    $self->_update_status($dbh, $prefix, 1, 'last_update', $now);
    $self->_update_status($dbh, $prefix, 2, 'update_pid', $$);
    $self->_update_status($dbh, $prefix, 10, 'lock_mode', $mode);
    $dbh->commit || confess $dbh->errstr;
    $self->_release_write_locks($dbh) unless $c->config->{'logcache_pxc_strict_mode'};

    if(($mode eq 'import' || $ENV{'THRUK_CRON'}) && !-f $c->config->{'tmp_path'}."/logcache_import.lock") {
        our $global_lock_created = 1;
        Thruk::Utils::IO::write($c->config->{'tmp_path'}."/logcache_import.lock", $$);
    }

    return 1;
}

sub _import_peer_logfiles {
    my($self,$c,$mode,$peer,$blocksize,$dbh,$host_lookup,$service_lookup,$prefix,$contact_lookup,$forcestart) = @_;

    return(-1) unless $self->_tables_exist($dbh, $prefix);

    if($blocksize > 86400) {
        _warn("logcache blocksize too long, reduced to 1 day");
        $blocksize = 86400;
    }

    # get start / end timestamp
    my($mstart, $mend);
    if($mode eq 'update' && !$forcestart) {
        my $driver = $self->_driver_name();
        $c->stats->profile(begin => "get last ".$driver." timestamp");
        # get last timestamp from DB
        ($mstart, $mend) = @{$peer->logcache->get_logs_start_end(collection => $prefix)};
        _debug("last entry from logcache: ".(scalar localtime $mend)) if $mend;
        $c->stats->profile(end => "get last ".$driver." timestamp");
    }

    my $log_count = 0;
    my($start, $end);
    if($forcestart) {
        $start = $forcestart;
    } elsif($mend) {
        $start = $mend;
    } else {
        if($mode eq 'import') {
            # it does not make sense to import more than we would clean immediately again
            $mend = Thruk::Utils::get_expanded_start_date($c, $c->config->{'logcache_clean_duration'});
        }
        # fetching logs without any filter is a terrible bad idea
        $c->stats->profile(begin => "get livestatus timestamp no filter");
        ($start, $end) = Thruk::Backend::Provider::Base::get_logs_start_end_no_filter($peer->{'class'}, $mend);
        if(defined $mend && $start < $mend) {
            $start = $mend;
        }
        $c->stats->profile(end => "get livestatus timestamp no filter");
    }
    if(!$start) {
        my $driver = $self->_driver_name();
        die("something went wrong, cannot get start from logfiles (".(defined $start ? $start : "undef").")\nIf this is an Icinga2 please have a look at: https://thruk.org/documentation/logfile-cache.html#icinga-2 for a workaround.\n");
    }

    _info("importing from ".(scalar localtime $start));
    _info("until latest entry in logfile: ".(scalar localtime $end)) if $end;
    my $time = $start;
    $end = time() unless $end;

    # add import filter again, even if it should have been filtered in the logs query already, but it seems like not all backends handle them correctly
    my $import_filter = [];
    for my $f (@{Thruk::Base::list($c->config->{'logcache_import_exclude'})}) {
        push @{$import_filter}, { message => { '!~~' => $f } }
    }
    if($mode eq 'import') {
        $self->_disable_index($dbh, $prefix);
    }
    my $compact_start_data = Thruk::Utils::get_expanded_start_date($c, $c->config->{'logcache_compact_duration'});
    my $alertstore = {};
    my $last_day = "";
    my $consecutive_errors = 0;
    my $good               = 0;
    my $err;

    my @columns = qw/class time type state host_name service_description message state_type contact_name/;
    my $reordered = 0;
    while($time <= $end) {
        my $stime = scalar localtime $time;
        $c->stats->profile(begin => $stime);
        my $duplicate_lookup = {};
        _infos(scalar localtime $time);

        my $today = POSIX::strftime("%Y-%m-%d", localtime($time));
        if($last_day ne $today) {
            $alertstore = {};
            $last_day = $today;
        }
        my $block_end = $time + $blocksize - 1;
        # round block end by days to avoid requesting multiple log files
        my $endday = POSIX::strftime("%Y-%m-%d", localtime($block_end));
        if($today ne $endday) {
            $block_end = Thruk::Utils::parse_date_string($endday." 00:00:00") - 1;
        }

        my $import_compacted = 0;
        if(($block_end) < $compact_start_data) {
            $import_compacted = 1;
        }

        my $logs = [];
        my $file = $peer->{'class'}->{'fetch_command'} ? 1 : undef;
        &timing_breakpoint('_get_logs');
        eval {
            # get logs from peer
            ($logs) = $peer->{'class'}->get_logs(nocache => 1,
                                                 filter  => [{ '-and' => [
                                                                    { time => { '>=' => $time } },
                                                                    { time => { '<=' => $block_end } },
                                                            ]}, @{$import_filter} ],
                                                 columns => \@columns,
                                                 file => $file,
                                                );
            &timing_breakpoint('_get_logs done');
            if($mode eq 'update') {
                # get already stored logs to filter duplicates
                $duplicate_lookup = $self->_fill_lookup_logs($prefix,$time,$block_end);
                &timing_breakpoint('_fill_lookup_logs_logs done');
            }
            _infoc(":");
        };
        if($@) {
            $err = $@;
            chomp($err);
            if($mode eq 'import') {
                die($err);
            } else {
                _debug($err);
                my $short;
                ($short, $err) = Thruk::Utils::extract_connection_error($err);
                $err = $short if $short;
                _infoc(" %s", $err);
                $consecutive_errors++;
                if($consecutive_errors >= 3) {
                    die("failed to update 3 times in a row, bailing out: ".$err);
                }
            }
        } else {
            $consecutive_errors = 0;
            $good++;
        }

        $time = $block_end + 1;

        if($file) {
            $file = $logs;
            $log_count += $self->_import_logcache_from_file($mode,$dbh,[$file],$host_lookup,$service_lookup,$prefix,$contact_lookup,$c, $import_compacted, $alertstore);
        } else {
            $log_count += $self->_insert_logs($dbh,$mode,$logs,$host_lookup,$service_lookup,$duplicate_lookup,$prefix,$contact_lookup,$c, undef, $import_compacted, $alertstore);
            $reordered = 1;
        }

        $c->stats->profile(end => $stime);
    }

    # all blocks failed
    if($err && $good == 0) {
        die(_strip_line($err));
    }

    if($mode eq 'import') {
        _infos("creating index...");
        $self->_enable_index($dbh, $prefix);
        if($reordered) {
            $self->_update_status($dbh, $prefix, 3, 'last_reorder', time());
        }
        _info("done");
        &timing_breakpoint('_import_peer_logfiles enable index done');
    }

    return $log_count;
}

sub _fill_lookup_logs {
    my($self,$prefix,$start,$end) = @_;
    my $lookup = {};
    my($mlogs) = $self->get_logs(
                                filter  => [{ '-and' => [
                                                         { time => { '>=' => $start } },
                                                         { time => { '<=' => $end } },
                                            ]}],
                                collection => $prefix,
                              );
    for my $l (@{$mlogs}) {
        next unless defined $l->{'message'};
        $lookup->{$l->{'message'}} = 1;
    }

    return $lookup;
}

sub _import_logcache_from_file {
    my($self,$mode,$dbh,$files,$host_lookup,$service_lookup,$prefix,$contact_lookup, $c, $import_compacted, $alertstore) = @_;
    my $log_count = 0;

    require Monitoring::Availability::Logs;

    # get current auto increment values
    my $auto_increments = $self->_get_autoincrements($dbh, $prefix);
    my $foreign_key_stash = {};

    # add import filter
    my $import_filter = $self->_get_exclude_filter($c->config);

    my $stm = "INSERT INTO " . $self->_quote_table($prefix."_log") . " (time,class,type,state,state_type,contact_id,host_id,service_id,message) VALUES";

    # make import with relative paths work (thruk chdirs into OMD at start)
    if($ENV{'THRUKOLDPWD'}) {
        chdir($ENV{'THRUKOLDPWD'});
    }

    my $failed = 0;
    for my $p (@{$files}) {
        my $expanded = [];
        if(-f $p) {
            $expanded = [$p];
        } elsif(-d $p.'/.') {
            $expanded = [glob($p.'/*')];
        } else {
            $expanded = [glob($p)];
            if(scalar @{$expanded} == 0) {
                $failed++;
                _warn("no files found for: $p");
                next;
            }
        }
        for my $f (@{$expanded}) {
            if(!-f $f) {
                $failed++;
                _warn("skipping $f: $!");
                next;
            }
            _infos($f);
            my $duplicate_lookup  = {};
            my $last_duplicate_ts = 0;
            my @values;

            open(my $fh, '<', $f) or die("cannot open ".$f.": ".$!);
            while(my $line = <$fh>) {
                chomp($line);
                &Thruk::Utils::Encode::decode_any($line);
                &Thruk::Utils::Encode::remove_utf8_surrogates($line);
                my $original_line = $line;
                my $l = &Monitoring::Availability::Logs::parse_line($line); # do not use xs here, unchanged $line breaks the _set_class later
                next unless($l && $l->{'time'});
                next if $import_filter && $original_line =~ $import_filter;

                if($mode eq 'update') {
                    if($last_duplicate_ts < $l->{'time'}) {
                        $self->_safe_insert($dbh, $stm, \@values);
                        $self->_safe_insert_stash($dbh, $prefix, $foreign_key_stash);
                        @values = ();
                        $duplicate_lookup = $self->_fill_lookup_logs($prefix,$l->{'time'},$l->{'time'}+86400);
                        $last_duplicate_ts = $l->{'time'}+86400;
                    }
                    next if defined $duplicate_lookup->{$original_line};
                }

                $log_count++;
                $l->{'message'} = $original_line;
                my($host, $svc, $contact) = $self->_fix_import_log($l, $host_lookup, $service_lookup, $contact_lookup, $dbh, $prefix, $auto_increments, $foreign_key_stash);

                # commit every 1000th to avoid to large blocks
                if($log_count%1000 == 0) {
                    $self->_safe_insert($dbh, $stm, \@values);
                    $self->_safe_insert_stash($dbh, $prefix, $foreign_key_stash);
                    @values = ();
                    _infoc('.');
                }

                if($import_compacted && $self->_is_compactable($l, $alertstore, $import_filter)) {
                    # skip insert
                    next;
                }

                push @values, sprintf('(%s,%s,%s,%s,%s,%s,%s,%s,%s)',
                        $l->{'time'},
                        $l->{'class'},
                        $dbh->quote($l->{'type'}),
                        $dbh->quote($l->{'state'}),
                        $dbh->quote($l->{'state_type'}),
                        $dbh->quote($contact),
                        $dbh->quote($host),
                        $dbh->quote($svc),
                        $dbh->quote($l->{'message'}),
                );
            }
            $self->_safe_insert($dbh, $stm, \@values);
            $self->_safe_insert_stash($dbh, $prefix, $foreign_key_stash);
            CORE::close($fh);
            _info(". OK");
        }
    }

    unless ($c->config->{'logcache_pxc_strict_mode'}) {
        $self->_release_write_locks($dbh);
        _info("it is recommended to run logcacheoptimize after importing logfiles.");
    }

    # restore old working dir
    if($ENV{'THRUKOLDPWD'}) {
        chdir($ENV{'HOME'});
    }

    if($failed == scalar @{$files}) {
        die("no file imported");
    }

    return $log_count;
}

sub _insert_logs {
    my($self,$dbh,$mode,$logs,$host_lookup,$service_lookup,$duplicate_lookup,$prefix,$contact_lookup,$c,$use_extended_inserts, $import_compacted, $alertstore) = @_;
    my $log_count = 0;
    my $compacted = 0;

    my $dots_each = 1000;
    if($mode eq 'update') {
        $mode = MODE_UPDATE;
    } elsif($mode eq 'import') {
        $mode = MODE_IMPORT;
        $dots_each = 10000;
    }

    if(!defined $use_extended_inserts) {
        $use_extended_inserts = $self->_use_load_data_infile($mode) ? 0 : 1;
    }

    # check pid / lock
    my $table_status = $self->_quote_table($prefix.'_status');
    my @pids = @{$dbh->selectcol_arrayref('SELECT value FROM '.$table_status.' WHERE status_id = 2 LIMIT 1')};
    if(scalar @pids == 1 && $pids[0] && $pids[0] != $$) {
        _warn("logcache update already running with pid ".$pids[0]);
        return $log_count;
    }

    # get current auto increment values
    my $auto_increments = $self->_get_autoincrements($dbh, $prefix);
    my $foreign_key_stash = {};

    # add import filter
    my $import_filter = $self->_get_exclude_filter($c->config);

    my $stm = "INSERT INTO " . $self->_quote_table($prefix."_log") . " (time,class,type,state,state_type,contact_id,host_id,service_id,message) VALUES";

    my @values;
    my($fh, $datafilename);
    if(!$use_extended_inserts) {
        load File::Temp, qw/tempfile/;
        ($fh, $datafilename) = tempfile();
        $fh->binmode (":encoding(utf-8)");
    }
    &timing_breakpoint('_insert_logs');
    for my $l (@{$logs}) {
        next unless $l->{'message'};
        &Thruk::Utils::Encode::remove_utf8_surrogates($l->{'message'});
        if($mode == MODE_UPDATE) {
            next if defined $duplicate_lookup->{$l->{'message'}};
        }

        next if $import_filter && $l->{'message'} =~ $import_filter;

        $log_count++;
        _infoc('.') if $log_count % $dots_each == 0;

        my($host, $svc, $contact) = $self->_fix_import_log($l, $host_lookup, $service_lookup, $contact_lookup, $dbh, $prefix, $auto_increments, $foreign_key_stash);

        if($import_compacted && $self->_is_compactable($l, $alertstore, $import_filter)) {
            # skip insert
            $compacted++;
            next;
        }

        if($use_extended_inserts) {
            push @values, sprintf('(%s,%s,%s,%s,%s,%s,%s,%s,%s)',
                    $l->{'time'},
                    $l->{'class'},
                    $dbh->quote($l->{'type'}),
                    $dbh->quote($l->{'state'}),
                    $dbh->quote($l->{'state_type'}),
                    $dbh->quote($contact),
                    $dbh->quote($host),
                    $dbh->quote($svc),
                    $dbh->quote($l->{'message'}),
            );
        } else {
            printf($fh "%s\0%s\0%s\0%s\0%s\0%s\0%s\0%s\0%s\n",
                    $l->{'time'},
                    $l->{'class'},
                    $l->{'type'}       // '\N',
                    $l->{'state'}      // '\N',
                    $l->{'state_type'} // '\N',
                    $contact           // '\N',
                    $host              // '\N',
                    $svc               // '\N',
                    $l->{'message'},
            );
        }

        # commit every 1000th to avoid to large blocks
        if($use_extended_inserts && $log_count%1000 == 0) {
            &timing_breakpoint('_insert_logs logs calculated');
            $self->_safe_insert($dbh, $stm, \@values);
            @values = ();
            &timing_breakpoint('_insert_logs logs inserted');
            $self->_safe_insert_stash($dbh, $prefix, $foreign_key_stash);
        }
    }
    if($use_extended_inserts) {
        $self->_safe_insert($dbh, $stm, \@values);
    } else {
        &timing_breakpoint('_insert_logs load data local');
        CORE::close($fh);
        my $load_stm = sprintf("LOAD DATA LOCAL INFILE '%s' INTO TABLE " . $self->_quote_table($prefix."_log") . " FIELDS TERMINATED BY '\0' ENCLOSED BY '' (time,class,type,state,state_type,contact_id,host_id,service_id,message)", $datafilename);
        eval {
            $dbh->do($load_stm);
        };
        my $err = $@;
        unlink($datafilename);
        if($err) {
            _error("ERROR DETAIL: ".$err);
            _error("ERROR SQL: ".$load_stm);
            # retry with extended inserts
            return($self->_insert_logs($dbh,$mode,$logs,$host_lookup,$service_lookup,$duplicate_lookup,$prefix,$contact_lookup,$c,1, $import_compacted, $alertstore));
        }
        $dbh->commit || confess $dbh->errstr;
        &timing_breakpoint('_insert_logs load data local done');
    }

    $self->_safe_insert_stash($dbh, $prefix, $foreign_key_stash);
    # release locks, unless in import mode. Import releases lock later
    if($mode != MODE_IMPORT) {
        $self->_release_write_locks($dbh) unless $c->config->{'logcache_pxc_strict_mode'};
    }

    if($compacted > 0) {
        _info('. '.($log_count-$compacted) . " entries added and ".$compacted." compacted rows skipped");
    } else {
        _info('. '.$log_count . " entries added");
    }
    return $log_count;
}

sub _drop_tables {
    my($self, $dbh, $prefix) = @_;
    my $cascade = $self->_sql_drop_table_cascade();
    for my $table (@{$self->tables()}) {
        $dbh->do("DROP TABLE IF EXISTS " . $self->_quote_table($prefix."_".$table) . $cascade);
    }
    $dbh->do("DROP TABLE IF EXISTS " . $self->_quote_table($prefix."_plugin_output") . $cascade);
    $dbh->commit || confess $dbh->errstr;
    return;
}

sub _safe_insert {
    my($self, $dbh, $stm, $values) = @_;
    return if scalar @{$values} == 0;
    my $suffix = $self->_sql_insert_on_conflict();
    eval {
        $dbh->do($stm.join(',', @{$values}).$suffix);
    };
    if($@) {
        _error("ERROR INSERT: ".$@);
        eval { $dbh->rollback; };

        # insert failed for some reason, try them one by one to see which one breaks
        for my $v (@{$values}) {
            eval {
                $dbh->do($stm.$v.$suffix);
                $dbh->commit;
            };
            if ($@) {
                _error("ERROR DETAIL: ".$@);
                _error("ERROR SQL: ".$stm.$v);
                eval { $dbh->rollback; };
            }
        }
    } else {
        $dbh->commit || confess $dbh->errstr;
    }
    return;
}

sub _safe_insert_stash {
    my($self, $dbh, $prefix, $foreign_key_stash) = @_;

    if($foreign_key_stash->{'host'}) {
        $self->_safe_insert($dbh, "INSERT INTO " . $self->_quote_table($prefix."_host") . " (host_id, host_name) VALUES", \@{$foreign_key_stash->{'host'}});
        delete $foreign_key_stash->{'host'};
    }

    if($foreign_key_stash->{'service'}) {
        $self->_safe_insert($dbh, "INSERT INTO " . $self->_quote_table($prefix."_service") . " (service_id, host_id, service_description) VALUES", \@{$foreign_key_stash->{'service'}});
        delete $foreign_key_stash->{'service'};
    }

    if($foreign_key_stash->{'contact'}) {
        $self->_safe_insert($dbh, "INSERT INTO " . $self->_quote_table($prefix."_contact") . " (contact_id, name) VALUES", \@{$foreign_key_stash->{'contact'}});
        delete $foreign_key_stash->{'contact'};
    }

    return;
}

sub _update_logcache_clean {
    my($self, $c, $dbh, $prefix, $blocksize) = @_;

    if($blocksize =~ m/^\d+[a-z]{1}/mx) {
        # blocksize is in days
        $blocksize = int(Thruk::Utils::expand_duration($blocksize) / 86400);
    }

    $self->_check_index($c, $dbh, $prefix);

    my $start = time() - ($blocksize * 86400);
    _debug2("cleaning logs older than: ", scalar localtime $start);
    my $plugin_ref_count = 0;
    my $log_count = $dbh->do("DELETE FROM " . $self->_quote_table($prefix."_log") . " WHERE time < ?", undef, $start);
    return([$log_count, $plugin_ref_count]) if $log_count == 0;

    $dbh->commit || confess $dbh->errstr;
    return([$log_count, $plugin_ref_count]);
}

sub _update_logcache_compact {
    my($self, $c, $dbh, $prefix, $blocksize, $force) = @_;
    my $log_count = 0;
    my $log_clear = 0;

    # since we usually backtrack 4 days in reports, use 3days plus 2 extra hours to compensate timeshifts to compact state changes
    my $offset = 74*3600;

    if($blocksize =~ m/^\d+[a-z]{1}/mx) {
        # blocksize is in days
        $blocksize = int(Thruk::Utils::expand_duration($blocksize) / 86400);
    }
    my $t1     = time();
    my $end  = Thruk::Utils::DateTime::start_of_day(time() - ($blocksize * 86400));
    _debug("compacting logs older than: ".(scalar localtime $end));
    my $table_status = $self->_quote_table($prefix.'_status');
    my $status = $dbh->selectall_hashref("SELECT name, value FROM ".$table_status, 'name');
    my $start  = $status->{'compact_till'}->{'value'};
    if(!$start || $force) {
        my($mstart) = @{$self->_get_logs_start_end()};
        $start = $mstart;
    }
    if(!$start) {
        return([$log_count, $log_clear]);
    }

    $self->_check_index($c, $dbh, $prefix);

    my $import_filter = $self->_get_exclude_filter($c->config);
    my $current = Thruk::Utils::DateTime::start_of_day($start - $offset);
    while(1) {
        if($current >= $end) {
            last;
        }

        _infos("compacting ".(scalar localtime $current));
        my $next = Thruk::Utils::DateTime::start_of_day($current + $offset);

        my $sth = $dbh->prepare("SELECT log_id, class, type, state, state_type, host_id, service_id, message FROM " . $self->_quote_table($prefix."_log") . " WHERE time >= ? and time < ?");
        $sth->execute($current, $next);
        _infoc(': ');
        my $processed = 0;
        my $removed = 0;
        my @delete;
        my $alerts = {};
        while(my $l = $sth->fetchrow_hashref()) {
            $processed++;
            _infoc('.') if $processed%10000 == 0;
            if($removed%10000 == 0 && scalar @delete > 0) {
                $dbh->do("DELETE FROM " . $self->_quote_table($prefix."_log") . " WHERE log_id IN (".join(",", @delete).")");
                $dbh->commit || confess $dbh->errstr;
                $log_clear += scalar @delete;
                @delete = ();
            }
            if($self->_is_compactable($l, $alerts, $import_filter)) {
                $removed++;
                push @delete, $l->{'log_id'};
            }
        }

        _info(sprintf("%d of %d removed (%.1f%%). done", $removed, $processed, $removed > 0 ? (($removed / $processed) * 100) : 0));
        $current  = $next;
        $log_count += $processed;
        $log_clear += $removed;

        if(scalar @delete > 0) {
            $dbh->do("DELETE FROM " . $self->_quote_table($prefix."_log") . " WHERE log_id IN (".join(",", @delete).")");
            $dbh->commit || confess $dbh->errstr;
        }

        $self->_update_status($dbh, $prefix, 9, 'compact_till', $end, $next);
        $dbh->commit || confess $dbh->errstr;
    }

    my $duration = time() - $t1;
    my $now = time();
    $self->_update_status($dbh, $prefix, 7, 'last_compact', $now);
    $self->_update_status($dbh, $prefix, 8, 'compact_duration', $duration);
    $self->_update_status($dbh, $prefix, 9, 'compact_till', $end);

    $dbh->commit || confess $dbh->errstr;
    return([$log_count, $log_clear]);
}

sub _is_compactable {
    my($self, $l, $alertstore, $excludepattern) = @_;
    return 1 if($excludepattern && $l->{'message'} =~ $excludepattern);

    if($l->{'class'} == 2 || $l->{'class'} == 3 || $l->{'class'} == 5 || $l->{'class'} == 6) {
        # keep program, notifications, external commands, timeperiod transitions
        return;
    }
    elsif($l->{'class'} == 1) {
        if($l->{'type'} eq 'HOST DOWNTIME ALERT' || $l->{'type'} eq 'SERVICE DOWNTIME ALERT') {
            # keep downtimes
            return;
        }
        # remove duplicate alerts
        my $uniq = sprintf("%s;%s", $l->{'state_type'}//'', $l->{'state'}//'');
        if($l->{'type'} eq 'SERVICE ALERT' || $l->{'type'} eq 'CURRENT SERVICE STATE' || $l->{'type'} eq 'INITIAL SERVICE STATE') {
            my $host_id    = $l->{'host_id'} // $l->{'host_name'} // '';
            my $service_id = $l->{'service_id'} // $l->{'service_description'} // '';
            my $chk = $alertstore->{'svc'}->{$host_id}->{$service_id};
            if(!$chk || $chk ne $uniq) {
                $alertstore->{'svc'}->{$host_id}->{$service_id} = $uniq;
                return;
            }
        }
        elsif($l->{'type'} eq 'HOST ALERT' || $l->{'type'} eq 'CURRENT HOST STATE' || $l->{'type'} eq 'INITIAL HOST STATE') {
            my $host_id = $l->{'host_id'} // $l->{'host_name'};
            my $chk     = $alertstore->{'hst'}->{$host_id};
            if(!$chk || $chk ne $uniq) {
                $alertstore->{'hst'}->{$host_id} = $uniq;
                return;
            }
        }
    }
    return 1;
}

sub _fix_import_log {
    my($self, $l, $host_lookup, $service_lookup, $contact_lookup, $dbh, $prefix, $auto_increments, $foreign_key_stash) = @_;
    my($host, $svc, $contact);

    if(exists $l->{'hard'}) {
        if($l->{'hard'}) {
            $l->{'state_type'} = 'HARD';
        } else {
            $l->{'state_type'} = 'SOFT';
        }
    }
    if(!$l->{'state_type'} || ($l->{'state_type'} ne 'HARD' && $l->{'state_type'} ne 'SOFT')) {
        $l->{'state_type'} = undef;
    }

    $l->{'state'} = undef unless(defined $l->{'state'} && $l->{'state'} ne '');
    $self->_set_class($l);
    $self->_set_type($l);

    if($l->{'class'} == 5) { $self->_set_external_command($l); }

    if($l->{'service_description'}) {
        $host = $host_lookup->{$l->{'host_name'}} || $self->_host_lookup($host_lookup, $l->{'host_name'}, $dbh, $prefix, $auto_increments, $foreign_key_stash);
        $svc  = $service_lookup->{$l->{'host_name'}}->{$l->{'service_description'}} || $self->_service_lookup($service_lookup, $host_lookup, $l->{'host_name'}, $l->{'service_description'}, $dbh, $prefix, $host, $auto_increments, $foreign_key_stash);
    }
    elsif($l->{'host_name'}) {
        $host = $host_lookup->{$l->{'host_name'}} || $self->_host_lookup($host_lookup, $l->{'host_name'}, $dbh, $prefix, $auto_increments, $foreign_key_stash);
    }
    if($l->{'contact_name'}) {
        $contact = $contact_lookup->{$l->{'contact_name'}} || $self->_contact_lookup($contact_lookup, $l->{'contact_name'}, $dbh, $prefix, $auto_increments, $foreign_key_stash);
    }
    return($host, $svc, $contact);
}

sub _set_class {
    my($self, $l) = @_;
    return if $l->{'class'};
    my $type = $l->{'type'};
    my $db_types = $self->db_types();
    $l->{'class'} = $db_types->{$type} if defined $type;
    return if $l->{'class'};

    if(!defined $l->{'message'}) {
        $l->{'class'}   = 0; # LOGCLASS_INFO
        $l->{'message'} = $type;
        $l->{'type'}    = '';
        return;
    }

    if(   $l->{'message'} =~ m/starting\.\.\./mxo
       or $l->{'message'} =~ m/shutting\ down\.\.\./mxo
       or $l->{'message'} =~ m/Bailing\ out/mxo
       or $l->{'message'} =~ m/active\ mode\.\.\./mxo
       or $l->{'message'} =~ m/standby\ mode\.\.\./mxo
    ) {
        $l->{'class'} = 2; # LOGCLASS_PROGRAM
        $l->{'message'} = $l->{'type'}.': '.$l->{'message'} if($l->{'type'} && $l->{'message'} !~ m/^\[\d+\]/mx);
        $l->{'type'}    = '';
        return;
    }

    $l->{'type'}    = '';
    $l->{'class'}   = 0; # LOGCLASS_INFO
    return;
}

sub _set_type {
    my($self, $l) = @_;

    if($l->{'message'} =~ m/^\[\d+\]\s+TIMEPERIOD\ TRANSITION/mxo) {
        $l->{'type'}  = 'TIMEPERIOD TRANSITION';
        $l->{'class'} = 6; # LOGCLASS_STATE
        return;
    }

    if(defined $l->{'type'}) {
        my $db_types = $self->db_types();
        if(!defined $db_types->{$l->{'type'}}) {
            # Set type to NULL to prevent SQL insert errors if type is not a special type.
            undef $l->{'type'};
        }
        return;
    }

    return;
}

sub _set_external_command {
    my($self, $l) = @_;
    # add hosts/services to external commands
    my $msg = $l->{'message'};
    $msg =~ s/^\[\d+\]\ EXTERNAL\ COMMAND:\ //gmxo;
    $msg =~ s/^(.*?);//gmxo;
    my $cmd;
    if($1) {
        $cmd = $1;
    }
    return unless $cmd;
    if($cmd =~ m/_HOST(_|$)/mx) {
        if($msg =~ m/^([^;]+);(;|$)/gmx) {
            $l->{'host_name'} = $1;
        }
    }
    elsif($cmd =~ m/_SVC(_|$)/mx) {
        if($msg =~ m/^([^;]+);([^;]+)(;|$)/gmx) {
            $l->{'host_name'} = $1;
            $l->{'service_description'} = $2;
        }
    }
    elsif($cmd =~ m/_CONTACT(_|$)/mx) {
        if($msg =~ m/^([^;]+);(;|$)/gmx) {
            $l->{'contact_name'} = $1;
        }
    }
    return;
}

sub _get_host_lookup {
    my($self, $dbh, $peer, $prefix, $noupdate) = @_;

    my $table = $self->_quote_table($prefix."_host");
    my $sth = $dbh->prepare("SELECT host_id, host_name FROM ".$table);
    $sth->execute;
    my $hosts_lookup = {};
    while(my $r = $sth->fetchrow_arrayref()) { $hosts_lookup->{$r->[1]} = $r->[0]; }
    return $hosts_lookup if $noupdate;

    my($hosts) = $peer->{'class'}->get_hosts(columns => [qw/name/]);
    my $stm = "INSERT INTO " . $table . " (host_name) VALUES";
    my @values;
    for my $h (@{$hosts}) {
        next if defined $hosts_lookup->{$h->{'name'}};
        push @values, "(".$dbh->quote($h->{'name'}).")";
    }
    # insert hosts in blocks of 1000
    while(my @chunk = splice(@values, 0, 1000)) {
        $dbh->do($stm.join(',', @chunk));
    }
    $dbh->commit || confess $dbh->errstr;
    return $self->_get_host_lookup($dbh, $peer, $prefix, 1);
}

sub _get_service_lookup {
    my($self, $dbh, $peer, $prefix, $hosts_lookup, $noupdate, $auto_increments, $foreign_key_stash) = @_;

    my $table_service = $self->_quote_table($prefix."_service");
    my $table_host    = $self->_quote_table($prefix."_host");
    my $sth = $dbh->prepare("SELECT s.service_id, h.host_name, s.service_description FROM ".$table_service." s, ".$table_host." h WHERE s.host_id = h.host_id");
    $sth->execute;
    my $services_lookup = {};
    while(my $r = $sth->fetchrow_arrayref()) { $services_lookup->{$r->[1]}->{$r->[2]} = $r->[0]; }
    return $services_lookup if $noupdate;

    my($services) = $peer->{'class'}->get_services(columns => [qw/host_name description/]);
    my $stm = "INSERT INTO " . $table_service . " (host_id, service_description) VALUES";
    my @values;
    for my $s (@{$services}) {
        next if defined $services_lookup->{$s->{'host_name'}}->{$s->{'description'}};
        my $host_id = $self->_host_lookup($hosts_lookup, $s->{'host_name'}, $dbh, $prefix, $auto_increments, $foreign_key_stash);
        push @values, "(".$host_id.", ".$dbh->quote($s->{'description'}).")";
    }
    # insert services in blocks of 1000
    while(my @chunk = splice(@values, 0, 1000)) {
        $dbh->do($stm.join(',', @chunk));
    }
    $dbh->commit || confess $dbh->errstr;
    return $self->_get_service_lookup($dbh, $peer, $prefix, $hosts_lookup, 1);
}

sub _get_contact_lookup {
    my($self, $dbh, $peer, $prefix, $noupdate) = @_;

    my $table = $self->_quote_table($prefix."_contact");
    my $sth = $dbh->prepare("SELECT contact_id, name FROM ".$table);
    $sth->execute;
    my $contact_lookup = {};
    while(my $r = $sth->fetchrow_arrayref()) { $contact_lookup->{$r->[1]} = $r->[0]; }
    return $contact_lookup if $noupdate;

    my($contacts) = $peer->{'class'}->get_contacts(columns => [qw/name/]);
    my $stm = "INSERT INTO " . $table . " (name) VALUES";
    my @values;
    for my $c (@{$contacts}) {
        next if defined $contact_lookup->{$c->{'name'}};
        push @values, "(".$dbh->quote($c->{'name'}).")";
    }
    # insert contacts in blocks of 1000
    while(my @chunk = splice(@values, 0, 1000)) {
        $dbh->do($stm.join(',', @chunk));
    }
    $dbh->commit || confess $dbh->errstr;
    return $self->_get_contact_lookup($dbh, $peer, $prefix, 1);
}

sub _host_lookup {
    my($self, $host_lookup, $host_name, $dbh, $prefix, $auto_increments, $foreign_key_stash) = @_;
    return unless $host_name;

    my $id = $host_lookup->{$host_name};
    return $id if $id;

    if($auto_increments) {
        $id = $auto_increments->{$prefix.'_host'}->{'AUTO_INCREMENT'}++;
        push @{$foreign_key_stash->{'host'}}, '('.$id.', '.$dbh->quote($host_name).')';
        $host_lookup->{$host_name} = $id;
        return $id;
    }

    $dbh->do("INSERT INTO " . $self->_quote_table($prefix."_host") . " (host_name) VALUES(?)", undef, $host_name);
    $id = $dbh->last_insert_id(undef, undef, undef, undef);
    $host_lookup->{$host_name} = $id;

    return $id;
}

sub _service_lookup {
    my($self, $service_lookup, $host_lookup, $host_name, $service_description, $dbh, $prefix, $host_id, $auto_increments, $foreign_key_stash) = @_;
    return unless $service_description;

    my $id = $service_lookup->{$host_name}->{$service_description};
    return $id if $id;

    $host_id = $self->_host_lookup($host_lookup, $host_name, $dbh, $prefix, $auto_increments, $foreign_key_stash) unless $host_id;

    if($auto_increments) {
        $id = $auto_increments->{$prefix.'_service'}->{'AUTO_INCREMENT'}++;
        push @{$foreign_key_stash->{'service'}}, '('.$id.', '.$host_id.', '.$dbh->quote($service_description).')';
        $service_lookup->{$host_name}->{$service_description} = $id;
        return $id;
    }

    $dbh->do("INSERT INTO " . $self->_quote_table($prefix."_service") . " (host_id, service_description) VALUES(?, ?)", undef, $host_id, $service_description);
    $id = $dbh->last_insert_id(undef, undef, undef, undef);
    $service_lookup->{$host_name}->{$service_description} = $id;

    return $id;
}

sub _contact_lookup {
    my($self, $contact_lookup, $contact_name, $dbh, $prefix, $auto_increments, $foreign_key_stash) = @_;
    return unless $contact_name;

    my $id = $contact_lookup->{$contact_name};
    return $id if $id;

    if($auto_increments) {
        $id = $auto_increments->{$prefix.'_contact'}->{'AUTO_INCREMENT'}++;
        push @{$foreign_key_stash->{'contact'}}, '('.$id.', '.$dbh->quote($contact_name).')';
        $contact_lookup->{$contact_name} = $id;
        return $id;
    }

    $dbh->do("INSERT INTO " . $self->_quote_table($prefix."_contact") . " (name) VALUES(?)", undef, $contact_name);
    $id = $dbh->last_insert_id(undef, undef, undef, undef);
    $contact_lookup->{$contact_name} = $id;

    return $id;
}

1;
