import QtQuick
import qs.src.shared

// Premium segmented control for settings choices: one rounded track, the selected
// segment filled with the Axiom accent. `options`: [{ name, value }]; `current` is the value.
Rectangle {
    id: seg

    property var options: []
    property var current
    signal picked(var value)

    height: 32
    width: row.implicitWidth + 8
    radius: 16
    color: Theme.stateHover
    border.width: 1
    border.color: Theme.borderSubtle

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4
        Repeater {
            model: seg.options
            delegate: Rectangle {
                required property var modelData
                readonly property bool on: seg.current === modelData.value
                height: 26
                width: label.implicitWidth + 26
                radius: 13
                color: on ? Theme.cyan : (hit.containsMouse ? Theme.surfaceHover : "transparent")
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: modelData.name
                    color: on ? "#06181A" : Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                    font.weight: on ? Font.DemiBold : Font.Normal
                }
                MouseArea {
                    id: hit
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: seg.picked(modelData.value)
                }
            }
        }
    }
}
