import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../code/jalali.js" as Jalali
import "../code/calendar.js" as Calendar

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: root.glassMode ? PlasmaCore.Types.TranslucentBackground : PlasmaCore.Types.DefaultBackground

    property date now: new Date()
    readonly property date calendarDay: new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12)
    readonly property int calendarType: plasmoid.configuration.calendarType >= 0
                                        ? Math.min(2, plasmoid.configuration.calendarType)
                                        : (plasmoid.configuration.jalaliDefault ? 0 : 1)
    readonly property int hijriAdjustment: plasmoid.configuration.hijriAdjustment
    readonly property string dateText: Calendar.dateText(calendarDay, calendarType, hijriAdjustment)
    readonly property string shortDateText: Calendar.dateText(calendarDay, calendarType, hijriAdjustment, true)
    property bool detailsVisible: false
    property bool updatingPlayers: false
    property string lastError: ""
    property var actionKinds: ({})
    property var probeSources: ({})
    property int probeSerial: 0
    readonly property var jnow: Jalali.toJalali(now)
    readonly property string clockText: Qt.formatTime(now, plasmoid.configuration.clock24h ? "hh:mm" : "h:mm AP")

    readonly property bool showMedia: plasmoid.configuration.showMedia
    readonly property bool showCalendar: plasmoid.configuration.showCalendar
    readonly property bool showFocus: plasmoid.configuration.showFocus
    readonly property bool showQuickControls: plasmoid.configuration.showQuickControls
    readonly property bool showConnectivity: plasmoid.configuration.showConnectivity
    readonly property bool showSystem: plasmoid.configuration.showSystem
    readonly property bool showCpuTemp: plasmoid.configuration.showCpuTemp
    readonly property bool showNetworkSpeed: plasmoid.configuration.showNetworkSpeed
    readonly property bool showBattery: plasmoid.configuration.showBattery
    readonly property bool showWifiTile: plasmoid.configuration.showWifiTile
    readonly property bool showBluetoothTile: plasmoid.configuration.showBluetoothTile
    readonly property bool showVolumeControl: plasmoid.configuration.showVolumeControl
    readonly property bool showBrightnessControl: plasmoid.configuration.showBrightnessControl
    readonly property bool showMicControl: plasmoid.configuration.showMicControl
    readonly property bool glassMode: plasmoid.configuration.glassMode
    readonly property int glassOpacity: plasmoid.configuration.glassOpacity
    readonly property int glassBorderOpacity: plasmoid.configuration.glassBorderOpacity
    readonly property bool jalaliDefault: plasmoid.configuration.jalaliDefault
    readonly property bool compactShowMedia: plasmoid.configuration.compactShowMedia
    readonly property bool compactShowDate: plasmoid.configuration.compactShowDate
    readonly property bool compactShowClock: plasmoid.configuration.compactShowClock
    readonly property bool showJalaliDate: plasmoid.configuration.showJalaliDate
    readonly property bool showHijriDate: plasmoid.configuration.showHijriDate
    readonly property bool showGregorianDate: plasmoid.configuration.showGregorianDate
    readonly property int popupWidth: plasmoid.configuration.popupWidth
    readonly property int cardRadius: plasmoid.configuration.cardRadius
    readonly property int focusPreset1: plasmoid.configuration.focusPreset1
    readonly property int focusPreset2: plasmoid.configuration.focusPreset2
    readonly property int focusPreset3: plasmoid.configuration.focusPreset3

    property bool hasMedia: false
    property var mediaPlayers: []
    property string activePlayer: ""
    property string status: ""
    property string artist: ""
    property string title: ""
    property string artUrl: ""
    property real pos: 0
    property real len: 0
    property real vol: 1
    readonly property bool playing: status === "Playing"

    property int ram: 0
    property real ramUsedGiB: 0
    property real ramTotalGiB: 0
    property int cpu: 0
    property int cpuTemp: -1
    property int battery: -1
    property string batteryStatus: ""
    property string batteryTime: ""
    property real netDown: 0
    property real netUp: 0
    property bool wifiOn: false
    property string wifiSsid: ""
    property int wifiSignal: -1
    property bool bluetoothOn: false
    property int bluetoothConnected: 0
    property int systemVolume: 0
    property bool systemMuted: false
    property bool micMuted: false
    property int brightness: -1
    property string brightnessBackend: ""
    property string brightnessDevice: ""
    property real brightnessMaxRaw: 0
    property string brightnessService: ""
    property bool volumeBusy: false
    property bool brightnessBusy: false
    property real pendingSystemVolume: -1
    property real pendingBrightness: -1

    property double prevCpuTotal: 0
    property double prevCpuIdle: 0
    property double prevNetMs: 0
    property var previousInterfaces: ({})

    property int focusLeft: 0
    property int focusTotal: 0
    property double focusDeadline: 0
    property bool focusPaused: false
    readonly property bool focusing: focusLeft > 0
    readonly property string focusText: Math.floor(focusLeft / 60) + ":" + ("0" + (focusLeft % 60)).slice(-2)

    toolTipTextFormat: Text.PlainText
    toolTipMainText: hasMedia ? title : clockText
    toolTipSubText: hasMedia ? artist : root.dateText

    readonly property string mediaCmd: "LC_ALL=C playerctl -a metadata --format '{{playerInstance}}\u001f{{status}}\u001f{{artist}}\u001f{{title}}\u001f{{mpris:artUrl}}\u001f{{position}}\u001f{{mpris:length}}\u001f{{volume}}\u001e' 2>/dev/null"
    readonly property string batteryCmd: "LC_ALL=C sh -c 'd=\"\"; for x in /sys/class/power_supply/*; do [ \"$(cat \"$x/type\" 2>/dev/null)\" = Battery ] && d=\"$x\" && break; done; [ -z \"$d\" ] && exit 0; c=$(cat \"$d/capacity\" 2>/dev/null); s=$(cat \"$d/status\" 2>/dev/null); e=$(cat \"$d/energy_now\" 2>/dev/null); p=$(cat \"$d/power_now\" 2>/dev/null); if [ -z \"$e\" ] || [ -z \"$p\" ]; then e=$(cat \"$d/charge_now\" 2>/dev/null); p=$(cat \"$d/current_now\" 2>/dev/null); fi; printf \"%s|%s|%s|%s\\n\" \"$c\" \"$s\" \"$e\" \"$p\"'"
    readonly property string tempCmd: "LC_ALL=C sh -c 'for d in /sys/class/hwmon/hwmon*; do n=$(cat \"$d/name\" 2>/dev/null); case \"$n\" in coretemp|k10temp|k8temp|zenpower|cpu_thermal|cpu-thermal|peci_cputemp) for f in \"$d\"/temp*_input; do [ -r \"$f\" ] && cat \"$f\"; done;; esac; done; for d in /sys/class/thermal/thermal_zone*; do n=$(cat \"$d/type\" 2>/dev/null); case \"$n\" in x86_pkg_temp|cpu-thermal|cpu_thermal|cpu[0-9]*-thermal) [ -r \"$d/temp\" ] && cat \"$d/temp\";; esac; done'"
    readonly property string wifiCmd: "LC_ALL=C sh -c 'state=$(nmcli -t -f WIFI general 2>/dev/null); line=$(nmcli -t --escape no -f ACTIVE,SIGNAL,SSID device wifi list --rescan no 2>/dev/null | sed -n \"s/^yes://p\" | head -n1); sig=${line%%:*}; ssid=${line#*:}; [ -z \"$line\" ] && ssid=\"\"; printf \"%s|%s|%s\\n\" \"$state\" \"$ssid\" \"$sig\"'"
    readonly property string bluetoothCmd: "LC_ALL=C sh -c 'p=$(bluetoothctl show 2>/dev/null | sed -n \"s/^[[:space:]]*Powered: //p\" | head -n1); c=$(bluetoothctl devices Connected 2>/dev/null | wc -l); printf \"%s|%s\\n\" \"$p\" \"$c\"'"
    readonly property string audioCmd: "LC_ALL=C sh -c 'wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true'"
    readonly property string micCmd: "LC_ALL=C sh -c 'wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true'"
    readonly property string brightnessCmd: "LC_ALL=C sh -c 'if command -v qdbus6 >/dev/null 2>&1; then for svc in org.kde.Solid.PowerManagement org.kde.org_kde_powerdevil local.org_kde_powerdevil; do cur=$(qdbus6 $svc /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightness 2>/dev/null); max=$(qdbus6 $svc /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightnessMax 2>/dev/null); if [ -n \"$cur\" ] && [ -n \"$max\" ]; then printf \"powerdevil|%s|%s|%s\n\" \"$svc\" \"$cur\" \"$max\"; exit 0; fi; done; fi; if command -v brightnessctl >/dev/null 2>&1; then line=$(brightnessctl -m -c backlight 2>/dev/null | head -n1); [ -n \"$line\" ] && printf \"brightnessctl|%s\n\" \"$line\"; fi'"

    function run(cmd) { runner.connectSource(cmd) }
    function probe(cmd) {
        // Data engines share sources. A unique source avoids reusing a periodic
        // poll's cached output when an immediate refresh is requested.
        const source = cmd + " # notch-probe-" + (++probeSerial)
        probeSources[source] = cmd
        runner.connectSource(source)
    }
    function quoteArg(s) {
        return "\"" + String(s).replace(/\\/g, "\\\\").replace(/\"/g, "\\\"").replace(/\$/g, "\\$").replace(/`/g, "\\`") + "\""
    }
    function cmdFor(player, action) {
        return player ? "playerctl -p " + quoteArg(player) + " " + action : "playerctl " + action
    }
    function updatePlayerOptimistic(player, action) {
        const p = mediaPlayers.find(x => x.name === player)
        if (!p) return
        if (action === "play-pause") p.status = p.status === "Playing" ? "Paused" : "Playing"
        else if (action.indexOf("position ") === 0) p.pos = Math.max(0, Number(action.slice(9)) * 1e6)
        else if (/^volume [0-9.]+$/.test(action)) p.vol = Math.max(0, Math.min(1, Number(action.slice(7))))
        if (player === activePlayer) selectPlayer(player)
    }

    function mediaActionFor(player, action) {
        if (!player) return
        if (executeAction(cmdFor(player, action), "media")) updatePlayerOptimistic(player, action)
    }

    function mediaAction(action) { mediaActionFor(activePlayer, action) }
    function startFocus(min) {
        focusTotal = Math.max(1, Math.round(min)) * 60
        focusLeft = focusTotal
        focusPaused = false
        focusDeadline = Date.now() + focusTotal * 1000
    }
    function stopFocus() { focusLeft = 0; focusDeadline = 0; focusPaused = false }
    function updateFocus(ms) {
        if (focusDeadline <= 0 || focusPaused) return
        focusLeft = Math.max(0, Math.ceil((focusDeadline - ms) / 1000))
        if (focusLeft === 0) {
            focusDeadline = 0
            run("notify-send -a Notch -i chronometer 'تمرکز تموم شد' 'وقت استراحته'")
        }
    }
    function toggleFocusPause() {
        if (!focusing) return
        if (focusPaused) { focusDeadline = Date.now() + focusLeft * 1000; focusPaused = false }
        else { updateFocus(Date.now()); if (focusing) focusPaused = true }
    }

    function openConfiguration() {
        try {
            const action = Plasmoid.internalAction("configure")
            if (action) action.trigger()
        } catch (e) {}
    }

    function toggleWifi() {
        executeAction("nmcli radio wifi " + (wifiOn ? "off" : "on"), "connectivity")
    }
    function toggleBluetooth() {
        executeAction("bluetoothctl power " + (bluetoothOn ? "off" : "on"), "connectivity")
    }
    function openNetworkSettings() { run("kcmshell6 kcm_networkmanagement") }
    function openBluetoothSettings() { run("kcmshell6 kcm_bluetooth") }
    function openAudioSettings() { run("kcmshell6 kcm_pulseaudio") }
    function setSystemVolume(pct) {
        const p = Math.max(0, Math.min(150, Math.round(pct)))
        systemVolume = p
        pendingSystemVolume = p
        volumeApply.restart()
    }
    function toggleSystemMute() {
        if (executeAction("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", "audio")) systemMuted = !systemMuted
    }
    function toggleMicMute() {
        if (executeAction("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", "audio")) micMuted = !micMuted
    }
    function setBrightness(pct) {
        const p = Math.max(1, Math.min(100, Math.round(pct)))
        brightness = p
        pendingBrightness = p
        brightnessApply.restart()
    }

    function applyBrightnessNow() {
        if (pendingBrightness < 0 || brightnessBusy) return
        const p = pendingBrightness
        pendingBrightness = -1
        brightnessBusy = true
        if (brightnessBackend === "powerdevil" && brightnessMaxRaw > 0 && brightnessService.length > 0) {
            const raw = Math.max(1, Math.round(brightnessMaxRaw * p / 100))
            executeAction("qdbus6 " + quoteArg(brightnessService) + " /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness " + raw, "brightness")
        } else if (brightnessBackend === "brightnessctl") {
            executeAction("brightnessctl -q -d " + quoteArg(brightnessDevice) + " set " + p + "%", "brightness")
        } else brightnessBusy = false
    }

    function formatRate(bytes) {
        if (bytes < 1024) return Math.round(bytes) + " B/s"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(bytes < 10240 ? 1 : 0) + " KB/s"
        return (bytes / 1024 / 1024).toFixed(bytes < 10 * 1024 * 1024 ? 1 : 0) + " MB/s"
    }

    function playerLabel(name) {
        if (!name) return "Player"
        let n = String(name).replace(/\.instance\d+.*/, "")
        if (n.length > 0) n = n.charAt(0).toUpperCase() + n.slice(1)
        return n
    }

    function parseMedia(out) {
        let parsed = []
        const records = out.split("\u001e")
        for (let i = 0; i < records.length; ++i) {
            const p = records[i].replace(/^\r?\n/, "").split("\u001f")
            if (p.length !== 8 || !p[0] || ["Playing", "Paused"].indexOf(p[1]) < 0) continue
            parsed.push({ name: p[0], app: playerLabel(p[0]), status: p[1], artist: p[2],
                          title: p[3] || "Unknown", artUrl: p[4], pos: Math.max(0, Number(p[5]) || 0),
                          len: Math.max(0, Number(p[6]) || 0), vol: Math.max(0, Math.min(1, Number(p[7]) || 0)) })
        }
        // Keep QObject identities and ordering stable while position updates arrive.
        // Replacing a JS array every poll recreates delegates and interrupts dragging.
        const previous = mediaPlayers
        let ordered = previous.filter(old => parsed.some(p => p.name === old.name))
        const fresh = parsed.filter(p => !previous.some(old => old.name === p.name))
        fresh.sort((a, b) => (a.status === "Playing" ? 0 : 1) - (b.status === "Playing" ? 0 : 1))
        for (let i = 0; i < fresh.length; ++i) ordered.push(playerComponent.createObject(root, fresh[i]))
        for (let i = 0; i < ordered.length; ++i) {
            const data = parsed.find(p => p.name === ordered[i].name)
            for (const key in data) ordered[i][key] = data[key]
        }
        hasMedia = ordered.length > 0
        const selected = ordered.find(p => p.name === activePlayer) || ordered.find(p => p.status === "Playing") || ordered[0]
        updatingPlayers = true
        if (ordered.length !== previous.length || ordered.some((p, i) => p !== previous[i])) mediaPlayers = ordered
        if (selected) selectPlayer(selected.name)
        else { activePlayer = ""; status = ""; artist = ""; title = ""; artUrl = ""; pos = 0; len = 0; vol = 1 }
        updatingPlayers = false
        for (let i = 0; i < previous.length; ++i) {
            if (ordered.indexOf(previous[i]) < 0) previous[i].destroy()
        }
    }

    function selectPlayer(name) {
        if (!mediaPlayers || mediaPlayers.length === 0) return
        let idx = mediaPlayers.findIndex(x => x.name === name)
        if (idx < 0) idx = 0
        const p = mediaPlayers[idx]
        activePlayer = p.name
        status = p.status; artist = p.artist; title = p.title; artUrl = p.artUrl
        pos = p.pos; len = p.len; vol = p.vol
    }

    function parseCpu(out) {
        const p = out.trim().split(/\s+/).map(Number)
        if (p.length < 5) return
        const idle = (p[3] || 0) + (p[4] || 0)
        let total = 0
        for (let i = 0; i < Math.min(8, p.length); ++i) total += p[i] || 0
        if (prevCpuTotal > 0 && total > prevCpuTotal) {
            const dTotal = total - prevCpuTotal
            const dIdle = idle - prevCpuIdle
            cpu = Math.max(0, Math.min(100, Math.round(100 * (dTotal - dIdle) / dTotal)))
        }
        prevCpuTotal = total
        prevCpuIdle = idle
    }

    function parseRam(out) {
        const l = out.split("\n").find(x => x.startsWith("Mem:"))
        if (!l) return
        const f = l.trim().split(/\s+/)
        const total = Number(f[1]) || 0
        const used = Number(f[2]) || 0
        if (total > 0) {
            ram = Math.round(100 * used / total)
            ramUsedGiB = used / 1073741824
            ramTotalGiB = total / 1073741824
        }
    }

    function parseTemp(out) {
        const vals = out.split(/\s+/).filter(x => x.length > 0).map(Number)
                         .filter(x => isFinite(x) && x >= 0 && x <= 125000)
        cpuTemp = vals.length ? Math.round(Math.max.apply(null, vals) / 1000) : -1
    }

    function parseNet(out) {
        const lines = out.split("\n")
        let current = {}, rxDelta = 0, txDelta = 0
        for (let i = 0; i < lines.length; ++i) {
            const m = lines[i].match(/^\s*([^:]+):\s*(.*)$/)
            if (!m || m[1].trim() === "lo") continue
            const name = m[1].trim(), f = m[2].trim().split(/\s+/)
            if (f.length < 9) continue
            const rx = Number(f[0]) || 0, tx = Number(f[8]) || 0
            current[name] = { rx: rx, tx: tx }
            const old = previousInterfaces[name]
            if (old) { rxDelta += Math.max(0, rx - old.rx); txDelta += Math.max(0, tx - old.tx) }
        }
        const ms = Date.now(), seconds = (ms - prevNetMs) / 1000
        netDown = prevNetMs > 0 && seconds > 0 ? rxDelta / seconds : 0
        netUp = prevNetMs > 0 && seconds > 0 ? txDelta / seconds : 0
        previousInterfaces = current; prevNetMs = ms
    }

    function parseBattery(out) {
        if (!out) { battery = -1; batteryStatus = ""; batteryTime = ""; return }
        const p = out.split("|")
        battery = parseInt(p[0])
        if (isNaN(battery) || battery < 0 || battery > 100) battery = -1
        batteryStatus = p[1] || ""
        const e = Number(p[2]) || 0
        const power = Number(p[3]) || 0
        batteryTime = ""
        if (e > 0 && power > 0 && batteryStatus.indexOf("Discharging") >= 0) {
            const minutes = Math.round(e / power * 60)
            batteryTime = Math.floor(minutes / 60) + "h " + (minutes % 60) + "m"
        }
    }

    function parseWifi(out) {
        const p = out.split("|")
        wifiOn = (p.shift() || "").trim().toLowerCase() === "enabled"
        const sig = parseInt(p.pop())
        wifiSsid = p.join("|")
        wifiSignal = isNaN(sig) ? -1 : Math.max(0, Math.min(100, sig))
    }
    function parseBluetooth(out) {
        const p = out.split("|")
        bluetoothOn = (p[0] || "").toLowerCase().indexOf("yes") >= 0
        const c = parseInt(p[1])
        bluetoothConnected = isNaN(c) ? 0 : c
    }
    function parseAudio(out) {
        const m = out.match(/Volume:\s*([0-9.]+)/)
        if (m && pendingSystemVolume < 0 && !volumeBusy) systemVolume = Math.round(Number(m[1]) * 100)
        systemMuted = out.indexOf("[MUTED]") >= 0
    }
    function parseMic(out) {
        micMuted = out.indexOf("[MUTED]") >= 0
    }
    function parseBrightness(out) {
        if (pendingBrightness >= 0 || brightnessBusy) return
        if (!out) { brightness = -1; brightnessBackend = ""; brightnessDevice = ""; brightnessMaxRaw = 0; brightnessService = ""; return }
        const line = out.trim()
        if (line.indexOf("powerdevil|") === 0) {
            const p = line.split("|")
            const cur = Number(p[2]), max = Number(p[3])
            if (isFinite(cur) && isFinite(max) && max > 0) {
                brightnessBackend = "powerdevil"
                brightnessService = p[1] || ""
                brightnessDevice = "PowerDevil"
                brightnessMaxRaw = max
                brightness = Math.max(0, Math.min(100, Math.round(cur * 100 / max)))
                return
            }
        }
        if (line.indexOf("brightnessctl|") === 0) {
            const rawLine = line.substring("brightnessctl|".length)
            const p = rawLine.split(",")
            const raw = p.length >= 5 ? p[3] : ""
            const n = parseInt(String(raw).replace("%", ""))
            brightnessBackend = isNaN(n) ? "" : "brightnessctl"
            brightnessService = ""
            brightnessDevice = p.length > 0 ? p[0] : ""
            brightnessMaxRaw = 0
            brightness = isNaN(n) ? -1 : Math.max(0, Math.min(100, n))
            return
        }
        brightness = -1; brightnessBackend = ""; brightnessDevice = ""; brightnessMaxRaw = 0; brightnessService = ""
    }

    function executeAction(cmd, kind) {
        if (actionKinds[cmd] !== undefined) return false
        lastError = ""
        actionKinds[cmd] = kind
        actionRunner.connectSource(cmd)
        return true
    }

    Component {
        id: playerComponent
        QtObject {
            property string name: ""
            property string app: ""
            property string status: ""
            property string artist: ""
            property string title: ""
            property string artUrl: ""
            property real pos: 0
            property real len: 0
            property real vol: 1
        }
    }

    Timer {
        id: audioRefresh
        interval: 100; repeat: false
        onTriggered: { root.probe(root.audioCmd); root.probe(root.micCmd) }
    }

    Timer {
        id: mediaRefreshFast
        interval: 90
        repeat: false
        onTriggered: {
            root.probe(root.mediaCmd)
            mediaRefreshSecond.restart()
        }
    }

    Timer {
        id: mediaRefreshSecond
        interval: 280
        repeat: false
        onTriggered: root.probe(root.mediaCmd)
    }

    Timer {
        id: volumeApply
        interval: 70
        repeat: false
        onTriggered: {
            if (root.pendingSystemVolume < 0 || root.volumeBusy) return
            const p = root.pendingSystemVolume
            root.pendingSystemVolume = -1
            root.volumeBusy = true
            root.executeAction("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + p + "%", "volume")
        }
    }

    Timer {
        id: brightnessApply
        interval: 90
        repeat: false
        onTriggered: root.applyBrightnessNow()
    }

    P5Support.DataSource {
        id: actionRunner
        engine: "executable"
        onNewData: (source, data) => {
            const kind = root.actionKinds[source] || ""
            delete root.actionKinds[source]
            disconnectSource(source)
            if (Number(data["exit code"]) !== 0) {
                root.lastError = (data.stderr || "The command failed. Check that the required utility is installed.").trim().slice(0, 220)
            }
            if (kind === "media") mediaRefreshFast.restart()
            else if (kind === "brightness") {
                root.brightnessBusy = false
                if (root.pendingBrightness >= 0) brightnessApply.restart()
                else brightnessRefresh.restart()
            } else if (kind === "volume") {
                root.volumeBusy = false
                if (root.pendingSystemVolume >= 0) volumeApply.restart()
                else audioRefresh.restart()
            } else if (kind === "audio") audioRefresh.restart()
            else if (kind === "connectivity") refreshConnectivity.restart()
        }
    }

    Timer {
        id: brightnessRefresh
        interval: 180
        repeat: false
        onTriggered: root.probe(root.brightnessCmd)
    }

    P5Support.DataSource {
        id: runner
        engine: "executable"
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            const command = root.probeSources[source] || source
            delete root.probeSources[source]
            disconnectSource(source)
            if (command === root.brightnessCmd) root.parseBrightness(o)
            else if (command === root.wifiCmd) root.parseWifi(o)
            else if (command === root.bluetoothCmd) root.parseBluetooth(o)
            else if (command === root.audioCmd) root.parseAudio(o)
            else if (command === root.micCmd) root.parseMic(o)
            else if (command === root.mediaCmd) root.parseMedia(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: root.detailsVisible ? 1000 : 2500
        connectedSources: root.showMedia || root.compactShowMedia ? [root.mediaCmd] : []
        onNewData: (source, data) => root.parseMedia((data.stdout || "").trim())
    }

    P5Support.DataSource {
        engine: "executable"; interval: root.detailsVisible ? 1500 : 10000
        connectedSources: (root.showSystem ? ["grep '^cpu ' /proc/stat"] : []).concat(root.showNetworkSpeed && root.showConnectivity ? ["cat /proc/net/dev"] : [])
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            if (source.indexOf("/proc/stat") >= 0) root.parseCpu(o.replace(/^cpu\s+/, ""))
            else root.parseNet(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: root.detailsVisible ? 5000 : 30000
        connectedSources: root.showSystem ? ["LC_ALL=C free -b"].concat(root.showCpuTemp ? [root.tempCmd] : []).concat(root.showBattery ? [root.batteryCmd] : []) : []
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            if (source === "LC_ALL=C free -b") root.parseRam(o)
            else if (source === root.tempCmd) root.parseTemp(o)
            else if (source === root.batteryCmd) root.parseBattery(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: root.detailsVisible ? 12000 : 30000
        connectedSources: root.showConnectivity || root.showQuickControls ? [root.wifiCmd, root.bluetoothCmd] : []
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            if (source === root.wifiCmd) root.parseWifi(o)
            else if (source === root.bluetoothCmd) root.parseBluetooth(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: root.detailsVisible ? 3000 : 10000
        connectedSources: root.showQuickControls ? (root.showVolumeControl ? [root.audioCmd] : []).concat(root.showMicControl ? [root.micCmd] : []) : []
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            if (source === root.audioCmd) root.parseAudio(o)
            else if (source === root.micCmd) root.parseMic(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: root.detailsVisible ? 7000 : 15000
        connectedSources: root.showQuickControls && root.showBrightnessControl ? [root.brightnessCmd] : []
        onNewData: (source, data) => root.parseBrightness((data.stdout || "").trim())
    }

    Timer {
        id: refreshConnectivity
        interval: 900; repeat: false
        onTriggered: {
            root.probe(root.wifiCmd)
            root.probe(root.bluetoothCmd)
            root.probe(root.audioCmd)
            root.probe(root.micCmd)
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            root.now = new Date()
            root.updateFocus(Date.now())
        }
    }

    compactRepresentation: Item {
        id: cr
        readonly property bool hovered: hh.hovered
        Layout.fillHeight: true
        Layout.minimumWidth: pill.width
        Layout.preferredWidth: pill.width

        HoverHandler { id: hh }

        Rectangle {
            id: pill
            anchors.verticalCenter: parent.verticalCenter
            height: Math.max(16, Math.min(parent.height - 4, Kirigami.Units.gridUnit * 1.9))
            width: row.implicitWidth + height * 0.9
            radius: height / 2
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            Kirigami.Theme.inherit: false
            color: root.glassMode
                   ? Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, root.glassOpacity / 100.0)
                   : Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.10)
            border.width: 1
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, root.glassMode ? root.glassBorderOpacity / 100.0 : 0.12)
            Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                onClicked: (m) => m.button === Qt.MiddleButton && root.hasMedia ? root.mediaAction("play-pause") : root.expanded = !root.expanded
                onWheel: (w) => { if (root.hasMedia) root.mediaAction("volume 0.05" + (w.angleDelta.y > 0 ? "+" : "-")) }
            }

            Row {
                id: row
                anchors.centerIn: parent
                spacing: Kirigami.Units.smallSpacing * 1.5

                Item {
                    width: pill.height - 8; height: width
                    anchors.verticalCenter: parent.verticalCenter
                    Cover { anchors.fill: parent; radius: width / 2; visible: root.hasMedia && root.compactShowMedia; source: root.artUrl }
                    Kirigami.Icon {
                        anchors.fill: parent; visible: !root.hasMedia || !root.compactShowMedia; color: Kirigami.Theme.textColor
                        source: root.focusing ? "chronometer" : "preferences-system-time"
                    }
                }

                Marquee {
                    visible: root.hasMedia && root.compactShowMedia
                    anchors.verticalCenter: parent.verticalCenter
                    maxWidth: cr.hovered ? 190 : 140
                    text: root.artist ? root.title + " — " + root.artist : root.title
                }
                PC3.Label { textFormat: Text.PlainText;
                    visible: root.compactShowDate || ((!root.hasMedia || !root.compactShowMedia) && !root.compactShowClock)
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.shortDateText
                }

                Eq {
                    visible: root.hasMedia && root.compactShowMedia && !cr.hovered
                    anchors.verticalCenter: parent.verticalCenter
                    active: root.playing && visible; color: Kirigami.Theme.highlightColor
                }
                Row {
                    visible: root.hasMedia && root.compactShowMedia && cr.hovered
                    anchors.verticalCenter: parent.verticalCenter
                    IconBtn { source: "media-skip-backward"; onClicked: root.mediaAction("previous") }
                    IconBtn { source: root.playing ? "media-playback-pause" : "media-playback-start"; onClicked: root.mediaAction("play-pause") }
                    IconBtn { source: "media-skip-forward"; onClicked: root.mediaAction("next") }
                }

                PC3.Label { textFormat: Text.PlainText;
                    visible: root.focusing
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.focusText; color: Kirigami.Theme.highlightColor; font.weight: Font.DemiBold
                }
                PC3.Label { textFormat: Text.PlainText;
                    visible: root.compactShowClock
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.clockText; font.weight: Font.DemiBold
                }
            }
        }
    }

    fullRepresentation: FullView { m: root }
}
