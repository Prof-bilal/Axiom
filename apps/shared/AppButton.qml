import QtQuick
import qs.src.shared

// Button for Axiom apps and dialogs. Solid, flat, no transparency. At rest a
// lighter graphite with light text; on hover it goes dark, as the menus do.
// `primary` is the solid cyan action (dark text), `destructive` the solid orange
// one (dark text). Orange stays reserved for destructive actions.
Rectangle {
    id: btn

    property string text: ""
    property bool primary: false
    property bool destructive: false
    property bool enabled: true

    signal clicked()

    readonly property color fillRest: destructive ? Theme.orange : primary ? Theme.cyan : "#1E2D33"
    readonly property color fillHover: destructive ? "#7A4208" : primary ? "#0E4A4D" : Theme.menuHover

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
        color: btn.destructive ? (mouse.containsMouse ? Theme.orangeBright : Theme.background)
             : btn.primary ? (mouse.containsMouse ? Theme.cyanBright : Theme.background)
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
