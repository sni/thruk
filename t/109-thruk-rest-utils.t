use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use HTTP::Request ();
use Test::More;

plan tests => 38;

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

subtest 'Custom-variable column discovery' => sub {
    my $c = TestUtils::ctx_request('/');
    $c->req->headers->header('X-Thruk-Output-Metadata-Only' => '1', 'x-thruk-columns' => 'true');
    local $c->config->{'show_custom_vars'} = ['TEST', 'HOSTTEST'];
    local $c->config->{'expose_custom_vars'} = [];
    local $c->user->{'roles'} = ['authorized_for_all_hosts', 'authorized_for_all_services'];

    no warnings 'redefine';
    local *Thruk::Backend::Manager::get_hosts = sub {
        my(undef, %options) = @_;
        is_deeply($options{'columns'}, ['custom_variable_names'], 'only host variable names requested');
        return [{custom_variable_names => ['TEST', 'PRIVATE']}];
    };
    local *Thruk::Backend::Manager::get_services = sub {
        my(undef, %options) = @_;
        is_deeply($options{'columns'}, ['custom_variable_names'], 'only service variable names requested');
        return [{custom_variable_names => ['TEST', 'PRIVATE']}];
    };

    for my $path ('/hosts', '/hosts/localhost', '/services', '/hosts/localhost/services', '/services/localhost/Ping',
                  '/thruk/bp/1/objects', '/thruk/bp/1/objects/recursive') {
        my $data = Thruk::Controller::rest_v1::process_rest_request($c, $path, 'GET');
        is_deeply($data->{'data'}, [], $path.' metadata response contains no rows');
        my $columns = { map { $_->{'name'} => $_ } @{$data->{'meta'}->{'columns'}} };
        ok(exists $columns->{'_TEST'}, $path.' exposed variable discovered');
        ok(!exists $columns->{'_PRIVATE'}, $path.' private variable hidden');
        if($path =~ m/services|\/objects/mx) {
            ok(exists $columns->{'description'}, $path.' service columns included');
            ok(exists $columns->{'_HOSTTEST'}, $path.' host variable discovered');
            ok(!exists $columns->{'_HOSTPRIVATE'}, $path.' private host variable hidden');
        }
    }

    $c->req->headers->remove_header('x-thruk-columns');
    $c->user->{'roles'} = ['authorized_for_admin'];
    my $admin_data = Thruk::Controller::rest_v1::process_rest_request($c, '/services', 'GET');
    my $admin_columns = { map { $_->{'name'} => $_ } @{$admin_data->{'meta'}->{'columns'}} };
    ok(exists $admin_columns->{'_PRIVATE'}, 'admin discovers all service variables without Grafana header');
    ok(exists $admin_columns->{'_HOSTPRIVATE'}, 'admin discovers all host variables without Grafana header');

    my $contact_data = Thruk::Controller::rest_v1::process_rest_request($c, '/contacts', 'GET');
    ok(!(grep { $_->{'name'} eq '_TEST' } @{$contact_data->{'meta'}->{'columns'}}), 'contact metadata excludes host and service variables');

    $c->req->parameters->{'columns'} = 'name';
    my $data = Thruk::Controller::rest_v1::process_rest_request($c, '/hosts', 'GET');
    is_deeply([map { $_->{'name'} } @{$data->{'meta'}->{'columns'}}], ['name'], 'explicit column selection preserved');
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
