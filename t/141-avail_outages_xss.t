use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok('Thruk::Utils::Filter');
use_ok('Thruk::Views::ToolkitRenderer');

my $c = TestUtils::get_c();

# the outage table is the sink of interest, so extract it from the shipped
# template and render exactly that fragment (stored XSS, GHSA-7qph-3mcp-cvqw)
my $file   = 'templates/avail_outages.tt';
my $content = do { local $/; open(my $fh, '<', $file) or die; <$fh> };

unlike($content, qr{^\s*<td class="truncate max-w-\[600px\]">\[\%\s*log_line_plugin_output\(l\)\s*%\]</td>\s*$}m,
    'plugin output cell is not rendered unescaped');
like($content, qr{<td class="truncate max-w-\[600px\]">\[\% IF escape_html_tags %\]\[\% escape_html\(log_line_plugin_output\(l\)\) %\]}m,
    'plugin output cell is html-escaped when escape_html_tags is set');

my ($table) = $content =~ m/(<table class="body cellspacing-x striped">.*?<\/table>)/s;
ok($table, 'extracted outage table from template');

$table = '[% USE date %]' . $table; # the table references date.now for ongoing outages

my $payload     = '<svg/onload=window.__avail_outage_probe=1>';
my $escaped     = Thruk::Utils::Filter::escape_html($payload);
my $benign      = 'BENIGN-AVAIL-CONTROL & "quotes" <b>';
my $escaped_ben = Thruk::Utils::Filter::escape_html($benign);

my $stash = {
    %{$c->stash},
    page            => 'avail',
    real_page       => 'avail',
    title           => 'Availability',
    minimal         => 3,
    show_nav        => 0,
    host            => 'host1',
    service         => 'svc1',
    start           => 1234567800,
    end             => 1234568000,
    type            => 'services',
    show_log_entries    => 0,
    rpttimeperiod       => '',
    has_lex_filter      => 0,
    has_error           => 0,
    searches            => { dfl_ => [] },
    outages           => [
        {
            host            => 'host1',
            service         => 'svc1',
            start           => 1234567810,
            end             => 1234567830,
            type            => 'outage',
            class           => 'bad',
            plugin_output   => $payload,
        },
        {
            host            => 'host1',
            service         => 'svc2',
            start           => 1234567900,
            end             => '',
            type            => 'outage',
            class           => 'bad',
            duration        => 100,
            plugin_output   => $benign,
        },
    ],
};

subtest 'availability outage table html-escapes plugin output' => sub {
    my $render = sub {
        my $stash = shift;
        my $html  = '';
        Thruk::Views::ToolkitRenderer::render($c, \$table, $stash, \$html);
        return $html;
    };
    my $html = $render->($stash);
    my @cells = $html =~ m{<td class="truncate max-w-\[600px\]">(.*?)</td>}gs;
    is(scalar(@cells), 2, 'both outage rows rendered');
    is($cells[0], $escaped, 'svg payload escaped in first outage row');
    unlike($html, qr/<svg\/onload=window\.__avail_outage_probe=1>/, 'no active svg payload rendered');
    is($cells[1], $escaped_ben, 'ampersands, quotes and tags escaped in benign row');
    unlike($cells[1] // '', qr/"quotes"<b>|&quot;quotes&quot;<b>/, 'no raw tags rendered in benign row');

    # AddDefaults sets escape_html_tags from config, defaulting to on
    ok((($c->config->{'escape_html_tags'} // 1)), 'escape_html_tags defaults to on');

    # opt-out: trusted setups can render html, like the other avail tables
    my $html2 = $render->({ %$stash, escape_html_tags => 0 });
    is(() = $html2 =~ /\Q$payload\E/g, 1, 'opt-out renders raw plugin output');
};
done_testing();
