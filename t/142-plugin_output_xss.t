use warnings;
use strict;
use File::Spec;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok('Thruk::Utils::Filter');
use_ok('Thruk::Utils::Trends');
use_ok('Thruk::Views::ToolkitRenderer');

my $c = TestUtils::get_c();

############################################################
# reports2 SLA outage templates: plugin output must be html-escaped
# (stored XSS via unescaped log_line_plugin_output rendered into
# the <div class="output"> sink; separate findings from GHSA-7qph-3mcp-cvqw)
my @sla = (
    'plugins/plugins-available/reports2/templates/reports/comp/sla_outage_details.tt',
    'plugins/plugins-available/reports2/templates/reports/comp/sla_outages_latest.tt',
    'plugins/plugins-available/reports2/templates/reports/comp/sla_outages_worst.tt',
    'plugins/plugins-available/reports2/templates/reports/sla_host_outage.tt',
    'plugins/plugins-available/reports2/templates/reports/sla_service_outage.tt',
);
for my $f (@sla) {
    my $content = do { local $/; open(my $fh, '<', $f) or die; <$fh> };
    unlike($content, qr{<div class="output">\[\%\s*log_line_plugin_output\([^%]*%\]</div>}m,
        "$f does not render log_line_plugin_output unescaped");
    like($content, qr{<div class="output">\[\%\s*escape_html\(log_line_plugin_output\([^%]*\)\s*%\]</div>}m,
        "$f escapes log_line_plugin_output in the output div");
}

############################################################
# trends: plugin output reaches a client-side innerHTML sink
# (trends_report.tt). It must be html-escaped when stored in the image_map so the
# default (escape_html_tags) branch renders it as text.
my $trends_pm = File::Spec->rel2abs('lib/Thruk/Utils/Trends.pm');
my $trends    = do { local $/; open(my $fh, '<', $trends_pm) or die; <$fh> };
unlike($trends, qr/"plugin_output"\s*=>\s*Thruk::Utils::Filter::log_line_plugin_output\(\)\s*,/m,
    'trends plugin_output is not stored raw in the image_map');
like($trends, qr/"plugin_output"\s*=>\s*Thruk::Utils::Filter::escape_html\(/m,
    'trends plugin_output is stored html-escaped in the image_map');
like($trends, qr/"real_plugin_output"\s*=>\s*Thruk::Utils::Filter::escape_html\(/m,
    'trends real_plugin_output is stored html-escaped in the image_map');

############################################################
# render the trends detail snippet and verify the default branch
# shows escaped text and the opt-out branch restores html
my $payload   = '<svg/onload=window.__avail_outage_probe=1>';
my $escaped   = Thruk::Utils::Filter::escape_html($payload);
my $image_map = [ { plugin_output => $escaped, real_plugin_output => $escaped } ];

my $snippet = q{
    function html_entity_decode(str) {
      var ta=document.createElement("textarea");
      ta.innerHTML=str.replace('<',"&lt;").replace('>',"&gt;");
      return ta.value;
    }
    var details = [% json_encode(image_map) %];
    function showDetail() {
      var out = '';
      if(details[0].plugin_output != details[0].real_plugin_output) {
        [% IF escape_html_tags %]
          out = details[0].plugin_output + "<br><i>original output was:<\/i><br>" + details[0].real_plugin_output;
        [% ELSE %]
          out = html_entity_decode(details[0].plugin_output) + "<br><i>original output was:<\/i><br>" + html_entity_decode(details[0].real_plugin_output);
        [% END %]
      } else {
        [% IF escape_html_tags %]
          out = details[0].plugin_output;
        [% ELSE %]
          out = html_entity_decode(details[0].plugin_output);
        [% END %]
      }
      document.getElementById('detail_plugin_output').innerHTML = out;
    }
};
my $render = sub {
    my $stash = shift;
    my $html  = '';
    Thruk::Views::ToolkitRenderer::render($c, \$snippet, $stash, \$html);
    return $html;
};

subtest 'trends detail innerHTML escapes plugin output by default' => sub {
    my $stash = { %{$c->stash}, escape_html_tags => 1, image_map => $image_map };
    my $html  = $render->($stash);
    like($html, qr/\Q$escaped\E/, 'escaped payload present in the default branch');
    unlike($html, qr/<svg\/onload=window\.__avail_outage_probe=1>/, 'no active svg in the rendered script');

    # opt-out: html_entity_decode restores the (now escaped) value back to html
    my $stash2 = { %{$c->stash}, escape_html_tags => 0, image_map => $image_map };
    my $html2  = $render->($stash2);
    like($html2, qr/html_entity_decode\(details\[0\]\.plugin_output\)/, 'opt-out decodes the escaped value');
};
done_testing();
