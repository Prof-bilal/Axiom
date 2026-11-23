import QtQuick
import Quickshell
import qs.src.shared
import qs.apps.files
import qs.apps.shared
import "../../apps/files/files.js" as Files

// Desktop surface: the contents of ~/Desktop as icons, with the right-click
// menus, in-place name editing, trash confirmation and properties dialog. It
// reuses the Files app's backend, dialogs and name editor, so create, rename,
// trash, copy and paste behave exactly as they do in Files. Lives inside the
// wallpaper window.
//
// shortcut: no drag to move icons or rubber-band selection; icons flow
// top-to-bottom in name/date/size order. Upgrade when the desktop gets layout
// persistence.
Item {
    id: desk

    // Room kept free for the panel above and the dock below.
    property int topInset: Theme.panelBottom + 12
    property int bottomInset: Theme.dockItemSize + Theme.dockPadding * 2 + Theme.dockEdgeGap + 12

    property int selected: -1
    readonly property var current: selected >= 0 && selected < backend.entries.length
                                   ? backend.entries[selected] : null
    // Selection follows an item by path, so a listing that inserts or removes icons cannot move it.
    property string selPath: ""
    // Rename in place: the path being edited, the name of a just-created item waiting for its listing,
    // a name to select after a rename, and the folder's names for the collision check.
    property string editPath: ""
    property string pendingEdit: ""
    property string pendingSelect: ""
    property var editNames: []

    function select(i) {
        selected = i
        selPath = i >= 0 && i < backend.entries.length ? backend.entries[i].path : ""
    }
    function indexOfName(name) {
        for (var i = 0; i < backend.entries.length; i++) if (backend.entries[i].name === name) return i
        return -1
    }

    FileBackend {
        id: backend
        initialPath: home + "/Desktop"
        persistState: false
    }

    Connections {
        target: backend
        function onListed() {
            if (desk.pendingEdit !== "") {
                var ei = desk.indexOfName(desk.pendingEdit)
                if (ei >= 0) {
                    desk.pendingEdit = ""
                    desk.select(ei)
                    desk.startEdit(backend.entries[ei])
                    return
                }
                // Still being created: keep waiting. Otherwise creating failed and nothing is shown.
                if (backend.operationsRunning === 0) desk.pendingEdit = ""
            }
            if (desk.pendingSelect !== "") {
                var si = desk.indexOfName(desk.pendingSelect)
                desk.pendingSelect = ""
                if (si >= 0) { desk.select(si); return }
            }
            var found = -1
            for (var i = 0; i < backend.entries.length; i++)
                if (backend.entries[i].path === desk.selPath) { found = i; break }
            desk.selected = found
            if (found < 0) desk.selPath = ""
        }
    }

    // The live medium's Install Axiom icon (hidden everywhere else).
    InstallTile {
        z: 2
        anchors.top: parent.top
        anchors.topMargin: desk.topInset
        anchors.right: parent.right
        anchors.rightMargin: 24
    }

    // ---- icons ---------------------------------------------------------------
    // Clicking the bare desktop clears the selection and opens the desktop menu.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: function (mouse) {
            desk.select(-1)
            desk.forceActiveFocus()
            if (mouse.button === Qt.RightButton) desk.showMenu(mouse.x, mouse.y, false)
        }
    }

    GridView {
        id: grid
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom
                  leftMargin: 20; topMargin: desk.topInset; bottomMargin: desk.bottomInset }
        width: parent.width - 40
        cellWidth: 104
        cellHeight: 116
        flow: GridView.FlowTopToBottom
        interactive: false
        // Integer model: the entries array is replaced on every listing, which would destroy the icons
        // (and a name being edited). Icons look their entry up by index instead, as the Files list does.
        model: backend.entries.length

        delegate: Item {
            id: cell
            required property int index
            readonly property var entry: backend.entries[index]
            readonly property bool editing: entry !== undefined && entry.path === desk.editPath
            width: grid.cellWidth
            height: grid.cellHeight
            readonly property bool isSelected: desk.selected === index

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: Theme.radiusSurface
                color: cell.isSelected ? Theme.stateSelected : (hit.containsMouse ? Theme.stateHover : "transparent")
                border.width: cell.isSelected ? 1 : 0
                border.color: Theme.stateSelectedBorder
            }

            FileGlyph {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 10
                size: 56
                entry: cell.entry
            }

            Loader {
                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 8 }
                width: item ? item.width : 0
                active: cell.editing
                sourceComponent: InlineName {
                    maxWidth: cell.width - 8
                    centered: true
                    showReason: true
                    original: cell.entry.name
                    existing: desk.editNames
                    onCommitted: function (name) { desk.commitEdit(cell.entry, name) }
                    onCancelled: desk.cancelEdit()
                }
            }

            Text {
                visible: !cell.editing
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom
                          leftMargin: 8; rightMargin: 8; bottomMargin: 10 }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                maximumLineCount: 2
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                text: cell.entry ? cell.entry.name : ""
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.6)
            }

            MouseArea {
                id: hit
                anchors.fill: parent
                enabled: !cell.editing   // clicks go to the text box while renaming
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: function (mouse) {
                    desk.select(cell.index)
                    desk.forceActiveFocus()
                    if (mouse.button === Qt.RightButton) {
                        var p = hit.mapToItem(desk, mouse.x, mouse.y)
                        desk.showMenu(p.x, p.y, true)
                    }
                }
                onDoubleClicked: function (mouse) {
                    if (mouse.button === Qt.LeftButton && cell.entry) backend.open(cell.entry)
                }
            }
        }
    }

    // ---- menus ---------------------------------------------------------------
    function showMenu(x, y, onItem) {
        var hasClip = backend.clipboard.paths.length > 0
        if (onItem) {
            menu.show(x, y, [
                { text: "Open", action: "open" },
                { separator: true },
                { text: "Cut", action: "cut" },
                { text: "Copy", action: "copy" },
                { text: "Paste into Desktop", action: "paste", enabled: hasClip },
                { separator: true },
                { text: "Rename…", action: "rename" },
                { text: "Move to Trash", action: "trash", destructive: true },
                { separator: true },
                { text: "Properties", action: "properties" }
            ])
        } else {
            menu.show(x, y, [
                { text: "New Folder", action: "newFolder" },
                { text: "New File", action: "newFile" },
                { separator: true },
                { text: "Sort by name" + (backend.sortKey === "name" ? "  ✓" : ""), action: "sortName" },
                { text: "Sort by date" + (backend.sortKey === "modified" ? "  ✓" : ""), action: "sortDate" },
                { text: "Sort by size" + (backend.sortKey === "size" ? "  ✓" : ""), action: "sortSize" },
                { separator: true },
                { text: "Paste", action: "paste", enabled: hasClip },
                { separator: true },
                { text: "Change Wallpaper…", action: "wallpaper" },
                { text: "Settings…", action: "settings" }
            ])
        }
    }

    ContextMenu {
        id: menu
        onTriggered: function (action) {
            menu.open = false
            var e = desk.current
            if (action === "open" && e) backend.open(e)
            else if (action === "cut" && e) backend.cut([e.path])
            else if (action === "copy" && e) backend.copy([e.path])
            else if (action === "paste") backend.paste()
            else if (action === "rename" && e) desk.startEdit(e)
            else if (action === "trash" && e) desk.askTrash(e)
            else if (action === "properties" && e) backend.properties(e, function (info) { props.show(info) })
            else if (action === "newFolder") desk.newItem(true)
            else if (action === "newFile") desk.newItem(false)
            else if (action === "sortName") { backend.sortKey = "name"; backend.sortAscending = true; backend.applyView() }
            else if (action === "sortDate") { backend.sortKey = "modified"; backend.sortAscending = false; backend.applyView() }
            else if (action === "sortSize") { backend.sortKey = "size"; backend.sortAscending = false; backend.applyView() }
            else if (action === "wallpaper") Quickshell.execDetached(["axiom-app", "settings"])
            else if (action === "settings") Quickshell.execDetached(["axiom-app", "settings"])
        }
    }

    // ---- names, edited in place ------------------------------------------------
    // New items are created at once with a free default name, then the name is edited on the icon.
    function newItem(folder) {
        var name = Files.uniqueNewName(folder ? "New folder" : "New file.txt",
                                       backend.rawEntries.map(function (e) { return e.name }))
        pendingEdit = name
        if (folder) backend.createFolder(name)
        else backend.createFile(name, "")
    }

    function startEdit(e) {
        editNames = backend.rawEntries.map(function (x) { return x.name })
        editPath = e.path
    }

    function commitEdit(e, name) {
        editPath = ""
        desk.forceActiveFocus()
        if (name === e.name) return
        pendingSelect = name
        backend.rename(e, name)
    }

    function cancelEdit() {
        editPath = ""
        desk.forceActiveFocus()
    }

    // ---- dialogs -------------------------------------------------------------
    function askTrash(entry) {
        trashDialog.entryPath = entry.path
        trashDialog.show("Move “" + entry.name + "” to Trash?",
                         entry.isDir ? "The folder and everything in it will move to Trash. You can restore it from there."
                                     : "The file will move to Trash. You can restore it from there.",
                         "Move to Trash", false)
    }

    ConfirmDialog {
        id: trashDialog
        property string entryPath: ""
        onAccepted: backend.trash([entryPath])
    }

    PropertiesDialog { id: props }

    // ---- keyboard ------------------------------------------------------------
    focus: true
    Keys.onPressed: function (event) {
        var e = desk.current
        if (!e) return
        if (event.key === Qt.Key_Delete) { desk.askTrash(e); event.accepted = true }
        else if (event.key === Qt.Key_F2) { desk.startEdit(e); event.accepted = true }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { backend.open(e); event.accepted = true }
        else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_C) { backend.copy([e.path]); event.accepted = true }
        else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_X) { backend.cut([e.path]); event.accepted = true }
    }
}
