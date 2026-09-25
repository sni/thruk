use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use Test::More;
use URI::Escape qw/uri_escape/;

use Thruk ();

BEGIN {
    plan skip_all => 'backends required' if(!-s ($ENV{'THRUK_CONFIG'} || '.').'/thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    use lib('t');
    require TestUtils;
    import TestUtils;
}

my $res = TestUtils::request('/thruk/cgi-bin/status.cgi?style=combined');
plan skip_all => 'no working backend' if !$res->is_success;
my $old_limit = Thruk->config->{'problems_limit'};
my $problems_limit = 2;
Thruk->config->{'problems_limit'} = $problems_limit;

my $all_problems = '/thruk/cgi-bin/status.cgi?style=combined'
                 . '&hst_s0_hoststatustypes=15&hst_s0_servicestatustypes=31&hst_s0_hostprops=0&hst_s0_serviceprops=0'
                 . '&svc_s0_hoststatustypes=15&svc_s0_servicestatustypes=31&svc_s0_hostprops=0&svc_s0_serviceprops=0';

$res = TestUtils::request($all_problems);
plan skip_all => 'no working backend' if !$res->is_success;

plan tests => 40;

my $content = $res->decoded_content || $res->content;

unlike($content, qr/show_all_hosts/,     'no more show_all_hosts link');
unlike($content, qr/show_all_services/,  'no more show_all_services link');
like($content, qr/Host and Service Details/m, 'combined page shows its heading');

my($href_hosts) = $content =~ m{<a href="([^"]*)"[^>]*><span class="textALERT">Limit of $problems_limit matching hosts reached};
ok($href_hosts, 'found show all hosts link to hostdetail page');
if($href_hosts) {
    like($href_hosts, qr/status\.cgi\?[^"]*style=hostdetail/mx,   'hosts link points to hostdetail');
    like($href_hosts, qr/dfl_s0_hoststatustypes=15/mx,             'hosts link keeps host filters with dfl_ prefix');
    like($href_hosts, qr/dfl_s0_servicestatustypes=31/mx,          'hosts link keeps host filters with dfl_ prefix');
    like($href_hosts, qr/dfl_s0_hostprops=0/mx,                    'hosts link keeps host properties with dfl_ prefix');
    like($href_hosts, qr/dfl_s0_serviceprops=0/mx,                 'hosts link keeps service properties with dfl_ prefix');
    unlike($href_hosts, qr/(?:^|[?&])svc_/mx,                      'hosts link drops service filters');
    unlike($href_hosts, qr/(?:^|[?&])hst_s0_/mx,                   'hosts link has no hst_ prefixed filters anymore');

    $href_hosts =~ s/&amp;/&/gmx;
    $href_hosts = '/thruk/cgi-bin/'.$href_hosts if $href_hosts =~ m{^status\.cgi\?};
    my $page_res = TestUtils::request($href_hosts);
    ok($page_res->is_success, 'hostdetail page should succeed');

    my $page_content = $page_res->decoded_content || $page_res->content;
    my($total) = $page_content =~ m{of (\d+) Items Displayed};

    like($page_content, qr/Current Network Status/m, 'hostdetail page renders');
    like($page_content, qr/of \d+ Items Displayed/m, 'hostdetail page is paginated');
    like($page_content, qr/dfl_s0_hoststatustypes/mx, 'hostdetail page kept the filters');
    ok(defined $total && $total > $problems_limit, 'hostdetail page shows more than problems_limit hosts');

    SKIP: {
        skip 'fewer than one page of hosts', 1 if !defined $total || $total <= 100;
        like($page_content, qr/page=2/mx, 'hostdetail page has a second page');
    }
    unlike($page_content, qr/Limit of $problems_limit matching hosts reached/m, 'hostdetail page is not limited by problems_limit');
}

ok(1, 'services table hit the problems limit');
my($href_services) = $content =~ m{<a href="([^"]*)"[^>]*><span class="alerttext">Limit of $problems_limit matching services reached};
ok($href_services, 'found show all services link to detail page');
if($href_services) {
    like($href_services, qr/status\.cgi\?[^"]*style=detail/mx,   'services link points to detail');
    like($href_services, qr/dfl_s0_hoststatustypes=15/mx,         'services link keeps service filters with dfl_ prefix');
    like($href_services, qr/dfl_s0_servicestatustypes=31/mx,      'services link keeps service filters with dfl_ prefix');
    like($href_services, qr/dfl_s0_hostprops=0/mx,                'services link keeps host properties with dfl_ prefix');
    like($href_services, qr/dfl_s0_serviceprops=0/mx,             'services link keeps service properties with dfl_ prefix');
    unlike($href_services, qr/(?:^|[?&])hst_/mx,                  'services link drops host filters');
    unlike($href_services, qr/(?:^|[?&])svc_s0_/mx,               'services link has no svc_ prefixed filters anymore');

    $href_services =~ s/&amp;/&/gmx;
    $href_services = '/thruk/cgi-bin/'.$href_services if $href_services =~ m{^status\.cgi\?};
    my $page_res = TestUtils::request($href_services);
    ok($page_res->is_success, 'detail page should succeed');

    my $page_content = $page_res->decoded_content || $page_res->content;
    my($total) = $page_content =~ m{of (\d+) Items Displayed};

    like($page_content, qr/Current Network Status/m, 'detail page renders');
    like($page_content, qr/of \d+ Items Displayed/m, 'detail page is paginated');
    like($page_content, qr/dfl_s0_hoststatustypes/mx, 'detail page kept the filters');
    ok(defined $total && $total > $problems_limit, 'detail page shows more than problems_limit services');

    SKIP: {
        skip 'fewer than one page of services', 1 if !defined $total || $total <= 100;
        like($page_content, qr/page=2/mx, 'detail page has a second page');
    }
    unlike($page_content, qr/Limit of $problems_limit matching services reached/m, 'detail page is not limited by problems_limit');
}

# sortoption state duration with ID 6 works together with the limit
$res = TestUtils::request($all_problems.'&sortoption_svc=6&sorttype_svc=1&sortoption_hst=6&sorttype_hst=1');
ok($res->is_success, 'combined page with state duration sort should succeed');
my $duration_content = $res->decoded_content || $res->content;
like($duration_content, qr/Limit of $problems_limit matching hosts reached/m, 'hosts limit hit with state duration sort');
like($duration_content, qr/Limit of $problems_limit matching services reached/m, 'services limit hit with state duration sort');



# no limit link if the filter matches fewer objects, exactly one, less than the current problems_limit which is two
my $host_res = TestUtils::request('/thruk/r/hosts?columns=name&limit=1');

my $hosts_json = eval { decode_json($host_res->decoded_content || $host_res->content) };
if(!$@ && ref $hosts_json eq 'ARRAY' && scalar @{$hosts_json} > 0) {
    my $host_name = $hosts_json->[0]->{'name'};
    my $single_host = '/thruk/cgi-bin/status.cgi?style=combined'
                    . '&hst_s0_type=host&hst_s0_op=%3D&hst_s0_value='.uri_escape($host_name)
                    . '&hst_s0_hoststatustypes=15&hst_s0_servicestatustypes=31&hst_s0_hostprops=0&hst_s0_serviceprops=0'
                    . '&svc_s0_hoststatustypes=15&svc_s0_servicestatustypes=31&svc_s0_hostprops=0&svc_s0_serviceprops=0';
    $res = TestUtils::request($single_host);

    ok($res->is_success, 'single host combined page should succeed');

    my $single_content = $res->decoded_content || $res->content;
    like($single_content, qr/1 of 1 Matching Host Entries Displayed/m, 'single host shows 1 of 1 hosts');
    unlike($single_content, qr/Limit of \d+ matching hosts reached/m, 'no host limit link for a single host');
}

# restore the limit for potential other tests in this process
Thruk->config->{'problems_limit'} = $old_limit;
