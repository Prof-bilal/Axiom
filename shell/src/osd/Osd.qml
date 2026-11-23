import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.src.shared
import qs.services

// On-screen display: a small solid card above the dock for volume, brightness
// and Caps Lock, like the reference. Shown by the compositor's media-key
// bindings through IPC (volumeStep, volumeMute, brightnessStep, capsLock); it
// never takes focus or clicks and hides itself after a moment.
//
// shortcut: the Caps Lock state is read from the keyboard LED in /sys, so a
// keyboard without a Caps Lock LED shows nothing. Upgrade when the compositor
// exposes lock state to the shell.
PanelWindow {
    id: osd

    property string kind: "volume"      // volume | brightness | caps
    property int value: 0               // 0..100 for volume and brightness
    property bool muted: false
    property bool capsOn: false
    property bool shown: false

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { bottom: true; left: true; right: true }
    implicitHeight: 300
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: shown
    mask: Region {}
    WlrLayershell.namespace: "axiom-osd"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrLayershell.None

    function show(k, v, m) {
        kind = k
        value = Math.max(0, Math.min(100, Math.round(v)))
        muted = !!m
        shown = true
        hideTimer.restart()
    }

    Timer { id: hideTimer; interval: 1500; onTriggered: osd.shown = false }

    // ---- actions bound to media keys (all through SystemService) -------------
    function volumeStep(delta) {
        if (!SystemService.audioAvailable) return
        if (SystemService.audioMuted && delta > 0) SystemService.toggleMute()
        var v = Math.max(0, Math.min(100, SystemService.audioVolume + delta))
        SystemService.setVolume(v)
        show("volume", v, false)
    }

    function volumeMute() {
        if (!SystemService.audioAvailable) return
        SystemService.toggleMute()
        // The mute flag updates a moment later; show the opposite of the old one.
        show("volume", SystemService.audioVolume, !SystemService.audioMuted)
    }

    function brightnessStep(delta) {
        if (!SystemService.brightnessAvailable) return
        SystemService.setBrightness(SystemService.brightnessPercent + delta)
        show("brightness", SystemService.brightnessPercent, false)
    }

    // Caps Lock: read the keyboard LED shortly after the key was released.
    function capsLock() { capsDelay.restart() }
    Timer { id: capsDelay; interval: 80; onTriggered: capsProbe.running = true }
    Process {
        id: capsProbe
        command: ["sh", "-c", "cat /sys/class/leds/*::capslock/brightness 2>/dev/null | head -n 1"]
        stdout: StdioCollector {
            onStreamFinished: {
                var t = text.trim()
                if (t.length === 0) return
                osd.capsOn = t !== "0"
                osd.show("caps", 0, false)
            }
        }
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.dockItemSize + Theme.dockPadding * 2 + Theme.dockEdgeGap + 18
        width: 190
        height: 128
        radius: 18
        color: Theme.menuSurface
        border.width: 1
        border.color: Theme.menuBorder
        opacity: osd.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.motionFeedback } }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 12
            text: osd.kind === "volume" ? "Volume" : osd.kind === "brightness" ? "Brightness" : "Caps Lock"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }

        AxiomIcon {
            visible: osd.kind !== "brightness"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 38
            width: 36; height: 36
            name: osd.kind === "volume" ? (osd.muted || osd.value === 0 ? "volume-muted"
                                           : osd.value > 50 ? "volume-high" : "volume-low")
                : "lock"
            color: osd.kind === "caps" && osd.capsOn ? Theme.warning : Theme.accentBright
        }

        // Brightness: a drawn sun (disc and eight rays).
        Item {
            visible: osd.kind === "brightness"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 38
            width: 36; height: 36
            Rectangle {
                anchors.centerIn: parent
                width: 14; height: 14; radius: 7
                color: Theme.warning
            }
            Repeater {
                model: 8
                delegate: Rectangle {
                    required property int index
                    width: 3; height: 7; radius: 1.5
                    color: Theme.warning
                    x: 16.5; y: 1
                    transform: Rotation { origin.x: 1.5; origin.y: 17; angle: index * 45 }
                }
            }
        }

        // Level bar for volume and brightness.
        Rectangle {
            visible: osd.kind !== "caps"
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom
                      leftMargin: 20; rightMargin: 20; bottomMargin: 26 }
            height: 6
            radius: 3
            color: Theme.statePressed
            Rectangle {
                width: parent.width * (osd.muted ? 0 : osd.value / 100)
                height: parent.height
                radius: 3
                color: osd.kind === "brightness" ? Theme.warning : Theme.accent
            }
        }
        Text {
            visible: osd.kind !== "caps"
            anchors { right: parent.right; bottom: parent.bottom; rightMargin: 20; bottomMargin: 6 }
            text: osd.muted ? "Muted" : osd.value + "%"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
        }
        Text {
            visible: osd.kind === "caps"
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 18 }
            text: osd.capsOn ? "Caps Lock on" : "Caps Lock off"
            color: osd.capsOn ? Theme.warning : Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
    }
}
