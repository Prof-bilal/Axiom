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
//   focused     -> teal pill + faint teal wash behind the icon
// While an app starts the icon bounces and the pointer shows busy over the dock.
Item {
    id: root

    property var item: null
    property bool launcher: false
    property string name: item ? item.name : ""
    property string iconSource: item ? item.icon : ""
    property bool focused: item ? item.focused : false
    readonly property var toplevels: item ? item.toplevels : []
    readonly property bool running: toplevels.length > 0

    // Set on launch; a new window ends it, whichever app id that window reports.
    // The Trash pin, for one, opens a Files window and never becomes "running".
    property bool launching: false
    readonly property int windowCount: WindowService.toplevels ? WindowService.toplevels.values.length : 0
    onWindowCountChanged: launching = false
    Timer { running: root.launching; interval: 10000; onTriggered: root.launching = false }

    function launchEntry() {
        if (!item.entry) return
        launching = true
        ApplicationService.launch(item.entry)
    }

    implicitWidth: Theme.dockItemSize
    implicitHeight: Theme.dockItemSize

    Accessible.role: Accessible.Button
    Accessible.name: name + (focused ? ", focused" : running ? ", running" : "")

    // Focus wash (the only cyan "glow" in the dock).
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Theme.radiusSurface
        color: root.focused ? Qt.rgba(0, 150 / 255, 150 / 255, 0.16)
             : mouse.containsMouse ? Qt.rgba(0, 0, 0, 0.07) : "transparent"
        border.width: root.focused ? 1 : 0
        border.color: Qt.rgba(0, 150 / 255, 150 / 255, 0.35)
        Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }
    }

    AppIcon {
        id: icon
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -1 + bounce.y
        size: Theme.dockIconSize
        source: root.iconSource
        scale: mouse.containsMouse ? Theme.dockHoverScale : 1.0
        Behavior on scale { NumberAnimation { duration: Theme.motionFeedback; easing.type: Easing.OutCubic } }
    }

    // Holds the bounce offset so stopping can settle back to rest.
    QtObject {
        id: bounce
        property real y: 0
    }

    SequentialAnimation {
        running: root.launching
        loops: Animation.Infinite
        alwaysRunToEnd: true
        NumberAnimation { target: bounce; property: "y"; to: -14; duration: 260; easing.type: Easing.OutQuad }
        NumberAnimation { target: bounce; property: "y"; to: 0; duration: 260; easing.type: Easing.InQuad }
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
        color: root.focused ? Qt.rgba(0, 130 / 255, 130 / 255, 1) : Qt.rgba(0, 0, 0, 0.55)
        Behavior on width { NumberAnimation { duration: Theme.motionFeedback } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.launching ? Qt.BusyCursor : Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: function (mouse) {
            if (root.launcher) {
                UiState.toggleLauncher("grid")
                return
            }
            if (!root.item) return
            UiState.closeAllOverlays()
            if (mouse.button === Qt.MiddleButton) {
                root.launchEntry()
                return
            }
            if (root.toplevels.length > 0) {
                var idx = root.toplevels.indexOf(WindowService.active)
                WindowService.activate(root.toplevels[(idx + 1) % root.toplevels.length])
                return
            }
            root.launchEntry()
        }
    }
}
