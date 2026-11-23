function test_shared_label_rendering() {
    var panel = {
        id: 'label_test',
        el: { dom: {} },
        host: { name: '<test>', state: 0, acknowledged: 1, last_check: 100000, private_field: 'hidden' },
        xdata: {}
    };
    var render = function(label) {
        var warnings = TP.labelWarnings(panel, 'label');
        var html = TP.IconLabel.prototype.setIconLabelDynamicText.call(panel, label, warnings);
        warnings.finish();
        return html;
    };
    var cases = [
        ['Healthy', 'Healthy'],
        ['<b>{{name}}</b><br>', '<b>&lt;test&gt;</b><br>'],
        ['<b title=x>label</b>', '<b title="x">label</b>'],
        ['<img border=1 width="50%" height=16 hspace=2 vspace=3 align=middle onload="unused">',
         '<img border="1" width="50%" height="16" hspace="2" vspace="3" align="middle">'],
        ['<p align=right border=1><font color=red face=serif size=3>Alert</font><br clear=all></p>',
         '<p align="right"><font color="red" face="serif" size="3">Alert</font><br clear="all"></p>'],
        ['<span class="site-label warning" onclick="unused">label</span>', '<span class="site-label warning">label</span>'],
        ['<img src="../plugins/panorama/images/server.png" alt="Server">',
         '<img alt="Server" src="'+new URL('../plugins/panorama/images/server.png', document.baseURI).href+'">'],
        ['<img src="https://example.invalid/icon.png" alt="Remote">', '<img alt="Remote">'],
        ['<img src="/other/icon.PNG?v=2#main">', '<img src="'+window.location.origin+'/other/icon.PNG?v=2#main">'],
        ['<img src="'+window.location.origin+'/icon.webp">', '<img src="'+window.location.origin+'/icon.webp">'],
        ['<img src="//example.invalid/image.svg">', '<img>'],
        ['<img src="/download?name=icon.png">', '<img>'],
        ['<span style="color: {{state == 0 ? \'green\' : \'red\'}}; position: fixed" onclick="unused">{{name}}</span>',
         '<span style="color: green;">&lt;test&gt;</span>'],
        ['{{private_field}}{{window}}{{TP}}', ''],
        ['<style>b{color:red}</style><b>label</b>', '<b>label</b>'],
        ['{{sprintf("%02d", acknowledged + 1)}}', '02'],
        ['{{strftime("%Y", last_check)}}', '1970'],
        ['{{if(acknowledged) {"yes"} else {"no"}}}', 'yes'],
        ['{{nl2br("a\\nb")}}', 'a<br>b'],
        ["{{panel['constructor']}}", ''],
        ['{{name.toString()}}', ''],
        ['{{toString()}}', ''],
        ['{{constructor}}', '']
    ];
    TP.availabilities = TP.availabilities || {};
    var opts = {d: '24h'};
    var cached = {};
    cached[Ext.JSON.encode(opts)] = {last: 99.5, last_refresh: Date.now()/1000};
    TP.availabilities[panel.id] = cached;
    cases.push(['{{sprintf("%.2f", availability({d: "24h"}))}}', '99.50']);
    try {
        var result = document.createElement('div');
        var image = "url('/assets/pattern.png?v=2')";
        result.innerHTML = render('<span style="background-image: '+image+'">label</span>');
        if(result.firstChild.style.backgroundImage != 'url("'+window.location.origin+'/assets/pattern.png?v=2")') { throw Error('missing label background'); }
        result.innerHTML = render('<span style="background-image: '+image+', url(https://example.invalid/icon.png)">label</span>');
        if(result.firstChild.style.backgroundImage) { throw Error('unexpected layered background'); }
        result.innerHTML = render('<span style="border: 1px solid red; border-image-source: url(icon.png)">label</span>');
        var style = result.firstChild.style;
        if(style.borderTop != '1px solid red' || /url/i.test(style.borderImageSource)) { throw Error('invalid label border'); }
        cases.forEach(function(c) {
            var actual = render(c[0]);
            if(actual !== c[1]) { throw Error(c[0]+': expected '+c[1]+', got '+actual); }
        });
        var originalWarn = console.warn;
        var logs = [];
        try {
            console.warn = function(message) { logs.push(message); };
            var bad = '<aside></aside><b data-other="secret" style="position: fixed">{{unknownField}}{{unknownFn()}}</b>';
            render(bad);
            render(bad);
            if(logs.length != 1 || logs[0].indexOf('secret') >= 0) { throw Error('invalid label warning log'); }
            ['aside', 'data-other', 'position', 'unknownField', 'unknownFn'].forEach(function(name) {
                if(panel.labelWarning.indexOf(name) < 0) { throw Error('missing warning for '+name); }
            });
            render('Healthy');
            if(panel.labelWarning || logs.length != 1) { throw Error('label warning did not clear'); }
        } finally {
            console.warn = originalWarn;
        }
    } finally {
        delete TP.availabilities[panel.id];
    }
    return 1;
}

function test_get_group_status_unknown() {
    var group = {"hosts":{"ack_down":0,"ack_unreachable":0,
                          "down":0, "pending":0, "unreachable":0,"up":0,
                          "downtime_down":0,"downtime_unreachable":0,"downtime_up":0,
                          "plain_down":0,"plain_pending":0,"plain_unreachable":0,"plain_up":0},
                 "services":{"ack_critical":0,"ack_unknown":0,"ack_warning":0,
                             "critical":1, "unknown":1,"warning":1, "ok":1,"pending":1,
                             "downtime_critical":0,"downtime_ok":0,"downtime_unknown":0,"downtime_warning":0,
                             "plain_critical":1,"plain_ok":1,"plain_pending":1,"plain_unknown":1,"plain_warning":1
                            }};

    var res = TP.get_group_status({
        group:          group,
        incl_ack:       false,
        incl_downtimes: false,
        incl_svc:       true,
        incl_hst:       false
    });
    //diag(Ext.JSON.encode(res));
    if(res.state != 3) {
        throw Error("res state failed: expected 3 got "+res.state);
    }
    if(res.acknowledged != false) {
        throw Error("res acknowledged failed: expected false got "+res.acknowledged);
    }
    if(res.downtime != false) {
        throw Error("res downtime failed: expected false got "+res.downtime);
    }
    if(res.hostProblem != false) {
        throw Error("res hostProblem failed: expected false got "+res.hostProblem);
    }
    return 1;
}

function test_get_group_status_critical() {
    var group = {"hosts":{"ack_down":0,"ack_unreachable":0,
                          "down":0, "pending":0, "unreachable":0,"up":0,
                          "downtime_down":0,"downtime_unreachable":0,"downtime_up":0,
                          "plain_down":0,"plain_pending":0,"plain_unreachable":0,"plain_up":0},
                 "services":{"ack_critical":0,"ack_unknown":0,"ack_warning":0,
                             "critical":1, "unknown":1,"warning":1, "ok":1,"pending":1,
                             "downtime_critical":0,"downtime_ok":0,"downtime_unknown":1,"downtime_warning":0,
                             "plain_critical":1,"plain_ok":1,"plain_pending":1,"plain_unknown":0,"plain_warning":1
                            }};

    var res = TP.get_group_status({
        group:          group,
        incl_ack:       false,
        incl_downtimes: false,
        incl_svc:       true,
        incl_hst:       false
    });
    //diag(Ext.JSON.encode(res));
    if(res.state != 2) {
        throw Error("res state failed: expected 2 got "+res.state);
    }
    if(res.acknowledged != false) {
        throw Error("res acknowledged failed: expected false got "+res.acknowledged);
    }
    if(res.downtime != false) {
        throw Error("res downtime failed: expected false got "+res.downtime);
    }
    if(res.hostProblem != false) {
        throw Error("res hostProblem failed: expected false got "+res.hostProblem);
    }
    return 1;
}

function test_get_group_status_unknown_downtime() {
    var group = {"hosts":{"ack_down":0,"ack_unreachable":0,
                          "down":0, "pending":0, "unreachable":0,"up":0,
                          "downtime_down":0,"downtime_unreachable":0,"downtime_up":0,
                          "plain_down":0,"plain_pending":0,"plain_unreachable":0,"plain_up":0},
                 "services":{"ack_critical":0,"ack_unknown":0,"ack_warning":0,
                             "critical":0, "unknown":1,"warning":0, "ok":1,"pending":0,
                             "downtime_critical":0,"downtime_ok":0,"downtime_unknown":1,"downtime_warning":0,
                             "plain_critical":0,"plain_ok":1,"plain_pending":0,"plain_unknown":0,"plain_warning":0
                            }};

    var res = TP.get_group_status({
        group:          group,
        incl_ack:       false,
        incl_downtimes: false,
        incl_svc:       true,
        incl_hst:       false
    });
    //diag(Ext.JSON.encode(res));
    if(res.state != 3) {
        throw Error("res state failed: expected 3 got "+res.state);
    }
    if(res.acknowledged != false) {
        throw Error("res acknowledged failed: expected false got "+res.acknowledged);
    }
    if(res.downtime != true) {
        throw Error("res downtime failed: expected true got "+res.downtime);
    }
    if(res.hostProblem != false) {
        throw Error("res hostProblem failed: expected false got "+res.hostProblem);
    }
    return 1;
}

function test_get_group_status_unknown_incl_downtime() {
    var group = {"hosts":{"ack_down":0,"ack_unreachable":0,
                          "down":0, "pending":0, "unreachable":0,"up":0,
                          "downtime_down":0,"downtime_unreachable":0,"downtime_up":0,
                          "plain_down":0,"plain_pending":0,"plain_unreachable":0,"plain_up":0},
                 "services":{"ack_critical":0,"ack_unknown":0,"ack_warning":0,
                             "critical":0, "unknown":1,"warning":0, "ok":1,"pending":0,
                             "downtime_critical":0,"downtime_ok":0,"downtime_unknown":1,"downtime_warning":0,
                             "plain_critical":0,"plain_ok":1,"plain_pending":0,"plain_unknown":0,"plain_warning":0
                            }};

    var res = TP.get_group_status({
        group:          group,
        incl_ack:       false,
        incl_downtimes: true,
        incl_svc:       true,
        incl_hst:       false
    });
    //diag(Ext.JSON.encode(res));
    if(res.state != 3) {
        throw Error("res state failed: expected 3 got "+res.state);
    }
    if(res.acknowledged != false) {
        throw Error("res acknowledged failed: expected false got "+res.acknowledged);
    }
    if(res.downtime != false) {
        throw Error("res downtime failed: expected true got "+res.downtime);
    }
    if(res.hostProblem != false) {
        throw Error("res hostProblem failed: expected false got "+res.hostProblem);
    }
    return 1;
}

function test_timeframe2seconds() {
    var val;
    val = TP.timeframe2seconds('24h');
    if(val != 86400) {
        throw Error("timeframe2seconds expected 86400: got "+val);
    }
    val = TP.timeframe2seconds('12345');
    if(val != 12345) {
        throw Error("timeframe2seconds expected 12345: got "+val);
    }
    val = TP.timeframe2seconds('3m');
    if(val != 180) {
        throw Error("timeframe2seconds expected 180: got "+val);
    }

    // not parsed, fallback to 1hour
    val = TP.timeframe2seconds('3abc');
    if(val != 3600) {
        throw Error("timeframe2seconds expected 3600: got "+val);
    }
    return 1;
}
