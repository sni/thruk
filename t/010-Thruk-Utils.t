#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper qw/Dumper/;
use Encode qw/is_utf8/;
use Test::More;
use utf8;

use Thruk::Config 'noautoload';
use Thruk::Context ();
use Thruk::Utils::Encode ();
use Thruk::Utils::Filter ();

BEGIN {
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
    plan tests => 116;

    use lib('t');
    require TestUtils;
    import TestUtils;
}

undef $ENV{'THRUK_MODE'}; # do not die on backend errors

use_ok('Thruk');
use_ok('Thruk::Utils');
use_ok('Thruk::Utils::External');
use_ok('Thruk::Backend::Manager');

#########################
# sort
my $befor = [
  {a => 0, b => 'b', c => 2},
  {a => 3, b => 'a', c => 10},
  {a => 2, b => 'c', c => 7},
  {a => 0, b => 'c', c => 11},
];
my $sorted_by_a_exp = [
  {a => 0, b => 'b', c => 2},
  {a => 0, b => 'c', c => 11},
  {a => 2, b => 'c', c => 7},
  {a => 3, b => 'a', c => 10},
];
my $sorted_by_b_exp = [
  {a => 3, b => 'a', c => 10},
  {a => 0, b => 'b', c => 2},
  {a => 2, b => 'c', c => 7},
  {a => 0, b => 'c', c => 11},
];
my $sorted_by_c_exp = [
  {a => 0, b => 'b', c => 2},
  {a => 2, b => 'c', c => 7},
  {a => 3, b => 'a', c => 10},
  {a => 0, b => 'c', c => 11},
];
my $sorted_by_ba_exp = [
  {a => 3, b => 'a', c => 10},
  {a => 0, b => 'b', c => 2},
  {a => 0, b => 'c', c => 11},
  {a => 2, b => 'c', c => 7},
];
my $sorted_by_abc_exp = [
  {a => 0, b => 'b', c => 2},
  {a => 0, b => 'c', c => 11},
  {a => 2, b => 'c', c => 7},
  {a => 3, b => 'a', c => 10},
];
#########################
# initialize backend manager
use_ok 'Thruk::Backend::Pool';
my $p = Thruk::Backend::Pool->new();
isa_ok($p, 'Thruk::Backend::Pool');
use_ok 'Thruk::Backend::Manager';
my $b = Thruk::Backend::Manager->new($p);
isa_ok($b, 'Thruk::Backend::Manager');

my $c = TestUtils::get_c();

#########################
my $app = $c->app;
{
    my $c = Thruk::Context->new($app, {'PATH_INFO' => '/dummy-internal'.__FILE__.':'.__LINE__});
    isa_ok($c, 'Thruk::Context');
    my $res1 = $c->sub_request('/r/thruk');
    is(ref $res1, 'HASH', 'got hash from sub_request');
    is($res1->{'rest_version'}, 1, 'got hash from sub_request with content') || diag(Dumper($res1));

    my $res2 = $c->sub_request('/r/thruk/reports');
    is(ref $res2, 'ARRAY', 'got array from sub_request') || diag(Dumper($res2));

    my $res3 = $c->sub_request('/r/thruk/sessions?columns=username&limit=1');
    is(ref $res3, 'ARRAY', 'got array from sub_request');
    is(scalar @{$res3}, 1, 'sending url parameters worked');
    is(scalar keys %{$res3->[0]}, 1, 'sending url parameters worked') || diag(Dumper($res3));
};

#########################
my $sorted_by_a = $b->sort_result($befor, { 'ASC' => 'a' });
is_deeply($sorted_by_a, $sorted_by_a_exp, 'sort by colum a');

my $sorted_by_b = $b->sort_result($befor, { 'ASC' => 'b'});
is_deeply($sorted_by_b, $sorted_by_b_exp, 'sort by colum b');

my $sorted_by_c = $b->sort_result($befor, { 'ASC' => 'c'});
is_deeply($sorted_by_c, $sorted_by_c_exp, 'sort by colum c');

my $sorted_by_ba = $b->sort_result($befor, { 'ASC' => ['b', 'a'] });
is_deeply($sorted_by_ba, $sorted_by_ba_exp, 'sort by colum b,a');

my $sorted_by_ba_reverse = $b->sort_result($befor, { 'DESC' => ['b', 'a'] });
my @sorted_by_ba_exp_reverse = reverse @{$sorted_by_ba_exp};
is_deeply($sorted_by_ba_reverse, \@sorted_by_ba_exp_reverse, 'sort by colum b,a reverse');

my $sorted_by_abc = $b->sort_result($befor, { 'ASC' => ['a','b','c'] });
is_deeply($sorted_by_abc, $sorted_by_abc_exp, 'sort by colum a,b,c');

#########################
# check sorting with case
my $befor_case = [
  {a => 'aAaZ', b => 1},
  {a => 'aaAY', b => 1},
  {a => 'aaaX', b => 1},
];
my $sorted_case = $b->sort_result($befor_case, { 'ASC' => ['a','b'] });
is_deeply($befor_case, $sorted_case, 'sort by colum case a,b');

#########################
SKIP: {
    skip 'external tests', 16 if Thruk::Base->config->{'no_external_job_forks'};

    my($res, $c) = ctx_request('/thruk/main.html');
    my $contactgroups = $c->db->get_contactgroups_by_contact('thrukadmin');
    is(ref $contactgroups, 'HASH', 'get_contactgroups_by_contact(thrukadmin)');

    $contactgroups = $c->db->get_contactgroups_by_contact('nonexistant');
    is_deeply($contactgroups, {}, 'get_contactgroups_by_contact(nonexistant)');

    #########################
    use_ok('XML::Parser');

    my $escaped = Thruk::Utils::Filter::escape_xml("& <br> üöä?");
    my $p1 = XML::Parser->new();
    eval {
        $p1->parse('<data>'.$escaped.'</data>');
    };
    is("$@", "", "no XML::Parser errors");

    #########################
    # external cmd
    Thruk::Utils::External::cmd($c, { cmd => "sleep 1; echo 'test'; echo \"err\" >&2;", background => 1 });
    my $id = $c->stash->{'job_id'};
    isnt($id, undef, "got an id: ".$id);

    # wait for completion
    for(1..5) {
        last unless Thruk::Utils::External::is_running($c, $id);
        sleep(1);
    }

    is(Thruk::Utils::External::is_running($c, $id), 0, "job finished") or BAIL_OUT("$0: job did not finish");
    my($out, $err, $time, $dir) = Thruk::Utils::External::get_result($c, $id);

    is($out,  "test\n", "got result");
    is($err,  "err\n",  "got error");
    isnt($dir, undef,   "got dir");
    ok($time >=1,       "runtime >= 1 (".$time."s)") or diag(`ls -la $dir && cat $dir/*`);

    #########################
    # external perl
    Thruk::Utils::External::perl($c, { expr => "print STDERR 'blah'; print 'blub';", background => 1 });
    $id = $c->stash->{'job_id'};
    isnt($id, undef, "got an id");

    # wait for completion
    for(1..5) {
        last unless Thruk::Utils::External::is_running($c, $id);
        sleep(1);
    }

    is(Thruk::Utils::External::is_running($c, $id), 0, "job finished");
    ($out, $err, $time, $dir) = Thruk::Utils::External::get_result($c, $id);

    is($out,     "blub",  "got result for job: ".$id);
    is($err,     "blah",  "got error for job: ".$id);
    ok($time <=3,         "runtime <= 3seconds, (".$time.")");
    isnt($dir,   undef,   "got dir");
};

#########################

is(Thruk::Utils::version_compare('1.0',         '1.0'),     1, 'version_compare: 1.0 vs. 1.0');
is(Thruk::Utils::version_compare('1.0.0',       '1.0'),     1, 'version_compare: 1.0.0 vs. 1.0');
is(Thruk::Utils::version_compare('1.0',         '1.0.0'),   1, 'version_compare: 1.0 vs. 1.0.0');
is(Thruk::Utils::version_compare('1.0.0',       '1.0.1'),   0, 'version_compare: 1.0.0 vs. 1.0.1');
is(Thruk::Utils::version_compare('1.0.1',       '1.0.0'),   1, 'version_compare: 1.0.1 vs. 1.0.0');
is(Thruk::Utils::version_compare('1.0.0',       '1.0.1b1'), 0, 'version_compare: 1.0.0 vs. 1.0.1b1');
is(Thruk::Utils::version_compare('1.0.1b1',     '1.0.1b2'), 0, 'version_compare: 1.0.1b1 vs. 1.0.1b2');
is(Thruk::Utils::version_compare('2.0-shinken', '1.1.3'),   1, 'version_compare: 2.0-shinken vs. 1.1.3');
is(Thruk::Utils::version_compare('2.4.2',       '2.2.2'),   1, 'version_compare: 2.4.2 vs. 2.2.2');

#########################
{
my $str      = '$USER1$/test -a $ARG1$ -b $ARG2$ -c $HOSTNAME$';
my $macros   = {'$USER1$' => '/opt', '$ARG1$' => 'a', '$HOSTNAME$' => 'host' };
my($replaced,$rc) = $b->_get_replaced_string($str, $macros);
my $expected = '/opt/test -a a -b  -c host';
is($rc, 1, 'macro replacement with empty args succeeds');
is($replaced, $expected, 'macro replacement with empty args string');
};

#########################
# test recursive macros which should not be replaced
{
my $str      = 'x$ARG1$x';
my $macros   = {'$ARG1$' => '$HOST$ $ARG2$ $ARG3$', '$HOST$' => 'x'};
my($replaced,$rc) = $b->_get_replaced_string($str, $macros);
my $expected = 'xx $ARG2$ $ARG3$x';
is($rc, 1, 'macro replacement with empty args succeeds');
is($replaced, $expected, 'macro replacement with empty args string');
};

#########################
# utf8 encoding
my $teststring = 'test';
my $encoded    = $teststring;
$encoded       = Thruk::Utils::Encode::ensure_utf8($encoded);
is($encoded, $teststring, 'ensure utf8 test');
ok(is_utf8($encoded), 'is_utf8 test');

$teststring = 'testä';
$encoded    = $teststring;
$encoded    = Thruk::Utils::Encode::ensure_utf8($encoded);
is($encoded, 'test'.chr(228), 'ensure utf8 testae');
ok(is_utf8($encoded), 'is_utf8 testae');

$teststring ='test€';
$encoded    = $teststring;
$encoded    = Thruk::Utils::Encode::ensure_utf8($encoded);
is($encoded, "test\x{20ac}", 'ensure utf8 testeuro');
ok(is_utf8($encoded), 'is_utf8 testeuro');

$teststring = "test\x{20ac}";
$encoded    = $teststring;
$encoded    = Thruk::Utils::Encode::ensure_utf8($encoded);
is($encoded, "test\x{20ac}", 'ensure utf8 test20ac');
ok(is_utf8($encoded), 'is_utf8 test20ac');

#########################
my $uri;
my($res, $context) = TestUtils::ctx_request('/thruk/main.html');
$c = $context;
$uri = Thruk::Utils::Filter::uri_with($c, {});
is($uri, 'main.html', 'uri_with without params');

$uri = Thruk::Utils::Filter::uri_with($c, { a => 1, b => 2, c => 3});
is($uri, 'main.html?a=1&amp;b=2&amp;c=3', 'uri_with with 3 params');

$uri = Thruk::Utils::Filter::uri_with($c, { a => 1, b => undef, c => 'undef'});
is($uri, 'main.html?a=1', 'uri_with with undef params');

($res, $context) = TestUtils::ctx_request('/thruk/main.html?a=1&b=2&c=3&a=4');
$c = $context;

my $param_exp = {a=>[1,4], b => 2, c => 3};
is_deeply($c->req->parameters, $param_exp, 'got array parameters');

$param_exp = {a=>[1,4], b => 2, c => 3};
is_deeply($c->req->query_parameters, $param_exp, 'got array query parameters');

$uri = Thruk::Utils::Filter::uri_with($c, {});
is($uri, 'main.html?a=1&amp;b=2&amp;c=3&amp;a=4', 'uri_with with existing params');

$uri = Thruk::Utils::Filter::full_uri($c);
is($uri, '/thruk/main.html?a=1&amp;b=2&amp;c=3&amp;a=4', 'full_uri with existing params');

$uri = Thruk::Utils::Filter::short_uri($c);
is($uri, 'main.html?a=1&amp;b=2&amp;c=3&amp;a=4', 'short_uri with existing params');

$uri = Thruk::Utils::Filter::uri_with($c, { d => 5 });
is($uri, 'main.html?a=1&amp;b=2&amp;c=3&amp;a=4&amp;d=5', 'uri_with with added params');

$uri = Thruk::Utils::Filter::uri_with($c, { b => 5 });
is($uri, 'main.html?a=1&amp;b=5&amp;c=3&amp;a=4', 'uri_with with replaced params');

#########################
my $args = Thruk::Utils::Filter::as_url_arg('blah=&blub"');
is($args, 'blah%3D%26blub%22', 'as_url_arg');

#########################
Thruk::Utils::set_message($c, 'fail_message', "test_error");

my $exp_cookie = {'value' => 'fail_message~~test_error', 'path' => '/thruk/', 'samesite' => 'lax', 'httponly' => 0 };
is_deeply($c->res->{'cookies'}->{'thruk_message'}, $exp_cookie, 'get_message cookie');

my @msg = Thruk::Utils::Filter::get_message($c);
my $exp = ['fail_message', 'test_error', 0];
is_deeply(\@msg, $exp, 'get_message');

is($c->res->{'cookies'}->{'thruk_message'}, undef, 'get_message cookie after');

#########################
my $locations = [
    ["http://localhost/thruk",              "localhost:80"],
    ["https://localhost/thruk",             "localhost:443"],
    ["http://localhost:80/thruk",           "localhost:80"],
    ["https://localhost:80/thruk",          "localhost:80"],
    ["http://localhost:81/thruk",           "localhost:81"],
    ["https://localhost:81/thruk",          "localhost:81"],
    ["http://some.other.host/thruk",        "some.other.host:80"],
    ["http://some.other.host:8000/thruk",   "some.other.host:8000"],
];
for my $l (@{$locations}) {
    is(Thruk::Utils::CookieAuth::get_netloc($l->[0]), $l->[1], "get_netloc for ".$l->[0]." is ".$l->[1]);
}

#########################
# wildcard expansion
is('',          Thruk::Utils::convert_wildcards_to_regex(''), 'empty wildcard');
is('.*',        Thruk::Utils::convert_wildcards_to_regex('*'), 'simple wildcard');
is('.*',        Thruk::Utils::convert_wildcards_to_regex('.*'), 'regex wildcard');
is('a*',        Thruk::Utils::convert_wildcards_to_regex('a*'), 'letter wildcard');
is('a+',        Thruk::Utils::convert_wildcards_to_regex('a+'), 'normal regex 1');
is('^a(b|c)d*', Thruk::Utils::convert_wildcards_to_regex('^a(b|c)d*'), 'normal regex 2');

#########################
my $absolute_urls = [
    [ 'https://127.0.0.1:60443/demo/thruk/', '/demo/thruk/cgi-bin/extinfo.cgi',  'https://127.0.0.1:60443/demo/thruk/cgi-bin/extinfo.cgi'],
    [ 'https://127.0.0.1:60443/demo/thruk/', '/demo/pnp4nagios/index.php/popup', 'https://127.0.0.1:60443/demo/pnp4nagios/index.php/popup' ],
    [ '/thruk/cgi-bin/status.cgi?host=all',  '/demo/logos/linux40.png',          '/demo/logos/linux40.png' ],
];
for my $urls (@{$absolute_urls}) {
    local $ENV{'OMD_ROOT'} = '/omd/sites/demo';
    local $ENV{'OMD_SITE'} = 'demo';
    my $got = Thruk::Utils::absolute_url($urls->[0], $urls->[1],1);
    is($got, $urls-> [2], "absolute_url from ".$urls->[0]." and ".$urls->[1])
}

#########################
# test custom variables
{
    my $show_custom_vars = ["A*"];
    is(Thruk::Utils::check_custom_var_list("_ABC", $show_custom_vars),     1, "check_custom_var_list I");
    is(Thruk::Utils::check_custom_var_list("_DEF", $show_custom_vars), undef, "check_custom_var_list II");
    is(Thruk::Utils::check_custom_var_list("_HOSTABD", $show_custom_vars), undef, "check_custom_var_list III");
    is(Thruk::Utils::check_custom_var_list("_HOSTDEF", $show_custom_vars), undef, "check_custom_var_list III");
};

{
    my $show_custom_vars = ["*"];
    is(Thruk::Utils::check_custom_var_list("_ABC", $show_custom_vars),     1, "check_custom_var_list IV");
    is(Thruk::Utils::check_custom_var_list("_DEF", $show_custom_vars),     1, "check_custom_var_list V");
    is(Thruk::Utils::check_custom_var_list("_HOSTABD", $show_custom_vars), undef, "check_custom_var_list VI");
    is(Thruk::Utils::check_custom_var_list("_HOSTDEF", $show_custom_vars), undef, "check_custom_var_list VII");
};

{
    my $show_custom_vars = ["A*", "HOST*"];
    is(Thruk::Utils::check_custom_var_list("_ABC", $show_custom_vars),     1, "check_custom_var_list VIII");
    is(Thruk::Utils::check_custom_var_list("_DEF", $show_custom_vars),undef , "check_custom_var_list IIX");
    is(Thruk::Utils::check_custom_var_list("_HOSTABD", $show_custom_vars), 1, "check_custom_var_list IX");
    is(Thruk::Utils::check_custom_var_list("_HOSTDEF", $show_custom_vars), 1, "check_custom_var_list X");
};

#########################
# test array functions
my $chunks = Thruk::Utils::array_chunk([1..100], 5);
is(scalar @{$chunks}, 5, "array_chunk returns 5 chunks");
is(scalar @{$chunks->[0]}, 20, "array_chunk returns evenly sized chunks");

$chunks = Thruk::Utils::array_chunk([1..100], 150);
is(scalar @{$chunks}, 100, "array_chunk returns 100 chunks");
is(scalar @{$chunks->[0]}, 1, "array_chunk returns evenly sized chunks");

$chunks = Thruk::Utils::array_chunk_fixed_size([1..100], 50);
is(scalar @{$chunks}, 2, "array_chunk_fixed_size returns 2 chunks");
is(scalar @{$chunks->[0]}, 50, "array_chunk_fixed_size returns fixed sized chunks");

$chunks = Thruk::Utils::array_chunk_fixed_size([1..100], 3);
is(scalar @{$chunks}, 34, "array_chunk_fixed_size returns 34 chunks");
is(scalar @{$chunks->[0]}, 3, "array_chunk_fixed_size returns fixed sized chunks");
is(scalar @{$chunks->[33]}, 1, "array_chunk_fixed_size returns fixed sized chunks");

#########################
{
    local $ENV{'THRUK_CONFIG'} = 't/data/number_lists';
    my $config = Thruk::Config::set_config_env();
    $app->{config} = $config;
    my $c = Thruk::Context->new($app, {'PATH_INFO' => '/dummy-internal'.__FILE__.':'.__LINE__});
    is(Thruk::Utils::command_disabled($c, 0), 1, "0 is disabled");
    is(Thruk::Utils::command_disabled($c, 3), 1, "3 is disabled");
    is(Thruk::Utils::command_disabled($c, 5), 0, "5 is enabled");
};

#########################
my $testparams = {
  'credential' => 'secret',
  "options" => {
    'credential' => 'secret'
  },
  'CSRFtoken' => "secret",
  "test" => { 'credential' => 'secret' },
  'data' => '{"credential": "secret", ', # json encoded string
};
my $dump       = Thruk::Utils::dump_params($testparams);
unlike($dump, "/secret/", "dump contains no secrets");

$dump          = Thruk::Utils::dump_params($testparams, undef, 0);
unlike($dump, "/secret/", "dump contains no secrets");
