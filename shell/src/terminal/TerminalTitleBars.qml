import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.src.shared
import qs.services

// Title bars for windows that do not draw their own (ADR-029: Hyprland draws
// none): the terminal, browser, editor and other third-party applications.
// Axiom apps (class org.axiom.*) draw the bar inside their window instead, in
// AppWindow, so they are skipped here. Fullscreen windows get no bar.
//
// One thin layer surface per window, placed above it where there is room under
// the panel, otherwise over its top edge. It uses the same buttons as the
// in-window bar. Close, minimize (hidden special workspace) and maximize.
//
// shortcut: bars follow the window by polling Hyprland every 250 ms, so they can
// lag a move by up to a quarter second and cannot be dragged; for a bar that is
// part of the window, use a compositor title-bar plugin. Applications that draw
// their own bar need it switched off (see the ISO defaults for Firefox and
// VS Code), or they show two bars.
Item {
    id: bars

    readonly property int barHeight: 30

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: Hyprland.refreshToplevels()
    }

    readonly property var windows: {
        var all = Hyprland.toplevels ? Hyprland.toplevels.values : []
        var out = []
        for (var i = 0; i < all.length; i++) {
            var o = all[i].lastIpcObject
            if (!o || !o.mapped || o.hidden || !o.workspace || o.workspace.id <= 0) continue
            var cls = o.class ? String(o.class) : ""
            if (cls.length === 0 || cls.indexOf("org.axiom.") === 0) continue
            if (o.fullscreen && o.fullscreen !== 0) continue
            out.push(all[i])
        }
        return out
    }

    Instantiator {
        model: bars.windows
        delegate: PanelWindow {
            id: bar
            required property var modelData
            readonly property var geo: modelData.lastIpcObject
            screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
            anchors { top: true; left: true }
            // Terminals: the bar sits on the window's top edge (foot reserves the
            // space with its top padding), so it reads as part of the window.
            // Other windows: above the window when there is room under the panel.
            readonly property bool overTop: String(geo ? geo.class : "") === "foot"
            margins.left: geo ? geo.at[0] : 0
            margins.top: geo ? ((!overTop && geo.at[1] - bars.barHeight >= Theme.panelBottom)
                                ? geo.at[1] - bars.barHeight : geo.at[1]) : 0
            implicitWidth: geo ? geo.size[0] : 0
            implicitHeight: bars.barHeight
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "axiom-titlebar"
            WlrLayershell.layer: WlrLayershell.Top
            WlrLayershell.keyboardFocus: WlrLayershell.None

            // Rounded top corners that match the window's (rounding 16); the
            // bottom is cut square by the clip so the bar joins the window body.
            Item {
                anchors.fill: parent
                clip: true
                Rectangle {
                    width: parent.width
                    height: parent.height + 24
                    radius: bar.overTop ? Theme.radiusWindow : Theme.radiusSurface
                    color: Theme.glassFillStrong
                    border.width: 1
                    border.color: Theme.stateSelectedBorder
                }
            }

            TrafficLights {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                onCloseClicked: if (bar.modelData.wayland) bar.modelData.wayland.close()
                onMinimizeClicked: bar.focusThen(function () { WindowService.minimizeActive() })
                onMaximizeClicked: bar.focusThen(function () { WindowService.toggleMaximizeActive() })
            }

            Text {
                anchors.centerIn: parent
                text: bar.modelData.title
                color: Theme.textPrimary
                opacity: 0.8
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                elide: Text.ElideRight
                width: parent.width - 120
                horizontalAlignment: Text.AlignHCenter
            }

            // Hyprland's dispatchers act on the focused window, so focus it first.
            function focusThen(action) {
                if (modelData.wayland) modelData.wayland.activate()
                action()
            }
        }
    }
}
