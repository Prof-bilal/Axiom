import QtQuick
import "hubstyle.js" as S

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
    color: primary ? (m.containsMouse ? S.accentHover : S.accent) : (m.containsMouse ? S.cardHover : "transparent")
    border.width: primary ? 0 : 1
    border.color: S.border

    Accessible.role: Accessible.Button
    Accessible.name: text

    Text {
        id: label
        anchors.centerIn: parent
        text: b.text
        color: b.primary ? "#FFFFFF" : S.text
        font.family: S.font
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
