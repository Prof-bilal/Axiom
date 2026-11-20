import QtQuick
import qs.src.shared
import "installer.js" as Ins

// A labelled box that opens the shared list (DropdownList, drawn above everything by the app window).
// `stacked` puts the label above the box instead of beside it.
Item {
    id: root

    property var be
    property string label: ""
    property var model: []
    property var names: ({})
    property string value: ""
    property int labelWidth: 150
    property bool stacked: false
    signal picked(string value)

    implicitHeight: stacked ? 62 : 38
    implicitWidth: 360

    IText {
        id: lab
        visible: root.label.length > 0
        width: root.stacked ? parent.width : root.labelWidth
        y: root.stacked ? 0 : (root.height - height) / 2
        text: root.label
        color: root.stacked ? Ins.C.dim : Ins.C.text
        font.pixelSize: root.stacked ? 12 : 14
        wrapMode: Text.NoWrap
    }
    Rectangle {
        id: box
        x: root.stacked || !lab.visible ? 0 : root.labelWidth
        y: root.stacked ? 22 : (root.height - height) / 2
        width: parent.width - x
        height: 34
        radius: 8
        color: hit.containsMouse ? "#323840" : Ins.C.field
        border.width: root.activeFocus ? 1 : 0
        border.color: Ins.C.orange

        IText {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: chev.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: Ins.nameOf(root.names, root.value)
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }
        IText {
            id: chev
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "⌄"
            color: Ins.C.dim
            font.pixelSize: 18
        }
        MouseArea {
            id: hit
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.open()
        }
    }

    function open() {
        root.forceActiveFocus()
        if (be && be.popup) be.popup.show(box, root.model, root.names, root.value, function (v) { root.picked(v) })
    }
    activeFocusOnTab: true
    Keys.onReturnPressed: open()
    Keys.onSpacePressed: open()
    Accessible.role: Accessible.ComboBox
    Accessible.name: label
}
