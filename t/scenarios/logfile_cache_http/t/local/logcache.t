use warnings;
use strict;
use File::Temp ();
use Test::More;

use Thruk::Config;
use Thruk::Utils::Encode ();

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

###########################################################
# test thruks script path
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
$ENV{'THRUK_TEST_AUTH_KEY'}  = "testkey";
$ENV{'THRUK_TEST_AUTH_USER'} = "omdadmin";

###########################################################
# schedule at least one check
TestUtils::test_command({
    cmd     => '/thruk/support/reschedule_all_checks.sh',
    like    => ['/successfully submitted/'],
});
# then disable checks to avoid log changes that break tests
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d '' /system/cmd/stop_executing_host_checks",
    like    => ['/Command successfully submitted/'],
});
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d '' /system/cmd/stop_executing_svc_checks",
    like    => ['/Command successfully submitted/'],
});

###########################################################
# create host alert
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d 'plugin_state=1' -d 'plugin_output=test' /hosts/localhost/cmd/process_host_check_result",
    like    => ['/Command successfully submitted/'],
});

###########################################################
# test thruk logcache example
{
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk logcache import -q -y",
        like    => [qr(\QOK - imported\E)],
    });
    TestUtils::test_command({
        cmd     => "/thruk/examples/get_logs var/log/naemon.log",
        like    => ['/^$/'],
    });
    TestUtils::test_command({
        cmd     => "/thruk/examples/get_logs var/log/naemon.log -n",
        like    => ['/^$/'],
    });
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk r '/logs'",
        like    => ['/class/', '/starting/'],
    });
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk r '/logs?limit=1&plugin_output[ne]='",
    });
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk r '/logs?limit=1&contact_name[ne]='",
    });
};

###########################################################
# test thruk logcache commands
{
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk logcache update -q",
        like    => ['/OK\ \-\ imported\ \d+\ log\ items\ from\ 1\ site/'],
    });

    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk logcache stats",
        like    => ['/demo/', '/OK/', qr(\QLast Update\E)],
    });

    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk logcache optimize -f -q",
        like    => [qr(\QOK - optimized logcache for 1 site in\E)],
    });
}

###########################################################
# some more /logs rest calls
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r \'/logs?limit=1&q=***host_name = "localhost"***\'',
        like => ['/command_name/', '/plugin_output/'],
    });
};

{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r \'/logs?limit=1&q=***host_name = "localhost" AND time > -24h***\'',
        like => ['/command_name/', '/plugin_output/'],
    });
};

{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r \'/logs?limit=1&q=***host_name != "" AND time > -24h***\'',
        like => ['/command_name/', '/plugin_output/'],
    });
};

###########################################################
# common database goals: the shared DBcommon engine,
# exercised on whichever driver this scenario is configured with
{
    my $c = TestUtils::get_c();
    my($peer) = grep { $_->{'logcache'} } @{ $c->db->get_peers(1) };
    ok($peer, 'found a logcache backend') or BAIL_OUT('no logcache backend, cannot test DBcommon');
    my $prefix   = $peer->{'key'};
    my $provider = $peer->logcache;
    my $dbh      = $provider->_dbh;
    my $qt       = sub { return $provider->_quote_table($_[0]); };
    my $logtable = $prefix.'_log';
    my $status   = $prefix.'_status';
    my $stale    = 'staleunittest';

    # removeunused protects the configured backends
    $c->stash->{'backends'} = [$prefix] unless defined $c->stash->{'backends'};

    ###########################################################
    # provider level import from a logfile fixture
    {
        my $fixture = '/thruk/t/data/mysql/archive.log';
        local $ENV{THRUK_QUIET} = 1;
        $provider->_drop_tables($dbh, $prefix);
        $provider->_create_tables($dbh, $prefix);
        is($provider->_update_logcache($c, 'update', $peer, $dbh, $prefix, undef, [$fixture]), 10, 'imported all fixture items');
        is($provider->_update_logcache($c, 'update', $peer, $dbh, $prefix, undef, [$fixture]),  0, 'fixture items are not imported twice');

        my($export) = $provider->get_logs(file => 1, collection => $prefix, sort => { 'ASC' => 'time' });
        is(-f $export, 1, 'logcache export file created');
        my $content = Thruk::Utils::IO::read($fixture);
        Thruk::Utils::Encode::decode_any($content);
        Thruk::Utils::Encode::remove_utf8_surrogates($content);
        utf8::encode($content);
        my($fh, $expected) = File::Temp::tempfile();
        CORE::close($fh);
        Thruk::Utils::IO::write($expected, $content);
        TestUtils::test_command({
            cmd   => '/usr/bin/diff -u '.$export.' '.$expected,
            like => ['/^$/'],
        });
        unlink($export);
        unlink($expected);
        # close the read transaction, the CLI commands below drop tables
        $dbh->commit;
    }

    ###########################################################
    # drop and re-import recreates the cache from scratch
    $dbh->commit;
    TestUtils::test_command({
        cmd  => "/usr/bin/env thruk logcache drop -y -q",
        like => [qr/\QOK - droped logcache for 1 site\E/],
    });
    is($provider->_has_log_table($dbh, $prefix), 0, 'logcache tables dropped');
    TestUtils::test_command({
        cmd  => "/usr/bin/env thruk logcache import -q -y",
        like => [qr/\QOK - imported\E/],
    });
    is($provider->_has_log_table($dbh, $prefix), 1, 'logcache tables recreated');
    $dbh->commit;
    TestUtils::test_command({
        cmd  => "/usr/bin/env thruk logcache optimize -f -q",
        like => [qr/\QOK - optimized logcache for 1 site in\E/],
    });
    $dbh->commit;

    ###########################################################
    TestUtils::test_command({
        cmd => "/usr/bin/env thruk logcache removeunused",
    });

    # removeunused: nothing to remove
    TestUtils::test_command({
        cmd  => "/usr/bin/env thruk logcache removeunused",
        like => [qr/\Qno old tables found in logcache\E/],
    });

    ###########################################################
    # removeunused: stale tables are detected, dropped and the active backend is kept.
    my $rows_before = $dbh->selectrow_array('SELECT count(*) FROM '.$qt->($logtable));
    $dbh->do('CREATE TABLE '.$qt->($stale.'_log').' (log_id integer, message text)');
    $dbh->do('CREATE TABLE '.$qt->($stale.'_status').' (status_id integer, name text, value text)');
    $dbh->commit;

    # selfcheck uses the print only variant of the same function
    my $to_remove = $provider->_log_removeunused($c, 1);
    ok(ref $to_remove eq 'HASH' && $to_remove->{$stale}, 'selfcheck lists the stale tables');
    ok(ref $to_remove eq 'HASH' && !$to_remove->{$prefix}, 'selfcheck keeps the active backend');

    # that call reconnects and its selects hold read locks, refresh and release them
    $dbh = $provider->_dbh;
    $dbh->commit;

    TestUtils::test_command({
        cmd  => "/usr/bin/env thruk logcache removeunused",
        like => [qr/\Q1 old backends removed (2 tables) from logcache\E/],
    });
    is($provider->_has_log_table($dbh, $stale),  0, 'stale logcache tables removed');
    is($provider->_has_log_table($dbh, $prefix), 1, 'active logcache tables kept');
    is($dbh->selectrow_array('SELECT count(*) FROM '.$qt->($logtable)), $rows_before, 'active logcache rows untouched');

    ###########################################################
    # clean removes entries older than the given duration
    my $old = time() - 10*86400;
    $dbh->do('INSERT INTO '.$qt->($logtable).' (time,class,type,state,state_type,contact_id,host_id,service_id,message)'
             .' VALUES (?,0,NULL,NULL,NULL,NULL,NULL,NULL,?)', undef, $old, 'dbcommon unittest old entry');
    $dbh->commit;
    TestUtils::test_command({
        cmd  => "/usr/bin/env thruk logcache clean 1 -q",
        like => [qr/\QOK - removed \E[1-9]\d*\Q log items from 1 site\E/],
    });
    is($dbh->selectrow_array('SELECT count(*) FROM '.$qt->($logtable).' WHERE message = ?', undef, 'dbcommon unittest old entry'), 0, 'old entry has been cleaned');

    ###########################################################
    # compact collapses repeated identical alerts
    my $very_old = time() - 100*86400;
    my($host_id) = $dbh->selectrow_array('SELECT host_id FROM '.$qt->($prefix.'_host').' LIMIT 1');
    isnt($host_id, undef, 'got a host for the compaction fixture');
    my $ins = 'INSERT INTO '.$qt->($logtable).' (time,class,type,state,state_type,contact_id,host_id,service_id,message)'
            .' VALUES (?,1,?,?,?,NULL,?,NULL,?)';
    for my $i (1..3) {
        $dbh->do($ins, undef, $very_old, 'HOST ALERT', 2, 'HARD', $host_id, 'dbcommon unittest duplicate alert');
    }
    $dbh->commit;
    TestUtils::test_command({
        cmd  => "/usr/bin/env thruk logcache compact 10w -f -q",
        like => [qr/\QOK - compacted \E\d+\Q log items and removed \E[1-9]\d*/],
    });
    cmp_ok($dbh->selectrow_array('SELECT count(*) FROM '.$qt->($logtable).' WHERE message = ?', undef, 'dbcommon unittest duplicate alert'), '<', 3, 'duplicate alerts compacted');

    ###########################################################
    # cache version guard
    {
        # keep the in process context out of it, we only want the version check
        local $Thruk::Globals::c;
        $dbh->do('UPDATE '.$qt->($status)." SET value = '1' WHERE status_id = 4");
        $dbh->commit;
        my $err = eval { $provider->get_logs(collection => $prefix); 1 } ? undef : $@;
        like($err, qr/Logcache too old/, 'stale cache version is detected');

        $dbh->do('UPDATE '.$qt->($status)." SET value = '".$provider->cache_version()."' WHERE status_id = 4");
        $dbh->commit;
        eval { $provider->get_logs(collection => $prefix, options => { limit => 1 }); };
        is($@, '', 'get_logs works again after restoring the cache version');
        $dbh->commit;
    }
    ###########################################################
    # DBcommon update locking and self heal
    {
        my $host = $prefix.'_host';

        my $status_rows = sub {
            my $rows = $dbh->selectall_hashref('SELECT name, value FROM '.$qt->($status), 'name');
            return { map { $_ => $rows->{$_}->{'value'} } keys %{$rows} };
        };
        my $set_status = sub {
            my($name, $value) = @_;
            $dbh->do('UPDATE '.$qt->($status).' SET value = ? WHERE name = ?', undef, $value, $name);
            return;
        };

        ###########################################################
        # a completed update clears all lock columns
        TestUtils::test_command({
            cmd  => "/usr/bin/env thruk logcache update -q -y",
            like => [qr/\QOK - \E/],
        });
        $dbh->commit;
        {
            my $rows = $status_rows->();
            is($rows->{'lock_mode'}, '', 'update: lock_mode cleared');
            is($rows->{'update_hostname'}, '', 'update: update_hostname cleared');
            ok(!defined $rows->{'update_pid'} || $rows->{'update_pid'} eq '', 'update: update_pid cleared');
            ok($rows->{'last_update'} > 0, 'update: last_update set');
        }

        ###########################################################
        # a stale lock is reported and taken over by the next update
        $set_status->('lock_mode', 'update');
        $set_status->('update_pid', 999999);
        $set_status->('update_hostname', 'othernode');
        $set_status->('last_update', time() - 86400);
        $dbh->commit;
        TestUtils::test_command({
            cmd  => "/usr/bin/env thruk logcache stats",
            like => [qr/stale update since/],
        });
        TestUtils::test_command({
            cmd  => "/usr/bin/env thruk logcache update -q -y",
            like => [qr/\QOK - \E/],
        });
        $dbh->commit;
        is($status_rows->()->{'lock_mode'}, '', 'stale lock: taken over and cleared');

        ###########################################################
        # a fresh lock held by a running pid stops the update
        $set_status->('lock_mode', 'update');
        $set_status->('update_pid', $$);
        $set_status->('update_hostname', Thruk::Config::hostname());
        $set_status->('last_update', time());
        $dbh->commit;
        TestUtils::test_command({
            cmd  => "/usr/bin/env thruk logcache stats",
            like => [qr/running update since/],
        });
        TestUtils::test_command({
            cmd     => "/usr/bin/env thruk logcache update -y",
            errlike => [qr/already running/],
        });
        $dbh->commit;
        {
            my $rows = $status_rows->();
            is($rows->{'lock_mode'}, 'update', 'fresh lock: update was skipped');
            is($rows->{'update_pid'}, $$, 'fresh lock: lock is still owned');
        }
        $set_status->('lock_mode', '');
        $set_status->('update_pid', undef);
        $set_status->('update_hostname', '');
        $set_status->('last_update', time());
        $dbh->commit;

        ###########################################################
        # duplicate host names are detected, healed and reported
        my $dup = 'dbcommon-heal-'.$$;
        $dbh->do('INSERT INTO '.$qt->($host).' (host_name) VALUES (?)', undef, $dup);
        $dbh->do('INSERT INTO '.$qt->($host).' (host_name) VALUES (?)', undef, $dup);
        $dbh->commit;
        is($dbh->selectrow_array('SELECT count(*) FROM '.$qt->($host).' WHERE host_name = ?', undef, $dup), 2, 'duplicate host fixture created');

        TestUtils::test_command({
            cmd  => "/usr/bin/env thruk selfcheck logcache_data",
            exit => 2,
            like => [qr/duplicate host names: \Q$dup\E/],
        });
        TestUtils::test_command({
            cmd     => "/usr/bin/env thruk selfcheck logcache_data --heal",
            exit    => 1,
            like    => [qr/duplicate host names healed: \Q$dup\E/],
            errlike => [qr/dbcommon-heal-/],
        });
        $dbh->commit;
        is($dbh->selectrow_array('SELECT count(*) FROM '.$qt->($host).' WHERE host_name = ?', undef, $dup), 1, 'duplicate host names healed');
        TestUtils::test_command({
            cmd  => "/usr/bin/env thruk selfcheck logcache_data",
            exit => 0,
            like => [qr/no errors in 1 logcache/],
        });

        ###########################################################
        # a fresh cache reports zero items, not negative ones
        $provider->_create_tables($dbh, 'clampunittest');
        $dbh->commit;
        my(undef, undef, $items) = $provider->_db_table_stats($dbh, 'clampunittest');
        cmp_ok($items, '>=', 0, 'fresh cache reports non-negative item count');
        $provider->_drop_tables($dbh, 'clampunittest');
        $dbh->commit;

        ###########################################################
        # an incomplete cache is reported instead of failing with a database error
        # pause cron so a logcache run cannot hit the missing status table
        TestUtils::test_command({
            cmd  => '/usr/bin/env omd stop crontab',
        });
        $dbh->do('DROP TABLE '.$qt->($status));
        $dbh->commit;
        TestUtils::test_command({
            cmd  => "/usr/bin/env thruk logcache stats",
            like => [qr/logcache is incomplete, status table is missing/],
        });

        ###########################################################
        # restore a complete cache for the remaining tests
        TestUtils::test_command({
            cmd  => "/usr/bin/env thruk logcache import -q -y",
            like => [qr/\QOK - imported\E/],
        });
        $dbh->commit;
        is($dbh->selectrow_array('SELECT count(*) FROM '.$qt->($status)), 12, 'import restores all status rows');
        TestUtils::test_command({
            cmd  => '/usr/bin/env omd start crontab',
        });
    }

}

###########################################################
# be nice and enable checks again
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d '' /system/cmd/start_executing_host_checks",
    like    => ['/Command successfully submitted/'],
});
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d '' /system/cmd/start_executing_svc_checks",
    like    => ['/Command successfully submitted/'],
});

###########################################################
# showlog with host filter
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/showlog.cgi?type=2&statetype=0&host=localhost&service=all&pattern=&exclude_pattern=&nosystem=on',
    'like'   => ["HOST ALERT: localhost;DOWN;HARD;1;test"],
);
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/showlog.cgi?type=2&statetype=0&host=localhost&service=all&pattern=&exclude_pattern=&nosystem=on&logcache=0',
    'like'   => ["HOST ALERT: localhost;DOWN;HARD;1;test"],
);

# all logs
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/showlog.cgi?type=0&statetype=0&host=&service=&pattern=&exclude_pattern=',
    'like'   => ["HOST ALERT:", "SERVICE ALERT:", "LOG VERSION:"],
);
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/showlog.cgi?type=0&statetype=0&host=&service=&pattern=&exclude_pattern=&logcache=0',
    'like'   => ["HOST ALERT:", "SERVICE ALERT:", "LOG VERSION:"],
);

# all alerts
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/showlog.cgi?type=0&statetype=0&host=&service=&pattern=&exclude_pattern=&noflapping=on&nodowntime=on&nosystem=on',
    'like'   => ["HOST ALERT:", "SERVICE ALERT:"],
);
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/showlog.cgi?type=0&statetype=0&host=&service=&pattern=&exclude_pattern=&noflapping=on&nodowntime=on&nosystem=on&logcache=0',
    'like'   => ["HOST ALERT:", "SERVICE ALERT:"],
);

# service entries
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/showlog.cgi?type=&statetype=0&host=localhost&service=Http&pattern=&exclude_pattern=&noflapping=on&nodowntime=on&nosystem=on',
    'like'   => ["SERVICE ALERT:", "EXTERNAL COMMAND: SCHEDULE_FORCED_SVC_CHECK"],
);
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/showlog.cgi?type=&statetype=0&host=localhost&service=Http&pattern=&exclude_pattern=&noflapping=on&nodowntime=on&nosystem=on&logcache=0',
    'like'   => ["SERVICE ALERT:", "EXTERNAL COMMAND: SCHEDULE_FORCED_SVC_CHECK"],
);

###########################################################
# selfcheck
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk selfcheck",
    like    => ['/no errors in 1 logcache/'],
});

###########################################################
done_testing();
