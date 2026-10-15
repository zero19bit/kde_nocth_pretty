import QtQuick
import QtQuick.Effects
import org.kde.kirigami as Kirigami

Item {
    id: c
    property url source
    property real radius: 8

    Rectangle { id: mask; anchors.fill: parent; radius: c.radius; visible: false; layer.enabled: true }
    Image {
        id: img; anchors.fill: parent; source: c.source
        fillMode: Image.PreserveAspectCrop; asynchronous: true
        sourceSize: Qt.size(width * 2, height * 2)
        visible: false; layer.enabled: true
    }
    MultiEffect {
        anchors.fill: parent; source: img
        maskEnabled: true; maskSource: mask
        visible: img.status === Image.Ready
    }
    Rectangle {
        anchors.fill: parent; radius: c.radius
        visible: img.status !== Image.Ready
        color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.highlightColor, 0.35)
        Kirigami.Icon { anchors.centerIn: parent; width: parent.width * 0.55; height: width
                        source: "audio-x-generic"; color: Kirigami.Theme.textColor }
    }
}
