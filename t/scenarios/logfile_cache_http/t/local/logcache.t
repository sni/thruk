use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 162;

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
