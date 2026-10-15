import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: b
    property alias source: ic.source
    property real size: Kirigami.Units.iconSizes.small
    signal clicked()

    implicitWidth: size + 8
    implicitHeight: size + 8

    Rectangle {
        anchors.fill: parent; radius: width / 2
        color: Kirigami.Theme.textColor
        opacity: ma.pressed ? 0.25 : (ma.containsMouse ? 0.14 : 0)
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }
    Kirigami.Icon { id: ic; anchors.centerIn: parent; width: b.size; height: b.size; color: Kirigami.Theme.textColor }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: b.clicked() }
}
