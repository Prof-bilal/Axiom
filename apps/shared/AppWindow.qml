import QtQuick
import Quickshell
import qs.src.shared
import qs.services

// Common top-level window for Axiom core apps. Content goes in `content`.
//
// Under labwc the compositor draws the title bar. Hyprland draws none (ADR-029),
// so there the window draws its own bar inside itself: traffic-light buttons, a
// centred title, drag to move and double-click to maximize. Because the bar is
// part of the window it moves with it and shares its rounded corners.
FloatingWindow {
    id: win

    default property alias content: area.data

    // Hyprland session: draw our own title bar.
    readonly property bool ownTitleBar: !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
    readonly property int titleBarHeight: ownTitleBar ? 38 : 0

    implicitWidth: 960
    implicitHeight: 640
    minimumSize: Qt.size(560, 360)
    color: Theme.background
    visible: true

    Item {
        id: bar
        visible: win.ownTitleBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: win.titleBarHeight

        Rectangle {
            anchors.fill: parent
            color: Theme.glassFillStrong
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: Theme.borderSubtle
        }

        MouseArea {
            anchors.fill: parent
            onPressed: win.startSystemMove()
            onDoubleClicked: WindowService.toggleMaximizeActive()
        }

        TrafficLights {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            onCloseClicked: Qt.quit()
            onMinimizeClicked: WindowService.minimizeActive()
            onMaximizeClicked: WindowService.toggleMaximizeActive()
        }

        Text {
            anchors.centerIn: parent
            width: parent.width - 160
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: win.title
            color: Theme.textPrimary
            opacity: 0.8
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
    }

    Item {
        id: area
        anchors { top: bar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
    }
}
