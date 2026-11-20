import QtQuick
import qs.src.shared
import "installer.js" as Ins

// Pick one value from a short list with the arrows (click, or Left/Right when focused).
Item {
    id: root

    property string label: ""
    property var model: []
    property var names: ({})
    property string value: ""
    property int labelWidth: 150
    signal picked(string value)

    implicitHeight: 38
    implicitWidth: 360

    function step(delta) { root.picked(Ins.cycle(root.model, root.value, delta)) }

    IText {
        id: lab
        visible: root.label.length > 0
        width: root.labelWidth
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        wrapMode: Text.NoWrap
    }
    Rectangle {
        id: box
        anchors.left: lab.visible ? lab.right : parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 34
        radius: 8
        color: Ins.C.field
        border.width: root.activeFocus ? 1 : 0
        border.color: Ins.C.orange

        IText {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: arrows.left
            anchors.verticalCenter: parent.verticalCenter
            text: Ins.nameOf(root.names, root.value)
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }
        Row {
            id: arrows
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            IText { text: "‹"; color: Ins.C.dim; font.pixelSize: 20 }
            IText { text: "›"; color: Ins.C.dim; font.pixelSize: 20 }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: function (m) { root.forceActiveFocus(); root.step(m.x < box.width / 2 ? -1 : 1) }
        }
    }
    activeFocusOnTab: true
    Keys.onLeftPressed: step(-1)
    Keys.onRightPressed: step(1)
    Accessible.role: Accessible.ComboBox
    Accessible.name: label
}
