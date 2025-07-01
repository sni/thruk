use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use Test::More;

die("*** ERROR: this test is meant to be run with PLACK_TEST_EXTERNALSERVER_URI set") unless defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};

BEGIN {
    plan tests => 32;

    use lib('t');
    require TestUtils;
    import TestUtils;
}

TestUtils::test_page(
    url     => '/thruk/cgi-bin/proxy.cgi/backend1/demo/thruk/cgi-bin/user.cgi',
    like    => ['authorized_for_all_hosts', 'authorized_for_read_only', '>User<.*?>omdadmin<'],
    unlike  => ['authorized_for_admin', 'authorized_for_system_commands'],
);

TestUtils::test_page(
    url     => '/thruk/cgi-bin/proxy.cgi/backend1/demo/thruk/cgi-bin/user.cgi?action=apikeys',
    like    => ['Read-Only sessions cannot create API keys'],
    unlike  => ['New API Key'],
);

TestUtils::test_page(
    url     => '/thruk/cgi-bin/proxy.cgi/backend1/demo/thruk/cgi-bin/extinfo.cgi?type=1&host=localhost',
    like    => ['Your account does not have permissions to execute commands'],
);
