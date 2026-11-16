import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.services

// Window and workspace transitions for labwc (ADR-016). labwc has no animation
// API and the shell cannot move real windows, so these are overlay effects drawn
// above the desktop and click-through (empty mask):
//   open     an app card at the centre fades and grows out, as a window appears
//   minimize an app card shrinks and flies to the dock, as a window goes away
//   slide    the wallpaper slides off in the direction of the new workspace
// Positions use the screen centre, since window geometry is not available.
PanelWindow {
    id: fx

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "axiom-transition"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrLayershell.None
    mask: Region {}

    property bool ready: false     // ignore the events of the initial session start
    property bool playing: false
    property string kind: ""       // "open", "minimize" or "slide"
    property string appId: ""
    property int slideDir: 1
    property int lastWs: -1
    property real progress: 0
    property int dur: 240

    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real dockX: width / 2
    readonly property real dockY: height - Theme.dockEdgeGap - Theme.dockItemSize / 2

    Timer { interval: 3000; running: true; onTriggered: fx.ready = true }

    function play(k, id) {
        kind = k
        appId = id || ""
        dur = k === "slide" ? 320 : k === "minimize" ? 280 : 220
        progress = 0
        playing = true
        anim.restart()
    }

    function switchTo(name) {
        var n = parseInt(name)
        if (isNaN(n)) return
        if (!ready) { lastWs = n; return }
        if (n === lastWs) return
        slideDir = n > lastWs ? 1 : -1
        lastWs = n
        play("slide", "")
    }

    NumberAnimation {
        id: anim
        target: fx
        property: "progress"
        from: 0
        to: 1
        duration: fx.dur
        easing.type: Easing.OutCubic
        onFinished: fx.playing = false
    }

    // One delegate per open window: a new window fires "open", and a window that is
    // minimized fires "minimize". Existing windows at start-up do not fire (ready).
    Instantiator {
        model: ToplevelManager.toplevels
        delegate: QtObject {
            id: tl
            required property var modelData
            property var watch: Connections {
                target: tl.modelData
                function onMinimizedChanged() {
                    if (fx.ready && tl.modelData.minimized) fx.play("minimize", tl.modelData.appId)
                }
            }
        }
        onObjectAdded: function (index, object) {
            if (fx.ready) fx.play("open", object.modelData.appId)
        }
    }

    // Workspace switches (ext-workspace state from WorkspaceService).
    Instantiator {
        model: WorkspaceService.list
        delegate: QtObject {
            id: wsd
            required property var modelData
            property var watch: Connections {
                target: wsd.modelData
                function onActiveChanged() {
                    if (wsd.modelData.active) fx.switchTo(wsd.modelData.name)
                }
            }
        }
    }

    // Wallpaper slide for workspace switches.
    Image {
        anchors.fill: parent
        visible: fx.playing && fx.kind === "slide"
        x: -fx.slideDir * fx.width * fx.progress
        opacity: 1 - fx.progress
        source: SettingsService.wallpaper.length > 0
            ? "file://" + SettingsService.wallpaper
            : Quickshell.shellPath("assets/wallpaper.png")
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: 1920
    }

    // App card for open and minimize (the metal card material, no blur).
    Rectangle {
        id: card
        visible: fx.playing && fx.kind !== "slide"
        width: 128
        height: 128
        radius: 28
        x: fx.cx - width / 2 + (fx.kind === "minimize" ? (fx.dockX - fx.cx) * fx.progress : 0)
        y: fx.cy - height / 2 + (fx.kind === "minimize" ? (fx.dockY - fx.cy) * fx.progress : 0)
        scale: fx.kind === "minimize" ? 1 - 0.85 * fx.progress : 0.92 + 0.08 * fx.progress
        opacity: fx.kind === "minimize" ? 1 - 0.7 * fx.progress : 0.95 * (1 - fx.progress)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#8C888D" }
            GradientStop { position: 1.0; color: "#3E3A3E" }
        }

        AppIcon {
            anchors.centerIn: parent
            size: 72
            source: ApplicationService.resolveIcon(fx.appId)
        }
    }
}
