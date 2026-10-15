import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Rectangle {
    id: tile
    property string iconName: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool enabledState: true
    property color accent: Kirigami.Theme.highlightColor
    property bool glassMode: false
    property int glassOpacity: 58
    property int glassBorderOpacity: 18
    signal clicked()

    implicitHeight: 58
    radius: 12
    color: glassMode
           ? Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, Math.max(0.18, glassOpacity / 100.0 - 0.18))
           : (active
              ? Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, accent, 0.16)
              : Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.055))
    border.width: 1
    border.color: active
                  ? Qt.rgba(accent.r, accent.g, accent.b, glassMode ? Math.max(0.26, glassBorderOpacity / 100.0) : 0.34)
                  : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, glassMode ? glassBorderOpacity / 100.0 : 0.08)
    opacity: enabledState ? 1 : 0.48

    RowLayout {
        anchors { fill: parent; margins: 10 }
        spacing: 8
        Kirigami.Icon {
            source: tile.iconName
            color: tile.active ? tile.accent : Kirigami.Theme.textColor
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            PC3.Label { textFormat: Text.PlainText;
                Layout.fillWidth: true
                text: tile.title
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            PC3.Label { textFormat: Text.PlainText;
                Layout.fillWidth: true
                visible: tile.subtitle.length > 0
                text: tile.subtitle
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.58)
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                elide: Text.ElideRight
            }
        }
        Rectangle {
            width: 8; height: 8; radius: 4
            visible: tile.active
            color: tile.accent
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: tile.enabledState
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.clicked()
    }
}
