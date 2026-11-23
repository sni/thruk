TP.labelPolicy = {
    tags: ['b', 'i', 'u', 'strong', 'em', 'center', 'br', 'span', 'div', 'p', 'small', 'sub', 'sup', 'img', 'font'],
    presentation: {
        img:  ['border', 'width', 'height', 'hspace', 'vspace', 'align'],
        div:  ['align'],
        p:    ['align'],
        br:   ['clear'],
        font: ['color', 'face', 'size']
    },
    styles: ['color', 'background-color', 'background-image', 'font-size', 'font-weight', 'font-style', 'text-align', 'text-decoration',
             'border', 'border-top', 'border-right', 'border-bottom', 'border-left', 'border-width', 'border-style',
             'border-color', 'border-radius'],
    imageURL: function(src) {
        try {
            var url = new URL(src, document.baseURI);
            if(/^https?:$/.test(url.protocol) && url.origin == window.location.origin && /\.(?:png|gif|jpe?g|webp|svg)$/i.test(url.pathname)) {
                return url.href;
            }
        } catch(err) { /* Invalid URL. */ }
    },
    attributes: {
        title: function(node, el) { el.title = node.title; },
        alt: function(node, el) { if(el.localName == 'img') { el.alt = node.alt; } },
        src: function(node, el) {
            if(el.localName == 'img') {
                var src = TP.labelPolicy.imageURL(node.getAttribute('src'));
                if(src) { el.src = src; }
            }
        },
        'class': function(node, el) { el.className = node.className; },
        style: function(node, el) {
            TP.labelPolicy.styles.forEach(function(prop) {
                var value = node.style.getPropertyValue(prop);
                if(prop == 'background-image') {
                    var match = /^url\("([^"]+)"\)$/.exec(value);
                    var src = match && TP.labelPolicy.imageURL(match[1]);
                    if(!src) { return; }
                    value = 'url("'+CSS.escape(src)+'")';
                }
                if(value) { el.style.setProperty(prop, value); }
            });
        }
    },
    functions: {
        strftime: { run: function(args) { return strftime.apply(null, args); } },
        sprintf:  { run: function(args) { return sprintf.apply(null, args); } },
        nl2br:    { run: function(args) { return String(args[0]).replace(/\\n/g, '\n'); } },
        availability: {
            options: ['d', 'tm', 's', 'h', 'downtime'],
            run: function(args, panel) { return availability(panel, args[0]); }
        }
    },
    fields: ['name', 'alias', 'state', 'host_name', 'description', 'has_been_checked', 'scheduled_downtime_depth',
             'acknowledged', 'last_check', 'last_state_change', 'last_notification', 'plugin_output',
             'long_plugin_output', 'trend', 'perf_data']
};

Ext.define('TP.IconLabel', {
    /* queue label renderer */
    setIconLabel: function(cfg) {
        var panel = this;
        if(!panel.el || !panel.el.dom)  { return; }
        TP.reduceDelayEvents(panel, function() {
            panel.setIconLabelDo(cfg);
        }, 300, panel.id+'setIconLabel');
    },

    /* render label for this widget */
    setIconLabelDo: function(cfg) {
        var panel = this;
        if(!panel.el || !panel.el.dom)  { return; }
        if(cfg == undefined) {
            cfg = panel.xdata.label;
            if(TP.iconSettingsWindow && TP.iconSettingsWindow.panel.id == panel.id) {
                var xdata = TP.get_icon_form_xdata(TP.iconSettingsWindow);
                cfg       = xdata.label;
            }
        }
        if(TP.removeLabel && TP.removeLabel[panel.id]) {
            /* remove later to avoid flickering during redraw */
            window.clearTimeout(TP.timeouts['remove_label_'+panel.id]);
            TP.timeouts['remove_label_'+panel.id] = window.setTimeout(function() {
                TP.removeLabel[panel.id].destroy();
                delete TP.removeLabel[panel.id];
                panel.setIconLabel(cfg);
            }, 100);
        }
        if(cfg == undefined) { return; }

        panel.setIconLabelText(cfg);
        panel.setIconLabelPosition(cfg);
        return;
    },

    setIconLabelText: function(cfg) {
        var panel = this;
        var txt = String(cfg.labeltext);
        if(txt == undefined) { txt = ''; }
        panel.el.dom.title = '';

        /* hide the icon element for label only appearance */
        if(panel.locked && panel.el) {
            if(panel.xdata.appearance.type == "none") {
                panel.el.dom.style.display = "none";
            }
        }

        /* dynamic label? */
        if(txt.match(/\{\{.*?\}\}/)) {
            txt = panel.setIconLabelDynamicText(txt);

            /* update value since it might have changed */
            if(panel.xdata.appearance.type == 'speedometer' && panel.xdata.appearance.speedosource.match(/^avail:(.*)$/)) {
                panel.updateRender(panel.xdata);
            }
        } else {
            txt = TP.labelMarkup(txt);
        }
        /* no label at all */
        if(!cfg.labeltext) {
            if(panel.labelEl) { panel.labelEl.destroy(); panel.labelEl = undefined; }
            return;
        }
        if(!panel.labelEl) {
            panel.createLabelEl();
        }
        if(!panel.labelEl || !panel.labelEl.el) { return; }
        var el    = panel.labelEl.el.dom;
        var style = el.style;
        style.zIndex = Number(panel.el.dom.style.zIndex)+1; /* keep above icon */
        var oldTxt = panel.labelEl.el.dom.innerHTML;
        if(oldTxt != txt) {
            panel.labelEl.update(txt);
        }
        style.color        = cfg.fontcolor || '#000000';
        style.fontFamily   = cfg.fontfamily || 'inherit';
        style.background   = cfg.bgcolor;
        style.fontWeight   = cfg.fontbold   ? 'bold'   : 'normal';
        style.fontStyle    = cfg.fontitalic ? 'italic' : 'normal';
        style.textAlign    = cfg.fontcenter ? 'center' : 'unset';
        style.paddingLeft  = "3px";
        style.paddingRight = "3px";
        if(cfg.orientation == 'vertical') { panel.labelEl.addCls('vertical');    }
        else                              { panel.labelEl.removeCls('vertical'); }

        return;
    },

    setIconLabelDynamicText: function(txt) {
        var panel = this;
        if(TP.availabilities == undefined) { TP.availabilities = {}; }
        if(TP.availabilities[panel.id] == undefined) { TP.availabilities[panel.id] = {}; }
        var macros = TP.getPanelMacros(panel);
        txt = txt.replace(/\{\{(.*?)\}\}(?!\})/g, function(match, part) {
            try {
                TP.lastAvailError = undefined;
                var res = TP.labelExpression(part, macros, panel);
                res = Ext.String.htmlEncode(String(res)).replace(/\n/g, '<br>');
                if(TP.lastAvailError) {
                    var err = String(TP.lastAvailError).replace(/ at .*?\/Thruk/g, ' at Thruk');
                    return '<span class="avail_result_error" title="'+Ext.String.htmlEncode(err)+'">error</span>';
                }
                if(/availability\s*\(/.test(part) && /-1/.test(res)) {
                    return '<span class="avail_result_not_ready" title="not yet ready">'+res.replace(/-1[.0]*/g, '...')+'</span>';
                }
                return res;
            } catch(err) {
                panel.el.dom.title = err.message;
                return '';
            }
        });
        /* remove inactive availabilities */
        var remove_older = (Math.floor(new Date().getTime()/1000)) - 120;
        for(var key in TP.availabilities[panel.id]) {
            if(TP.availabilities[panel.id][key]['active'] < remove_older) {
                delete TP.availabilities[panel.id][key];
            }
        }
        return TP.labelMarkup(txt);
    },

    setIconLabelPosition: function(cfg) {
        var panel = this;
        if(!panel.labelEl || !panel.labelEl.el)     { return; }
        if(!panel.size && panel.iconType != "text") { return; }
        if(cfg == undefined) {
            if(TP.iconSettingsWindow && TP.iconSettingsWindow.panel.id == panel.id) {
                var xdata = TP.get_icon_form_xdata(TP.iconSettingsWindow);
                cfg = xdata.label;
            } else {
                cfg = panel.xdata.label;
            }
        }
        var left          = TP.extract_number_with_unit({ value: panel.el.dom.style.left, unit:'px',  floor: true, defaultValue: 100 });
        var top           = TP.extract_number_with_unit({ value: panel.el.dom.style.top,  unit:'px',  floor: true, defaultValue: 100 });
        var offsetx       = TP.extract_number_with_unit({ value: cfg.offsetx,             unit:' px', floor: true, defaultValue:   0 });
        var offsety       = TP.extract_number_with_unit({ value: cfg.offsety,             unit:' px', floor: true, defaultValue:   0 });
        var fontsize      = TP.extract_number_with_unit({ value: cfg.fontsize,            unit:' px', floor: true, defaultValue:  14 });
        var elWidth       = TP.extract_number_with_unit({ value: panel.width,             unit:'',    floor: true, defaultValue:   0 });
        var elHeight      = TP.extract_number_with_unit({ value: panel.height,            unit:'',    floor: true, defaultValue:   0 });
        var bordersize    = TP.extract_number_with_unit({ value: cfg.bordersize,          unit:' px', floor: true, defaultValue:   0 });

        // avoid flickering when not yet positioned correctly
        if(elWidth == 0 && elHeight == 0 && left == 0 && top == 0) { return; }

        var el    = panel.labelEl.el.dom;
        var style = el.style;

        /* use original reference coordinates for shrinked icons */
        if(panel.shrinked) {
            left     = panel.shrinked.x;
            top      = panel.shrinked.y;
            elWidth  = panel.shrinked.size;
            elHeight = panel.shrinked.size;
        }

        if(cfg.bordercolor && bordersize > 0) {
            style.border = bordersize+"px solid "+cfg.bordercolor;
        } else {
            style.border = "";
        }

        if(cfg.width == undefined || cfg.width == '') {
            style.width    = '';
            style.overflow = '';
        } else {
            style.width    = cfg.width+"px";
            style.overflow = 'hidden';
        }
        if(cfg.height == undefined || cfg.height == '') {
            style.height = '';
        } else {
            style.height = cfg.height+"px";
        }
        if(cfg.roundcorners && cfg.roundcorners != '' && cfg.roundcorners > 0) {
            style.borderRadius = cfg.roundcorners+"px";
        } else {
            style.borderRadius = '';
        }

        style.fontSize = fontsize+'px';
        var size          = panel.labelEl.getSize();
        if(size.width == 0) { return; }

        if(cfg.position == 'above') {
            top = top - offsety - size.height;
            if(cfg.orientation == 'horizontal') {
                left = left + (elWidth / 2) - (size.width / 2) + 2;
            }
            left = left - offsetx;
        }
        else if(cfg.position == 'below') {
            top = top + offsety + elHeight;
            if(cfg.orientation == 'horizontal') {
                left = left + (elWidth / 2) - (size.width / 2) + 2;
            }
            left = left - offsetx;
        }
        else if(cfg.position == 'right') {
            left = left + offsety + elWidth + 2;
            if(cfg.orientation == 'horizontal') {
                top  = top + elHeight/2 - size.height/2;
            }
            top = top - offsetx;
        }
        else if(cfg.position == 'left') {
            left = left - offsety - size.width - 2;
            if(cfg.orientation == 'horizontal') {
                top  = top + elHeight/2 - size.height/2;
            }
            top = top - offsetx;
        }
        else if(cfg.position == 'center') {
            top  = top + offsety + (elHeight/2) - (size.height/2);
            left = left + (elWidth / 2) - (size.width / 2) - offsetx;
        }
        else if(cfg.position == 'top-left') {
            top  = top + offsety;
            left = left + offsetx;
        }
        style.left = left+"px";
        style.top  = top+"px";
        panel.labelEl.oldX = left;
        panel.labelEl.oldY = top;
    },

    /* creates the label element */
    createLabelEl: function() {
        var panel = this;
        if(!panel.tab.isActiveTab()) { return; } /* no need for a label on inactive tab */
        this.labelEl = Ext.create("Ext.Component", {
            'html':     ' ',
            panel:       panel,
            draggable:  !panel.locked,
            renderTo:  "iconContainer",
            shadow:     false,
            hidden:     (!TP.iconSettingsWindow && panel.xdata.label.display && panel.xdata.label.display == 'mouseover'),
            hideMode:  'visibility',
            cls:        ((panel.xdata.link && panel.xdata.link.link) ? '' : 'not') +'clickable iconlabel tooltipTarget', // defaults to text cursor otherwise
            style:      {
                whiteSpace: 'nowrap',
                left:       '-1000px'    // hide initally before setIconLabelPosition moves it to the correct position
            },
            autoEl: {
                tag:     'a',
                href:    panel.xdata.link ? panel.xdata.link.link : '',
                target:  '',
                onclick: "return(false);"
            },
            listeners: {
                /* move parent element according to our drag / drop */
                move: function(This, x, y, eOpts) {
                    var diffX = 0, diffY = 0;
                    if(x != undefined && This.oldX != undefined) { diffX = x - This.oldX; }
                    if(y != undefined && This.oldY != undefined) { diffY = y - This.oldY; }
                    if(x != undefined) { This.oldX = x; }
                    if(y != undefined) { This.oldY = y; }
                    if(diffX != 0 || diffY != 0) {
                        var pos = panel.getPosition();
                        var newX = pos[0]+diffX;
                        var newY = pos[1]+diffY;
                        panel.setRawPosition(newX, newY);
                        panel.updateMapLonLat(undefined, "center");
                        // update settings window
                        if(TP.iconSettingsWindow) {
                            Ext.getCmp('layoutForm').getForm().setValues({x:newX, y:newY});
                        }
                        if(!panel.readonly) {
                            panel.xdata.layout.x = newX;
                            panel.xdata.layout.y = newY;
                            if(panel.xdata.appearance.type == "connector" && panel.xdata.appearance.connectorfromx != undefined) {
                                panel.xdata.appearance.connectorfromx += diffX;
                                panel.xdata.appearance.connectorfromy += diffY;
                                panel.xdata.appearance.connectortox   += diffX;
                                panel.xdata.appearance.connectortoy   += diffY;
                            }
                            panel.saveState();
                        }
                        if(panel.dragEl1) { panel.dragEl1.resetDragEl(); }
                        if(panel.dragEl2) { panel.dragEl2.resetDragEl(); }
                    }
                },
                boxready: function( This, width, height, eOpts ) {
                    panel.addDDListener(This);
                },
                afterrender: function(This, eOpts) {
                    panel.addClickEventhandler(This.el);
                    panel.addDDListener(This);
                    if(!panel.locked) {
                        This.el.on('mouseover', function(evt,t,a) {
                            if(!panel.el) { return; }
                            if(!panel.el.dom.style.outline.match("orange") && !This.el.dom.style.outline.match("orange")) {
                                This.el.dom.style.outline = "1px dashed grey";
                                if(panel.iconType != "text") {
                                    panel.el.dom.style.outline = "1px dashed grey";
                                }
                            }
                        });
                        This.el.on('mouseout', function(evt,t,a) {
                            if(This.el.dom.style.outline.match("grey")) {
                                This.el.dom.style.outline = "";
                            }
                            if(panel.el && panel.el.dom && panel.el.dom.style.outline.match("grey")) {
                                panel.el.dom.style.outline = "";
                            }
                        });
                    }
                },
                beforeshow: function( This, eOpts ) {
                    if(!TP.iconSettingsWindow && panel.xdata.label.display && panel.xdata.label.display == "mouseover" && !This.mouseover) {
                        return(false);
                    }
                    return(true);
                },
                show: function( This, eOpts ) {
                    panel.addDDListener(This);
                }
            }
        });
        if(panel.rotateLabel) {
            panel.rotateEl = panel.labelEl.el;
        }
        panel.applyRotation(panel.xdata.layout.rotation);    /* add dbl click and context menu events */
    }
});

function nl2br(text) {
    text = text.replace(/\n/g, "<br>");
    text = text.replace(/\\n/g, "<br>");
    return(text);
}

TP.labelMarkup = function(text) {
    if(!/[<&]/.test(text)) { return text; }
    // Parse in an inert template. Only new formatting elements enter the label.
    var template = document.createElement('template');
    template.innerHTML = text;
    var label = document.createElement('div');
    function copy(parent, target) {
        for(var node = parent.firstChild; node; node = node.nextSibling) {
            if(node.nodeType == 3) { target.appendChild(document.createTextNode(node.data)); continue; }
            if(node.nodeType != 1 || node.namespaceURI != 'http://www.w3.org/1999/xhtml') { continue; }
            if(TP.labelPolicy.tags.indexOf(node.localName) < 0) { continue; }
            var el = document.createElement(node.localName);
            var presentation = TP.labelPolicy.presentation[node.localName] || [];
            presentation.forEach(function(attr) {
                if(node.hasAttribute(attr)) { el.setAttribute(attr, node.getAttribute(attr)); }
            });
            Object.keys(TP.labelPolicy.attributes).forEach(function(attr) {
                if(node.hasAttribute(attr)) { TP.labelPolicy.attributes[attr](node, el); }
            });
            copy(node, el);
            target.appendChild(el);
        }
    }
    copy(template.content, label);
    return label.innerHTML;
};

TP.labelExpression = function(source, macros, panel) {
    var tokens = source.match(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[a-zA-Z_]\w*|-?\d+(?:\.\d+)?|===|!==|==|!=|>=|<=|\S/g) || [];
    var i = 0;
    function invalid() { throw new Error('Invalid label expression'); }
    function take(s) {
        if(tokens[i] !== s) { return false; }
        i++;
        return true;
    }
    function need(s) { if(!take(s)) { invalid(); } }
    function identifier(s) {
        if(!s || !/^[a-zA-Z_]\w*$/.test(s)) { invalid(); }
        return s;
    }
    function string(s) {
        if(!s || s.length < 2 || !/^['"]/.test(s)) { invalid(); }
        return s.slice(1,-1).replace(/\\(['"\\])/g, '$1');
    }
    function expression(run) {
        var value = sum(run);
        var op = tokens[i];
        if(/^(===|!==|==|!=|>=|<=|>|<)$/.test(op)) {
            i++;
            var right = sum(run);
            switch(op) {
                case '===': value = value === right; break;
                case '!==': value = value !== right; break;
                case '==':  value = value == right; break;
                case '!=':  value = value != right; break;
                case '>=':  value = value >= right; break;
                case '<=':  value = value <= right; break;
                case '>':   value = value > right; break;
                case '<':   value = value < right; break;
            }
        }
        if(take('?')) {
            var yes = expression(run && value);
            need(':');
            var no = expression(run && !value);
            return value ? yes : no;
        }
        return value;
    }
    function sum(run) {
        var value = term(run);
        while(take('+')) { value += term(run); }
        return value;
    }
    function term(run) {
        var s = tokens[i++];
        if(!s) { invalid(); }
        if(/^['"]/.test(s)) { return string(s); }
        if(/^-?\d/.test(s)) { return Number(s); }
        identifier(s);
        if(s == 'true' || s == 'false') { return s == 'true'; }
        if(take('(')) {
            if(s == 'if') {
                var condition = expression(run);
                need(')');
                need('{');
                var yes = expression(run && condition);
                need('}');
                var no = '';
                if(take('else')) { need('{'); no = expression(run && !condition); need('}'); }
                return condition ? yes : no;
            }
            if(!Object.prototype.hasOwnProperty.call(TP.labelPolicy.functions, s)) { invalid(); }
            var fn = TP.labelPolicy.functions[s];
            var args = [];
            if(fn.options) {
                var opts = {};
                need('{');
                do {
                    var k = tokens[i++];
                    if(fn.options.indexOf(k) < 0) { invalid(); }
                    need(':');
                    opts[k] = expression(run);
                } while(take(','));
                need('}');
                args.push(opts);
            } else {
                do { args.push(expression(run)); } while(take(','));
            }
            need(')');
            return run ? fn.run(args, panel) : '';
        }
        var value = macros;
        var name = s;
        do {
            if(/^(?:panel|constructor|prototype|__proto__)$/.test(name)) { invalid(); }
            value = value && typeof value == 'object' && Object.prototype.hasOwnProperty.call(value, name) ? value[name] : undefined;
            if(take('.')) { name = identifier(tokens[i++]); }
            else if(name == 'perfdata' && take('[')) { name = string(tokens[i++]); need(']'); }
            else { break; }
        } while(true);
        if(value == null) { return ''; }
        if(typeof value == 'object' || typeof value == 'function') { invalid(); }
        return value;
    }
    var result = expression(true);
    if(i != tokens.length) { invalid(); }
    return result;
};
