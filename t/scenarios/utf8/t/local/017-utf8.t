use warnings;
use strict;
use Test::More;
use utf8;

plan tests => 15;

BEGIN {
    $ENV{'THRUK_AUTHOR'} = 1;
    use lib('t');
    require TestUtils;
    import TestUtils;
}

###########################################################
# check accessing utf host by rest api
{
    local $ENV{'THRUK_TEST_AUTH_KEY'}  = "testkey";
    TestUtils::test_page(
        url     => '/thruk/r/hosts/öäüß€/',
        like    => ['check_command" : "check-host-alive'],
    );
    TestUtils::test_page(
        url     => '/thruk/r/hosts/öäüß€/config',
        like    => [':FILE', 'test.cfg'],
    );
}

###########################################################
