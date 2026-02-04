use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 140;

###########################################################
# test thruks script path
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
# transformation functions in the order of:
# https://thruk.org/documentation/rest.html#_transformation-functions
###########################################################

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
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=calc(last_check, \"/\", 7) as calc"',
        like => [qr/^#calc$/smx, qr/^\d+\.\d+$/smx],
    });
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=calc(last_check, \"*\", 1.11) as calc"',
        like => [qr/^#calc$/smx, qr/^\d+\.\d+$/smx],
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
# fmt
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=fmt(\"%.3f\", state) as test"',
        like => [qr/^#test$/smx, qr/^\d\.000$/smx],
    });
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=fmt(\"%s:%.3f\", name, state) as test"',
        like => [qr/^#test$/smx, qr/^localhost:\d\.000$/smx],
    });
};

###########################################################
# lc / lower
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
# s
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=s(name, \"l.*l\", \"TST\") as test"',
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
# unit
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/wrapped_json/hosts?columns=rta&name=localhost"',
        like => [qr/^#rta$/smx, qr/"unit"\ :\ "ms"/mx],
    });
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/wrapped_json/hosts?columns=unit(calc(rta, \"*\", 1000), \"s\") as rta_seconds&name=localhost"',
        like => [qr/^#rta_seconds$/smx, qr/"unit"\ :\ "s"/mx],
    });
};

###########################################################
# uc / upper
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
# aggregation functions in the order of:
# https://thruk.org/documentation/rest.html#_aggregation-functions
###########################################################

###########################################################
# count
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/services?columns=count(*) as test"',
        like => [qr/^#test$/smx, qr/^test;12$/smx],
    });
};

###########################################################
# avg
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/services?columns=avg(execution_time) as test"',
        like => [qr/^#test$/smx, qr/^test;\d+\.\d+$/smx],
    });
};

###########################################################
# sum
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/services?columns=sum(state) as test"',
        like => [qr/^#test$/smx, qr/^test;\d+$/smx],
    });
};

###########################################################
# min
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/services?columns=min(state) as test"',
        like => [qr/^#test$/smx, qr/^test;\d+$/smx],
    });
};

###########################################################
# max
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/services?columns=max(state) as test"',
        like => [qr/^#test$/smx, qr/^test;\d+$/smx],
    });
};

###########################################################
# uniq
{
    TestUtils::test_command({
        cmd    => '/usr/bin/env thruk r "/csv/services?columns=uniq(),host_name"',
        like   => [qr/^#host_name$/smx, qr/^localhost$/smx],
        unlike => [qr/uniq/smx],
    });
};

###########################################################
# disaggregation functions in the order of:
# https://thruk.org/documentation/rest.html#_disaggregation-functions
###########################################################

###########################################################
# to_rows / as_rows
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=host_name,to_rows(services):svc"',
        like => [qr/^#host_name;svc$/smx, qr/^localhost;Http$/smx],
    });
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r "/csv/hosts?columns=host_name,as_rows(services):svc"',
        like => [qr/^#host_name;svc$/smx, qr/^localhost;Http$/smx],
    });
};

###########################################################
