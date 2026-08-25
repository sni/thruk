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
    waitfor => '"worst_service_state"\ :\ 3', # might take a while till summary attributes will be updated
    maxwait => 60,
    like    => [
            '/"num_hosts" : 7,/',
            '/"num_services" : 21,/',
            '/"worst_service_state" : 3/',
    ],
});

TestUtils::test_command({
    cmd    => '/usr/bin/env thruk r "/servicegroups?name=All Pings"',
    like   => [
            '/"num_services" : 7,/',
            '/"worst_service_state" : 3/',
    ],
});
