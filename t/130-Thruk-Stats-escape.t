#!/usr/bin/env perl

# Regression test for GHSA-ww3m-8p89-562g: profile labels (row name, title,
# debug hint) reach the generated profile HTML (p.html) which is rendered
# raw in templates/_profiles.tt. They must be HTML-escaped at the sink.

use warnings;
use strict;
use Test::More;

use Thruk::Base ();
use Thruk::Stats ();

my $url = 'https://attacker.test/p?x=<svg/onload=PROFILE_MARKER>&y=1" onmouseover=alert(1)>';

# profile name derived from an external request URL (report_from_url flow)
my $name = sprintf('_external_request(%s, %s)', 'GET', Thruk::Base::url_clean_credentials($url));
my $stats = Thruk::Stats->new;
$stats->enable;
$stats->profile(begin => $name);
$stats->profile(end   => $name);
my $html = $stats->report_html();
unlike($html, qr{<svg/onload=PROFILE_MARKER>}, "profile name is not emitted as raw markup");
unlike($html, qr{PROFILE_MARKER&y=1"},            "no attribute breakout via profile name");
like($html,   qr{&lt;svg/onload=PROFILE_MARKER&gt;}, "profile name is escaped as text");

# debug_hint / debug_hint_title (set from the request URI in UserAgent.pm)
my $stats2 = Thruk::Stats->new;
$stats2->enable;
$stats2->profile(begin => 'http GET', debug_hint => $url, debug_hint_title => $url);
$stats2->profile(end   => 'http GET', debug_hint => $url, debug_hint_title => $url);
my $html2 = $stats2->report_html();
unlike($html2, qr{<svg/onload=PROFILE_MARKER>}, "debug hints are not emitted as raw markup");
like($html2,   qr{&lt;svg/onload=PROFILE_MARKER&gt;}, "debug hints are escaped as text");

# benign control stays unchanged
my $stats3 = Thruk::Stats->new;
$stats3->enable;
my $benign = '_external_request(GET, https://attacker.test/health)';
$stats3->profile(begin => $benign);
$stats3->profile(end   => $benign);
my $html3 = $stats3->report_html();
like($html3,   qr{<div class="flexrow gap-x-1 justify-between">\Q$benign\E</div>}, "benign profile row unchanged");
unlike($html3, qr{&amp;|&lt;}, "benign profile row not over-escaped");

done_testing();
