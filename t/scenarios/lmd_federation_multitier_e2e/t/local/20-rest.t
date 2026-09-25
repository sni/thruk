use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 17;

###########################################################
# test thruks script path
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
TestUtils::test_command({
    cmd     => '/usr/bin/env thruk r "/hostgroups?name=all"',
    # every host has an always-CRITICAL service and Naemon's ranking is
    # OK < WARN < UNKNOWN < CRIT, so worst_service_state is deterministically 2.
    waitfor => [
            '"num_hosts"\ :\ 7,',
            '"num_services"\ :\ 21,',
            '"worst_service_state"\ :\ 2',
    ],
    maxwait => 60,
    like    => [
            '/"num_hosts" : 7,/',
            '/"num_services" : 21,/',
            '/"worst_service_state" : 2/',
    ],
});

TestUtils::test_command({
    cmd    => '/usr/bin/env thruk r "/servicegroups?name=All Pings"',
    like   => [
            '/"num_services" : 7,/',
            '/"worst_service_state" : 3/',
    ],
});
