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
    property var dockWindow: null
    property bool launcher: false
    // Position of this slot in the dock's row; the dock's layout (magnify.js) says how much it has grown.
    property int slot: 0
    readonly property real magScale: dockWindow && dockWindow.lay.scales[slot] !== undefined ? dockWindow.lay.scales[slot] : 1
    // How far the icon is raised: none at rest, the full dockLift at the peak.
    readonly property real lift: Theme.dockLift * (magScale - 1) / (Theme.dockMagnifyPeak - 1)
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

    // The slot widens with the icon (the dock gets wider, like macOS); its height stays fixed.
    implicitWidth: Theme.dockItemSize * magScale
    implicitHeight: Theme.dockItemSize

    Accessible.role: Accessible.Button
    Accessible.name: name + (focused ? ", focused" : running ? ", running" : "")

    // The icon and its focus wash share one box, so they grow together: upward from the bottom edge, rising
    // by `lift` (the only cyan "glow" in the dock is the wash).
    Item {
        id: iconBox
        width: Theme.dockIconSize
        height: Theme.dockIconSize
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -1 + bounce.y - root.lift
        scale: root.magScale
        transformOrigin: Item.Bottom

        Rectangle {
            anchors.fill: parent
            anchors.margins: -7
            radius: Theme.radiusSurface
            color: root.focused ? Qt.rgba(255 / 255, 148 / 255, 24 / 255, 0.16) : "transparent"
            border.width: root.focused ? 1 : 0
            border.color: Qt.rgba(255 / 255, 148 / 255, 24 / 255, 0.35)
            Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }
        }

        AppIcon {
            id: icon
            anchors.centerIn: parent
            size: Theme.dockIconSize
            source: root.iconSource
        }
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
        color: root.focused ? Theme.accent : Qt.rgba(255 / 255, 148 / 255, 24 / 255, 0.7)
        Behavior on width { NumberAnimation { duration: Theme.motionFeedback } }
    }

    onNameChanged: if (mouse.containsMouse) root.announce()
    function announce() {
        if (!root.dockWindow || root.name.length === 0) return
        root.dockWindow.showTip(root.name, root)
    }

    MouseArea {
        id: mouse
        // Covers the grown icon too: it reaches above the slot while magnified.
        x: 0
        width: parent.width
        y: -(Theme.dockIconSize * (root.magScale - 1) + root.lift)
        height: parent.height - y
        hoverEnabled: true
        onContainsMouseChanged: {
            if (containsMouse) root.announce()
            else if (root.dockWindow) root.dockWindow.hideTip(root.name)
        }
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
                var target = root.toplevels[(idx + 1) % root.toplevels.length]
                if (!WindowService.restore(target)) WindowService.activate(target)
                return
            }
            root.launchEntry()
        }
    }
}
