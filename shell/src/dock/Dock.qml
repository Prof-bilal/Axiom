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

    // The surface is larger than the visible dock by `shadow` on each side so a
    // soft shadow can be drawn; only the dock body takes input, and only the
    // body's height is reserved from the work area.
    readonly property int shadow: 10

    anchors { bottom: true }
    margins.bottom: Theme.dockEdgeGap - shadow
    implicitHeight: body.height + shadow * 2
    implicitWidth: body.width + shadow * 2
    exclusiveZone: body.height + Theme.dockEdgeGap - shadow
    color: "transparent"
    mask: Region { item: body }
    WlrLayershell.namespace: "axiom-dock"
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.keyboardFocus: WlrLayershell.None

    // Soft shadow: a few widening, fading copies of the body.
    Repeater {
        model: 4
        delegate: Rectangle {
            required property int index
            readonly property int spread: (index + 1) * 2
            anchors.centerIn: body
            width: body.width + spread * 2
            height: body.height + spread * 2
            radius: Theme.radiusDock + spread
            color: "black"
            opacity: 0.14 - index * 0.03
        }
    }

    // Body: a white surface with a hairline edge.
    Rectangle {
        id: body
        anchors.centerIn: parent
        width: row.implicitWidth + Theme.dockPadding * 2
        height: Theme.dockItemSize + Theme.dockPadding * 2
        radius: Theme.radiusDock
        color: Theme.dockBackground
        border.width: 1
        border.color: Theme.dockBorder
    }

    Row {
        id: row
        anchors.centerIn: body
        spacing: Theme.spacingXs

        DockItem {
            launcher: true
            name: "Applications"
            iconSource: Quickshell.shellPath("assets/mascots/launcher.png")
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
                color: Theme.dockBorder
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
