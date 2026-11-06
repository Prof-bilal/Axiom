import QtQuick
import qs.src.shared

// On/off switch for settings rows. Emits `toggled` and leaves `checked` to the
// caller, so the state shown is always the state the service reports.
Rectangle {
    id: sw

    property bool checked: false
    property bool enabled: true
    property string accessibleName: ""
    signal toggled()

    width: 42
    height: 22
    radius: 11
    opacity: enabled ? 1 : 0.45
    color: checked ? Theme.cyanMuted : Theme.surfaceHover
    border.width: 1
    border.color: checked ? Theme.cyan : Theme.border

    Accessible.role: Accessible.CheckBox
    Accessible.name: accessibleName
    Accessible.checked: checked

    Rectangle {
        width: 16
        height: 16
        radius: 8
        anchors.verticalCenter: parent.verticalCenter
        x: sw.checked ? parent.width - width - 3 : 3
        color: sw.checked ? Theme.textPrimary : Theme.textSecondary
        Behavior on x { NumberAnimation { duration: Theme.motionFeedback } }
    }

    MouseArea {
        anchors.fill: parent
        enabled: sw.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: sw.toggled()
    }
}
