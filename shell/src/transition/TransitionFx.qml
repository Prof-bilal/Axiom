import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.services

// Window and workspace transitions for labwc (ADR-016). labwc has no animation
// API and the shell cannot move real windows, so these are overlay effects drawn
// above the desktop and click-through (empty mask):
//   open     the app's icon grows out of its own dock icon and fades as the window appears
//   minimize the app's icon shrinks and flies down into its own dock icon
//   slide    the wallpaper slides off in the direction of the new workspace
// Dock positions come from the dock (UiState.dockSlots). Window geometry is not
// available, so the icon travels between the dock and the screen centre.
// Under Hyprland (ADR-031) the compositor animates real windows and workspaces
// itself, so this overlay stays out of the way: one owner per motion.
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

    // The compositor animates by itself (Hyprland sets this variable in its session).
    readonly property bool compositorAnimates: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "") !== ""
    visible: !compositorAnimates

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
    // The icon's own place in the dock (its centre when the app has no dock icon).
    readonly property string slotKey: {
        var e = ApplicationService.entryForAppId(appId)
        return e ? e.id : appId
    }
    readonly property real dockX: cx + (UiState.dockSlots[slotKey] !== undefined ? UiState.dockSlots[slotKey] : 0)
    readonly property real dockY: height - Theme.dockEdgeGap - Theme.dockItemSize / 2

    // Easing, applied to the 0..1 progress so each effect can have its own curve.
    function easeOut(t) { var u = 1 - t; return 1 - u * u * u }                 // fast start, soft landing
    function easeInOut(t) { return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2 }
    function easeIn(t) { return t * t * t }

    Timer { interval: 3000; running: true; onTriggered: fx.ready = true }

    function play(k, id) {
        kind = k
        appId = id || ""
        dur = k === "slide" ? 420 : k === "minimize" ? 380 : 340
        progress = 0
        playing = true
        anim.restart()
    }

    function switchTo(name) {
        if (compositorAnimates) return
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
        easing.type: Easing.Linear
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
                    if (fx.ready && !fx.compositorAnimates && tl.modelData.minimized) fx.play("minimize", tl.modelData.appId)
                }
            }
        }
        onObjectAdded: function (index, object) {
            if (fx.ready && !fx.compositorAnimates) fx.play("open", object.modelData.appId)
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

    // Wallpaper slide for workspace switches: the old desktop slides away in the direction of travel
    // (a soft edge shadow rides its trailing side), revealing the new workspace.
    Item {
        id: slide
        anchors.fill: parent
        visible: fx.playing && fx.kind === "slide"
        readonly property real t: fx.easeInOut(fx.progress)
        x: -fx.slideDir * fx.width * t

        Image {
            anchors.fill: parent
            opacity: 1 - 0.35 * slide.t
            source: SettingsService.wallpaper.length > 0
                ? "file://" + SettingsService.wallpaper
                : Quickshell.shellPath("assets/wallpaper.png")
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 1920
        }
        Rectangle {
            width: 36
            height: parent.height
            x: fx.slideDir > 0 ? parent.width : -width
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: fx.slideDir > 0 ? Qt.rgba(0, 0, 0, 0.28) : "transparent" }
                GradientStop { position: 1.0; color: fx.slideDir > 0 ? "transparent" : Qt.rgba(0, 0, 0, 0.28) }
            }
        }
    }

    // App icon for open and minimize.
    //   open     starts small on its dock icon, rises to the middle of the screen, then melts away
    //   minimize starts in the middle and is pulled down into its dock icon (slow, then fast, like a genie)
    Rectangle {
        id: card
        visible: fx.playing && fx.kind !== "slide"
        width: 128
        height: 128
        radius: 28

        readonly property bool opening: fx.kind === "open"
        // Travel: 0 at the start place, 1 at the end place.
        readonly property real travel: opening ? fx.easeOut(fx.progress) : fx.easeIn(fx.progress)
        readonly property real fromX: opening ? fx.dockX : fx.cx
        readonly property real fromY: opening ? fx.dockY : fx.cy
        readonly property real toX: opening ? fx.cx : fx.dockX
        readonly property real toY: opening ? fx.cy : fx.dockY

        x: fromX + (toX - fromX) * travel - width / 2
        y: fromY + (toY - fromY) * travel - height / 2
        scale: opening ? 0.3 + 0.85 * travel : 1.05 - 0.9 * travel
        opacity: opening ? (fx.progress < 0.55 ? 1 : 1 - (fx.progress - 0.55) / 0.45) * 0.95
                         : 1 - 0.8 * fx.progress
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
