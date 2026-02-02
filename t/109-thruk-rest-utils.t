use warnings;
use strict;
use Test::More;

plan tests => 34;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}
use_ok 'Thruk::Utils::CLI::Rest';
use_ok 'Thruk::Controller::rest_v1';
use_ok 'Thruk::Utils::Status';
use_ok 'Thruk::Utils';

_test_replace_output();
_test_get_filter();

################################################################################
sub _test_replace_output{
    my $test_result = [{json => {
            "text1"  => "text1",
            "int1"   => 5,
            "float1" => 3.7,
            "total"  => 1,
        }}, {json =>  {
            "text2"  => "text2",
            "int2"   => 2,
            "float2" => 1.7,
            "total"  => 2,
        }}
    ];

    my $totals = Thruk::Utils::CLI::Rest::_calculate_data_totals($test_result, {});
    unshift(@{$test_result}, $totals);

    # simple text
    is(Thruk::Utils::CLI::Rest::_replace_output('text1', $test_result), "text1", "simple text 1");
    is(Thruk::Utils::CLI::Rest::_replace_output('text2', $test_result), "text2", "simple text 2");

    # numbers
    is(Thruk::Utils::CLI::Rest::_replace_output('int1', $test_result), "5", "number 1");
    is(Thruk::Utils::CLI::Rest::_replace_output('int1%d', $test_result), "5", "number 2");
    is(Thruk::Utils::CLI::Rest::_replace_output('float1%0.2f', $test_result), "3.70", "number 3");

    # totals
    is(Thruk::Utils::CLI::Rest::_replace_output('1:total', $test_result), "1", "total 1");
    is(Thruk::Utils::CLI::Rest::_replace_output('2:total', $test_result), "2", "total 2");
    is(Thruk::Utils::CLI::Rest::_replace_output('total', $test_result), "3", "total 3");

    # arithmetic
    is(Thruk::Utils::CLI::Rest::_replace_output('1:total + 2:total', $test_result), "3", "arithmetic 1");
    is(Thruk::Utils::CLI::Rest::_replace_output('2:total - 1:total', $test_result), "1", "arithmetic 2");
    is(Thruk::Utils::CLI::Rest::_replace_output('1:total / 2:total%0.2f', $test_result), "0.50", "arithmetic 3");
    is(Thruk::Utils::CLI::Rest::_replace_output('total / 3', $test_result), "1", "arithmetic 4");
}

################################################################################
sub _test_get_filter {
    use Thruk::Controller::rest_v1;

    my $url = "/?columns=count(*):sessions,max(active):active&active[gte]=today";
    ok(1, $url);
    my $c      = TestUtils::ctx_request($url);
    my $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::PRE_STATS);
    my $txt    = Thruk::Utils::Status::filter2text($filter);
    my($s, $e) = Thruk::Utils::get_start_end_for_timeperiod($c, "today");
    is($txt, "active >= $s", "pre stats: active filter text 1");

    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::POST_STATS2);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, undef, "post stats: active filter text 1");

    ###############
    $url = "/?columns=name,upper(groups):gr&gr[gte]=test&name=localhost";
    ok(1, $url);
    $c      = TestUtils::ctx_request($url);
    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::PRE_STATS);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, "groups >= 'test' and name = 'localhost'", "pre stats: active filter text 2");

    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::POST_STATS2);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, undef, "post stats: active filter text 2");

    ###############
    $url = "/?columns=name,to_rows(services):svc&svc[like]=^U&host_name=localhost";
    ok(1, $url);
    $c      = TestUtils::ctx_request($url);
    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::PRE_STATS);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, "host_name = 'localhost'", "pre stats: active filter text 3");

    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::POST_STATS2);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, "svc ~~ '^U'", "post stats: active filter text 3");

    ###############
    $url = "/?columns=count(*):total,state&sort=total&host_name=localhost&total[gte]=0";
    ok(1, $url);
    $c      = TestUtils::ctx_request($url);
    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::PRE_STATS);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, "host_name = 'localhost'", "pre stats: active filter text 4");

    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::POST_STATS2);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, "total >= 0", "post stats: active filter text 4");

    ###############
    $url = "/?columns=host_name,description,groups&q=***groups != '' and host_name like ^l***";
    ok(1, $url);
    $c      = TestUtils::ctx_request($url);
    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::PRE_STATS);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, "groups != '' and host_name ~~ '^l'", "pre stats: active filter text 5");

    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::POST_STATS2);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, undef, "post stats: active filter text 5");

    ###############
    $url = "/?columns=count(*):total,host_name,description,groups&q=***groups != '' and host_name like ^l and total > 0***";
    ok(1, $url);
    $c      = TestUtils::ctx_request($url);
    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::PRE_STATS);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, "groups != '' and host_name ~~ '^l'", "pre stats: active filter text 6");

    $filter = Thruk::Controller::rest_v1::_get_filter($c, Thruk::Controller::rest_v1::POST_STATS2);
    $txt    = Thruk::Utils::Status::filter2text($filter);
    is($txt, "total > 0", "post stats: active filter text 6");
}
