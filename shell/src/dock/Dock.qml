import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.src.dock
import qs.services
import "magnify.js" as Mag

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

    // ---- magnification (macOS style) ----------------------------------------------------
    // The maths is in magnify.js. As the pointer moves along the dock, slots grow by a falloff of their
    // distance to it and the row widens around the icon under the pointer, so that icon never slides away.
    // Rest geometry (slot sizes, body, exclusive zone) is unchanged, so every number elsewhere that
    // assumes the dock's size stays valid.
    readonly property int gap: Theme.spacingXs
    readonly property var magParams: ({ peak: Theme.dockMagnifyPeak, reach: Theme.dockMagnifyReach })

    // Slot widths at rest, in Row order: launcher, pinned, separator (only with running apps), running.
    readonly property var restSlots: {
        var out = [{ w: Theme.dockItemSize, grow: true }]
        for (var i = 0; i < pinnedItems.length; i++) out.push({ w: Theme.dockItemSize, grow: true })
        if (runningItems.length > 0) out.push({ w: 9, grow: false })
        for (var j = 0; j < runningItems.length; j++) out.push({ w: Theme.dockItemSize, grow: true })
        return out
    }
    readonly property real restRowWidth: {
        var w = 0
        for (var i = 0; i < restSlots.length; i++) w += restSlots[i].w
        return w + gap * Math.max(0, restSlots.length - 1)
    }
    // Room the widened row can reach past the rest row. The window is sized from it once, so it never
    // resizes while the pointer moves (a resizing layer surface would flicker).
    readonly property var room: Mag.bounds(restSlots, gap, magParams)
    readonly property real extra: Math.max(room.before, room.after)

    // Tell the window transitions where each icon is (same order as restSlots), once per screen layout.
    function publishSlots() {
        if (screen !== Quickshell.screens[0]) return
        var keys = ["launcher"]
        pinnedItems.forEach(function (i) { keys.push(i.key) })
        if (runningItems.length > 0) keys.push("")           // the separator has no icon
        runningItems.forEach(function (i) { keys.push(i.key) })
        var out = {}, x = -restRowWidth / 2
        for (var i = 0; i < restSlots.length; i++) {
            if (keys[i]) out[keys[i]] = x + restSlots[i].w / 2
            x += restSlots[i].w + gap
        }
        UiState.dockSlots = out
    }
    onRestSlotsChanged: publishSlots()
    Component.onCompleted: publishSlots()

    property real pointerX: 0
    // 0 at rest, 1 while the pointer is on the dock; eases the effect in and out.
    property real strength: 0
    Behavior on strength { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    readonly property bool magnifying: strength > 0.02
    readonly property var lay: Mag.layout(restSlots, gap, (implicitWidth - restRowWidth) / 2, pointerX, strength, magParams)

    // The surface is larger than the visible dock: `shadow` on each side for a soft shadow, `extra` on each
    // side for the widened row, and headroom above for the lifted icons and the name tooltip. Only the live
    // row takes input, and only the body's height is reserved from the work area.
    readonly property int shadow: 10
    readonly property int tipSpace: 72
    property string tipText: ""
    property Item tipItem: null
    function showTip(text, item) { tipText = text; tipItem = item }
    function hideTip(name) { if (tipText === name) { tipText = ""; tipItem = null } }

    anchors { bottom: true }
    margins.bottom: Theme.dockEdgeGap - shadow
    implicitHeight: body.height + shadow * 2 + tipSpace
    implicitWidth: restRowWidth + Theme.dockPadding * 2 + extra * 2 + shadow * 2
    exclusiveZone: body.height + Theme.dockEdgeGap - shadow
    color: "transparent"
    mask: Region { item: zone }
    WlrLayershell.namespace: "axiom-dock"
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.keyboardFocus: WlrLayershell.None

    // Body at rest: transparent, so the wallpaper shows behind the icons; no border.
    Item {
        id: body
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: dock.shadow
        width: dock.restRowWidth + Theme.dockPadding * 2
        height: Theme.dockItemSize + Theme.dockPadding * 2

        // No plate and no outline: the icons sit directly on the wallpaper.
        Rectangle {
            anchors.fill: parent
            radius: Theme.radiusDock
            color: Theme.dockBackground
            border.width: 0
        }
    }

    // Input region: the live row. The headroom above it counts only while the pointer is on the dock, so at
    // rest that strip stays click-through and never takes clicks from windows underneath.
    Item {
        id: zone
        x: row.x - Theme.dockPadding
        width: dock.lay.total + Theme.dockPadding * 2
        y: body.y - (dock.magnifying ? dock.tipSpace : 0)
        height: body.height + (dock.magnifying ? dock.tipSpace : 0)
    }

    // One pointer tracker for the whole dock (the per-icon areas only see their own slot).
    Item {
        anchors.fill: parent
        HoverHandler {
            onHoveredChanged: dock.strength = hovered ? 1 : 0
            onPointChanged: if (hovered) dock.pointerX = point.position.x
        }
    }

    // Name tooltip above the hovered entry, following its grown icon.
    Rectangle {
        id: tip
        visible: dock.tipText.length > 0 && dock.tipItem !== null
        width: tipLabel.implicitWidth + 16
        height: 24
        radius: Theme.radiusSmall
        color: Theme.panelBackground
        border.width: 1
        border.color: Theme.panelBorder
        y: body.y + Theme.dockPadding + Theme.dockItemSize / 2 + Theme.dockIconSize / 2 - 1
           - (dock.tipItem ? dock.tipItem.lift + Theme.dockIconSize * dock.tipItem.magScale : 0) - height - 6
        x: Math.max(4, Math.min(dock.width - width - 4,
                                (dock.tipItem ? row.x + dock.tipItem.x + dock.tipItem.width / 2 : 0) - width / 2))
        Text {
            id: tipLabel
            anchors.centerIn: parent
            text: dock.tipText
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
        }
    }

    Row {
        id: row
        x: dock.lay.origin
        y: body.y + Theme.dockPadding
        spacing: dock.gap

        DockItem {
            launcher: true
            slot: 0
            dockWindow: dock
            name: "Applications"
            iconSource: Quickshell.shellPath("assets/mascots/launcher.png")
            focused: UiState.launcherOpen && UiState.launcherMode === "grid"
        }

        Repeater {
            model: dock.pinnedItems
            delegate: DockItem {
                required property var modelData
                required property int index
                item: modelData
                slot: 1 + index
                dockWindow: dock
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
                required property int index
                item: modelData
                slot: 2 + dock.pinnedItems.length + index
                dockWindow: dock
            }
        }
    }
}
