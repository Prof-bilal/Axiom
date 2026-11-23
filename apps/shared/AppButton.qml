import QtQuick
import qs.src.shared

// Button for Axiom apps and dialogs. Solid, flat, no transparency. At rest a
// lighter graphite with light text; on hover it goes dark, as the menus do.
// `primary` is the solid orange action (dark text), `destructive` the solid red
// one (dark text). Orange stays reserved for destructive actions.
Rectangle {
    id: btn

    property string text: ""
    property bool primary: false
    property bool destructive: false
    property bool enabled: true

    signal clicked()

    readonly property color fillRest: destructive ? Theme.danger : primary ? Theme.accent : "#33353A"
    readonly property color fillHover: destructive ? Theme.dangerMuted : primary ? Theme.accentMuted : Theme.menuHover

    implicitWidth: label.implicitWidth + 28
    implicitHeight: 34
    radius: 9
    opacity: enabled ? 1 : 0.45
    color: mouse.pressed ? Qt.darker(fillHover, 1.15)
         : mouse.containsMouse ? fillHover : fillRest
    Behavior on color { ColorAnimation { duration: 110 } }
    border.width: primary || destructive ? 0 : 1
    border.color: Theme.menuBorder

    Accessible.role: Accessible.Button
    Accessible.name: text

    Text {
        id: label
        anchors.centerIn: parent
        text: btn.text
        color: btn.destructive ? (mouse.containsMouse ? Theme.dangerBright : Theme.background)
             : btn.primary ? (mouse.containsMouse ? Theme.accentBright : Theme.background)
             : Theme.menuText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        font.weight: Font.DemiBold
        Behavior on color { ColorAnimation { duration: 110 } }
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
