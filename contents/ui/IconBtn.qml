import QtQuick
import QtQuick.Controls as Controls
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

PC3.ToolButton {
    id: b
    property string source: ""
    property real size: Kirigami.Units.iconSizes.small
    readonly property string accessibleLabel: {
        const labels = { "media-skip-backward": "Previous track", "media-skip-forward": "Next track",
            "media-playback-pause": "Pause", "media-playback-start": "Play", "configure": "Settings",
            "go-previous": "Previous", "go-next": "Next", "dialog-close": "Dismiss message",
            "audio-volume-muted": "Unmute", "audio-volume-high": "Mute" }
        return labels[source] || source
    }
    implicitWidth: size + 8
    implicitHeight: size + 8
    icon.name: source
    icon.width: size
    icon.height: size
    text: accessibleLabel
    display: Controls.AbstractButton.IconOnly
    Accessible.name: accessibleLabel
    Controls.ToolTip.visible: hovered
    Controls.ToolTip.text: accessibleLabel
}
