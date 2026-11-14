import QtQuick
import qs.src.shared

// Rounded button. `primary` is the orange fill; otherwise an outline.
Rectangle {
    id: b

    property string text: ""
    property bool primary: true
    property bool small: false

    signal clicked()

    implicitWidth: label.implicitWidth + (small ? 22 : 30)
    implicitHeight: small ? 26 : 34
    radius: 6
    opacity: enabled ? 1 : 0.45
    color: primary ? (m.containsMouse ? Theme.cyanBright : Theme.cyan) : (m.containsMouse ? Theme.surfaceHover : "transparent")
    border.width: primary ? 0 : 1
    border.color: Theme.border

    Accessible.role: Accessible.Button
    Accessible.name: text

    Text {
        id: label
        anchors.centerIn: parent
        text: b.text
        color: b.primary ? Theme.background : Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: b.small ? 12 : 13
        font.weight: Font.Medium
    }

    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: b.clicked()
    }
}
