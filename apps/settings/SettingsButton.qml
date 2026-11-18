import QtQuick
import qs.src.shared

// Premium pill button for the Settings pages. Same API as the shared AppButton:
// `primary` is the Axiom accent action, `destructive` the orange one, otherwise a
// quiet raised pill. Hover lifts the fill, press darkens it.
Rectangle {
    id: btn

    property string text: ""
    property bool primary: false
    property bool destructive: false
    property bool enabled: true

    signal clicked()

    readonly property color fillRest: primary ? Theme.cyan : destructive ? "transparent" : Theme.surfaceElevated
    readonly property color fillHover: primary ? Theme.cyanBright : destructive ? Qt.rgba(1, 148 / 255, 24 / 255, 0.16) : Theme.surfaceHover

    implicitWidth: label.implicitWidth + 30
    implicitHeight: 32
    radius: 16
    opacity: enabled ? 1 : 0.45
    color: mouse.pressed ? Qt.darker(fillHover, 1.12) : mouse.containsMouse ? fillHover : fillRest
    Behavior on color { ColorAnimation { duration: 120 } }
    border.width: primary ? 0 : 1
    border.color: destructive ? Theme.orange : Theme.borderSubtle

    Accessible.role: Accessible.Button
    Accessible.name: text

    Text {
        id: label
        anchors.centerIn: parent
        text: btn.text
        color: btn.primary ? "#06181A" : btn.destructive ? Theme.orangeBright : Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
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
