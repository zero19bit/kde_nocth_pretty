// Run with Node.js 18+: node tests/check.cjs
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const base = path.resolve(__dirname, '..');
const jalali = {};
vm.createContext(jalali);
vm.runInContext(fs.readFileSync(path.join(base, 'contents/code/jalali.js'), 'utf8').replace(/^\.pragma library/m, ''), jalali);
const calendar = { Jalali: jalali };
vm.createContext(calendar);
vm.runInContext(fs.readFileSync(path.join(base, 'contents/code/calendar.js'), 'utf8').replace(/^\.(pragma|import).*$/gm, ''), calendar);
let checks = 0;
function check(name, test) { test(); checks++; console.log('PASS', name); }
function plain(x) { return JSON.parse(JSON.stringify(x)); }
const source = fs.readFileSync(path.join(base, 'contents/ui/main.qml'), 'utf8');
const context = { pendingBrightness: -1, brightnessBusy: false, pendingSystemVolume: -1, volumeBusy: false,
    prevCpuTotal: 0, prevCpuIdle: 0, previousInterfaces: {}, prevNetMs: 0, mediaPlayers: [], activePlayer: '',
    focusLeft: 0, focusTotal: 0, focusDeadline: 0, focusPaused: false, run: () => context.notifications++, notifications: 0 };
Object.defineProperty(context, 'focusing', { get() { return context.focusLeft > 0; } });
context.root = context;
context.playerComponent = { createObject(parent, props) { return { ...props, destroy() { this.destroyed = true; } }; } };
vm.createContext(context);
for (const name of ['parseBrightness', 'parseCpu', 'parseRam', 'parseTemp', 'parseNet', 'parseBattery', 'parseWifi',
    'parseBluetooth', 'parseAudio', 'parseMic', 'parseMedia', 'selectPlayer', 'playerLabel', 'updatePlayerOptimistic',
    'startFocus', 'updateFocus', 'toggleFocusPause', 'quoteArg', 'cmdFor', 'executeAction', 'probe']) {
    const match = source.match(new RegExp('^    function ' + name + '\\(.*?^    }', 'ms'));
    assert.ok(match, name + ' exists');
    vm.runInContext(match[0], context);
}
check('brightnessctl percentage, raw maximum, zero and invalid data', () => {
    context.parseBrightness('brightnessctl|intel_backlight,backlight,600,50%,1200'); assert.equal(context.brightness, 50);
    context.parseBrightness('brightnessctl|intel_backlight,backlight,0,0%,1200'); assert.equal(context.brightness, 0);
    context.parseBrightness('powerdevil|org.kde.Solid.PowerManagement|300|1200'); assert.equal(context.brightness, 25);
    context.parseBrightness(''); assert.equal(context.brightness, -1);
});
check('pending controls reject stale polling responses', () => {
    context.brightness = 70; context.pendingBrightness = 70;
    context.parseBrightness('brightnessctl|test,backlight,60,5%,1200'); assert.equal(context.brightness, 70);
    context.pendingBrightness = -1; context.volumeBusy = true; context.systemVolume = 80;
    context.parseAudio('Volume: 0.20'); assert.equal(context.systemVolume, 80); context.volumeBusy = false;
});
check('CPU guest time is not counted twice', () => {
    context.parseCpu('100 0 0 100 0 0 0 0 0 0');
    context.parseCpu('200 0 0 200 0 0 0 0 100 0'); assert.equal(context.cpu, 50);
});
check('CPU temperature supports cold readings and absent sensor', () => {
    context.parseTemp('12500\n45000\n'); assert.equal(context.cpuTemp, 45);
    context.parseTemp('12500'); assert.equal(context.cpuTemp, 13);
    context.parseTemp(''); assert.equal(context.cpuTemp, -1);
});
check('battery minutes carry into hours', () => {
    context.parseBattery('50|Discharging|1999|1000'); assert.equal(context.batteryTime, '2h 0m');
    context.parseBattery('50|Discharging|1000|0'); assert.equal(context.batteryTime, '');
    context.parseBattery(''); assert.equal(context.battery, -1);
});
check('SSID pipes, colons and backslashes survive', () => {
    context.parseWifi('enabled|Cafe|WiFi:5\\G|75'); assert.equal(context.wifiSsid, 'Cafe|WiFi:5\\G'); assert.equal(context.wifiSignal, 75);
    context.parseWifi('disabled||'); assert.equal(context.wifiOn, false); assert.equal(context.wifiSignal, -1);
});
function record(name, status, title, pos = 1e6) { return [name, status, 'Artist|with\nnewline', title, 'file:///cover.jpg', pos, 120e6, 0.5].join('\x1f') + '\x1e\n'; }
check('media metadata preserves separators and newlines; instance IDs remain unique', () => {
    context.parseMedia(record('vlc.instance1', 'Playing', '<b>title|||with\nnewline</b>') + record('vlc.instance2', 'Paused', 'second'));
    assert.equal(context.mediaPlayers.length, 2); assert.equal(context.title, '<b>title|||with\nnewline</b>');
    assert.equal(context.activePlayer, 'vlc.instance1');
});
check('media polling preserves object identities, order and selection', () => {
    const first = context.mediaPlayers[0], second = context.mediaPlayers[1], array = context.mediaPlayers;
    context.selectPlayer(second.name);
    context.parseMedia(record(second.name, 'Playing', 'second', 2e6) + record(first.name, 'Paused', 'first', 3e6));
    assert.equal(context.mediaPlayers, array); assert.equal(context.mediaPlayers[0], first); assert.equal(context.mediaPlayers[1], second);
    assert.equal(second.pos, 2e6); assert.equal(context.activePlayer, second.name);
    context.updatePlayerOptimistic(second.name, 'position 5.00'); assert.equal(second.pos, 5e6);
    context.parseMedia(record(first.name, 'Playing', 'first')); assert.equal(context.activePlayer, first.name); assert.equal(second.destroyed, true);
});
check('action execution ignores duplicate in-flight commands', () => {
    context.actionKinds = {}; let calls = 0; context.actionRunner = { connectSource() { calls++; } };
    assert.equal(context.executeAction('test-command', 'media'), true);
    assert.equal(context.executeAction('test-command', 'media'), false); assert.equal(calls, 1);
});
check('immediate probes use fresh sources instead of cached periodic data', () => {
    context.probeSerial = 0; context.probeSources = {}; const called = [];
    context.runner = { connectSource(cmd) { called.push(cmd); } };
    context.probe('probe-command'); context.probe('probe-command');
    assert.equal(called.length, 2); assert.notEqual(called[0], called[1]);
    assert.equal(context.probeSources[called[0]], 'probe-command');
});
check('network counters ignore newly appearing interfaces and resets', () => {
    const line = (name, rx, tx) => `${name}: ${rx} 0 0 0 0 0 0 0 ${tx} 0 0 0 0 0 0 0`;
    context.parseNet(line('eth0', 1000, 500));
    context.prevNetMs = Date.now() - 1000;
    context.parseNet(line('eth0', 2000, 700) + '\n' + line('wlan0', 9000000, 8000000));
    assert.ok(context.netDown > 900 && context.netDown < 1100); assert.ok(context.netUp < 250);
    context.prevNetMs = Date.now() - 1000; context.parseNet(line('eth0', 0, 0)); assert.equal(context.netDown, 0);
});
check('focus timer catches up after sleep and notifies once', () => {
    context.startFocus(1); const deadline = context.focusDeadline;
    context.updateFocus(deadline - 20000); assert.equal(context.focusLeft, 20);
    context.updateFocus(deadline + 3600000); assert.equal(context.focusLeft, 0); assert.equal(context.notifications, 1);
    context.updateFocus(deadline + 7200000); assert.equal(context.notifications, 1);
    context.startFocus(25); context.toggleFocusPause(); const left = context.focusLeft;
    context.updateFocus(context.focusDeadline + 3600000); assert.equal(context.focusLeft, left);
    context.toggleFocusPause(); assert.equal(context.focusPaused, false);
});
check('Jalali new year and leap boundaries', () => {
    assert.deepEqual(plain(calendar.parts(new Date(2024, 2, 20, 12), 0, 0)), {y: 1403, m: 1, d: 1});
    assert.equal(calendar.monthLength(1403, 12, 0), 30); assert.equal(calendar.monthLength(1404, 12, 0), 29);
});
check('Hijri civil epoch and known year boundary', () => {
    assert.equal(calendar.civilToDay(1, 1, 1), 1948440);
    assert.deepEqual(plain(calendar.parts(new Date(2024, 6, 8, 12), 2, 0)), {y: 1446, m: 1, d: 1});
    assert.equal(calendar.monthLength(1445, 12, 2), 30); assert.equal(calendar.monthLength(1446, 12, 2), 29);
});
check('all three calendars: 1900–2100 roundtrips, month cells and Hijri adjustments', () => {
    for (let y = 1900; y <= 2100; y++) for (let m = 0; m < 12; m++) for (let type = 0; type < 3; type++) {
        const date = new Date(y, m, 15, 12);
        for (const offset of type === 2 ? [-2, 0, 2] : [0]) {
            const p = calendar.parts(date, type, offset), back = calendar.toDate(p.y, p.m, p.d, type, offset);
            assert.equal(+back, +date);
            const cells = calendar.monthCells(type, p.y, p.m, offset), len = calendar.monthLength(p.y, p.m, type);
            assert.equal(cells.length, 42); assert.equal(cells.filter(x => x > 0).length, len);
            const first = calendar.toDate(p.y, p.m, 1, type, offset);
            assert.equal(cells.indexOf(1), (first.getDay() + (type === 1 ? 6 : 1)) % 7);
        }
    }
});
check('Hijri civil matches ICU for every day from 2020 through 2030', () => {
    const formatter = new Intl.DateTimeFormat('en-u-ca-islamic-civil', {year:'numeric', month:'numeric', day:'numeric'});
    const date = new Date(2020, 0, 1, 12);
    while (date.getFullYear() <= 2030) {
        const p = calendar.parts(date, 2, 0);
        const expected = Object.fromEntries(formatter.formatToParts(date).filter(x => ['year','month','day'].includes(x.type)).map(x => [x.type, Number(x.value)]));
        assert.deepEqual(plain(p), {y:expected.year, m:expected.month, d:expected.day});
        date.setDate(date.getDate() + 1);
    }
});
if (process.argv.includes('--calendar-json')) {
    const result = [];
    for (let y = 1900; y <= 2100; y++) for (let m = 0; m < 12; m++) {
        const date = new Date(y,m,15,12);
        result.push({g:[y,m+1,15], h:plain(calendar.parts(date,2,0)), j:plain(calendar.parts(date,0,0))});
    }
    fs.writeFileSync('/tmp/notch-calendar-samples.json', JSON.stringify(result));
}
console.log(`${checks} test groups passed; TZ=${process.env.TZ || 'system default'}`);
