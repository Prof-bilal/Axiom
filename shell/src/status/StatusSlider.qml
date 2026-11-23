import QtQuick
import qs.src.shared

// A labelled level control: caption and value on top, a track below. `value` is 0..100; `moved` carries the
// new value while dragging. Read-only when `enabledControl` is false (the battery level).
Item {
    id: slider

    property string caption: ""
    property real value: 0
    property bool dim: false
    property bool enabledControl: true
    property color fillColor: Theme.accent
    signal moved(int v)

    width: parent ? parent.width : 300
    height: 54

    Text {
        x: Theme.spacingSm
        y: 4
        text: slider.caption
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
    }
    Text {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingSm
        y: 4
        text: Math.round(slider.value) + "%"
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        font.features: { "tnum": 1 }
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingSm
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingSm
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        height: 14
        radius: 7
        color: Theme.stateHover
        border.width: 1
        border.color: Theme.borderSubtle

        Rectangle {
            height: parent.height
            radius: height / 2
            width: Math.max(height, parent.width * Math.min(1, slider.value / 100))
            color: slider.dim ? Theme.textDisabled : slider.fillColor
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            enabled: slider.enabledControl
            cursorShape: Qt.PointingHandCursor
            function apply(m) { slider.moved(Math.max(0, Math.min(100, Math.round(100 * (m.x - 8) / track.width)))) }
            onPressed: function (m) { apply(m) }
            onPositionChanged: function (m) { if (pressed) apply(m) }
        }
    }
}
