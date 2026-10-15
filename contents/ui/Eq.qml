import QtQuick

Row {
    id: eq
    property bool active: false
    property color color: "white"
    property real phase: 0
    spacing: 2
    height: 14

    Timer { interval: 90; running: eq.active; repeat: true; onTriggered: eq.phase += 0.9 }

    Repeater {
        model: 4
        Item {
            id: slot
            required property int index
            width: 3; height: eq.height
            Rectangle {
                width: parent.width; radius: width / 2; color: eq.color
                anchors.bottom: parent.bottom
                height: eq.active ? 3 + (eq.height - 3) * (0.5 + 0.5 * Math.sin(eq.phase * (1 + slot.index * 0.35) + slot.index * 1.7)) : 3
                Behavior on height { NumberAnimation { duration: 90 } }
            }
        }
    }
}
