import QtQuick
import Quickshell
import qs.src.shared
import qs.services

// Common top-level window for Axiom core apps. Content goes in `content`.
//
// The compositor (labwc, ADR-016) draws the title bar and window frame, themed
// in themes/Axiom/labwc/themerc, so the app draws none of its own. Close,
// minimize and maximize are on the keyboard (Super+Q/W, Super+H, Super+M).
FloatingWindow {
    id: win

    default property alias content: area.data

    implicitWidth: 960
    implicitHeight: 640
    minimumSize: Qt.size(560, 360)
    color: Theme.background
    visible: true

    // Background: a flat solid surface in both modes (white in light, near-black in dark).
    Rectangle {
        anchors.fill: parent
        color: Theme.light ? Theme.surface : "#121212"
    }

    // Drag strip along the top: a press starts a compositor move. It sits under the
    // content, so buttons and fields in the app header still get their own clicks.
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 44
        onPressed: function (mouse) { if (mouse.button === Qt.LeftButton) win.startSystemMove() }
    }

    Item {
        id: area
        anchors.fill: parent
    }
}
