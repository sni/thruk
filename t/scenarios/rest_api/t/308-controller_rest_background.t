use warnings;
use strict;
use Cpanel::JSON::XS;
use Test::More;

die("*** ERROR: this test is meant to be run with PLACK_TEST_EXTERNALSERVER_URI set,\nex.: THRUK_TEST_AUTH=omdadmin:omd PLACK_TEST_EXTERNALSERVER_URI=http://localhost:60080/demo perl t/scenarios/rest_api/t/301-controller_rest_scenario.t") unless defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};

BEGIN {
    plan tests => 20;

    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok 'Thruk::Controller::rest_v1';
TestUtils::set_test_user_token();

################################################################################
# test limit when having aggregation functions
{
    my $page = TestUtils::test_page(
        'url'          => '/thruk/r/services/?columns=description,state&limit=1&background=1',
        'like'         => ['"job_id" :'],
    );
    my $data = Cpanel::JSON::XS::decode_json($page->{'content'});
    ok($data->{'result_url'}, "got a result url: ".($data->{'result_url'}//""));

    TestUtils::test_page(
        'url'          => '/thruk/r'.$data->{'result_url'},
        'like'         => ['description', 'state'],
        'content_type' => 'application/json; charset=utf-8',
    );
};

################################################################################
