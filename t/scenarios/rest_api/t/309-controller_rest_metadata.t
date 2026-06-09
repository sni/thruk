use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use Test::More;
use URI::Escape qw/uri_escape/;

use lib 'lib';

use Thruk::Utils::IO ();

BEGIN {
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan tests => 477;
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}
BEGIN { use_ok 'Thruk::Controller::rest_v1' }

TestUtils::set_test_user_token();
my($host,$service) = TestUtils::get_test_service();

my $list_pages = [
    '/',
    '/v1/',
    '/index',
    '/sites',
    '/config/diff',
    '/config/precheck',
    '/config/files',
    '/config/objects',
    '/config/fullobjects',
    '/commands',
    '/comments',
    '/contactgroups',
    '/contacts',
    '/downtimes',
    '/hostgroups',
    '/hosts',
    '/hosts/availability',
    '/hosts/'.uri_escape($host),
    '/hosts/'.uri_escape($host).'/services',
    '/hosts/outages',
    '/hosts/'.uri_escape($host).'/outages',
    '/logs',
    '/alerts',
    '/notifications',
    '/processinfo',
    '/servicegroups',
    '/services',
    '/services/availability',
    '/services/outages',
    '/services/'.uri_escape($host).'/'.uri_escape($service),
    '/services/'.uri_escape($host).'/'.uri_escape($service).'/outages',
    '/timeperiods',
    '/lmd/sites',
    '/thruk/bp',
    '/thruk/cluster',
    '/thruk/recurring_downtimes',
    '/thruk/jobs',
    '/thruk/panorama',
    '/thruk/reports',
    '/thruk/broadcasts',
    '/thruk/sessions',
    '/thruk/users',
    '/thruk/api_keys',
    '/thruk/logcache/stats',
];

my $hash_pages = [
    '/contacts/totals',
    '/checks/stats',
    '/hosts/stats',
    '/hosts/totals',
    '/hosts/'.uri_escape($host).'/availability',
    '/processinfo/stats',
    '/services/stats',
    '/services/totals',
    '/services/'.uri_escape($host).'/'.uri_escape($service).'/availability',
    '/thruk',
    '/thruk/config',
    '/thruk/stats',
    '/thruk/metrics',
    '/thruk/whoami',
];

# get config from rest endpoint
my $config = {};
{
    my $page = TestUtils::test_page(
        'url'          => '/thruk/r/thruk/config',
        'content_type' => 'application/json; charset=utf-8',
    );
    $config = decode_json($page->{'content'});
}

# Test all endpoints with the X-Thruk-Output-Metadata-Only header
for my $url (@{$list_pages}) {
    SKIP: {
        skip "skipped, logcache is disabled ", 8 if ($url =~ m/logcache/mx && !$config->{'logcache'});

        if($url =~ m/logs/mx) {
            $url = $url.'?limit=100';
        }

        my $page = TestUtils::test_page(
            'url'          => '/thruk/r'.$url,
            'content_type' => 'application/json; charset=utf-8',
            'headers'      => { 'X-Thruk-Output-Metadata-Only' => 'true' }
        );
        my $data = decode_json($page->{'content'});
        is(ref $data, 'ARRAY', "json result is an array: ".$url);
    };
}

for my $url (@{$hash_pages}) {
    my $page = TestUtils::test_page(
        'url'          => '/thruk/r'.$url,
        'content_type' => 'application/json; charset=utf-8',
        'headers'      => { 'X-Thruk-Output-Metadata-Only' => 'true' }
    );
    my $data = decode_json($page->{'content'});
    is(ref $data, 'HASH', "json result is a hash: ".$url);
}

################################################################################
my $content = Thruk::Utils::IO::read(__FILE__);
my($paths, $keys, $docs) = Thruk::Controller::rest_v1::get_rest_paths();
for my $p (sort keys %{$paths}) {
    if($paths->{$p}->{'GET'}) {
        next if $p =~ m%<%mx;
        next if $p =~ m%heartbeat%mx;
        next if $p =~ m%/editor%mx;
        next if $p =~ m%/nc/%mx;
        next if $p =~ m%/node-control/%mx;
        if($content !~ m%$p%mx) {
            fail("missing test case for ".$p);
        }
    }
}
