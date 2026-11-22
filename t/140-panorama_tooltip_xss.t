use warnings;
use strict;
use File::Spec;
use Test::More;

my $js = File::Spec->rel2abs('plugins/plugins-available/panorama/root/js/panorama_js_panlet_icon_tooltip.js');
ok(-f $js, 'panorama tooltip js found');

# regression check: raw backend values must not be concatenated into the
# tooltip HTML (stored XSS, GHSA-j445-m9r7-q45g)
my $content = do { local $/; open(my $fh, '<', $js) or die; <$fh> };
unlike($content, qr/\+d\['description'\]\+/, 'description is not concatenated raw into tooltip html');
unlike($content, qr/\+d\[prefix\+'name'\]\+/, 'host name is not concatenated raw into tooltip html');
unlike($content, qr/\+d\['host_name'\]\+/, 'service host_name is not concatenated raw into tooltip html');
like($content, qr/Ext\.String\.htmlEncode/, 'tooltip renderer html-encodes backend values');

my $has_node = system('node --version > /dev/null 2>&1') == 0;

my $jscode = <<'JS';
const fs   = require('fs');
const vm   = require('vm');
const path = require('path');

const content = fs.readFileSync(process.argv[2], 'utf8');
const start = content.indexOf('TP.renderTipDetails = function(');
const end   = content.indexOf('TP.isInside = function', start);
if (start < 0 || end < 0) { console.error('cannot extract renderTipDetails'); process.exit(2); }
const fn = content.substring(start, end);

function encode(v) {
    return String(v)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}
// JSON roundtrip makes plain objects context-appropriate for vm
function contextify(o) { return JSON.parse(JSON.stringify(o)); }

function setup(data, inclHst, inclSvc) {
    const updated = [];
    const sandbox = {
        Ext: { String: { htmlEncode: encode } },
        TP: {
            iconTip: {
                panel: {
                    iconType: 'servicegroup',
                    xdata: { general: { incl_hst: inclHst, incl_svc: inclSvc }, state: 1 },
                },
                detailsTarget: { update: (h) => updated.push(h), doLayout: () => {} },
                getSize: () => ({ width: 1, height: 1 }),
                showAt: () => {},
                syncShadow: () => {},
            },
            iconSettingsWindow: undefined,
            getNextToPanelPos: () => [0, 0],
            create_host_object_from_service: (d) => d,
            render_host_icons: () => '',
            render_host_status: () => 'UP',
            render_service_icons: () => '',
            render_service_status: () => 'OK',
            getIconDetailsLink: () => '#',
        },
    };
    vm.createContext(sandbox);
    vm.runInContext(fn, sandbox, { filename: 'extracted-renderTipDetails.js' });
    sandbox.TP.renderTipDetails(contextify(data));
    return updated.join('');
}

const out = {};
out.service = setup(
    [{ host_name: "host'><script>alert(1)<\/script>", description: "<img src=x onerror=alert(1)>", plugin_output: "<b>ok</b>" }],
    true, true);
out.host = setup([{ name: "host\"><script>alert(1)<\/script>", state: 0, plugin_output: "<b>ok</b>" }], true, false);

const checks = [
    ['service: description escaped',      out.service.includes('&lt;img src=x onerror=alert(1)&gt;')],
    ['service: no raw img tag',           !out.service.includes('<img src=x')],
    ['service: host_name escaped',        out.service.includes('host&#39;&gt;&lt;script&gt;')],
    ['service: no raw script tag',        !out.service.includes('<script>')],
    ['service: plugin_output stays HTML', out.service.includes('<b>ok</b>')],
    ['host: name escaped',                out.host.includes('host&quot;&gt;&lt;script&gt;')],
    ['host: no raw script tag',           !out.host.includes('<script>')],
    ['host: plugin_output stays HTML',    out.host.includes('<b>ok</b>')],
];
for (const [name, ok] of checks) {
    console.log((ok ? 'PASS' : 'FAIL') + ' ' + name);
    if (!ok) {
        console.log('--- rendered service html ---');
        console.log(out.service);
        console.log('--- rendered host html ---');
        console.log(out.host);
        process.exit(1);
    }
}
JS

SKIP: {
    skip('node not available', 1) unless $has_node;
    my $jsfile = File::Spec->catfile('/tmp', 'thruk-panorama-tooltip-probe-' . $$ . '.js');
    open(my $out, '>', $jsfile) or die $!;
    print $out $jscode;
    close $out;
    my $res = `node $jsfile "$js" 2>&1`;
    unlink $jsfile;
    my @pass = $res =~ m/^PASS \S+/mgm;
    my @fail = $res =~ m/^FAIL \S+/mgm;
    ok(scalar @pass == 8 && !@fail, 'renderTipDetails encodes host/service names and descriptions');
    diag("node probe failed:\n$res") if @fail;
}

done_testing();
