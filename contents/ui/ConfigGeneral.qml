import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
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
    property bool cfg_jalaliDefault: true // Legacy preference used until a calendar is selected.
    property alias cfg_calendarType: calendarSetting.value
    property alias cfg_showJalaliDate: showJalaliDate.checked
    property alias cfg_showHijriDate: showHijriDate.checked
    property alias cfg_hijriAdjustment: hijriAdjustment.value
    property alias cfg_compactShowMedia: compactShowMedia.checked
    property alias cfg_compactShowDate: compactShowDate.checked
    property alias cfg_compactShowClock: compactShowClock.checked
    property alias cfg_showGregorianDate: showGregorianDate.checked
    property alias cfg_popupWidth: popupWidth.value
    property alias cfg_cardRadius: cardRadius.value
    property alias cfg_focusPreset1: focusPreset1.value
    property alias cfg_focusPreset2: focusPreset2.value
    property alias cfg_focusPreset3: focusPreset3.value

    // Plasma also listens to this signal. Explicit notifications keep the new
    // settings detectable when upgrading an applet with an older cached schema.
    // The shell must still be reloaded once after an upgrade to save new keys.
    signal configurationChanged()
    onCfg_calendarTypeChanged: configurationChanged()
    onCfg_showJalaliDateChanged: configurationChanged()
    onCfg_showHijriDateChanged: configurationChanged()
    onCfg_hijriAdjustmentChanged: configurationChanged()
    onCfg_compactShowDateChanged: configurationChanged()

    QtObject {
        id: calendarSetting
        property int value: -1
    }

    ColumnLayout {
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
        Controls.Label { text: "Primary calendar / تقویم اصلی" }
        Controls.ComboBox {
            id: calendarSelector
            objectName: "primaryCalendarSelector"
            Layout.fillWidth: true
            model: ["شمسی — Jalali", "میلادی — Gregorian", "قمری — Hijri (civil)"]
            currentIndex: page.cfg_calendarType < 0 ? (page.cfg_jalaliDefault ? 0 : 1) : page.cfg_calendarType
            onActivated: (index) => {
                page.cfg_calendarType = index
            }
        }
        Controls.Label { text: "Also show below the primary date:" }
        Controls.CheckBox { id: showJalaliDate; text: "شمسی — Jalali" }
        Controls.CheckBox { id: showGregorianDate; text: "میلادی — Gregorian" }
        Controls.CheckBox { id: showHijriDate; text: "قمری — Hijri" }
        RowLayout {
            Controls.Label { text: "Hijri day adjustment / اصلاح روز قمری" }
            Controls.SpinBox { id: hijriAdjustment; from: -2; to: 2; editable: true }
        }
        Controls.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: "Hijri uses the calculated civil calendar. Local moon-sighting dates may differ; use the day adjustment to match your local calendar."
            color: Kirigami.Theme.disabledTextColor
        }

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
        Controls.CheckBox { id: compactShowDate; text: "Show date / نمایش تاریخ در پنل" }
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
