import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_showMedia: showMedia.checked
    property alias cfg_showCalendar: showCalendar.checked
    property alias cfg_showFocus: showFocus.checked
    property alias cfg_showQuickControls: showQuickControls.checked
    property alias cfg_showConnectivity: showConnectivity.checked
    property alias cfg_showSystem: showSystem.checked
    property alias cfg_showCpuTemp: showCpuTemp.checked
    property alias cfg_showNetworkSpeed: showNetworkSpeed.checked
    property alias cfg_showBattery: showBattery.checked
    property alias cfg_showWifiTile: showWifiTile.checked
    property alias cfg_showBluetoothTile: showBluetoothTile.checked
    property alias cfg_showVolumeControl: showVolumeControl.checked
    property alias cfg_showBrightnessControl: showBrightnessControl.checked
    property alias cfg_showMicControl: showMicControl.checked
    property alias cfg_glassMode: glassMode.checked
    property alias cfg_glassOpacity: glassOpacity.value
    property alias cfg_glassBorderOpacity: glassBorderOpacity.value
    property alias cfg_clock24h: clock24h.checked
    property alias cfg_jalaliDefault: jalaliDefault.checked
    property alias cfg_compactShowMedia: compactShowMedia.checked
    property alias cfg_compactShowClock: compactShowClock.checked
    property alias cfg_showGregorianDate: showGregorianDate.checked
    property alias cfg_popupWidth: popupWidth.value
    property alias cfg_cardRadius: cardRadius.value
    property alias cfg_focusPreset1: focusPreset1.value
    property alias cfg_focusPreset2: focusPreset2.value
    property alias cfg_focusPreset3: focusPreset3.value

    ColumnLayout {
        width: page.availableWidth
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading { text: "Visible modules"; level: 3 }
        GridLayout {
            columns: width > 520 ? 2 : 1
            Layout.fillWidth: true
            Controls.CheckBox { id: showMedia; text: "Media carousel" }
            Controls.CheckBox { id: showCalendar; text: "Calendar" }
            Controls.CheckBox { id: showFocus; text: "Focus timer" }
            Controls.CheckBox { id: showQuickControls; text: "Quick controls" }
            Controls.CheckBox { id: showConnectivity; text: "Wi‑Fi / Bluetooth" }
            Controls.CheckBox { id: showSystem; text: "System statistics" }
        }

        Kirigami.Separator { Layout.fillWidth: true }
        Kirigami.Heading { text: "Quick controls"; level: 3 }
        GridLayout {
            columns: width > 520 ? 2 : 1
            Layout.fillWidth: true
            Controls.CheckBox { id: showWifiTile; text: "Wi‑Fi toggle" }
            Controls.CheckBox { id: showBluetoothTile; text: "Bluetooth toggle" }
            Controls.CheckBox { id: showVolumeControl; text: "Output volume" }
            Controls.CheckBox { id: showMicControl; text: "Microphone mute" }
            Controls.CheckBox { id: showBrightnessControl; text: "Screen brightness" }
        }

        Kirigami.Separator { Layout.fillWidth: true }
        Kirigami.Heading { text: "System details"; level: 3 }
        GridLayout {
            columns: width > 520 ? 2 : 1
            Layout.fillWidth: true
            Controls.CheckBox { id: showCpuTemp; text: "CPU temperature" }
            Controls.CheckBox { id: showNetworkSpeed; text: "Network speed" }
            Controls.CheckBox { id: showBattery; text: "Battery" }
        }


        Kirigami.Separator { Layout.fillWidth: true }
        Kirigami.Heading { text: "Appearance"; level: 3 }
        Controls.CheckBox { id: glassMode; text: "Glassmorphism mode" }
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            Controls.Label { text: "Glass opacity" }
            Controls.SpinBox { id: glassOpacity; from: 20; to: 92; stepSize: 2; editable: true; enabled: glassMode.checked }
            Controls.Label { text: "Border opacity" }
            Controls.SpinBox { id: glassBorderOpacity; from: 4; to: 50; stepSize: 2; editable: true; enabled: glassMode.checked }
        }
        Controls.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Kirigami.Theme.disabledTextColor
            text: "Glass mode uses translucent surfaces and lets Plasma/KWin provide background blur when the compositor supports it."
        }

        Kirigami.Separator { Layout.fillWidth: true }
        Kirigami.Heading { text: "Clock & calendar"; level: 3 }
        Controls.CheckBox { id: clock24h; text: "Use 24-hour clock" }
        Controls.CheckBox { id: jalaliDefault; text: "Open calendar in Jalali mode" }
        Controls.CheckBox { id: showGregorianDate; text: "Show Gregorian date under Persian date" }

        GridLayout {
            columns: 2
            Controls.Label { text: "Popup width" }
            Controls.SpinBox { id: popupWidth; from: 320; to: 560; stepSize: 10; editable: true }
            Controls.Label { text: "Card corner radius" }
            Controls.SpinBox { id: cardRadius; from: 4; to: 28; stepSize: 1; editable: true }
        }

        Kirigami.Separator { Layout.fillWidth: true }
        Kirigami.Heading { text: "Panel pill"; level: 3 }
        Controls.CheckBox { id: compactShowMedia; text: "Show current media" }
        Controls.CheckBox { id: compactShowClock; text: "Show clock" }

        Kirigami.Separator { Layout.fillWidth: true }
        Kirigami.Heading { text: "Focus timer presets"; level: 3 }
        RowLayout {
            Controls.SpinBox { id: focusPreset1; from: 1; to: 180; editable: true }
            Controls.SpinBox { id: focusPreset2; from: 1; to: 180; editable: true }
            Controls.SpinBox { id: focusPreset3; from: 1; to: 180; editable: true }
        }

        Controls.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: "Tip: disable modules you do not use. Notch is designed to stay compact and only expose controls that save clicks."
        }
    }
}
