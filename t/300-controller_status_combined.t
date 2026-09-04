use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use Test::More;
use URI::Escape qw/uri_escape/;

BEGIN {
    plan skip_all => 'backends required' if(!-s ($ENV{'THRUK_CONFIG'} || '.').'/thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    use lib('t');
    require TestUtils;
    import TestUtils;
}

# lower the problems limit, so we can hit it with the test site
my $res = TestUtils::request('/thruk/cgi-bin/status.cgi?style=combined');
plan skip_all => 'no working backend' if !$res->is_success;
my $old_limit = Thruk->config->{'problems_limit'};
my $problems_limit = 2;
Thruk->config->{'problems_limit'} = $problems_limit;

# make sure the test site is big enough to hit the limit
$res = TestUtils::request('/thruk/cgi-bin/status.cgi?style=combined&view_mode=json&hst_s0_hoststatustypes=15&hst_s0_servicestatustypes=31&hst_s0_hostprops=0&hst_s0_serviceprops=0&svc_s0_hoststatustypes=15&svc_s0_servicestatustypes=31&svc_s0_hostprops=0&svc_s0_serviceprops=0');
plan skip_all => 'test site too small for combined limit tests' if !$res->is_success;
my $json = decode_json($res->decoded_content || $res->content);
plan skip_all => 'test site too small for combined limit tests' if scalar @{$json->{'hosts'}}    <= $problems_limit;
plan skip_all => 'test site too small for combined limit tests' if scalar @{$json->{'services'}} <= $problems_limit;

plan 'no_plan';

my $all_problems = '/thruk/cgi-bin/status.cgi?style=combined'
                 . '&hst_s0_hoststatustypes=15&hst_s0_servicestatustypes=31&hst_s0_hostprops=0&hst_s0_serviceprops=0'
                 . '&svc_s0_hoststatustypes=15&svc_s0_servicestatustypes=31&svc_s0_hostprops=0&svc_s0_serviceprops=0';

# --------------------------------------------------------------------------
# html view fetches only problems_limit + 1 rows and links to the paginated
# hostdetail/detail tables instead of rendering all rows.
# --------------------------------------------------------------------------
my $page = TestUtils::test_page(
    'url' => $all_problems,
    'like' => [
        qr/Limit of $problems_limit matching hosts reached, click to show all matching hosts\./,
        qr/Limit of $problems_limit matching services reached, click to show all matching services\./,
    ],
    'unlike' => [
        'show_all_hosts',
        'show_all_services',
    ],
);
my $content = $page->{'content'};

my($hosts_href) = $content =~ m{<a href="([^"]*)"[^>]*><span class="textALERT">Limit of $problems_limit matching hosts reached};
my($services_href) = $content =~ m{<a href="([^"]*)"[^>]*><span class="alerttext">Limit of $problems_limit matching services reached};
ok($hosts_href, 'found show all hosts link to hostdetail page') || diag($content);
ok($services_href, 'found show all services link to detail page') || diag($content);

# host filters must be converted from the combined prefix (hst_) to the dfl_
# prefix used by the hostdetail page and the service filters must be dropped
like($hosts_href, qr/status\.cgi\?[^"]*style=hostdetail/mx, 'hosts link points to hostdetail');
like($hosts_href, qr/dfl_s0_hoststatustypes=15/mx,      'hosts link keeps host filters with dfl_ prefix');
like($hosts_href, qr/dfl_s0_servicestatustypes=31/mx,   'hosts link keeps host filters with dfl_ prefix');
unlike($hosts_href, qr/(?:^|[?&])svc_/mx,               'hosts link drops service filters');
unlike($hosts_href, qr/(?:^|[?&])hst_s0_/mx,            'hosts link has no hst_ prefixed filters anymore');

like($services_href, qr/status\.cgi\?[^"]*style=detail/mx, 'services link points to detail');
like($services_href, qr/dfl_s0_hoststatustypes=15/mx,    'services link keeps service filters with dfl_ prefix');
like($services_href, qr/dfl_s0_servicestatustypes=31/mx, 'services link keeps service filters with dfl_ prefix');
unlike($services_href, qr/(?:^|[?&])hst_/mx,            'services link drops host filters');
unlike($services_href, qr/(?:^|[?&])svc_s0_/mx,         'services link has no svc_ prefixed filters anymore');

# the linked pages must be the paginated host/service tables showing the
# same filters
$hosts_href =~ s/&amp;/&/gmx;
$hosts_href = '/thruk/cgi-bin/'.$hosts_href if $hosts_href =~ m{^status\.cgi\?};
my $hosts_res = TestUtils::request($hosts_href);
ok($hosts_res->is_success, 'hostdetail page should succeed');
my $hosts_content = $hosts_res->decoded_content || $hosts_res->content;
like($hosts_content, qr/of \d+ Items Displayed/m, 'hostdetail page is paginated');
like($hosts_content, qr/dfl_s0_hoststatustypes/mx, 'hostdetail page kept the filters');
like($hosts_content, qr/page=2/mx, 'hostdetail page has a second page');
unlike($hosts_content, qr/Limit of $problems_limit matching hosts reached/m, 'hostdetail page is not limited by problems_limit');

$services_href =~ s/&amp;/&/gmx;
$services_href = '/thruk/cgi-bin/'.$services_href if $services_href =~ m{^status\.cgi\?};
my $services_res = TestUtils::request($services_href);
ok($services_res->is_success, 'detail page should succeed');
my $services_content = $services_res->decoded_content || $services_res->content;
like($services_content, qr/of \d+ Items Displayed/m, 'detail page is paginated');
like($services_content, qr/dfl_s0_hoststatustypes/mx, 'detail page kept the filters');
like($services_content, qr/page=2/mx, 'detail page has a second page');
unlike($services_content, qr/Limit of $problems_limit matching services reached/m, 'detail page is not limited by problems_limit');

# --------------------------------------------------------------------------
# sortoption 6 (state duration) works together with the limit
# --------------------------------------------------------------------------
my $duration = $all_problems.'&sortoption_svc=6&sorttype_svc=1&sortoption_hst=6&sorttype_hst=1';
TestUtils::test_page(
    'url' => $duration,
    'like' => [
        qr/Limit of $problems_limit matching hosts reached/m,
        qr/Limit of $problems_limit matching services reached/m,
    ],
);

# --------------------------------------------------------------------------
# show_all_hosts / show_all_services params keep working and disable the limit
# --------------------------------------------------------------------------
my $all_res = TestUtils::request($all_problems.'&show_all_hosts=1');
ok($all_res->is_success, 'show_all_hosts page should succeed');
my $all_content = $all_res->decoded_content || $all_res->content;
like($all_content, qr/of \d+ Matching Host Entries Displayed/m, 'show_all_hosts renders all hosts');
unlike($all_content, qr/Limit of \d+ matching hosts reached/m, 'show_all_hosts disables the host limit');
$all_res = TestUtils::request($all_problems.'&show_all_services=1');
ok($all_res->is_success, 'show_all_services page should succeed');
$all_content = $all_res->decoded_content || $all_res->content;
like($all_content, qr/of \d+ Matching Service Entries Displayed/m, 'show_all_services renders all services');
unlike($all_content, qr/Limit of \d+ matching services reached/m, 'show_all_services disables the service limit');

# --------------------------------------------------------------------------
# exports are not limited
# --------------------------------------------------------------------------
my $json_page = TestUtils::test_page(
    'url'          => $all_problems.'&view_mode=json',
    'content_type' => 'application/json; charset=utf-8',
);
my $data = decode_json($json_page->{'content'});
is(ref $data, 'HASH', 'json result is a hash');
ok(scalar @{$data->{'hosts'}}    > $problems_limit, 'json export contains all hosts');
ok(scalar @{$data->{'services'}} > $problems_limit, 'json export contains all services');

# --------------------------------------------------------------------------
# no limit link if the filter matches fewer objects than the problems_limit
# --------------------------------------------------------------------------
my $host_name = $data->{'hosts'}->[0]->{'name'};
my $single_host = '/thruk/cgi-bin/status.cgi?style=combined'
                . '&hst_s0_type=host&hst_s0_op=%3D&hst_s0_value='.uri_escape($host_name)
                . '&hst_s0_hoststatustypes=15&hst_s0_servicestatustypes=31&hst_s0_hostprops=0&hst_s0_serviceprops=0'
                . '&svc_s0_hoststatustypes=15&svc_s0_servicestatustypes=31&svc_s0_hostprops=0&svc_s0_serviceprops=0';
TestUtils::test_page(
    'url'   => $single_host,
    'like'  => [ qr/1 of 1 Matching Host Entries Displayed/m ],
    'unlike'=> [ qr/Limit of \d+ matching hosts reached/m ],
);

# restore the limit for potential other tests in this process
Thruk->config->{'problems_limit'} = $old_limit;

done_testing();
