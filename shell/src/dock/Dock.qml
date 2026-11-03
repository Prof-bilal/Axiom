import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.src.dock
import qs.services

// Axiom dock — the Axiom launcher, pinned applications, then every other
// running application, backed by real compositor toplevel state. Pinned
// entries that are not installed are omitted; there are no placeholder icons.
//
// Anchored to the bottom edge only, so the compositor centres it on every
// output size and reserves its exclusive zone (windows never slide under it).
PanelWindow {
    id: dock
    property var modelData
    screen: modelData

    // Pinned desktop-entry ids, in order: the user's Settings choice, or the
    // defaults (terminal, files, browser, code editor, trash). Ids that are not
    // installed are skipped.
    readonly property var pinnedIds: SettingsService.dockPins

    readonly property var items: {
        var entries = ApplicationService.all // binding dependency
        var toplevels = WindowService.toplevels ? WindowService.toplevels.values : []
        var active = WindowService.active
        var running = {}
        for (var i = 0; i < toplevels.length; i++) {
            var tid = toplevels[i].appId
            if (!tid || tid.length === 0) continue
            var te0 = ApplicationService.entryForAppId(tid)
            var key = te0 ? te0.id : tid
            if (!running[key]) running[key] = []
            running[key].push(toplevels[i])
        }
        var focusedKey = ""
        if (active && active.appId) {
            var ae = ApplicationService.entryForAppId(active.appId)
            focusedKey = ae ? ae.id : active.appId
        }

        var out = []
        var seen = {}
        for (var p = 0; p < dock.pinnedIds.length; p++) {
            var pe = ApplicationService.entryForAppId(dock.pinnedIds[p])
            if (!pe || seen[pe.id]) continue
            seen[pe.id] = true
            out.push({
                key: pe.id,
                name: pe.name,
                icon: ApplicationService.iconFor(pe),
                pinned: true,
                toplevels: running[pe.id] || [],
                focused: focusedKey === pe.id,
                entry: pe
            })
        }
        for (var j = 0; j < toplevels.length; j++) {
            var t = toplevels[j]
            if (!t.appId) continue
            var te = ApplicationService.entryForAppId(t.appId)
            var k = te ? te.id : t.appId
            if (seen[k]) continue
            seen[k] = true
            out.push({
                key: k,
                name: te ? te.name : (t.title || t.appId),
                icon: te ? ApplicationService.iconFor(te) : ApplicationService.resolveIcon(t.appId),
                pinned: false,
                toplevels: running[k] || [],
                focused: focusedKey === k,
                entry: te
            })
        }
        return out
    }

    readonly property var pinnedItems: items.filter(function (i) { return i.pinned })
    readonly property var runningItems: items.filter(function (i) { return !i.pinned })

    // The surface is larger than the visible dock by `glow` on each side so the
    // soft edge glow can be drawn; only the dock body takes input, and only
    // the body's height is reserved from the work area.
    readonly property int glow: 10

    anchors { bottom: true }
    margins.bottom: Theme.dockEdgeGap - glow
    implicitHeight: body.height + glow * 2
    implicitWidth: body.width + glow * 2
    exclusiveZone: body.height + Theme.dockEdgeGap - glow
    color: "transparent"
    mask: Region { item: body }
    WlrLayershell.namespace: "axiom-dock"
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.keyboardFocus: WlrLayershell.None

    // Edge gradient: Axiom cyan leading into a warm orange trailing edge.
    component EdgeGradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: Theme.cyan }
        GradientStop { position: 0.55; color: Theme.cyanMuted }
        GradientStop { position: 1.0; color: Theme.orange }
    }

    // Soft glow: a few widening, fading copies of the edge behind the body.
    Repeater {
        model: 4
        delegate: Rectangle {
            required property int index
            readonly property int spread: (index + 1) * 2
            anchors.centerIn: body
            width: body.width + spread * 2
            height: body.height + spread * 2
            radius: Theme.radiusDock + spread
            opacity: 0.10 - index * 0.022
            gradient: EdgeGradient {}
        }
    }

    // Body: 1 px gradient edge around a graphite glass fill.
    Rectangle {
        id: body
        anchors.centerIn: parent
        width: row.implicitWidth + Theme.dockPadding * 2
        height: Theme.dockItemSize + Theme.dockPadding * 2
        radius: Theme.radiusDock
        gradient: EdgeGradient {}

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Theme.radiusDock - 1
            color: Qt.rgba(7 / 255, 11 / 255, 14 / 255, 0.94)

            // Faint top highlight so the edge reads as a surface, not a hole.
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                anchors.leftMargin: Theme.radiusDock
                anchors.rightMargin: Theme.radiusDock
                anchors.topMargin: 1
                height: 1
                color: Qt.rgba(1, 1, 1, 0.05)
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: body
        spacing: Theme.spacingXs

        DockItem {
            launcher: true
            name: "Applications"
            iconSource: Quickshell.shellPath("assets/axiom-mark.svg")
            focused: UiState.launcherOpen && UiState.launcherMode === "grid"
        }

        Repeater {
            model: dock.pinnedItems
            delegate: DockItem {
                required property var modelData
                item: modelData
            }
        }

        // Separator between pinned and other running applications.
        Item {
            visible: dock.runningItems.length > 0
            width: 9
            height: Theme.dockItemSize
            Rectangle {
                anchors.centerIn: parent
                width: 1
                height: Theme.dockIconSize * 0.7
                color: Theme.border
            }
        }

        Repeater {
            model: dock.runningItems
            delegate: DockItem {
                required property var modelData
                item: modelData
            }
        }
    }
}
