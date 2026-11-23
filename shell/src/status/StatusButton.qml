import QtQuick
import qs.src.shared

// Small pill button for status popups. `primary` is the cyan action; `selected` marks the current choice
// in a row of options (power profiles).
Rectangle {
    id: btn

    property string text: ""
    property bool primary: false
    property bool selected: false
    property bool enabled: true
    signal clicked()

    implicitWidth: label.implicitWidth + 22
    height: 28
    radius: 14
    opacity: enabled ? 1 : 0.45
    color: selected || primary ? Theme.accent : (mouse.containsMouse ? Theme.stateHover : Theme.cardFill)
    border.width: 1
    border.color: selected || primary ? Theme.accentBright : Theme.borderSubtle

    Accessible.role: Accessible.Button
    Accessible.name: text

    Text {
        id: label
        anchors.centerIn: parent
        text: btn.text
        color: btn.selected || btn.primary ? "#1A0E00" : Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        font.weight: Font.DemiBold
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: btn.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
