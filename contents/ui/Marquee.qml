import QtQuick
import org.kde.plasma.components as PC3

Item {
    id: m
    property string text
    property real maxWidth: 150
    property bool bold: false
    readonly property bool scrolls: lbl.implicitWidth > maxWidth

    implicitWidth: Math.min(lbl.implicitWidth, maxWidth)
    implicitHeight: lbl.implicitHeight
    clip: true

    PC3.Label { id: lbl; text: m.text; font.bold: m.bold; wrapMode: Text.NoWrap }

    SequentialAnimation {
        running: m.scrolls
        loops: Animation.Infinite
        PauseAnimation { duration: 1800 }
        NumberAnimation { target: lbl; property: "x"; to: m.maxWidth - lbl.implicitWidth
                          duration: Math.max(500, (lbl.implicitWidth - m.maxWidth) * 35) }
        PauseAnimation { duration: 1200 }
        NumberAnimation { target: lbl; property: "x"; to: 0; duration: 500 }
    }
    onScrollsChanged: if (!scrolls) lbl.x = 0
    onTextChanged: lbl.x = 0
}
