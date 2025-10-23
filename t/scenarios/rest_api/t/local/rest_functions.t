use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 74;

###########################################################
# test thruks script path
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
# age
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=age(last_check) as age"',
        like => [qr/^#age$/smx, qr/^\d+$/smx],
    });
};

###########################################################
# calc
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=calc(last_check, "/", 2) as calc"',
        like => [qr/^#calc$/smx, qr/^\d+\.5+$/smx],
    });
};

###########################################################
# upper
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=uc(name) as host"',
        like => [qr/^#host$/smx, qr/^LOCALHOST$/smx],
    });
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=upper(name) as host"',
        like => [qr/^#host$/smx, qr/^LOCALHOST$/smx],
    });
};

###########################################################
# lower
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=lc(name) as host"',
        like => [qr/^#host$/smx, qr/^uppercase$/smx],
    });
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=lower(name) as host"',
        like => [qr/^#host$/smx, qr/^uppercase$/smx],
    });
};

###########################################################
# concat
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=concat(name, \"_\", state, \"::\") as test"',
        like => [qr/^#test$/smx, qr/^localhost_\d::$/smx],
    });
};

###########################################################
# duration
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=duration(last_check) as duration"',
        like => [qr/^#duration$/smx, qr/^\d+\w/smx],
    });
};

###########################################################
# s
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=s(name, "l.*l", "TST") as test"',
        like => [qr/^#test$/smx, qr/^TSThost$/smx],
    });
};

###########################################################
# substr
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=substr(name, 2, 3) as test"',
        like => [qr/^#test$/smx, qr/^cal$/smx],
    });
};

###########################################################
# utc
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=utc(last_check) as test"',
        like => [qr/^#test$/smx, qr/^\d+\-\d+\-\d+\s+\d+:\d+:\d+\s+UTC$/smx],
    });
};

###########################################################
# date
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=date(last_check) as test"',
        like => [qr/^#test$/smx, qr/^\d+\-\d+\-\d+\s+\d+:\d+:\d+/smx],
    });
};

###########################################################
# hoststate
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=hoststate(state) as test"',
        like => [qr/^#test$/smx, qr/^(UP|DOWN|UNREACHABLE)$/smx],
    });
};

###########################################################
# servicestate
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/services?columns=servicestate(state) as test"',
        like => [qr/^#test$/smx, qr/^(OK|WARNING|UNKNOWN|CRITICAL)$/smx],
    });
};

###########################################################
