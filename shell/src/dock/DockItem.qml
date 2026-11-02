import QtQuick
import qs.src.shared
import qs.services

// A single dock entry.
//   left click   -> focus the app's window (cycling if it is already
//                   focused and has several), or launch it
//   middle click -> always launch a new instance
// Indicators (extremely small, below the icon):
//   not running -> none
//   running     -> dim cyan dot
//   focused     -> bright cyan pill + faint cyan wash behind the icon
Item {
    id: root

    property var item: null
    property bool launcher: false
    property string name: item ? item.name : ""
    property string iconSource: item ? item.icon : ""
    property bool focused: item ? item.focused : false
    readonly property var toplevels: item ? item.toplevels : []
    readonly property bool running: toplevels.length > 0

    implicitWidth: Theme.dockItemSize
    implicitHeight: Theme.dockItemSize

    Accessible.role: Accessible.Button
    Accessible.name: name + (focused ? ", focused" : running ? ", running" : "")

    // Focus wash (the only cyan "glow" in the dock).
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Theme.radiusSurface
        color: root.focused ? Theme.stateSelected
             : mouse.containsMouse ? Theme.stateHover : "transparent"
        border.width: root.focused ? 1 : 0
        border.color: Qt.rgba(32 / 255, 214 / 255, 210 / 255, 0.28)
        Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }
    }

    AppIcon {
        id: icon
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -1
        size: root.launcher ? Theme.dockIconSize - 6 : Theme.dockIconSize
        source: root.iconSource
        scale: mouse.containsMouse ? Theme.dockHoverScale : 1.0
        Behavior on scale { NumberAnimation { duration: Theme.motionFeedback; easing.type: Easing.OutCubic } }
    }

    // Running / focused indicator.
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        visible: root.running || (root.launcher && root.focused)
        width: root.focused ? 12 : 4
        height: root.focused ? 3 : 4
        radius: height / 2
        color: root.focused ? Theme.cyanBright : Theme.cyanMuted
        Behavior on width { NumberAnimation { duration: Theme.motionFeedback } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: function (mouse) {
            if (root.launcher) {
                UiState.toggleLauncher("grid")
                return
            }
            if (!root.item) return
            UiState.closeAllOverlays()
            if (mouse.button === Qt.MiddleButton) {
                if (root.item.entry) ApplicationService.launch(root.item.entry)
                return
            }
            if (root.toplevels.length > 0) {
                var idx = root.toplevels.indexOf(WindowService.active)
                WindowService.activate(root.toplevels[(idx + 1) % root.toplevels.length])
                return
            }
            if (root.item.entry) ApplicationService.launch(root.item.entry)
        }
    }
}
