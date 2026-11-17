import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared

// Snap feedback: a dashed cyan-to-amber zone with a label over the half of the
// screen a window is snapping to ("Snap to Left" / "Snap to Right"), shown for a
// moment when the compositor's snap keys are used. Click-through, no focus.
//
// shortcut: shown from the snap key bindings only; there is no live preview
// while dragging a window to an edge, because Hyprland gives the shell no drag
// events. Upgrade when it does, or when drag is handled in the shell.
PanelWindow {
    id: hint

    property string side: "right"
    property bool shown: false
    readonly property int pad: 10

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    // The window is the zone itself (half the screen under the panel, above the dock).
    anchors { top: true; left: side === "left"; right: side === "right" }
    margins { top: Theme.panelBottom + pad; left: pad; right: pad }
    implicitWidth: screen ? screen.width / 2 - pad * 2 : 600
    implicitHeight: screen ? screen.height - Theme.panelBottom - pad
                             - Theme.dockItemSize - Theme.dockPadding * 2 - Theme.dockEdgeGap - pad * 2 : 600
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: shown
    mask: Region {}
    WlrLayershell.namespace: "axiom-snap"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrLayershell.None

    function show(s) {
        side = s === "left" ? "left" : "right"
        shown = true
        hideTimer.restart()
    }

    Timer { id: hideTimer; interval: 800; onTriggered: hint.shown = false }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusWindow
        color: Theme.surfaceElevated
    }

    Canvas {
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var g = ctx.createLinearGradient(0, 0, width, height)
            g.addColorStop(0, "#37F0EA")
            g.addColorStop(1, "#FFB348")
            ctx.strokeStyle = g
            ctx.lineWidth = 3
            ctx.setLineDash([12, 8])
            var r = Theme.radiusWindow, x = 2, y = 2, w = width - 4, h = height - 4
            ctx.beginPath()
            ctx.moveTo(x + r, y)
            ctx.lineTo(x + w - r, y); ctx.arcTo(x + w, y, x + w, y + r, r)
            ctx.lineTo(x + w, y + h - r); ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
            ctx.lineTo(x + r, y + h); ctx.arcTo(x, y + h, x, y + h - r, r)
            ctx.lineTo(x, y + r); ctx.arcTo(x, y, x + r, y, r)
            ctx.stroke()
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingMd

        // Half-screen glyph: a filled half and an outlined half.
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            layoutDirection: hint.side === "left" ? Qt.LeftToRight : Qt.RightToLeft
            Rectangle { width: 30; height: 56; radius: 6; color: Theme.textPrimary }
            Rectangle { width: 30; height: 56; radius: 6; color: "transparent"
                        border.width: 2; border.color: Theme.textPrimary }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: hint.side === "left" ? "Snap to Left" : "Snap to Right"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontTitle
        }
    }
}
