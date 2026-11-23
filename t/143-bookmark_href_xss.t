use warnings;
use strict;
use Test::More;

use Thruk::Request ();

use_ok('Thruk::Utils::Filter');
use_ok('Thruk::Controller::status');
use_ok('Thruk::Context');
use_ok('Thruk::Controller::user');

subtest 'setcookie redirects stay local' => sub {
    my $req = Thruk::Request->new({ QUERY_STRING => 'setcookie', SERVER_NAME => 'localhost', 'psgi.url_scheme' => 'http' });
    my $c = bless { req => $req, stash => { url_prefix => '/thruk/' } }, 'Thruk::Context';
    no warnings qw/redefine once/;
    local *Thruk::Context::redirect_to = sub { return $_[1]; };
    $req->parameters({ referer => '//example.invalid/' });
    is(Thruk::Controller::user::index($c), '/thruk/', 'external target falls back');
    $req->parameters({ referer => '/thruk/status.cgi', style => 'grid' });
    is(Thruk::Controller::user::index($c), '/thruk/status.cgi?style=grid', 'local target keeps query parameters');
};

subtest 'bookmark changes use the shared CSRF policy' => sub {
    local $ENV{'THRUK_MODE'} = 'FASTCGI';
    my $req = Thruk::Request->new({ REQUEST_METHOD => 'GET', REMOTE_ADDR => '192.0.2.1' });
    my $c = bless { req => $req, env => $req->env, config => { csrf_allowed_hosts => [] }, stash => {}, session => { private_key => 'dummy', csrf_token => 'test-token' } }, 'Thruk::Context';
    no warnings qw/redefine once/;
    local *Thruk::Context::detach = sub { return; };
    local *Thruk::Context::error = sub { return; };
    local *Thruk::Utils::get_user_data = sub { return {}; };
    my $saved;
    local *Thruk::Utils::store_user_data = sub { $saved = $_[1]; return 1; };
    local *Thruk::Utils::set_message = sub { return; };
    local *Thruk::Context::redirect_to = sub { return $_[1]; };

    my %form = (addb => 'add bookmark', newname => 'Hosts', section => 'Views', bookmark => 'status.cgi');
    $req->parameters({ %form, CSRFtoken => 'test-token' });
    ok(!Thruk::Controller::status::_process_bookmarks($c), 'reject GET even with a token');
    $req->env->{'REQUEST_METHOD'} = 'POST';
    $req->parameters({ %form });
    ok(!Thruk::Controller::status::_process_bookmarks($c), 'reject POST without a token');
    $req->parameters({ %form, CSRFtoken => 'wrong' });
    ok(!Thruk::Controller::status::_process_bookmarks($c), 'reject incorrect token');
    ok(!defined $saved, 'rejected requests did not write user data');
    $req->parameters({ %form, CSRFtoken => 'test-token' });
    Thruk::Controller::status::_process_bookmarks($c);
    is($saved->{'bookmarks'}->{'Views'}->[0]->[0], 'Hosts', 'valid POST saves the bookmark');
    {
        local $c->config->{'csrf_allowed_hosts'} = ['192.0.2.1'];
        $req->parameters({ %form, newname => 'Trusted' });
        Thruk::Controller::status::_process_bookmarks($c);
        is($saved->{'bookmarks'}->{'Views'}->[0]->[0], 'Trusted', 'configured trusted host can save without a token');
    }
    for my $target ('//example.invalid/', '/\\example.invalid/', 'https:/example.invalid/', "/page\n", 'status.cgi?style=grid', '/site/thruk/') {
        $req->parameters({ CSRFtoken => 'test-token', referer => $target });
        my $expected = $target =~ /^(?:status\.cgi|\/site\/)/ ? $target : 'status.cgi';
        is(Thruk::Controller::status::_process_bookmarks($c), $expected, "bookmark redirect: $target");
    }
};

############################################################
# unit: is_safe_bookmark_url rejects executable schemes,
# allows relative and http(s) urls (GHSA-w5pf-vr4p-h335)
my %cases = (
    'javascript:alert(1)'                       => 0,
    'JAVASCRIPT:alert(1)'                       => 0,
    "  javascript:alert(1)"                     => 0,
    "\x09javascript:alert(1)"                   => 0,
    'data:text/html,<script>alert(1)</script>'  => 0,
    'vbscript:msgbox(1)'                        => 0,
    'file:///etc/passwd'                        => 0,
    '/thruk/cgi-bin/status.cgi?style=overview'  => 1,
    'https://example.com/a?b=1'                 => 1,
    'http://example.com'                        => 1,
    '#anchor'                                   => 1,
);
for my $u (sort keys %cases) {
    is(Thruk::Utils::Filter::is_safe_bookmark_url($u), $cases{$u},
        "is_safe_bookmark_url('$u')");
}

############################################################
# regression: status.pm must validate the bookmark url before storing it,
# otherwise a stored javascript: url reaches side.tt's href as stored xss
my $status_pm = do { local $/; open(my $fh, '<', 'lib/Thruk/Controller/status.pm') or die; <$fh> };
my($process) = $status_pm =~ /# store bookmarks and redirect to last page\nsub _process_bookmarks \{(.*?)\n\n\n##########################################################/ms
    or die "cannot extract _process_bookmarks";
like($process, qr/and Thruk::Utils::Filter::is_safe_bookmark_url\(\$bookmark\)/,
    '_process_bookmarks validates the bookmark url before storing it');

############################################################
# regression: side.tt must keep html-escaping the bookmark href
my $side_tt = do { local $/; open(my $fh, '<', 'templates/side.tt') or die; <$fh> };
like($side_tt, qr{href="\[\% escape_html\(link\.href\) %\]"},
    'side.tt html-escapes the link href');
like($side_tt, qr{href="\[\% escape_html\(sublink\.href\) %\]"},
    'side.tt html-escapes the sublink href');

done_testing();
