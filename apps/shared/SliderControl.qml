import QtQuick
import qs.src.shared

// Pointer slider (no QtQuick.Controls). `value` is 0..100 and is set by the
// caller; `moved(percent)` fires while dragging.
Item {
    id: slider

    property real value: 0
    property bool enabled: true
    property color accent: Theme.cyan
    property string accessibleName: ""
    signal moved(int percent)

    implicitWidth: 200
    implicitHeight: 22
    opacity: enabled ? 1 : 0.45

    Accessible.role: Accessible.Slider
    Accessible.name: accessibleName

    Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 4; radius: 2; color: Theme.surfaceHover }
    Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width * Math.max(0, Math.min(1, slider.value / 100)); height: 4; radius: 2; color: slider.accent }
    Rectangle {
        x: Math.max(0, Math.min(parent.width - width, parent.width * slider.value / 100 - width / 2))
        anchors.verticalCenter: parent.verticalCenter
        width: 14; height: 14; radius: 7
        color: Theme.textPrimary
        border.width: 2
        border.color: slider.accent
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        enabled: slider.enabled
        cursorShape: Qt.PointingHandCursor
        function apply(mouse) { slider.moved(Math.max(0, Math.min(100, Math.round(100 * (mouse.x - 6) / slider.width)))) }
        onPressed: function (mouse) { apply(mouse) }
        onPositionChanged: function (mouse) { if (pressed) apply(mouse) }
    }
}
