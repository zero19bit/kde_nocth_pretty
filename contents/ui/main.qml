import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../code/jalali.js" as Jalali

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: root.glassMode ? PlasmaCore.Types.TranslucentBackground : PlasmaCore.Types.DefaultBackground

    property date now: new Date()
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
    readonly property bool compactShowClock: plasmoid.configuration.compactShowClock
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
    property real pendingSystemVolume: -1
    property real pendingBrightness: -1
    property string pendingMediaPlayer: ""
    property string pendingMediaAction: ""

    property double prevCpuTotal: 0
    property double prevCpuIdle: 0
    property double prevRx: -1
    property double prevTx: -1
    property double prevNetMs: 0

    property int focusLeft: 0
    property int focusTotal: 0
    readonly property bool focusing: focusLeft > 0
    readonly property string focusText: Math.floor(focusLeft / 60) + ":" + ("0" + (focusLeft % 60)).slice(-2)

    toolTipMainText: hasMedia ? title : clockText
    toolTipSubText: hasMedia ? artist : Jalali.fa(jnow.jd) + " " + Jalali.months[jnow.jm - 1]

    readonly property string mediaCmd: "playerctl -a metadata --format '{{playerName}}|||{{status}}|||{{artist}}|||{{title}}|||{{mpris:artUrl}}|||{{position}}|||{{mpris:length}}|||{{volume}}|||{{xesam:url}}' 2>/dev/null"
    readonly property string batteryCmd: "sh -c 'd=\"\"; for x in /sys/class/power_supply/BAT*; do [ -d \"$x\" ] && d=\"$x\" && break; done; [ -z \"$d\" ] && exit 0; c=$(cat \"$d/capacity\" 2>/dev/null); s=$(cat \"$d/status\" 2>/dev/null); e=$(cat \"$d/energy_now\" 2>/dev/null); [ -z \"$e\" ] && e=$(cat \"$d/charge_now\" 2>/dev/null); p=$(cat \"$d/power_now\" 2>/dev/null); [ -z \"$p\" ] && p=$(cat \"$d/current_now\" 2>/dev/null); echo \"$c|$s|$e|$p\"'"
    readonly property string tempCmd: "sh -c 'for f in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input; do [ -r \"$f\" ] || continue; v=$(cat \"$f\" 2>/dev/null); [ -n \"$v\" ] && echo \"$v\"; done'"
    readonly property string wifiCmd: "sh -c 'state=$(nmcli -t -f WIFI general 2>/dev/null); ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | sed -n \"s/^yes://p\" | head -n1); sig=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | sed -n \"s/^\\*://p\" | head -n1); printf \"%s|%s|%s\\n\" \"$state\" \"$ssid\" \"$sig\"'"
    readonly property string bluetoothCmd: "sh -c 'p=$(bluetoothctl show 2>/dev/null | sed -n \"s/^[[:space:]]*Powered: //p\" | head -n1); c=$(bluetoothctl devices Connected 2>/dev/null | wc -l); printf \"%s|%s\\n\" \"$p\" \"$c\"'"
    readonly property string audioCmd: "sh -c 'wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true'"
    readonly property string micCmd: "sh -c 'wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true'"
    readonly property string brightnessCmd: "sh -c 'if command -v qdbus6 >/dev/null 2>&1; then for svc in org.kde.Solid.PowerManagement org.kde.org_kde_powerdevil local.org_kde_powerdevil; do cur=$(qdbus6 $svc /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightness 2>/dev/null); max=$(qdbus6 $svc /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightnessMax 2>/dev/null); if [ -n \"$cur\" ] && [ -n \"$max\" ]; then printf \"powerdevil|%s|%s|%s\n\" \"$svc\" \"$cur\" \"$max\"; exit 0; fi; done; fi; if command -v brightnessctl >/dev/null 2>&1; then line=$(brightnessctl -m -c backlight 2>/dev/null | head -n1); [ -n \"$line\" ] && printf \"brightnessctl|%s\n\" \"$line\"; fi'"

    function run(cmd) { runner.connectSource(cmd) }
    function quoteArg(s) {
        return "\"" + String(s).replace(/\\/g, "\\\\").replace(/\"/g, "\\\"").replace(/\$/g, "\\$").replace(/`/g, "\\`") + "\""
    }
    function cmdFor(player, action) {
        return player ? "playerctl -p " + quoteArg(player) + " " + action : "playerctl " + action
    }
    function updatePlayerOptimistic(player, action) {
        if (!mediaPlayers || mediaPlayers.length === 0) return
        let out = []
        for (let i = 0; i < mediaPlayers.length; ++i) {
            let p = mediaPlayers[i]
            if (p.name === player) {
                let q = {
                    name: p.name, app: p.app, status: p.status, artist: p.artist,
                    title: p.title, artUrl: p.artUrl, pos: p.pos, len: p.len, vol: p.vol
                }
                if (action === "play-pause") q.status = p.status === "Playing" ? "Paused" : "Playing"
                p = q
            }
            out.push(p)
        }
        mediaPlayers = out
        if (player === activePlayer && action === "play-pause")
            status = status === "Playing" ? "Paused" : "Playing"
    }

    function mediaActionFor(player, action) {
        if (!player) return
        updatePlayerOptimistic(player, action)
        actionRunner.connectSource(cmdFor(player, action) + " >/dev/null 2>&1")
        pendingMediaPlayer = player
        pendingMediaAction = action
        mediaRefreshFast.restart()
    }

    function mediaAction(action) { mediaActionFor(activePlayer, action) }
    function startFocus(min) { focusTotal = min * 60; focusLeft = focusTotal }
    function stopFocus() { focusLeft = 0 }

    function openConfiguration() {
        try {
            const action = Plasmoid.internalAction("configure")
            if (action) action.trigger()
        } catch (e) {}
    }

    function toggleWifi() {
        run("nmcli radio wifi " + (wifiOn ? "off" : "on"))
        refreshConnectivity.restart()
    }
    function toggleBluetooth() {
        run("bluetoothctl power " + (bluetoothOn ? "off" : "on"))
        refreshConnectivity.restart()
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
        run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        systemMuted = !systemMuted
    }
    function toggleMicMute() {
        run("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
        micMuted = !micMuted
    }
    function setBrightness(pct) {
        const p = Math.max(1, Math.min(100, Math.round(pct)))
        brightness = p
        pendingBrightness = p
        brightnessApply.restart()
    }

    function applyBrightnessNow() {
        if (pendingBrightness < 0) return
        const p = pendingBrightness
        pendingBrightness = -1
        if (brightnessBackend === "powerdevil" && brightnessMaxRaw > 0 && brightnessService.length > 0) {
            const raw = Math.max(1, Math.round(brightnessMaxRaw * p / 100))
            actionRunner.connectSource("qdbus6 " + brightnessService + " /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightnessSilent " + raw + " >/dev/null 2>&1")
        } else if (brightnessBackend === "brightnessctl") {
            actionRunner.connectSource("brightnessctl -q -c backlight set " + p + "% >/dev/null 2>&1")
        }
        brightnessRefresh.restart()
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
        const lines = out.split("\n").filter(x => x.trim().length > 0)
        let items = []
        for (let i = 0; i < lines.length; ++i) {
            const p = lines[i].split("|||")
            if (p.length < 8 || p[1] === "Stopped") continue
            const vv = Number(p[7])
            items.push({
                name: p[0], app: playerLabel(p[0]), status: p[1], artist: p[2],
                title: p[3] || "Unknown", artUrl: p[4], pos: Number(p[5]) || 0,
                len: Number(p[6]) || 0, vol: isNaN(vv) ? 1 : Math.max(0, Math.min(1, vv))
            })
        }
        items.sort((a, b) => (a.status === "Playing" ? 0 : 1) - (b.status === "Playing" ? 0 : 1))
        mediaPlayers = items
        hasMedia = items.length > 0
        if (!hasMedia) {
            activePlayer = ""; status = ""; artist = ""; title = ""; artUrl = ""; pos = 0; len = 0; vol = 1
            return
        }
        let idx = items.findIndex(x => x.name === activePlayer)
        if (idx < 0) idx = 0
        selectPlayer(items[idx].name)
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
        for (let i = 0; i < p.length; ++i) total += p[i] || 0
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
        const vals = out.split(/\s+/).map(Number).filter(x => isFinite(x) && x > 1000 && x < 150000)
        if (!vals.length) { cpuTemp = -1; return }
        let best = -1
        for (let i = 0; i < vals.length; ++i) {
            const c = vals[i] / 1000
            if (c >= 20 && c <= 115) best = Math.max(best, c)
        }
        cpuTemp = best < 0 ? -1 : Math.round(best)
    }

    function parseNet(out) {
        const lines = out.split("\n")
        let rx = 0, tx = 0
        for (let i = 0; i < lines.length; ++i) {
            const m = lines[i].match(/^\s*([^:]+):\s*(.*)$/)
            if (!m || m[1].trim() === "lo") continue
            const f = m[2].trim().split(/\s+/)
            if (f.length >= 9) { rx += Number(f[0]) || 0; tx += Number(f[8]) || 0 }
        }
        const ms = Date.now()
        if (prevRx >= 0 && prevNetMs > 0 && ms > prevNetMs) {
            const sec = (ms - prevNetMs) / 1000
            netDown = Math.max(0, (rx - prevRx) / sec)
            netUp = Math.max(0, (tx - prevTx) / sec)
        }
        prevRx = rx; prevTx = tx; prevNetMs = ms
    }

    function parseBattery(out) {
        if (!out) { battery = -1; batteryStatus = ""; batteryTime = ""; return }
        const p = out.split("|")
        battery = parseInt(p[0])
        if (isNaN(battery)) battery = -1
        batteryStatus = p[1] || ""
        const e = Number(p[2]) || 0
        const power = Number(p[3]) || 0
        batteryTime = ""
        if (e > 0 && power > 0 && batteryStatus.indexOf("Discharging") >= 0) {
            const h = e / power
            const hh = Math.floor(h), mm = Math.round((h - hh) * 60)
            batteryTime = hh + "h " + mm + "m"
        }
    }

    function parseWifi(out) {
        const p = out.split("|")
        wifiOn = (p[0] || "").toLowerCase().indexOf("enabled") >= 0
        wifiSsid = p[1] || ""
        const sig = parseInt(p[2])
        wifiSignal = isNaN(sig) ? -1 : sig
    }
    function parseBluetooth(out) {
        const p = out.split("|")
        bluetoothOn = (p[0] || "").toLowerCase().indexOf("yes") >= 0
        const c = parseInt(p[1])
        bluetoothConnected = isNaN(c) ? 0 : c
    }
    function parseAudio(out) {
        const m = out.match(/Volume:\s*([0-9.]+)/)
        if (m) systemVolume = Math.round(Number(m[1]) * 100)
        systemMuted = out.indexOf("[MUTED]") >= 0
    }
    function parseMic(out) {
        micMuted = out.indexOf("[MUTED]") >= 0
    }
    function parseBrightness(out) {
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
                brightness = Math.max(1, Math.min(100, Math.round(cur * 100 / max)))
                return
            }
        }
        if (line.indexOf("brightnessctl|") === 0) {
            const rawLine = line.substring("brightnessctl|".length)
            const p = rawLine.split(",")
            const raw = p.length >= 5 ? p[4] : ""
            const n = parseInt(String(raw).replace("%", ""))
            brightnessBackend = isNaN(n) ? "" : "brightnessctl"
            brightnessService = ""
            brightnessDevice = p.length > 0 ? p[0] : ""
            brightnessMaxRaw = 0
            brightness = isNaN(n) ? -1 : Math.max(1, Math.min(100, n))
            return
        }
        brightness = -1; brightnessBackend = ""; brightnessDevice = ""; brightnessMaxRaw = 0; brightnessService = ""
    }

    Timer {
        id: mediaRefreshFast
        interval: 90
        repeat: false
        onTriggered: {
            mediaProbe.connectSource(root.mediaCmd)
            mediaRefreshSecond.restart()
        }
    }

    Timer {
        id: mediaRefreshSecond
        interval: 280
        repeat: false
        onTriggered: mediaProbe.connectSource(root.mediaCmd)
    }

    Timer {
        id: volumeApply
        interval: 70
        repeat: false
        onTriggered: {
            if (root.pendingSystemVolume < 0) return
            const p = root.pendingSystemVolume
            root.pendingSystemVolume = -1
            actionRunner.connectSource("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + p + "% >/dev/null 2>&1")
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
        onNewData: (source, data) => disconnectSource(source)
    }

    P5Support.DataSource {
        id: mediaProbe
        engine: "executable"
        onNewData: (source, data) => {
            root.parseMedia((data.stdout || "").trim())
            disconnectSource(source)
        }
    }

    Timer {
        id: brightnessRefresh
        interval: 180
        repeat: false
        onTriggered: runner.connectSource(root.brightnessCmd)
    }

    P5Support.DataSource {
        id: runner
        engine: "executable"
        onNewData: (source, data) => disconnectSource(source)
    }

    P5Support.DataSource {
        engine: "executable"; interval: 700
        connectedSources: [root.mediaCmd]
        onNewData: (source, data) => root.parseMedia((data.stdout || "").trim())
    }

    P5Support.DataSource {
        engine: "executable"; interval: 1500
        connectedSources: ["grep '^cpu ' /proc/stat", "cat /proc/net/dev"]
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            if (source.indexOf("/proc/stat") >= 0) root.parseCpu(o.replace(/^cpu\s+/, ""))
            else root.parseNet(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: 5000
        connectedSources: ["free -b", root.tempCmd, root.batteryCmd]
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            if (source === "free -b") root.parseRam(o)
            else if (source === root.tempCmd) root.parseTemp(o)
            else if (source === root.batteryCmd) root.parseBattery(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: 12000
        connectedSources: [root.wifiCmd, root.bluetoothCmd]
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            if (source === root.wifiCmd) root.parseWifi(o)
            else if (source === root.bluetoothCmd) root.parseBluetooth(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: 3000
        connectedSources: [root.audioCmd, root.micCmd]
        onNewData: (source, data) => {
            const o = (data.stdout || "").trim()
            if (source === root.audioCmd) root.parseAudio(o)
            else if (source === root.micCmd) root.parseMic(o)
        }
    }

    P5Support.DataSource {
        engine: "executable"; interval: 7000
        connectedSources: [root.brightnessCmd]
        onNewData: (source, data) => root.parseBrightness((data.stdout || "").trim())
    }

    Timer {
        id: refreshConnectivity
        interval: 900; repeat: false
        onTriggered: {
            runner.connectSource(root.wifiCmd)
            runner.connectSource(root.bluetoothCmd)
            runner.connectSource(root.audioCmd)
            runner.connectSource(root.micCmd)
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            root.now = new Date()
            if (root.focusLeft > 0) {
                root.focusLeft--
                if (root.focusLeft === 0)
                    root.run("notify-send -a Notch -i chronometer 'تمرکز تموم شد' 'وقت استراحته'")
            }
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
            height: Math.min(parent.height - 4, Kirigami.Units.gridUnit * 1.9)
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
                PC3.Label {
                    visible: (!root.hasMedia || !root.compactShowMedia) && !root.compactShowClock
                    anchors.verticalCenter: parent.verticalCenter
                    text: Jalali.fa(root.jnow.jd) + " " + Jalali.months[root.jnow.jm - 1]
                }

                Eq {
                    visible: root.hasMedia && root.compactShowMedia && !cr.hovered
                    anchors.verticalCenter: parent.verticalCenter
                    active: root.playing; color: Kirigami.Theme.highlightColor
                }
                Row {
                    visible: root.hasMedia && root.compactShowMedia && cr.hovered
                    anchors.verticalCenter: parent.verticalCenter
                    IconBtn { source: "media-skip-backward"; onClicked: root.mediaAction("previous") }
                    IconBtn { source: root.playing ? "media-playback-pause" : "media-playback-start"; onClicked: root.mediaAction("play-pause") }
                    IconBtn { source: "media-skip-forward"; onClicked: root.mediaAction("next") }
                }

                PC3.Label {
                    visible: root.focusing
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.focusText; color: Kirigami.Theme.highlightColor; font.weight: Font.DemiBold
                }
                PC3.Label {
                    visible: root.compactShowClock
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.clockText; font.weight: Font.DemiBold
                }
            }
        }
    }

    fullRepresentation: FullView { m: root }
}
