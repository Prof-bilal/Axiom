import QtQuick
import Quickshell
import qs.src.shared

// Common top-level window for Axiom core apps. The compositor draws the
// title bar (icon, title, minimize/maximize/close); the app draws only its
// client area on the Axiom graphite background. Content goes in `content`.
FloatingWindow {
    id: win

    default property alias content: area.data

    implicitWidth: 960
    implicitHeight: 640
    minimumSize: Qt.size(560, 360)
    color: Theme.background
    visible: true

    Item {
        id: area
        anchors.fill: parent
    }
}
