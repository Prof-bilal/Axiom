import QtQuick
import Quickshell
import qs.src.shared
import qs.apps.files
import qs.apps.shared

// Desktop surface: the contents of ~/Desktop as icons, with the right-click
// menus, name prompt, trash confirmation and properties dialog. It reuses the
// Files app's backend and dialogs, so create, rename, trash, copy and paste
// behave exactly as they do in Files. Lives inside the wallpaper window.
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

    FileBackend {
        id: backend
        initialPath: home + "/Desktop"
        persistState: false
    }

    // ---- icons ---------------------------------------------------------------
    // Clicking the bare desktop clears the selection and opens the desktop menu.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: function (mouse) {
            desk.selected = -1
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
        model: backend.entries

        delegate: Item {
            id: cell
            required property var modelData
            required property int index
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
                entry: cell.modelData
            }

            Text {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom
                          leftMargin: 8; rightMargin: 8; bottomMargin: 10 }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                maximumLineCount: 2
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                text: cell.modelData.name
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.6)
            }

            MouseArea {
                id: hit
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: function (mouse) {
                    desk.selected = cell.index
                    desk.forceActiveFocus()
                    if (mouse.button === Qt.RightButton) {
                        var p = hit.mapToItem(desk, mouse.x, mouse.y)
                        desk.showMenu(p.x, p.y, true)
                    }
                }
                onDoubleClicked: function (mouse) {
                    if (mouse.button === Qt.LeftButton) backend.open(cell.modelData)
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
                { text: "New Document", action: "newDocument" },
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
            else if (action === "rename" && e) desk.ask("rename", "Rename", e.name, "Rename")
            else if (action === "trash" && e) desk.askTrash(e)
            else if (action === "properties" && e) backend.properties(e, function (info) { props.show(info) })
            else if (action === "newFolder") desk.ask("folder", "New folder", "New folder", "Create")
            else if (action === "newDocument") desk.ask("file", "New document", "New document.txt", "Create")
            else if (action === "sortName") { backend.sortKey = "name"; backend.sortAscending = true; backend.applyView() }
            else if (action === "sortDate") { backend.sortKey = "modified"; backend.sortAscending = false; backend.applyView() }
            else if (action === "sortSize") { backend.sortKey = "size"; backend.sortAscending = false; backend.applyView() }
            else if (action === "wallpaper") Quickshell.execDetached(["axiom-app", "settings"])
            else if (action === "settings") Quickshell.execDetached(["axiom-app", "settings"])
        }
    }

    // ---- dialogs -------------------------------------------------------------
    property string promptKind: ""
    function ask(kind, titleText, initial, button) {
        promptKind = kind
        prompt.show(titleText, initial, button)
    }

    PromptDialog {
        id: prompt
        onAccepted: function (text) {
            if (desk.promptKind === "folder") backend.createFolder(text)
            else if (desk.promptKind === "file") backend.createFile(text)
            else if (desk.promptKind === "rename" && desk.current) backend.rename(desk.current, text)
        }
    }

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
        else if (event.key === Qt.Key_F2) { desk.ask("rename", "Rename", e.name, "Rename"); event.accepted = true }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { backend.open(e); event.accepted = true }
        else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_C) { backend.copy([e.path]); event.accepted = true }
        else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_X) { backend.cut([e.path]); event.accepted = true }
    }
}
