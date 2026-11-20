import QtQuick
import qs.src.shared
import "installer.js" as Ins

// Flat button: grey by default, `primary` is the orange action, `danger` the red one.
Rectangle {
    id: btn

    property string text: ""
    property bool primary: false
    property bool danger: false
    property bool enabled: true
    signal clicked()

    implicitWidth: Math.max(96, label.implicitWidth + 36)
    implicitHeight: 34
    radius: 8
    opacity: enabled ? 1 : 0.45
    color: danger ? (mouse.containsMouse ? "#ff8f8f" : Ins.C.red)
         : primary ? (mouse.containsMouse ? "#ffb348" : Ins.C.orange)
         : (mouse.containsMouse ? "#343a41" : Ins.C.field)
    visible: text.length > 0

    Accessible.role: Accessible.Button
    Accessible.name: text

    Text {
        id: label
        anchors.centerIn: parent
        text: btn.text
        color: btn.primary || btn.danger ? Ins.C.orangeInk : Ins.C.text
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.weight: Font.DemiBold
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
