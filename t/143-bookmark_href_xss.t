use warnings;
use strict;
use Test::More;

use_ok('Thruk::Utils::Filter');
use_ok('Thruk::Controller::status');

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
