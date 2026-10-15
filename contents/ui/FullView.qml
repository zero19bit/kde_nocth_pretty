import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import "../code/jalali.js" as Jalali

Item {
    id: v
    required property var m

    readonly property real pad: Kirigami.Units.largeSpacing * 1.2
    readonly property real cardRadius: m.cardRadius
    readonly property color accent: Kirigami.Theme.highlightColor
    readonly property color cardColor: m.glassMode
                                       ? Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, Math.max(0.20, m.glassOpacity / 100.0 - 0.12))
                                       : Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.055)
    readonly property color cardBorder: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, m.glassMode ? m.glassBorderOpacity / 100.0 : 0.08)
    readonly property color panelColor: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, m.glassMode ? m.glassOpacity / 100.0 : 0.0)
    readonly property color mutedText: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.58)

    Layout.preferredWidth: m.popupWidth
    Layout.minimumWidth: Layout.preferredWidth
    Layout.preferredHeight: col.implicitHeight + 2 * pad
    Layout.minimumHeight: Layout.preferredHeight

    property bool jal: true
    property int cy: 0
    property int cm: 1

    function today() {
        if (jal) { cy = m.jnow.jy; cm = m.jnow.jm }
        else { cy = m.now.getFullYear(); cm = m.now.getMonth() + 1 }
    }
    function shift(n) {
        cm += n
        if (cm > 12) { cm = 1; cy++ }
        if (cm < 1) { cm = 12; cy-- }
    }
    function fmt(us) {
        const s = Math.max(0, Math.floor(us / 1e6))
        return Math.floor(s / 60) + ":" + ("0" + (s % 60)).slice(-2)
    }
    function isToday(d) {
        return jal ? (cy === m.jnow.jy && cm === m.jnow.jm && d === m.jnow.jd)
                   : (cy === m.now.getFullYear() && cm === m.now.getMonth() + 1 && d === m.now.getDate())
    }

    Component.onCompleted: { jal = m.jalaliDefault; today() }

    Rectangle {
        anchors.fill: parent
        visible: v.m.glassMode
        radius: v.cardRadius + 8
        color: v.panelColor
        border.width: 1
        border.color: v.cardBorder
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.06) }
            GradientStop { position: 0.45; color: v.panelColor }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.08) }
        }
    }

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: v.pad }
        spacing: Kirigami.Units.largeSpacing

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            PC3.Label {
                text: v.m.clockText
                font.pixelSize: 46
                font.weight: Font.Light
            }
            PC3.Label {
                Layout.fillWidth: true
                text: Jalali.weekdays[v.m.now.getDay()] + "، " + Jalali.fa(v.m.jnow.jd) + " " + Jalali.months[v.m.jnow.jm - 1] + " " + Jalali.fa(v.m.jnow.jy)
                color: v.accent
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize + 1
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
            }
            PC3.Label {
                Layout.fillWidth: true
                visible: v.m.showGregorianDate
                text: Qt.formatDate(v.m.now, "dddd, d MMMM yyyy")
                color: v.mutedText
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: v.m.showMedia && v.m.hasMedia
            spacing: Kirigami.Units.smallSpacing

            ListView {
                id: mediaList
                Layout.fillWidth: true
                Layout.preferredHeight: 166
                orientation: ListView.Horizontal
                model: v.m.mediaPlayers
                clip: true
                spacing: Kirigami.Units.smallSpacing
                snapMode: ListView.SnapOneItem
                boundsBehavior: Flickable.StopAtBounds
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: 0
                preferredHighlightEnd: 0
                currentIndex: 0

                onCurrentIndexChanged: {
                    if (currentIndex >= 0 && currentIndex < v.m.mediaPlayers.length)
                        v.m.selectPlayer(v.m.mediaPlayers[currentIndex].name)
                }

                delegate: Rectangle {
                    required property var modelData
                    width: mediaList.width
                    height: mediaList.height
                    radius: v.cardRadius
                    color: v.cardColor
                    border.width: 1
                    border.color: v.cardBorder

                    ColumnLayout {
                        anchors { fill: parent; margins: v.pad * 0.9 }
                        spacing: Kirigami.Units.smallSpacing

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.largeSpacing
                            Cover {
                                Layout.preferredWidth: 58
                                Layout.preferredHeight: 58
                                radius: 11
                                source: modelData.artUrl
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Marquee { text: modelData.title; bold: true; maxWidth: Kirigami.Units.gridUnit * 10.5 }
                                PC3.Label { Layout.fillWidth: true; text: modelData.artist || "Unknown artist"; color: v.mutedText; elide: Text.ElideRight }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Kirigami.Icon { source: "applications-multimedia"; color: v.mutedText; Layout.preferredWidth: 13; Layout.preferredHeight: 13 }
                                    PC3.Label { Layout.fillWidth: true; text: modelData.app; color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize; elide: Text.ElideRight }
                                }
                            }
                            Eq { active: modelData.status === "Playing"; color: v.accent; height: 20; Layout.alignment: Qt.AlignTop }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing
                            PC3.Label { text: v.fmt(modelData.pos); color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize }
                            PC3.Slider {
                                id: seekSlider
                                Layout.fillWidth: true
                                from: 0; to: Math.max(1, modelData.len); value: modelData.pos
                                enabled: modelData.len > 0
                                property real pendingValue: value
                                onMoved: pendingValue = value
                                // Seeking only on release avoids spawning a playerctl process for every pixel dragged.
                                onPressedChanged: if (!pressed && enabled)
                                    v.m.mediaActionFor(modelData.name, "position " + (pendingValue / 1e6).toFixed(2))
                            }
                            PC3.Label { text: v.fmt(modelData.len); color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing
                            Item { Layout.fillWidth: true }
                            IconBtn { source: "media-skip-backward"; size: Kirigami.Units.iconSizes.smallMedium; onClicked: v.m.mediaActionFor(modelData.name, "previous") }
                            IconBtn { source: modelData.status === "Playing" ? "media-playback-pause" : "media-playback-start"; size: Kirigami.Units.iconSizes.medium; onClicked: v.m.mediaActionFor(modelData.name, "play-pause") }
                            IconBtn { source: "media-skip-forward"; size: Kirigami.Units.iconSizes.smallMedium; onClicked: v.m.mediaActionFor(modelData.name, "next") }
                            Item { Layout.fillWidth: true }
                            Kirigami.Icon { source: modelData.vol <= 0.01 ? "audio-volume-muted" : "audio-volume-high"; color: Kirigami.Theme.textColor; Layout.preferredWidth: Kirigami.Units.iconSizes.small; Layout.preferredHeight: Kirigami.Units.iconSizes.small }
                            PC3.Slider {
                                id: playerVolumeSlider
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 4.5
                                from: 0; to: 1; value: modelData.vol
                                property real pendingValue: value
                                onMoved: {
                                    pendingValue = value
                                    playerVolumeApply.restart()
                                }
                                onPressedChanged: if (!pressed) {
                                    playerVolumeApply.stop()
                                    v.m.mediaActionFor(modelData.name, "volume " + pendingValue.toFixed(2))
                                }
                                Timer {
                                    id: playerVolumeApply
                                    interval: 90
                                    repeat: false
                                    onTriggered: v.m.mediaActionFor(modelData.name, "volume " + playerVolumeSlider.pendingValue.toFixed(2))
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                visible: v.m.mediaPlayers.length > 1
                spacing: 6
                Repeater {
                    model: v.m.mediaPlayers.length
                    Rectangle {
                        required property int index
                        width: index === mediaList.currentIndex ? 16 : 6
                        height: 6; radius: 3
                        color: index === mediaList.currentIndex ? v.accent : v.cardBorder
                        Behavior on width { NumberAnimation { duration: 140 } }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { mediaList.currentIndex = parent.index; mediaList.positionViewAtIndex(parent.index, ListView.Beginning) }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: v.cardRadius
            color: v.cardColor
            border.width: 1; border.color: v.cardBorder
            visible: v.m.showCalendar
            implicitHeight: cal.implicitHeight + 2 * (v.pad * 0.82)

            ColumnLayout {
                id: cal
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: v.pad * 0.82 }
                spacing: Kirigami.Units.smallSpacing
                RowLayout {
                    Layout.fillWidth: true
                    IconBtn { source: "go-previous"; onClicked: v.shift(v.jal ? 1 : -1) }
                    PC3.Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.weight: Font.DemiBold
                        text: v.jal ? Jalali.months[v.cm - 1] + " " + Jalali.fa(v.cy) : Qt.formatDate(new Date(v.cy, v.cm - 1, 1), "MMMM yyyy")
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { v.jal = !v.jal; v.today() } }
                    }
                    IconBtn { source: "go-next"; onClicked: v.shift(v.jal ? -1 : 1) }
                }
                GridLayout {
                    columns: 7; columnSpacing: 2; rowSpacing: 1
                    Layout.fillWidth: true
                    LayoutMirroring.enabled: v.jal; LayoutMirroring.childrenInherit: true
                    Repeater {
                        model: v.jal ? ["ش", "ی", "د", "س", "چ", "پ", "ج"] : ["M", "T", "W", "T", "F", "S", "S"]
                        PC3.Label {
                            required property string modelData
                            Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.preferredHeight: 21
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize; font.weight: Font.Medium
                            text: modelData
                        }
                    }
                    Repeater {
                        model: Jalali.monthCells(v.jal, v.cy, v.cm)
                        Item {
                            id: cell
                            required property int modelData
                            required property int index
                            readonly property bool isToday: modelData > 0 && v.isToday(modelData)
                            readonly property bool weekend: v.jal ? (index % 7 === 6) : (index % 7 >= 5)
                            Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.preferredHeight: 30
                            Rectangle { anchors.centerIn: parent; width: 28; height: 28; radius: 14; color: cell.isToday ? v.accent : "transparent" }
                            PC3.Label {
                                anchors.centerIn: parent
                                text: cell.modelData > 0 ? (v.jal ? Jalali.fa(cell.modelData) : cell.modelData) : ""
                                color: cell.isToday ? Kirigami.Theme.highlightedTextColor : (cell.weekend ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor)
                                font.weight: cell.isToday ? Font.DemiBold : Font.Normal
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: v.cardRadius
            color: v.cardColor
            border.width: 1; border.color: v.cardBorder
            visible: v.m.showFocus
            implicitHeight: ft.implicitHeight + 2 * (v.pad * 0.72)
            ColumnLayout {
                id: ft
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: v.pad * 0.72 }
                spacing: Kirigami.Units.smallSpacing
                RowLayout {
                    Layout.fillWidth: true
                    LayoutMirroring.enabled: true; LayoutMirroring.childrenInherit: true
                    Kirigami.Icon { source: "chronometer"; color: v.m.focusing ? v.accent : Kirigami.Theme.textColor; Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium; Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium }
                    PC3.Label { Layout.fillWidth: true; text: v.m.focusing ? "تمرکز  " + v.m.focusText : "تایمر تمرکز"; font.weight: v.m.focusing ? Font.DemiBold : Font.Medium; horizontalAlignment: Text.AlignRight }
                    Repeater {
                        model: v.m.focusing ? [] : [v.m.focusPreset1, v.m.focusPreset2, v.m.focusPreset3]
                        Rectangle {
                            required property int modelData
                            Layout.preferredWidth: 54; Layout.preferredHeight: 28; radius: 9
                            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.07)
                            border.width: 1; border.color: v.cardBorder
                            PC3.Label { anchors.centerIn: parent; text: Jalali.fa(parent.modelData); font.pixelSize: Kirigami.Theme.smallFont.pixelSize; font.weight: Font.Medium }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: v.m.startFocus(parent.modelData) }
                        }
                    }
                    PC3.Button { visible: v.m.focusing; text: "توقف"; onClicked: v.m.stopFocus() }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 3; radius: 2; visible: v.m.focusing
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.10)
                    Rectangle { height: parent.height; radius: 2; color: v.accent; width: parent.width * (1 - v.m.focusLeft / Math.max(1, v.m.focusTotal)); Behavior on width { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } } }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            visible: v.m.showQuickControls
            radius: v.cardRadius
            color: v.cardColor
            border.width: 1; border.color: v.cardBorder
            implicitHeight: quickCol.implicitHeight + 2 * (v.pad * 0.72)

            ColumnLayout {
                id: quickCol
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: v.pad * 0.72 }
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true
                    PC3.Label { text: "Quick controls"; font.weight: Font.DemiBold }
                    Item { Layout.fillWidth: true }
                    IconBtn { source: "configure"; onClicked: v.m.openConfiguration() }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Kirigami.Units.smallSpacing
                    rowSpacing: Kirigami.Units.smallSpacing

                    QuickTile {
                        visible: v.m.showWifiTile
                        Layout.fillWidth: true
                        iconName: "network-wireless"
                        title: "Wi‑Fi"
                        subtitle: v.m.wifiOn ? (v.m.wifiSsid || "On") + (v.m.wifiSignal >= 0 ? " · " + v.m.wifiSignal + "%" : "") : "Off"
                        active: v.m.wifiOn
                        glassMode: v.m.glassMode
                        glassOpacity: v.m.glassOpacity
                        glassBorderOpacity: v.m.glassBorderOpacity
                        onClicked: v.m.toggleWifi()
                    }
                    QuickTile {
                        visible: v.m.showBluetoothTile
                        Layout.fillWidth: true
                        iconName: "preferences-system-bluetooth"
                        title: "Bluetooth"
                        subtitle: v.m.bluetoothOn ? (v.m.bluetoothConnected > 0 ? v.m.bluetoothConnected + " connected" : "On") : "Off"
                        active: v.m.bluetoothOn
                        glassMode: v.m.glassMode
                        glassOpacity: v.m.glassOpacity
                        glassBorderOpacity: v.m.glassBorderOpacity
                        onClicked: v.m.toggleBluetooth()
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: v.m.showVolumeControl
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        IconBtn { source: v.m.systemMuted ? "audio-volume-muted" : "audio-volume-high"; onClicked: v.m.toggleSystemMute() }
                        PC3.Label { text: "Volume"; font.weight: Font.Medium }
                        Item { Layout.fillWidth: true }
                        PC3.Label { text: v.m.systemMuted ? "Muted" : v.m.systemVolume + "%"; color: v.mutedText }
                    }
                    PC3.Slider {
                        Layout.fillWidth: true
                        from: 0; to: 150; value: v.m.systemVolume
                        onMoved: v.m.setSystemVolume(value)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: v.m.showBrightnessControl
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        Kirigami.Icon { source: "brightness-high"; Layout.preferredWidth: 20; Layout.preferredHeight: 20 }
                        PC3.Label { text: "Brightness"; font.weight: Font.Medium }
                        PC3.Label {
                            visible: v.m.brightnessDevice.length > 0
                            text: "· " + v.m.brightnessDevice
                            color: v.mutedText
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            elide: Text.ElideRight
                            Layout.maximumWidth: 130
                        }
                        Item { Layout.fillWidth: true }
                        PC3.Label { text: v.m.brightness >= 0 ? v.m.brightness + "%" : "Unavailable"; color: v.mutedText }
                    }
                    PC3.Slider {
                        Layout.fillWidth: true
                        enabled: v.m.brightness >= 0
                        from: 1; to: 100; value: Math.max(1, v.m.brightness)
                        onMoved: v.m.setBrightness(value)
                    }
                    PC3.Label {
                        Layout.fillWidth: true
                        visible: v.m.brightness < 0
                        wrapMode: Text.WordWrap
                        color: v.mutedText
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        text: "No controllable brightness backend found. Notch tries KDE PowerDevil first, then brightnessctl."
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: v.m.showMicControl
                    PC3.Button {
                        Layout.fillWidth: true
                        icon.name: v.m.micMuted ? "microphone-sensitivity-muted" : "audio-input-microphone"
                        text: v.m.micMuted ? "Unmute microphone" : "Mute microphone"
                        onClicked: v.m.toggleMicMute()
                    }
                    PC3.Button {
                        text: "Audio settings"
                        onClicked: v.m.openAudioSettings()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            visible: v.m.showConnectivity
            radius: v.cardRadius
            color: v.cardColor
            border.width: 1; border.color: v.cardBorder
            implicitHeight: connCol.implicitHeight + 2 * (v.pad * 0.72)

            ColumnLayout {
                id: connCol
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: v.pad * 0.72 }
                spacing: Kirigami.Units.smallSpacing
                PC3.Label { text: "Connectivity"; font.weight: Font.DemiBold }
                RowLayout {
                    Layout.fillWidth: true
                    PC3.Button {
                        Layout.fillWidth: true
                        icon.name: "network-wireless"
                        text: v.m.wifiOn ? (v.m.wifiSsid || "Wi‑Fi on") : "Wi‑Fi off"
                        onClicked: v.m.openNetworkSettings()
                    }
                    PC3.Button {
                        Layout.fillWidth: true
                        icon.name: "preferences-system-bluetooth"
                        text: v.m.bluetoothOn ? (v.m.bluetoothConnected > 0 ? "Bluetooth · " + v.m.bluetoothConnected : "Bluetooth on") : "Bluetooth off"
                        onClicked: v.m.openBluetoothSettings()
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: v.m.showNetworkSpeed
                    PC3.Label { text: "↓ " + v.m.formatRate(v.m.netDown); color: v.mutedText }
                    Item { Layout.fillWidth: true }
                    PC3.Label { text: "↑ " + v.m.formatRate(v.m.netUp); color: v.mutedText }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            visible: v.m.showSystem
            radius: v.cardRadius
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.28)
            border.width: 1; border.color: v.cardBorder
            implicitHeight: sysCol.implicitHeight + 2 * (v.pad * 0.68)

            ColumnLayout {
                id: sysCol
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: v.pad * 0.68 }
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing
                    Repeater {
                        model: [
                            { n: "RAM", f: v.m.ram / 100, t: v.m.ram + "%", s: v.m.ramUsedGiB.toFixed(1) + "/" + v.m.ramTotalGiB.toFixed(1) + " GB" },
                            { n: "CPU", f: v.m.cpu / 100, t: v.m.cpu + "%", s: v.m.showCpuTemp ? (v.m.cpuTemp >= 0 ? v.m.cpuTemp + "°C" : "—") : "" },
                            { show: v.m.showBattery, n: "BAT", f: v.m.battery >= 0 ? v.m.battery / 100 : 0, t: v.m.battery >= 0 ? v.m.battery + "%" : "—", s: v.m.batteryTime || v.m.batteryStatus || "—" }
                        ]
                        ColumnLayout {
                            required property var modelData
                            visible: modelData.show === undefined ? true : modelData.show
                            Layout.fillWidth: true; Layout.preferredWidth: 1; spacing: 2
                            RowLayout {
                                Layout.fillWidth: true
                                PC3.Label { text: modelData.n; color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize; font.weight: Font.Medium }
                                Item { Layout.fillWidth: true }
                                PC3.Label { text: modelData.t; font.pixelSize: Kirigami.Theme.smallFont.pixelSize }
                            }
                            PC3.Label { Layout.fillWidth: true; text: modelData.s; color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize; elide: Text.ElideRight }
                            Rectangle {
                                Layout.fillWidth: true; height: 3; radius: 2
                                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.10)
                                Rectangle { height: parent.height; radius: 2; color: v.accent; width: parent.width * Math.max(0, Math.min(1, modelData.f)); Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } } }
                            }
                        }
                    }
                }


            }
        }
    }
}
