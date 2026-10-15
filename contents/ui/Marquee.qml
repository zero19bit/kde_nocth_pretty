import QtQuick
import org.kde.plasma.components as PC3

Item {
    id: m
    property string text
    property real maxWidth: 150
    property bool bold: false
    readonly property real viewportWidth: Math.max(0, Math.min(width, maxWidth))
    readonly property bool scrolls: lbl.implicitWidth > viewportWidth

    implicitWidth: Math.min(lbl.implicitWidth, maxWidth)
    implicitHeight: lbl.implicitHeight
    clip: true

    PC3.Label {
        id: lbl
        text: m.text
        textFormat: Text.PlainText
        font.bold: m.bold
        wrapMode: Text.NoWrap
    }

    function restartScroll() {
        animation.stop()
        lbl.x = 0
        if (scrolls && visible) animation.start()
    }
    SequentialAnimation {
        id: animation
        loops: Animation.Infinite
        PauseAnimation { duration: 1800 }
        NumberAnimation {
            target: lbl; property: "x"; to: m.viewportWidth - lbl.implicitWidth
            duration: Math.max(500, (lbl.implicitWidth - m.viewportWidth) * 35)
        }
        PauseAnimation { duration: 1200 }
        NumberAnimation { target: lbl; property: "x"; to: 0; duration: 500 }
    }
    onTextChanged: Qt.callLater(restartScroll)
    onViewportWidthChanged: Qt.callLater(restartScroll)
    onVisibleChanged: Qt.callLater(restartScroll)
    Component.onCompleted: Qt.callLater(restartScroll)
}
