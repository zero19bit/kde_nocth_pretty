import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import "../code/jalali.js" as Jalali
import "../code/calendar.js" as Calendar

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
    Layout.minimumWidth: 320
    Layout.preferredHeight: Math.min(col.implicitHeight + 2 * pad, Math.max(240, Screen.height - 100), 820)
    Layout.minimumHeight: 180

    property int calType: m.calendarType
    property int cy: 0
    property int cm: 1
    property bool followingToday: true
    readonly property bool calendarRtl: calType !== 1

    function today() {
        const p = Calendar.parts(m.calendarDay, calType, m.hijriAdjustment)
        cy = p.y; cm = p.m; followingToday = true
    }
    function shift(n) {
        let year = cy, month = cm + n
        if (month > 12) { month = 1; year++ }
        if (month < 1) { month = 12; year-- }
        if (year < 1 || year > 3177) return
        followingToday = false; cy = year; cm = month
    }
    function fmt(us) {
        const seconds = Math.max(0, Math.floor(us / 1e6))
        return Math.floor(seconds / 60) + ":" + ("0" + (seconds % 60)).slice(-2)
    }
    function isToday(d) {
        const p = Calendar.parts(m.calendarDay, calType, m.hijriAdjustment)
        return cy === p.y && cm === p.m && d === p.d
    }

    Component.onCompleted: { today(); m.detailsVisible = visible }
    onVisibleChanged: m.detailsVisible = visible
    Component.onDestruction: m.detailsVisible = false
    Connections {
        target: v.m
        function onCalendarTypeChanged() { v.calType = v.m.calendarType; v.today() }
        function onHijriAdjustmentChanged() { if (v.followingToday) v.today() }
        function onCalendarDayChanged() { if (v.followingToday) v.today() }
    }

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

    Controls.ScrollView {
        id: scroll
        anchors.fill: parent
        padding: v.pad
        clip: true
        contentWidth: availableWidth
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff

    ColumnLayout {
        id: col
        width: scroll.availableWidth
        spacing: Kirigami.Units.largeSpacing

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            PC3.Label { textFormat: Text.PlainText;
                text: v.m.clockText
                font.pixelSize: 46
                font.weight: Font.Light
            }
            PC3.Label { textFormat: Text.PlainText;
                Layout.fillWidth: true
                text: v.m.dateText
                wrapMode: Text.WordWrap
                color: v.accent
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize + 1
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
            }
            PC3.Label { textFormat: Text.PlainText;
                Layout.fillWidth: true
                visible: v.m.showGregorianDate && v.m.calendarType !== 1
                text: Calendar.dateText(v.m.calendarDay, 1, v.m.hijriAdjustment)
                wrapMode: Text.WordWrap
                color: v.mutedText
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            }
        }

        PC3.Label { textFormat: Text.PlainText;
            Layout.fillWidth: true
            visible: v.m.showJalaliDate && v.m.calendarType !== 0
            text: Calendar.dateText(v.m.calendarDay, 0, v.m.hijriAdjustment)
            wrapMode: Text.WordWrap
            color: v.mutedText
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        }
        PC3.Label { textFormat: Text.PlainText;
            Layout.fillWidth: true
            visible: v.m.showHijriDate && v.m.calendarType !== 2
            text: Calendar.dateText(v.m.calendarDay, 2, v.m.hijriAdjustment)
            wrapMode: Text.WordWrap
            color: v.mutedText
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        }
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: errorRow.implicitHeight + 16
            visible: v.m.lastError.length > 0
            radius: v.cardRadius
            color: Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.12)
            RowLayout {
                id: errorRow
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                PC3.Label { textFormat: Text.PlainText; Layout.fillWidth: true; text: v.m.lastError; wrapMode: Text.WrapAnywhere; color: Kirigami.Theme.negativeTextColor }
                IconBtn { source: "dialog-close"; onClicked: v.m.lastError = "" }
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
                function syncIndex() {
                    const index = v.m.mediaPlayers.findIndex(p => p.name === v.m.activePlayer)
                    if (index >= 0 && index !== currentIndex) {
                        currentIndex = index
                        positionViewAtIndex(index, ListView.Beginning)
                    }
                }
                Component.onCompleted: Qt.callLater(syncIndex)
                Connections {
                    target: v.m
                    function onMediaPlayersChanged() { Qt.callLater(mediaList.syncIndex) }
                    function onActivePlayerChanged() { Qt.callLater(mediaList.syncIndex) }
                }
                onCurrentIndexChanged: {
                    if (!v.m.updatingPlayers && currentIndex >= 0 && currentIndex < v.m.mediaPlayers.length)
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
                                Marquee { Layout.fillWidth: true; text: modelData.title; bold: true; maxWidth: Math.max(20, mediaList.width - 130) }
                                PC3.Label { textFormat: Text.PlainText; Layout.fillWidth: true; text: modelData.artist || "Unknown artist"; color: v.mutedText; elide: Text.ElideRight }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Kirigami.Icon { source: "applications-multimedia"; color: v.mutedText; Layout.preferredWidth: 13; Layout.preferredHeight: 13 }
                                    PC3.Label { textFormat: Text.PlainText; Layout.fillWidth: true; text: modelData.app; color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize; elide: Text.ElideRight }
                                }
                            }
                            Eq { active: modelData.status === "Playing" && v.visible; color: v.accent; height: 20; Layout.alignment: Qt.AlignTop }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing
                            PC3.Label { textFormat: Text.PlainText; text: v.fmt(modelData.pos); color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize }
                            PC3.Slider {
                                id: seekSlider
                                Layout.fillWidth: true
                                from: 0; to: Math.max(1, modelData.len)
                                Binding { target: seekSlider; property: "value"; value: modelData.pos; when: !seekSlider.pressed && !seekSlider.dirty }
                                enabled: modelData.len > 0
                                property real pendingValue: 0
                                property bool dirty: false
                                function applySeek() {
                                    if (!dirty || !enabled) return
                                    v.m.mediaActionFor(modelData.name, "position " + (pendingValue / 1e6).toFixed(2))
                                    dirty = false
                                }
                                onMoved: {
                                    pendingValue = value; dirty = true
                                    if (!pressed) applySeek()
                                }
                                onPressedChanged: if (!pressed) applySeek()
                            }
                            PC3.Label { textFormat: Text.PlainText; text: v.fmt(modelData.len); color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize }
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
                                from: 0; to: 1
                                Binding { target: playerVolumeSlider; property: "value"; value: modelData.vol; when: !playerVolumeSlider.pressed && !playerVolumeSlider.dirty }
                                property real pendingValue: 0
                                property bool dirty: false
                                function applyVolume() {
                                    if (!dirty) return
                                    v.m.mediaActionFor(modelData.name, "volume " + pendingValue.toFixed(2))
                                    dirty = false
                                }
                                onMoved: {
                                    pendingValue = value; dirty = true
                                    playerVolumeApply.restart()
                                }
                                onPressedChanged: if (!pressed) {
                                    playerVolumeApply.stop(); applyVolume()
                                }
                                Timer {
                                    id: playerVolumeApply
                                    interval: 90
                                    repeat: false
                                    onTriggered: playerVolumeSlider.applyVolume()
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
                    Controls.ComboBox {
                        Layout.fillWidth: true
                        model: ["شمسی — Jalali", "میلادی — Gregorian", "قمری — Hijri"]
                        currentIndex: v.calType
                        onActivated: { v.calType = currentIndex; v.today() }
                    }
                    PC3.Button { text: "امروز"; onClicked: v.today() }
                }
                RowLayout {
                    Layout.fillWidth: true
                    LayoutMirroring.enabled: false
                    IconBtn { source: "go-previous"; onClicked: v.shift(v.calendarRtl ? 1 : -1) }
                    PC3.Label { textFormat: Text.PlainText;
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.weight: Font.DemiBold
                        text: Calendar.monthName(v.cm, v.calType) + " " + Calendar.number(v.cy, v.calType)
                    }
                    IconBtn { source: "go-next"; onClicked: v.shift(v.calendarRtl ? -1 : 1) }
                }
                GridLayout {
                    columns: 7; columnSpacing: 2; rowSpacing: 1
                    Layout.fillWidth: true
                    LayoutMirroring.enabled: v.calendarRtl; LayoutMirroring.childrenInherit: true
                    Repeater {
                        model: v.calendarRtl ? ["ش", "ی", "د", "س", "چ", "پ", "ج"] : ["M", "T", "W", "T", "F", "S", "S"]
                        PC3.Label { textFormat: Text.PlainText;
                            required property string modelData
                            Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.preferredHeight: 21
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize; font.weight: Font.Medium
                            text: modelData
                        }
                    }
                    Repeater {
                        model: Calendar.monthCells(v.calType, v.cy, v.cm, v.m.hijriAdjustment)
                        Item {
                            id: cell
                            required property int modelData
                            required property int index
                            readonly property bool isToday: modelData > 0 && v.isToday(modelData)
                            readonly property bool weekend: v.calendarRtl ? (index % 7 === 6) : (index % 7 >= 5)
                            Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.preferredHeight: 30
                            Rectangle { anchors.centerIn: parent; width: 28; height: 28; radius: 14; color: cell.isToday ? v.accent : "transparent" }
                            PC3.Label { textFormat: Text.PlainText;
                                anchors.centerIn: parent
                                text: cell.modelData > 0 ? Calendar.number(cell.modelData, v.calType) : ""
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
                    PC3.Label { textFormat: Text.PlainText; Layout.fillWidth: true; text: v.m.focusing ? v.m.focusText : "تایمر تمرکز"; font.weight: v.m.focusing ? Font.DemiBold : Font.Medium; horizontalAlignment: Text.AlignRight }
                    Repeater {
                        model: v.m.focusing ? [] : [v.m.focusPreset1, v.m.focusPreset2, v.m.focusPreset3]
                        Rectangle {
                            required property int modelData
                            Layout.preferredWidth: 44; Layout.preferredHeight: 28; radius: 9
                            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.07)
                            border.width: 1; border.color: v.cardBorder
                            PC3.Label { textFormat: Text.PlainText; anchors.centerIn: parent; text: Jalali.fa(parent.modelData); font.pixelSize: Kirigami.Theme.smallFont.pixelSize; font.weight: Font.Medium }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: v.m.startFocus(parent.modelData) }
                        }
                    }
                    PC3.Button { visible: v.m.focusing; text: v.m.focusPaused ? "ادامه" : "مکث"; onClicked: v.m.toggleFocusPause() }
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
                    PC3.Label { textFormat: Text.PlainText; text: "Quick controls"; font.weight: Font.DemiBold }
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
                        PC3.Label { textFormat: Text.PlainText; text: "Volume"; font.weight: Font.Medium }
                        Item { Layout.fillWidth: true }
                        PC3.Label { textFormat: Text.PlainText; text: v.m.systemMuted ? "Muted" : v.m.systemVolume + "%"; color: v.mutedText }
                    }
                    PC3.Slider {
                        id: systemVolumeSlider
                        Layout.fillWidth: true
                        from: 0; to: 150
                        Binding { target: systemVolumeSlider; property: "value"; value: v.m.systemVolume; when: !systemVolumeSlider.pressed }
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
                        PC3.Label { textFormat: Text.PlainText; text: "Brightness"; font.weight: Font.Medium }
                        PC3.Label { textFormat: Text.PlainText;
                            visible: v.m.brightnessDevice.length > 0
                            text: "· " + v.m.brightnessDevice
                            color: v.mutedText
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            elide: Text.ElideRight
                            Layout.maximumWidth: 130
                        }
                        Item { Layout.fillWidth: true }
                        PC3.Label { textFormat: Text.PlainText; text: v.m.brightness >= 0 ? v.m.brightness + "%" : "Unavailable"; color: v.mutedText }
                    }
                    PC3.Slider {
                        id: brightnessSlider
                        Layout.fillWidth: true
                        enabled: v.m.brightness >= 0
                        from: 1; to: 100
                        Binding { target: brightnessSlider; property: "value"; value: Math.max(1, v.m.brightness); when: !brightnessSlider.pressed }
                        onMoved: v.m.setBrightness(value)
                    }
                    PC3.Label { textFormat: Text.PlainText;
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
                PC3.Label { textFormat: Text.PlainText; text: "Connectivity"; font.weight: Font.DemiBold }
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
                    PC3.Label { textFormat: Text.PlainText; text: "↓ " + v.m.formatRate(v.m.netDown); color: v.mutedText }
                    Item { Layout.fillWidth: true }
                    PC3.Label { textFormat: Text.PlainText; text: "↑ " + v.m.formatRate(v.m.netUp); color: v.mutedText }
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
                            { n: "RAM", f: v.m.ram / 100, t: v.m.ram + "%", s: v.m.ramUsedGiB.toFixed(1) + "/" + v.m.ramTotalGiB.toFixed(1) + " GiB" },
                            { n: "CPU", f: v.m.cpu / 100, t: v.m.cpu + "%", s: v.m.showCpuTemp ? (v.m.cpuTemp >= 0 ? v.m.cpuTemp + "°C" : "—") : "" },
                            { show: v.m.showBattery, n: "BAT", f: v.m.battery >= 0 ? v.m.battery / 100 : 0, t: v.m.battery >= 0 ? v.m.battery + "%" : "—", s: v.m.batteryTime || v.m.batteryStatus || "—" }
                        ]
                        ColumnLayout {
                            required property var modelData
                            visible: modelData.show === undefined ? true : modelData.show
                            Layout.fillWidth: true; Layout.preferredWidth: 1; spacing: 2
                            RowLayout {
                                Layout.fillWidth: true
                                PC3.Label { textFormat: Text.PlainText; text: modelData.n; color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize; font.weight: Font.Medium }
                                Item { Layout.fillWidth: true }
                                PC3.Label { textFormat: Text.PlainText; text: modelData.t; font.pixelSize: Kirigami.Theme.smallFont.pixelSize }
                            }
                            PC3.Label { textFormat: Text.PlainText; Layout.fillWidth: true; text: modelData.s; color: v.mutedText; font.pixelSize: Kirigami.Theme.smallFont.pixelSize; elide: Text.ElideRight }
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
}
