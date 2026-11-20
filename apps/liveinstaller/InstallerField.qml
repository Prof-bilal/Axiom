import QtQuick
import qs.src.shared
import "installer.js" as Ins

// Labelled text box. `password` masks it; `reveal` shows it. Enter emits `accepted`.
Item {
    id: root

    property string label: ""
    property alias text: input.text
    property bool password: false
    property bool reveal: false
    property int labelWidth: 150
    property bool invalid: false
    signal accepted()

    implicitHeight: 38
    implicitWidth: 360

    IText {
        id: lab
        visible: root.label.length > 0
        width: root.labelWidth
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        wrapMode: Text.NoWrap
    }
    Rectangle {
        anchors.left: lab.visible ? lab.right : parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 34
        radius: 8
        color: Ins.C.field
        border.width: input.activeFocus || root.invalid ? 1 : 0
        border.color: root.invalid ? Ins.C.red : Ins.C.orange

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Ins.C.text
            selectionColor: Ins.C.orange
            selectedTextColor: Ins.C.orangeInk
            font.family: Theme.fontFamily
            font.pixelSize: 14
            echoMode: root.password && !root.reveal ? TextInput.Password : TextInput.Normal
            Accessible.name: root.label
            onAccepted: root.accepted()
        }
    }
    function focusField() { input.forceActiveFocus() }
}
