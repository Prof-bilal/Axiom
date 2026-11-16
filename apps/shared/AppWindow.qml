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

    // Background: the card metal material (same as the cards), drawn first so the
    // window's content sits on top of it. No blur.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#8C888D" }
            GradientStop { position: 0.5; color: "#6B666C" }
            GradientStop { position: 1.0; color: "#3E3A3E" }
        }
    }

    Item {
        id: area
        anchors.fill: parent
    }
}
