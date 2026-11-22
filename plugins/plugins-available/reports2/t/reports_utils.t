use warnings;
use strict;
use Test::More;

use Thruk::Utils::Reports::Render ();

BEGIN {
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
    plan tests => 37;
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok("Thruk::Utils::Reports::Render");
TestUtils::get_c();

###########################################################
# _replace_link
my($baseurl,$a,$b,$url,$d,$e) = ('http://test.local/thruk/cgi-bin/', '', '',  '', '', '');

$url = '#';
is(Thruk::Utils::Reports::Render::_replace_link($baseurl,$a,$b,$url,$d,$e), "#", "_replace_link($url)");

$url = 'avail.cgi';
is(Thruk::Utils::Reports::Render::_replace_link($baseurl,$a,$b,$url,$d,$e), "http://test.local/thruk/cgi-bin/avail.cgi", "_replace_link($url)");

$url = '/index.html';
is(Thruk::Utils::Reports::Render::_replace_link($baseurl,$a,$b,$url,$d,$e), "http://test.local/index.html", "_replace_link($url)");


###########################################################
# page_splice
my $data  = [0..33];
my $paged = Thruk::Utils::Reports::Render::page_splice($data, 7, 3);
is(scalar @{$paged}, 3, "page_splice() pages size");
is(scalar @{$paged->[0]}, 7, "page_splice() slice size");

$paged = Thruk::Utils::Reports::Render::page_splice($data, 7, 20);
is(scalar @{$paged}, 5, "page_splice() pages size");
is(scalar @{$paged->[0]}, 7, "page_splice() slice size");
is(scalar @{$paged->[4]}, 6, "page_splice() slice size");

###########################################################
# _absolutize_url
my $urls = [
    [ 'http://test.com',                'test.html',            'http://test.com/test.html' ],
    [ 'http://test.com/',               'test.html',            'http://test.com/test.html' ],
    [ '',                               '/thruk/test.html',     '/thruk/test.html' ],
    [ 'http://test.com/blah/',          '../test.html',         'http://test.com/test.html' ],
    [ 'http://test.com/blah/',          '/test.html',           'http://test.com/test.html' ],
    [ 'http://test.com/css/style.css',  '../images/test.png',   'http://test.com/images/test.png' ],
    [ 'http://test.com/css/style.css',  '/test.png',            'http://test.com/test.png' ],
    [ 'http://test.com',                'http://test2.com/',    'http://test2.com/' ],
];
for my $url (@{$urls}) {
    is(Thruk::Utils::Reports::Render::_absolutize_url($url->[0], $url->[1]), $url->[2], '_absolutize_url('.($url->[0]||'').', '.$url->[1].') -> '.$url->[2]);
}

###########################################################
# _check_report_url
{
    my $c = TestUtils::get_c();
    local $c->{config}->{omd_local_site_url}     = 'http://127.0.0.1:8388/omd';
    local $c->{config}->{report_allow_url_hosts} = ['example.com'];

    # allowed urls
    for my $url (
        '/thruk/cgi-bin/status.cgi',            # relative thruk url
        'status.cgi?style=hostdetail',          # relative cgi url
        'http://127.0.0.1:8388/omd/status.cgi', # omd_local_site_url host
        'http://example.com/status.cgi',        # in report_allow_url_hosts
        'http://sub.example.com/status.cgi',    # subdomain of allowed host
    ) {
        ok(defined eval { Thruk::Utils::Reports::Render::_check_report_url($c, $url); 1 }, "_check_report_url('$url') allowed");
    }

    # disallowed urls (ssrf targets)
    for my $url (
        'http://127.0.0.1:8080/internal-secret',  # omd host, wrong port
        'http://localhost/internal-secret',
        'http://0.0.0.0/',
        'http://10.0.0.1/',
        'http://172.16.0.1/',
        'http://192.168.1.1/',
        'http://169.254.169.254/latest/meta-data/',
        'http://100.64.0.1/',
        'http://[::1]/',
        'http://[fd12::1]/',
        'http://[fe80::1]/',
        'http://[2001:db8::1]/',
        'http://evil.com/',                     # not in allowlist
        'http://example.evil.com/',             # lookalike suffix
        'ftp://example.com/',                   # unsupported scheme
    ) {
        my $err;
        eval { Thruk::Utils::Reports::Render::_check_report_url($c, $url) };
        $err = $@;
        ok($err, "_check_report_url('$url') rejected: $err");
    }
}
