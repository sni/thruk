use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use HTTP::Request ();
use MIME::Base64 qw/encode_base64/;
use Test::More;

plan tests => 39;

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

subtest 'REST input features require a local CLI origin' => sub {
    my $c = TestUtils::ctx_request('/');
    local $ENV{'THRUK_VERBOSE'} = 0;
    my @calls;
    no warnings 'redefine';
    local *Thruk::Utils::IO::cmd = sub { push @calls, 'command'; return(0, 'canary', 'canary', ''); };
    local *Thruk::Utils::IO::read = sub { push @calls, 'file'; return('{}'); };
    local *Thruk::Utils::CLI::request_url = sub { push @calls, 'external'; return(200, {result => '{}'}); };
    local *Thruk::Utils::CLI::Rest::_replace_url_template = sub { push @calls, 'template'; return('hosts'); };
    local *Thruk::Context::sub_request = sub {
        my($ctx, $url) = @_;
        push @calls, $url;
        $ctx->res->body('{}');
        $ctx->res->code(200);
        return $ctx;
    };

    for my $origin ('CLI', 'FCGI', '', undef, 'other') {
        local $ENV{'THRUK_CLI_SRC'} = $origin;
        my $name = $origin // 'unset';
        for my $test (
            [['--command', 'printf canary'], ['command']],
            [['t/data/check_thruk_rest/nested.json'], ['file']],
            [['https://example.invalid/'], ['external']],
            [["[% 'hosts' %]"], ['template', '/r/v1/hosts']],
            [['--string', 'canary'], []],
            [['{}'], []],
            [['/hosts'], ['/r/v1/hosts']],
        ) {
            my($args, $local_calls) = @{$test};
            my $opts = Thruk::Utils::CLI::Rest::_parse_args([@{$args}], $origin && $origin eq 'CLI' ? 'local' : 'fcgi');
            @calls = ();
            my $result = Thruk::Utils::CLI::Rest::_fetch_results($c, $opts, {});
            my $url = $args->[-1];
            $url =~ s|^/||mx;
            is_deeply(\@calls, $origin && $origin eq 'CLI' ? $local_calls : ['/r/v1/'.$url], "$name: @{$args}");
            is($result->[0]->{'rc'}, 0, 'request completes');
        }
    }
    done_testing();
};

subtest 'REST output templates require a local CLI origin' => sub {
    for my $origin ('CLI', 'FCGI', '', undef, 'other') {
        local $ENV{'THRUK_CLI_SRC'} = $origin;
        my $name = $origin // 'unset';
        for my $template (
            "[% 'LOCAL_TEMPLATE' %]",
            'data:'.encode_base64("[% 'LOCAL_TEMPLATE' %]", ''),
            't/data/check_thruk_rest/nested.json',
        ) {
            my $result = [{result => '{}', rc => 0, template => $template}];
            my($output, $rc) = Thruk::Utils::CLI::Rest::_create_output(undef, [], $result);
            if($origin && $origin eq 'CLI') {
                is($rc, 0, "$name: template works");
                like($output, qr/LOCAL_TEMPLATE|timestamp/mx, 'template was rendered');
            } else {
                is($rc, 3, "$name: template rejected");
                like($output, qr/only allowed from the local command line/mx, 'reports origin restriction');
            }
        }
    }
    done_testing();
};

subtest 'Livestatus column metadata' => sub {
    for my $test (
        ['/hosts', 'last_check', 'time'],
        ['/hosts', 'next_check', 'time'],
        ['/hosts', 'last_state', 'number'],
        ['/hosts', 'name', 'string'],
        ['/services', 'host_last_check', 'time'],
        ['/services', 'last_check as checked', 'time'],
        ['/logs', 'time', 'time'],
        ['/downtimes', 'start_time', 'time'],
        ['/downtimes', 'duration', 'number', 's'],
        ['/comments', 'entry_time', 'time'],
        ['/processinfo', 'last_log_rotation', 'time'],
        ['/processinfo', 'interval_length', 'number', 's'],
        ['/hosts', 'execution_time', 'number', 's'],
        ['/hosts', 'latency', 'number', 's'],
        ['/hosts', 'latency as delay', 'number', 's'],
        ['/services', 'host_execution_time', 'number', 's'],
        ['/services', 'latency as delay', 'number', 's'],
        ['/logs', 'current_service_latency', 'number', 's'],
        ['/hosts', 'percent_state_change', 'number', '%'],
        ['/services', 'host_high_flap_threshold', 'number', '%'],
        ['/services', 'low_flap_threshold', 'number', '%'],
        ['/checks/stats', 'hosts_latency_avg', 'number', 's'],
        ['/checks/stats', 'services_latency_max', 'number', 's'],
        ['/checks/stats', 'hosts_active_state_change_avg', 'number', '%'],
        ['/thruk/recurring_downtimes', 'duration', 'number', 'minutes'],
        ['/hosts', 'check_interval', 'number'],
    ) {
        my($path, $column, $type, $unit) = @{$test};
        my $c = TestUtils::ctx_request('/?columns='.$column);
        my $meta = Thruk::Controller::rest_v1::_get_columns_meta_for_path($c, $path, 'GET', []);
        is($meta->[0]->{'type'}, $type, $path.' '.$column);
        is($meta->[0]->{'config'}->{'unit'}, $unit, $path.' '.$column.' unit');
    }
    done_testing();
};

subtest 'Grafana column discovery headers' => sub {
    my $request = HTTP::Request->new('GET' => '/thruk/r/v1/hosts?limit=1');
    $request->header(
        'X-Thruk-Output-Metadata-Only' => '1',
        'X-THRUK-OutputFormat'         => 'wrapped_json',
        'x-thruk-columns'             => 'true',
    );
    my $response = TestUtils::request($request);
    is($response->code, 200, 'column discovery request succeeds');
    my $data = decode_json($response->content);
    is_deeply($data->{'data'}, [], 'metadata-only response contains no rows');
    is(ref $data->{'meta'}->{'columns'}, 'ARRAY', 'response contains column metadata');
    my $columns = { map { $_->{'name'} => $_ } @{$data->{'meta'}->{'columns'}} };
    is($columns->{'name'}->{'type'}, 'string', 'host name has string metadata');
    is($columns->{'state'}->{'type'}, 'number', 'host state has number metadata');
    is($columns->{'last_check'}->{'type'}, 'time', 'last check has time metadata');
    ok(!exists $columns->{'limit'}, 'limit is not included as a column');
    done_testing();
};

# the most specific documented path must win, otherwise a prefix like /thruk/bp
# would shadow /thruk/bp/<nr>/objects/recursive and return the wrong columns
# (this is the metadata-fallback used by the grafana datasource, ex. a
# metadata-only wrapped_json request without an explicit columns param)
subtest 'BP path column metadata specificity' => sub {
    my $c = TestUtils::ctx_request('/');

    my $meta = Thruk::Controller::rest_v1::_get_columns_meta_for_path($c, '/thruk/bp/1/objects/recursive', 'GET', []);
    my $columns = { map { $_->{'name'} => $_ } @{$meta} };
    is($columns->{'_type'}->{'type'}, 'string', 'recursive: _type metadata from objects docs');
    ok(exists $columns->{'host_name'}, 'recursive: host_name metadata present');

    $meta = Thruk::Controller::rest_v1::_get_columns_meta_for_path($c, '/thruk/bp/1/objects', 'GET', []);
    $columns = { map { $_->{'name'} => $_ } @{$meta} };
    is($columns->{'_type'}->{'type'}, 'string', 'objects: _type metadata from objects docs');

    # bp objects rows are livestatus host and service rows, so their columns
    # must be documented as well
    for my $col (qw/address state description plugin_output execution_time/) {
        ok(exists $columns->{$col}, "objects: livestatus column $col documented");
    }

    # /thruk/bp/<nr> itself must still resolve to the business process list docs
    $meta = Thruk::Controller::rest_v1::_get_columns_meta_for_path($c, '/thruk/bp/1', 'GET', []);
    $columns = { map { $_->{'name'} => $_ } @{$meta} };
    ok(exists $columns->{'name'}, 'bp: name (business process list) metadata present');
    ok(!exists $columns->{'_type'}, 'bp: _type metadata absent');
    done_testing();
};

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
