(function() {
    'use strict';
    var root = document.getElementById('status-replay');
    if(!root) { return; }
    var data = JSON.parse(root.getAttribute('data-replay'));
    var dateFormat = root.getAttribute('data-date-format');
    var slider = document.getElementById('replay-position');
    var play = document.getElementById('replay-play');
    var speed = document.getElementById('replay-speed');
    var clock = document.getElementById('replay-time');
    var summary = document.getElementById('replay-summary');
    var body = document.getElementById('replay-objects');
    var currentLog = document.getElementById('replay-event');
    var previousLog = document.getElementById('replay-event-prev');
    var nextLog = document.getElementById('replay-event-next');
    var eventsBefore = document.getElementById('replay-events-before');
    var eventsAfter = document.getElementById('replay-events-after');
    var keyboardMode = document.getElementById('replay-keyboard-mode');
    var logPanel = document.getElementById('replay-log-panel');
    var panes = document.getElementById('replay-panes');
    var splitter = document.getElementById('replay-splitter');
    var logHeight = 90;
    var resizing = null;
    var position = data.start;
    var cursor = 0;
    var logIndices = data.log_indices || data.events.map(function(event, index) { return index; });
    var shownLogs = [];
    var logCursor = 0;
    var timer = null;
    var lastTick;
    var hostIndicators = data.objects.map(function() { return []; });
    var serviceIndicators = [];
    var currentStates = [];
    var viewStart = data.start;
    var viewEnd = data.end;
    var viewFirst = 0;
    var plot;
    var dragging = false;
    var dragStartX;
    var dragMoved = false;

    function formatTime(time) {
        return new Date(time * 1000).strftime(dateFormat);
    }

    function themeColor(className) {
        var sample = document.createElement('span');
        sample.className = className;
        sample.style.display = 'none';
        root.appendChild(sample);
        var color = window.getComputedStyle(sample).color;
        sample.remove();
        return color;
    }

    function eventCategory(event) {
        if(/^(HOST|SERVICE) NOTIFICATION$/.test(event.type)) { return 2; }
        if(/^(HOST|SERVICE) ALERT$/.test(event.type)) { return event.state === 0 ? 1 : 0; }
        return 3;
    }

    function drawTimeline() {
        shownLogs = logIndices.filter(function(index) { return data.events[index].time >= viewStart && data.events[index].time <= viewEnd; });
        logCursor = 0;
        var categories = [
            {label: 'Alerts', color: themeColor('textALERT')},
            {label: 'Recoveries', color: themeColor('textSUCCESS')},
            {label: 'Notifications', color: themeColor('textActive1')},
            {label: 'Other', color: themeColor('textHINTsoft')}
        ];
        var width = (viewEnd - viewStart) / 80;
        var bars = {show: true, align: 'center', barWidth: width * 200, fill: 0.8};
        var maxCount = 1;
        categories.forEach(function(category) {
            category.data = [];
            category.bars = bars;
            category.stack = true;
        });
        if (shownLogs.length <= 2000) {
            // One bar per event timestamp so the position marker lands on the event's own bar.
            var byTime = {}, byBucket = {};
            shownLogs.forEach(function(index) {
                var event = data.events[index];
                byTime[event.time] = (byTime[event.time] || 0) + 1;
                var key = event.time + '|' + eventCategory(event);
                byBucket[key] = (byBucket[key] || 0) + 1;
            });
            Object.keys(byBucket).forEach(function(key) {
                var parts = key.split('|');
                categories[parts[1]].data.push([Number(parts[0]) * 1000, byBucket[key]]);
            });
            Object.keys(byTime).forEach(function(time) { maxCount = Math.max(maxCount, byTime[time]); });
            categories.forEach(function(category) { category.data.sort(function(a, b) { return a[0] - b[0]; }); });
        } else {
            var counts = new Array(80).fill(0);
            categories.forEach(function(category) {
                category.data = counts.map(function(count, index) { return [(viewStart + (index + 0.5) * width) * 1000, 0]; });
                category.sums = new Array(counts.length).fill(0);
            });
            shownLogs.forEach(function(index) {
                var event = data.events[index];
                var bin = Math.min(counts.length - 1, Math.floor((event.time - viewStart) / width));
                var category = eventCategory(event);
                categories[category].data[bin][1]++;
                categories[category].sums[bin] += event.time;
                counts[bin]++;
            });
            // Center each bar on the mean time of its events instead of the bin center.
            categories.forEach(function(category) {
                category.data.forEach(function(point, bin) {
                    if(point[1] > 0) { point[0] = category.sums[bin] / point[1] * 1000; }
                });
            });
            maxCount = Math.max.apply(null, counts.concat([1]));
        }
        plot = jQuery.plot(slider, categories, {
            xaxis: {mode: 'time', timezone: 'browser', min: viewStart * 1000, max: viewEnd * 1000, ticks: 5,
                    minTickSize: [1, 'second'], tickFormatter: function(value) { return formatTime(value / 1000); }},
            yaxis: {min: 0, max: Math.min(100, maxCount), tickDecimals: 0},
            grid: {aboveData: true, hoverable: true, borderWidth: 1, color: themeColor('textTH'), markings: function() {
                return [{xaxis: {from: position * 1000, to: position * 1000}, color: themeColor('text-default'), lineWidth: 1.5}];
            }},
            selection: {mode: 'x', color: categories[2].color}, crosshair: {mode: 'x', color: themeColor('textTH')}, legend: {show: false}
        });
        slider.setAttribute('aria-valuemin', viewStart);
        slider.setAttribute('aria-valuemax', viewEnd);
        document.getElementById('replay-zoom-reset').style.display = viewStart > data.start || viewEnd < data.end ? '' : 'none';
    }

    function setWindow(start, end) {
        start = Math.max(data.start, start);
        end = Math.min(data.end, end);
        if(end <= start) { plot.clearSelection(true); return; }
        pause();
        viewStart = start;
        viewEnd = end;
        viewFirst = data.events.findIndex(function(event) { return event.time >= viewStart; });
        if(viewFirst < 0) { viewFirst = data.events.length; }
        drawTimeline();
        seek(position);
    }

    var rows = data.objects.map(function(object, index) {
        if(object.hidden) { return null; }
        var row = document.createElement('tr');
        var cells = [];
        for(var i = 0; i < 9; i++) {
            cells.push(document.createElement('td'));
            cells[i].style.whiteSpace = 'nowrap';
            cells[i].style.overflow = 'hidden';
            cells[i].style.textOverflow = 'ellipsis';
            row.appendChild(cells[i]);
        }
        cells[0].textContent = object.site;
        var hostUrl = 'extinfo.cgi?type=1&host=' + encodeURIComponent(object.host) + '&backend=' + encodeURIComponent(object.backend);
        var hostLink = document.createElement('a');
        hostLink.href = hostUrl;
        hostLink.textContent = object.host;
        cells[1].appendChild(hostLink);
        var hostIcon = createIndicators(cells[1], data.objects[object.host_object] || object);
        if(object.host_object !== null && object.host_object !== undefined) {
            hostIndicators[object.host_object].push(hostIcon);
        } else {
            paintFlags(hostIcon);
        }
        if(object.service) {
            var serviceCell = document.createElement('div');
            serviceCell.className = 'flex items-center min-w-0';
            var serviceLink = document.createElement('a');
            serviceLink.className = 'truncate flex-1 min-w-0';
            serviceLink.href = 'extinfo.cgi?type=2&host=' + encodeURIComponent(object.host) + '&service=' + encodeURIComponent(object.service) + '&backend=' + encodeURIComponent(object.backend);
            serviceLink.textContent = object.service;
            serviceCell.appendChild(serviceLink);
            var serviceIcons = document.createElement('span');
            serviceIcons.className = 'flex shrink-0';
            serviceCell.appendChild(serviceIcons);
            var serviceIcon = createIndicators(serviceIcons, object);
            cells[2].appendChild(serviceCell);
            serviceIndicators[index] = serviceIcon;
        } else {
            cells[2].textContent = '—';
            serviceIndicators[index] = null;
        }
        return cells;
    });
    var order = data.objects.map(function(object, index) { return index; }).filter(function(index) { return rows[index] !== null; });
    order.sort(function(a, b) {
        var left = data.objects[a];
        var right = data.objects[b];
        return left.host.localeCompare(right.host) || left.service.localeCompare(right.service) ||
            (left.backend || '').localeCompare(right.backend || '');
    });
    var previousHost;
    order.forEach(function(index) {
        var object = data.objects[index];
        var cells = rows[index];
        if(previousHost && previousHost.host === object.host && previousHost.backend === object.backend) {
            cells[1].replaceChildren();
            cells[1].className = 'border-t-0 border-b-0 bgTable';
            cells[1].setAttribute('aria-label', object.host);
        }
        body.appendChild(cells[0].parentNode);
        previousHost = object;
    });
    var objectCount = rows.filter(function(row) { return row !== null; }).length;
    document.getElementById('replay-object-summary').textContent = objectCount + ' objects';

    function createIndicators(cell, object) {
        var icons = {passive: object.accept_passive_checks};
        ['downtime', 'acknowledged', 'checks'].forEach(function(name) {
            icons[name] = document.createElement('i');
            cell.appendChild(icons[name]);
        });
        return icons;
    }

    function paintFlags(icons, state) {
        state = state || {};
        var acknowledged = state.acknowledged && (!state.ack_expire || state.ack_expire > position);
        var disabled = state.active_checks_enabled === 0;
        var flags = {
            downtime: [state.downtime, 'fa-solid fa-moon has_downtime', 'In scheduled downtime at replay time'],
            acknowledged: [acknowledged, 'fa-solid fa-person-digging', 'Problem acknowledged at replay time'],
            checks: [disabled, icons.passive ? 'fa-solid fa-arrows-down-to-line' : 'fa-solid fa-xmark round small red',
                     icons.passive ? 'Active checks disabled; passive checks accepted' : 'Active checks disabled']
        };
        Object.keys(flags).forEach(function(name) {
            var flag = flags[name];
            var icon = icons[name];
            icon.className = flag[0] ? flag[1] + ' ml-1' : '';
            icon.title = flag[0] ? flag[2] : '';
            icon.setAttribute('aria-label', icon.title);
        });
    }

    function refreshFlags(index, state) {
        hostIndicators[index].forEach(function(icons) { paintFlags(icons, state); });
        if(serviceIndicators[index]) { paintFlags(serviceIndicators[index], state); }
    }

    function paint(index, state) {
        var object = data.objects[index];
        currentStates[index] = state;
        refreshFlags(index, state);
        var cells = rows[index];
        if(!cells) { return; }
        var names = object.service ? ['OK', 'WARNING', 'CRITICAL', 'UNKNOWN'] : ['UP', 'DOWN', 'UNREACHABLE'];
        var checked = state && state.state !== undefined;
        var name = checked ? names[state.state] : 'No data';
        cells[3].textContent = name;
        cells[3].className = checked ? 'state ' + name : '';
        cells[4].textContent = checked ? state.state_type : '—';
        cells[5].textContent = (checked && state.check_attempts != null ? state.check_attempts : '—') + '/' + (object.max_attempts == null ? '—' : object.max_attempts);
        cells[6].textContent = state && state.notification_count || 0;
        cells[6].title = 'Notification log entries replayed in this time range';
        cells[7].textContent = checked ? formatTime(state.last_check || state.time) : '—';
        cells[8].textContent = checked ? state.output : '';
        cells[8].title = checked ? state.output : '';
    }

    function seek(time, reset, eventLimit) {
        time = Math.max(viewStart, Math.min(viewEnd, time));
        var backwards = time < position || (eventLimit !== undefined && eventLimit < cursor);
        position = time;
        if(reset || backwards) {
            cursor = 0;
            data.objects.forEach(function(object, index) { paint(index, object.initial); });
        }
        while(cursor < data.events.length && data.events[cursor].time <= position && (eventLimit === undefined || cursor < eventLimit)) {
            var event = data.events[cursor++];
            paint(event.object, event);
        }
        currentStates.forEach(function(state, index) {
            if(state && state.ack_expire) { refreshFlags(index, state); }
        });
        slider.setAttribute('aria-valuenow', Math.floor(position));
        clock.textContent = formatTime(position);
        slider.setAttribute('aria-valuetext', clock.textContent);
        while(logCursor > 0 && shownLogs[logCursor - 1] >= cursor) { logCursor--; }
        while(logCursor < shownLogs.length && shownLogs[logCursor] < cursor) { logCursor++; }
        summary.textContent = logCursor + ' / ' + shownLogs.length + ' events replayed';
        renderLogContext();
        plot.draw();
    }

    function renderLogContext() {
        showEvent(previousLog, logCursor - 2);
        showEvent(currentLog, logCursor - 1);
        showEvent(nextLog, logCursor);
        // Render only the context that fits, not the entire log range.
        var extra = Math.max(0, Math.floor((logHeight - 12) / ((currentLog.offsetHeight || 18) + 4)) - 3);
        var before = Math.min(Math.max(0, logCursor - 2), Math.floor(extra / 2));
        var after = Math.min(Math.max(0, shownLogs.length - logCursor - 1), extra - before);
        before = Math.min(Math.max(0, logCursor - 2), extra - after);
        renderContextRows(eventsBefore, logCursor - 2 - before, before);
        renderContextRows(eventsAfter, logCursor + 1, after);
    }

    function renderContextRows(container, start, count) {
        container.replaceChildren();
        for(var index = start; index < start + count; index++) {
            var row = document.createElement('div');
            row.className = 'flex gap-2 min-w-0';
            var label = document.createElement('span');
            label.className = 'w-20 shrink-0';
            var message = document.createElement('a');
            message.className = 'truncate flex-1 text-inherit';
            showEvent(message, index);
            row.appendChild(label);
            row.appendChild(message);
            container.appendChild(row);
        }
    }

    function showEvent(element, index) {
        var event = data.events[shownLogs[index]];
        if(event) {
            var message = (event.log || event.output || '').replace(/^\[\d+(?:\.\d+)?\]\s*/, '');
            element.textContent = '[' + formatTime(event.time) + '] ' + message;
            element.href = '#';
            element.onclick = function(click) { click.preventDefault(); jumpToEvent(index); };
        } else {
            element.textContent = '—';
            element.removeAttribute('href');
            element.onclick = null;
        }
        element.title = element.textContent;
    }

    function jumpToEvent(index) {
        var rawIndex = shownLogs[index];
        if(rawIndex === undefined) { return; }
        var event = data.events[rawIndex];
        pause();
        seek(event.time, false, rawIndex + 1);
        logPanel.focus();
    }

    function previousEventIndex() {
        var index = logCursor - 1;
        if(index >= 0 && data.events[shownLogs[index]].time === position) { index--; }
        return index;
    }

    function stepEvent(direction) {
        pause();
        var index = direction > 0 ? logCursor : previousEventIndex();
        var rawIndex = shownLogs[index];
        var event = data.events[rawIndex];
        if(event) { seek(event.time, false, rawIndex + 1); }
        else if(direction < 0) { seek(viewStart, true, viewFirst); }
    }

    function pause() {
        clearInterval(timer);
        timer = null;
        play.textContent = 'Play';
        play.setAttribute('aria-pressed', 'false');
    }

    play.addEventListener('click', function() {
        if(timer !== null) { pause(); return; }
        if(position >= viewEnd) { seek(viewStart, true); }
        lastTick = performance.now();
        play.textContent = 'Pause';
        play.setAttribute('aria-pressed', 'true');
        timer = setInterval(function() {
            var now = performance.now();
            seek(position + (now - lastTick) / 1000 * Number(speed.value));
            lastTick = now;
            if(position >= viewEnd) { pause(); }
        }, 100);
    });
    function scrub(event, snap) {
        var time = plot.c2p({left: event.pageX - plot.offset().left, top: 0}).x / 1000;
        if(snap) {
            var closest = -1;
            var distance = Infinity;
            shownLogs.forEach(function(index) {
                var log = data.events[index];
                if(log.time >= viewStart && log.time <= viewEnd && Math.abs(log.time - time) <= distance) {
                    closest = index;
                    distance = Math.abs(log.time - time);
                }
            });
            if(closest >= 0) { seek(data.events[closest].time, false, closest + 1); return; }
        }
        seek(time);
    }

    slider.addEventListener('mousedown', function(event) {
        if(event.button !== 0) { return; }
        pause();
        if(event.shiftKey) { return; }
        event.preventDefault();
        event.stopPropagation();
        slider.focus();
        dragging = true;
        dragStartX = event.pageX;
        dragMoved = false;
        scrub(event, true);
    }, true);
    document.addEventListener('mousemove', function(event) {
        if(dragging && Math.abs(event.pageX - dragStartX) > 3) { dragMoved = true; }
        if(dragging && dragMoved) { scrub(event); }
        if(resizing) { setSplit(resizing.height + event.clientY - resizing.y); }
    });
    document.addEventListener('mouseup', function(event) {
        if(dragging) { dragging = false; if(dragMoved) { scrub(event); } }
        resizing = null;
    });
    window.addEventListener('blur', function() { dragging = false; resizing = null; });
    jQuery(slider).on('plotselected', function(event, ranges) {
        setWindow(ranges.xaxis.from / 1000, ranges.xaxis.to / 1000);
    });
    jQuery(slider).on('plothover', function(event, point, item) {
        slider.title = item ? formatTime(item.datapoint[0] / 1000) + ': ' + item.series.data[item.dataIndex][1] + ' ' + item.series.label.toLowerCase() : '';
    });
    function navigate(event) {
        if(event.altKey || event.ctrlKey || event.metaKey) { return; }
        if(event.key === 'ArrowUp' || event.key === 'ArrowDown' ||
           (keyboardMode.value === 'event' && (event.key === 'ArrowLeft' || event.key === 'ArrowRight'))) {
            event.preventDefault();
            stepEvent(event.key === 'ArrowLeft' || event.key === 'ArrowUp' ? -1 : 1);
            return;
        }
        var step = Number(speed.value);
        var targets = {ArrowLeft: position - step, ArrowRight: position + step, Home: viewStart, End: viewEnd};
        if(Object.prototype.hasOwnProperty.call(targets, event.key)) {
            event.preventDefault();
            pause();
            seek(targets[event.key]);
        }
    }
    slider.addEventListener('keydown', navigate);
    logPanel.addEventListener('keydown', navigate);
    logPanel.addEventListener('mousedown', function() { logPanel.focus(); });

    function setSplit(height) {
        var max = Math.max(80, panes.clientHeight - 128);
        logHeight = Math.max(80, Math.min(max, height));
        panes.style.gridTemplateRows = logHeight + 'px 8px minmax(120px,1fr)';
        splitter.setAttribute('aria-valuemax', max);
        splitter.setAttribute('aria-valuenow', Math.round(logHeight));
        renderLogContext();
    }

    function resizePanes() {
        panes.style.height = Math.max(240, window.innerHeight - panes.getBoundingClientRect().top - 16) + 'px';
        setSplit(logHeight);
    }
    splitter.addEventListener('mousedown', function(event) {
        if(event.button !== 0) { return; }
        event.preventDefault();
        splitter.focus();
        resizing = {y: event.clientY, height: logHeight};
    });
    splitter.addEventListener('keydown', function(event) {
        var targets = {ArrowUp: logHeight - 10, ArrowDown: logHeight + 10, Home: 80, End: panes.clientHeight - 128};
        if(Object.prototype.hasOwnProperty.call(targets, event.key)) {
            event.preventDefault();
            setSplit(targets[event.key]);
        }
    });
    window.addEventListener('resize', resizePanes);
    document.getElementById('replay-reset').addEventListener('click', function() { pause(); seek(viewStart, true, viewFirst); });
    function wheelStep(event) {
        if(event.ctrlKey || event.deltaY === 0) { return; }
        event.preventDefault();
        stepEvent((event.deltaY > 0 ? 1 : -1) * (event.currentTarget === slider ? -1 : 1));
    }
    logPanel.addEventListener('wheel', wheelStep, {passive: false});
    slider.addEventListener('wheel', wheelStep, {passive: false});
    document.getElementById('replay-zoom-reset').addEventListener('click', function() { setWindow(data.start, data.end); });
    window.addEventListener('pagehide', pause);
    drawTimeline();
    resizePanes();
    seek(data.start, true);
}());
