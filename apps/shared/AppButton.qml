import QtQuick
import qs.src.shared

// Compact text button for Axiom apps (dialogs, toolbars, detail panes). `primary` uses the cyan wash, `destructive`
// orange (Axiom: orange means attention / destructive only).
Rectangle {
    id: btn

    property string text: ""
    property bool primary: false
    property bool destructive: false
    property bool enabled: true

    signal clicked()

    implicitWidth: label.implicitWidth + Theme.spacingXl
    implicitHeight: 30
    radius: Theme.radiusControl
    opacity: enabled ? 1 : 0.45
    color: destructive ? (mouse.containsMouse ? Qt.rgba(1, 148 / 255, 24 / 255, 0.26) : Theme.stateUrgentWash)
         : primary ? (mouse.containsMouse ? Qt.rgba(32 / 255, 214 / 255, 210 / 255, 0.26) : Theme.stateSelected)
         : (mouse.containsMouse ? Theme.stateHover : Theme.surfaceElevated)
    border.width: 1
    border.color: destructive ? Theme.orangeMuted : primary ? Theme.stateSelectedBorder : Theme.border

    Accessible.role: Accessible.Button
    Accessible.name: text

    Text {
        id: label
        anchors.centerIn: parent
        text: btn.text
        color: btn.destructive ? Theme.orangeBright : btn.primary ? Theme.cyanBright : Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        font.weight: Font.Medium
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: btn.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
