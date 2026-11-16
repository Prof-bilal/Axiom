import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.services

// Alt+Tab window switcher (reference style): a centred solid card with one tile
// per open window, the selected tile outlined in cyan, and page dots below.
// The compositor binds Alt+Tab to `switcherNext` and the release of Alt to
// `switcherCommit` (hyprland.lua, opt-in). While open the overlay also takes the
// keyboard, so Alt being let go is seen here even if the compositor's release
// binding does not fire (it did not in QEMU): Alt up commits, Escape cancels.
// Minimized windows are listed too and come back when chosen.
PanelWindow {
    id: switcher

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: open
    WlrLayershell.namespace: "axiom-switcher"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: open ? WlrLayershell.Exclusive : WlrLayershell.None
    // Clicks pass through: the switcher is keyboard-driven.
    mask: Region {}

    property bool open: false
    property int index: 0
    property var entries: []

    readonly property int perPage: 5
    readonly property int pageCount: Math.max(1, Math.ceil(entries.length / perPage))
    readonly property int page: Math.floor(index / perPage)

    // Windows most recently used first. The compositor's foreign-toplevel list has
    // no focus order, so the shell remembers it: each time a window becomes the
    // active one it moves to the front of `mru`.
    property var mru: []
    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() {
            var a = ToplevelManager.activeToplevel
            if (!a) return
            var next = [a]
            for (var i = 0; i < switcher.mru.length; i++) if (switcher.mru[i] !== a) next.push(switcher.mru[i])
            switcher.mru = next
        }
    }

    function collect() {
        var all = WindowService.list()
        var out = []
        for (var i = 0; i < all.length; i++) {
            var t = all[i]
            if (!t.appId) continue
            var order = mru.indexOf(t)
            out.push({ wl: t, cls: String(t.appId), title: String(t.title || ""),
                       order: order < 0 ? 1000 + i : order })
        }
        out.sort(function (a, b) { return a.order - b.order })
        return out
    }

    function next(step) {
        if (!open) {
            entries = collect()
            if (entries.length === 0) return
            // Alt+Tab goes to the previous window; Alt+Shift+Tab to the oldest.
            index = step > 0 ? Math.min(1, entries.length - 1) : entries.length - 1
            open = true
            return
        }
        index = (index + step + entries.length) % entries.length
    }

    // Choose the highlighted window and close.
    function commit() {
        if (!open) return
        open = false
        var e = entries[index]
        if (!e) return
        if (!WindowService.restore(e.wl)) WindowService.activate(e.wl)
    }

    function cancel() { open = false }

    Item {
        anchors.fill: parent
        focus: switcher.open
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) { switcher.cancel(); event.accepted = true }
            else if (event.key === Qt.Key_Tab) { switcher.next(1); event.accepted = true }
            else if (event.key === Qt.Key_Backtab) { switcher.next(-1); event.accepted = true }
            else if (event.key === Qt.Key_Right) { switcher.next(1); event.accepted = true }
            else if (event.key === Qt.Key_Left) { switcher.next(-1); event.accepted = true }
        }
        Keys.onReleased: function (event) {
            if (event.key === Qt.Key_Alt) { switcher.commit(); event.accepted = true }
        }
    }

    SolidSurface {
        id: card
        anchors.centerIn: parent
        strong: true
        radius: Theme.radiusWindow
        width: row.implicitWidth + Theme.spacingXl * 2
        height: 190 + 24

        Row {
            id: row
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.spacingLg
            spacing: Theme.spacingMd

            Repeater {
                model: switcher.entries.slice(switcher.page * switcher.perPage,
                                              (switcher.page + 1) * switcher.perPage)

                delegate: Item {
                    id: tile
                    required property var modelData
                    required property int index
                    readonly property int absolute: switcher.page * switcher.perPage + index
                    readonly property bool selected: absolute === switcher.index
                    readonly property var entry: ApplicationService.entryForAppId(modelData.cls)
                    width: 128
                    height: 150

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: tile.selected ? Theme.stateSelected : "transparent"
                        border.width: tile.selected ? 2 : 0
                        border.color: Theme.cyan
                    }

                    AppIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 18
                        size: 72
                        source: tile.entry ? ApplicationService.iconFor(tile.entry)
                                           : ApplicationService.resolveIcon(tile.modelData.cls)
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 10
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        text: tile.entry ? tile.entry.name : tile.modelData.cls
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }
                }
            }
        }

        // Page dots.
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            spacing: 6
            Repeater {
                model: switcher.pageCount
                delegate: Rectangle {
                    required property int index
                    width: 28; height: 4; radius: 2
                    color: index === switcher.page ? Theme.textPrimary : Theme.textDisabled
                }
            }
        }
    }
}
