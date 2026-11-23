import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.src.shared

// Screenshot and screen-recording bar (ADR-030), opened with Print or
// Super+Shift+S. Pick a mode (image: region, screen; video: region,
// screen), then press the capture button or Enter. Region modes ask for a
// dragged rectangle first. The shell only builds the argument list; grim and
// wf-recorder do the capture, and a recording shows a Stop pill until it ends.
//
// shortcut: there is no window mode (labwc's foreign-toplevel protocol gives no
// window geometry). The recording pill is itself on screen and so appears in the
// video. Upgrade with a toplevel-capture path that excludes the shell's surfaces.
Scope {
    id: cap

    property bool open: false
    property string mode: "region"     // region | screen | vregion | vscreen
    property bool mic: false
    property bool timer3: false
    property rect sel: Qt.rect(0, 0, 0, 0)
    property string message: ""

    readonly property bool isVideo: mode === "vregion" || mode === "vscreen"
    readonly property bool needsRect: mode === "region" || mode === "vregion"
    readonly property bool hasSel: sel.width >= 8 && sel.height >= 8

    function toggle() {
        if (recorder.running) { stopRecording(); return }
        open = !open
        if (open) { message = ""; sel = Qt.rect(0, 0, 0, 0) }
    }

    function stamp() { return Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss") }
    function geometry(r) {
        return Math.round(r.x) + "," + Math.round(r.y) + " " + Math.round(r.width) + "x" + Math.round(r.height)
    }

    // The area to capture: the dragged/picked rectangle, or the whole screen.
    function area() {
        var s = Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        if (!needsRect) return s ? Qt.rect(0, 0, s.width, s.height) : Qt.rect(0, 0, 0, 0)
        return sel
    }

    function capture() {
        if (needsRect && !hasSel) { message = "Drag to choose an area"; return }
        var r = area()
        open = false
        startDelay.pendingArea = r
        startDelay.interval = (timer3 ? 3000 : 0) + 400   // 400 ms lets the bar fade out
        startDelay.start()
    }

    Timer {
        id: startDelay
        property rect pendingArea
        onTriggered: {
            var g = cap.geometry(pendingArea)
            var home = Quickshell.env("HOME")
            if (cap.isVideo) {
                var vf = home + "/Videos/Recording-" + cap.stamp() + ".mp4"
                recorder.file = vf
                recorder.command = ["sh", "-c", "f=\"$1\"; shift; mkdir -p \"$(dirname \"$f\")\"; exec wf-recorder -f \"$f\" \"$@\"",
                                    "_", vf, "-g", g].concat(cap.mic ? ["--audio"] : [])
                recorder.seconds = 0
                recorder.running = true
            } else {
                var f = home + "/Pictures/Screenshots/Screenshot-" + cap.stamp() + ".png"
                shot.file = f
                shot.command = ["sh", "-c",
                    "f=\"$1\"; shift; mkdir -p \"$(dirname \"$f\")\" && grim \"$@\" \"$f\" && { command -v wl-copy >/dev/null && wl-copy < \"$f\"; notify-send -a Axiom 'Screenshot saved' \"$f\"; }",
                    "_", f, "-g", g]
                shot.running = true
            }
        }
    }

    Process {
        id: shot
        property string file: ""
        onExited: function (code) {
            if (code !== 0) Quickshell.execDetached(["notify-send", "-a", "Axiom", "Screenshot failed",
                code === 127 ? "grim is not installed." : "grim could not capture the screen."])
        }
    }

    Process {
        id: recorder
        property string file: ""
        property int seconds: 0
        onExited: function (code, status) {
            // 130 is wf-recorder finishing after SIGINT, which is how Stop ends it.
            if (code === 0 || code === 130 || code === 2)
                Quickshell.execDetached(["notify-send", "-a", "Axiom", "Recording saved", file])
            else Quickshell.execDetached(["notify-send", "-a", "Axiom", "Recording failed",
                code === 127 ? "wf-recorder is not installed." : "wf-recorder stopped unexpectedly."])
        }
    }

    function stopRecording() { if (recorder.running) recorder.signal(2) }

    // ---- recording indicator ---------------------------------------------------
    PanelWindow {
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; left: true; right: true }
        implicitHeight: 52 + Theme.panelBottom
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: recorder.running
        mask: Region { item: pill }
        WlrLayershell.namespace: "axiom-recording"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrLayershell.None

        Timer { interval: 1000; repeat: true; running: recorder.running; onTriggered: recorder.seconds++ }

        Rectangle {
            id: pill
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.panelBottom + 6
            width: pillRow.implicitWidth + Theme.spacingLg * 2
            height: 38
            radius: height / 2
            color: Theme.menuSurface
            border.width: 1
            border.color: Theme.menuBorder
            Row {
                id: pillRow
                anchors.centerIn: parent
                spacing: Theme.spacingMd
                Rectangle { width: 10; height: 10; radius: 5; color: "#FF5252"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Recording  " + Math.floor(recorder.seconds / 60) + ":" + ("0" + recorder.seconds % 60).slice(-2)
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: stopLabel.implicitWidth + 20; height: 24; radius: 12
                    color: stopArea.containsMouse ? Qt.rgba(1, 148 / 255, 24 / 255, 0.35) : Theme.stateUrgentWash
                    Text { id: stopLabel; anchors.centerIn: parent; text: "Stop"; color: Theme.dangerBright
                           font.family: Theme.fontFamily; font.pixelSize: Theme.fontCaption; font.weight: Font.DemiBold }
                    MouseArea { id: stopArea; anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor; onClicked: cap.stopRecording() }
                }
            }
        }
    }

    // ---- capture overlay -------------------------------------------------------
    PanelWindow {
        id: win
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: cap.open
        WlrLayershell.namespace: "axiom-capture"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: cap.open ? WlrLayershell.Exclusive : WlrLayershell.None

        onVisibleChanged: if (visible) keys.forceActiveFocus()

        Item {
            id: keys
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: cap.open = false
            Keys.onReturnPressed: cap.capture()
            Keys.onEnterPressed: cap.capture()
        }

        // Dim everything except the chosen rectangle.
        Rectangle { color: Theme.scrim; x: 0; y: 0; width: parent.width; height: cap.hasSel && cap.needsRect ? cap.sel.y : parent.height }
        Rectangle { visible: cap.hasSel && cap.needsRect; color: Theme.scrim
                    x: 0; y: cap.sel.y; width: cap.sel.x; height: cap.sel.height }
        Rectangle { visible: cap.hasSel && cap.needsRect; color: Theme.scrim
                    x: cap.sel.x + cap.sel.width; y: cap.sel.y; width: parent.width - x; height: cap.sel.height }
        Rectangle { visible: cap.hasSel && cap.needsRect; color: Theme.scrim
                    x: 0; y: cap.sel.y + cap.sel.height; width: parent.width; height: parent.height - y }

        MouseArea {
            id: drag
            anchors.fill: parent
            hoverEnabled: true
            property real sx: 0
            property real sy: 0
            property bool dragging: false
            onPressed: function (m) {
                if (cap.mode === "region" || cap.mode === "vregion") {
                    sx = m.x; sy = m.y; dragging = true
                    cap.sel = Qt.rect(m.x, m.y, 0, 0)
                }
            }
            onPositionChanged: function (m) {
                if (dragging) {
                    cap.sel = Qt.rect(Math.min(sx, m.x), Math.min(sy, m.y), Math.abs(m.x - sx), Math.abs(m.y - sy))
                }
            }
            onReleased: dragging = false
        }

        // Selection frame and size label.
        Rectangle {
            visible: cap.needsRect && cap.hasSel
            x: cap.sel.x; y: cap.sel.y; width: cap.sel.width; height: cap.sel.height
            color: "transparent"
            border.width: 2
            border.color: Theme.accentBright
        }
        Rectangle {
            visible: cap.needsRect && cap.hasSel
            x: cap.sel.x; y: Math.max(4, cap.sel.y - 26)
            width: sizeText.implicitWidth + 14; height: 22; radius: 6
            color: Theme.surfaceElevated
            Text { id: sizeText; anchors.centerIn: parent
                   text: Math.round(cap.sel.width) + " x " + Math.round(cap.sel.height)
                   color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontCaption }
        }

        // ---- mode bar ----
        component ModeButton: Item {
            id: mb
            property string label: ""
            property string kind: ""        // region | window | screen | vregion | vscreen
            property bool toggle: false     // a switch rather than a mode
            property bool on: false
            signal pressed()
            width: 54; height: 56
            readonly property bool active: toggle ? on : cap.mode === kind

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 2; width: 42; height: 38; radius: 10
                color: mb.active ? Theme.stateSelected : (area.containsMouse ? Theme.stateHover : "transparent")
                border.width: mb.active ? 1 : 0
                border.color: Theme.stateSelectedBorder
                // Glyph: a dashed frame, a window, a screen, with a red dot for video.
                Item {
                    anchors.centerIn: parent
                    width: 22; height: 18
                    Rectangle { anchors.fill: parent; radius: mb.kind === "window" ? 3 : 2; color: "transparent"
                                border.width: 1.5; border.color: mb.active ? Theme.accentBright : Theme.textPrimary
                                visible: !mb.toggle }
                    Rectangle { visible: mb.kind === "window"; x: 1; y: 1; width: parent.width - 2; height: 5
                                color: mb.active ? Theme.accentBright : Theme.textPrimary; opacity: 0.6 }
                    Rectangle { visible: mb.kind === "vregion" || mb.kind === "vscreen"; width: 8; height: 8; radius: 4
                                anchors.centerIn: parent; color: "#FF5252" }
                    Text { visible: mb.toggle; anchors.centerIn: parent; text: mb.label.charAt(0)
                           color: mb.on ? Theme.accentBright : Theme.textPrimary; font.pixelSize: 15; font.family: Theme.fontFamily }
                }
            }
            Text {
                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
                text: mb.label
                color: mb.active ? Theme.textPrimary : Theme.textSecondary
                font.family: Theme.fontFamily; font.pixelSize: 11
            }
            MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: mb.pressed() }
        }

        Rectangle {
            id: bar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.dockItemSize + Theme.dockPadding * 2 + Theme.dockEdgeGap + 18
            width: barRow.implicitWidth + Theme.spacingXl * 2
            height: 92
            radius: Theme.radiusOverlay + 6
            color: Theme.menuSurface
            border.width: 1
            border.color: Theme.menuBorder

            Row {
                id: barRow
                anchors.centerIn: parent
                spacing: Theme.spacingSm

                Column {
                    spacing: 2
                    Row {
                        spacing: 2
                        ModeButton { label: "Region"; kind: "region"; onPressed: { cap.mode = "region"; cap.sel = Qt.rect(0,0,0,0) } }
                        ModeButton { label: "Screen"; kind: "screen"; onPressed: cap.mode = "screen" }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Image"
                           color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: 10 }
                }

                Rectangle { width: 1; height: 56; color: Theme.borderSubtle; anchors.verticalCenter: parent.verticalCenter }

                Column {
                    spacing: 2
                    Row {
                        spacing: 2
                        ModeButton { label: "Region"; kind: "vregion"; onPressed: { cap.mode = "vregion"; cap.sel = Qt.rect(0,0,0,0) } }
                        ModeButton { label: "Screen"; kind: "vscreen"; onPressed: cap.mode = "vscreen" }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Video"
                           color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: 10 }
                }

                Rectangle { width: 1; height: 56; color: Theme.borderSubtle; anchors.verticalCenter: parent.verticalCenter }

                Column {
                    spacing: 2
                    Row {
                        spacing: 2
                        ModeButton { label: "3s timer"; toggle: true; on: cap.timer3; onPressed: cap.timer3 = !cap.timer3 }
                        ModeButton { label: "Mic"; toggle: true; on: cap.mic; onPressed: cap.mic = !cap.mic }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Options"
                           color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: 10 }
                }

                // Capture / record button.
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 56; height: 56; radius: 18
                    color: goArea.containsMouse ? Theme.accentBright : Theme.accent
                    Rectangle {
                        anchors.centerIn: parent
                        width: 24; height: 24; radius: cap.isVideo ? 12 : 6
                        color: cap.isVideo ? "#FF5252" : Theme.background
                    }
                    MouseArea { id: goArea; anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor; onClicked: cap.capture() }
                    Accessible.role: Accessible.Button
                    Accessible.name: cap.isVideo ? "Start recording" : "Take screenshot"
                }
            }

            Text {
                visible: cap.message.length > 0
                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.top; bottomMargin: 8 }
                text: cap.message
                color: Theme.dangerBright
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }
        }
    }
}
