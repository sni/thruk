use warnings;
use strict;
use Test::More;
use utf8;

plan tests => 13;

BEGIN {
    $ENV{'THRUK_AUTHOR'} = 1;
    use lib('t');
    require TestUtils;
    import TestUtils;
}

###########################################################
# verify that we use the correct thruk binary
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
# check hosts livestatus data
TestUtils::test_command({
    cmd  => '/usr/bin/env thruk r /hosts/öäüß€/',
    like => ['/check_command" : "check-host-alive/'],
});

###########################################################
# check hosts config data
TestUtils::test_command({
    cmd  => '/usr/bin/env thruk r /hosts/öäüß€/config',
    like => ['/:FILE/', '/test.cfg/'],
});

###########################################################
