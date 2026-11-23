import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared
import "files.js" as Files

// Axiom Files: browse, open, create, rename, copy, move, trash and restore real
// files. All system work is in FileBackend (argv-array processes); this file
// is presentation, selection and keyboard handling.
AppWindow {
    id: root

    title: backend.trashView ? "Trash" : (Files.baseName(backend.path) || "File System")
    implicitWidth: 1060
    implicitHeight: 660
    color: Theme.background

    // path -> true
    property var selected: ({})
    // "list" (columns) or "grid" (icon tiles).
    property string viewMode: "list"
    property int currentIndex: -1
    property int anchorIndex: -1
    property string pendingSelect: ""
    // Rename in place (Windows style): the path whose name is being edited, the name of a just-created item
    // waiting for its first listing, and the names in the folder for the collision check.
    property string editPath: ""
    property string pendingEdit: ""
    property var editNames: []
    readonly property int selectedCount: Object.keys(selected).length
    readonly property real sizeW: 90
    readonly property real modifiedW: 150
    readonly property real kindW: 150
    readonly property bool showModified: list.width > 640
    readonly property bool showKind: list.width > 820

    FileBackend { id: backend }

    // ---- selection ------------------------------------------------------------
    function selectedEntries() {
        return backend.entries.filter(function (e) { return selected[e.path] === true })
    }

    function setSelection(paths, current, anchor) {
        var o = {}
        paths.forEach(function (p) { o[p] = true })
        selected = o
        currentIndex = current
        anchorIndex = anchor
    }

    function selectOnly(i) {
        if (i < 0 || i >= backend.entries.length) { setSelection([], -1, -1); return }
        setSelection([backend.entries[i].path], i, i)
    }

    function selectRange(from, to) {
        var lo = Math.min(from, to), hi = Math.max(from, to), paths = []
        for (var i = lo; i <= hi; i++) paths.push(backend.entries[i].path)
        setSelection(paths, to, from)
    }

    function toggle(i) {
        var o = Object.assign({}, selected)
        var p = backend.entries[i].path
        if (o[p]) delete o[p]; else o[p] = true
        selected = o
        currentIndex = i
        anchorIndex = i
    }

    function move(delta, extend) {
        var n = backend.entries.length
        if (n === 0) return
        var i = currentIndex < 0 ? (delta > 0 ? 0 : n - 1) : Math.max(0, Math.min(n - 1, currentIndex + delta))
        if (extend && anchorIndex >= 0) selectRange(anchorIndex, i)
        else selectOnly(i)
        list.positionViewAtIndex(i, ListView.Contain)
    }

    function selectAll() {
        setSelection(backend.entries.map(function (e) { return e.path }), backend.entries.length - 1, 0)
    }

    Connections {
        target: backend
        function onListed() {
            // Keep only selections that still exist; honour a pending select.
            if (root.pendingEdit !== "") {
                var ei = -1
                for (var k = 0; k < backend.entries.length; k++)
                    if (backend.entries[k].name === root.pendingEdit) { ei = k; break }
                if (ei >= 0) {
                    root.pendingEdit = ""
                    root.selectOnly(ei)
                    list.positionViewAtIndex(ei, ListView.Contain)
                    grid.positionViewAtIndex(ei, GridView.Contain)
                    root.startEdit(backend.entries[ei])
                    return
                }
                // Still creating it: keep waiting. Otherwise creating failed and the status bar says why.
                if (backend.operationsRunning === 0) root.pendingEdit = ""
            }
            var present = {}
            backend.entries.forEach(function (e) { present[e.path] = true })
            var keep = Object.keys(root.selected).filter(function (p) { return present[p] })
            if (root.pendingSelect !== "") {
                var idx = -1
                for (var i = 0; i < backend.entries.length; i++)
                    if (backend.entries[i].name === root.pendingSelect) { idx = i; break }
                root.pendingSelect = ""
                if (idx >= 0) { root.selectOnly(idx); list.positionViewAtIndex(idx, ListView.Contain); return }
            }
            var cur = -1
            for (var j = 0; j < backend.entries.length; j++)
                if (keep.indexOf(backend.entries[j].path) >= 0) { cur = j; break }
            root.setSelection(keep, keep.length > 0 ? cur : -1, keep.length > 0 ? cur : -1)
        }
        function onPathChanged() { root.setSelection([], -1, -1) }
    }

    // ---- actions ------------------------------------------------------------------
    function openEntry(e) { backend.open(e) }

    function openSelection() {
        var sel = selectedEntries()
        if (sel.length === 1) openEntry(sel[0])
        else sel.forEach(function (e) { if (!e.isDir) backend.open(e) })
    }

    function trashSelection() {
        var sel = selectedEntries()
        if (sel.length === 0) return
        backend.trash(sel.map(function (e) { return e.path }))
    }

    function deleteSelection() {
        if (backend.trashView) {
            var sel = selectedEntries()
            if (sel.length === 0) return
            confirm.show("Delete permanently?",
                sel.length === 1 ? "“" + sel[0].name + "” will be deleted permanently. This cannot be undone."
                                 : sel.length + " items will be deleted permanently. This cannot be undone.",
                "Delete permanently", true)
            confirm.acceptedAction = function () { backend.deletePermanently(sel) }
        } else {
            trashSelection()
        }
    }

    function emptyTrash() {
        confirm.show("Empty Trash?", "All items in the Trash will be deleted permanently. This cannot be undone.", "Empty Trash", true)
        confirm.acceptedAction = function () { backend.emptyTrash() }
    }

    // The folder shown in the name sheets, like the macOS location line.
    function locationLine() {
        return backend.trashView ? "Trash" : backend.path
    }

    // New items are created at once with a free default name, then their name is edited in place.
    function newFolder() {
        if (backend.trashView) return
        var name = Files.uniqueNewName("New folder", backend.rawEntries.map(function (e) { return e.name }))
        pendingEdit = name
        backend.createFolder(name)
    }

    function newFile() {
        if (backend.trashView) return
        var name = Files.uniqueNewName("New file.txt", backend.rawEntries.map(function (e) { return e.name }))
        pendingEdit = name
        backend.createFile(name, "")
    }

    function renameSelected() {
        var sel = selectedEntries()
        if (sel.length === 1 && !backend.trashView) startEdit(sel[0])
    }

    function startEdit(e) {
        editNames = backend.rawEntries.map(function (x) { return x.name })
        editPath = e.path
    }

    function commitEdit(e, name) {
        editPath = ""
        keyTarget.forceActiveFocus()
        if (name === e.name) return
        pendingSelect = name
        backend.rename(e, name)
    }

    function cancelEdit() {
        editPath = ""
        keyTarget.forceActiveFocus()
    }

    function showProperties() {
        var sel = selectedEntries()
        var e = sel.length === 1 ? sel[0] : null
        if (!e) {
            e = { name: Files.baseName(backend.path) || "/", path: backend.path, isDir: true, isLink: false, broken: false,
                  size: 0, mtime: 0, mode: "", target: "" }
        }
        backend.properties(e, function (info) { info.isTrash = !!e.isTrash; props.show(info) })
    }

    function terminalHere() {
        var sel = selectedEntries()
        var dir = (sel.length === 1 && sel[0].isDir && !backend.trashView) ? sel[0].path
                  : (backend.trashView ? backend.home : backend.path)
        TerminalService.open(dir, "", [])
    }

    function showContext(x, y, background) {
        var sel = selectedEntries()
        var one = sel.length === 1
        var items = []
        if (backend.trashView) {
            if (!background && sel.length > 0) {
                items.push({ text: "Restore", action: "restore" })
                items.push({ text: "Delete permanently", action: "delete", destructive: true })
                items.push({ separator: true })
                items.push({ text: "Properties", action: "properties", enabled: one })
                items.push({ separator: true })
            }
            items.push({ text: "Empty Trash", action: "empty", enabled: backend.entries.length > 0, destructive: true })
        } else if (!background && sel.length > 0) {
            items.push({ text: one && sel[0].isDir ? "Open" : "Open", action: "open" })
            items.push({ text: "Open terminal here", action: "terminal", enabled: one && sel[0].isDir })
            items.push({ separator: true })
            items.push({ text: "Rename", action: "rename", enabled: one })
            items.push({ text: "Copy", action: "copy" })
            items.push({ text: "Cut", action: "cut" })
            items.push({ text: "Paste", action: "paste", enabled: backend.canPaste })
            items.push({ separator: true })
            items.push({ text: "Move to Trash", action: "trash", destructive: true })
            items.push({ separator: true })
            items.push({ text: "Properties", action: "properties", enabled: one })
        } else {
            items.push({ text: "New folder", action: "newfolder" })
            items.push({ text: "New file", action: "newfile" })
            items.push({ text: "Paste", action: "paste", enabled: backend.canPaste })
            items.push({ separator: true })
            items.push({ text: "Open terminal here", action: "terminal" })
            items.push({ text: backend.showHidden ? "Hide hidden files" : "Show hidden files", action: "hidden" })
            items.push({ separator: true })
            items.push({ text: "Properties", action: "properties" })
        }
        menu.show(x, y, items)
    }

    function runAction(action) {
        var sel = selectedEntries()
        var paths = sel.map(function (e) { return e.path })
        switch (action) {
        case "open": openSelection(); break
        case "terminal": terminalHere(); break
        case "rename": renameSelected(); break
        case "copy": backend.copy(paths); break
        case "cut": backend.cut(paths); break
        case "paste": backend.paste(); break
        case "trash": trashSelection(); break
        case "restore": backend.restore(sel); break
        case "delete": deleteSelection(); break
        case "empty": emptyTrash(); break
        case "newfolder": newFolder(); break
        case "newfile": newFile(); break
        case "hidden": backend.showHidden = !backend.showHidden; break
        case "properties": showProperties(); break
        }
        // A dialog or a name being edited owns the keyboard; do not take it back.
        if (!confirm.open && !props.open && editPath === "") keyTarget.forceActiveFocus()
    }

    function rowPressed(i, mods, button, x, y) {
        var e = backend.entries[i]
        keyTarget.forceActiveFocus()
        if (button === Qt.RightButton) {
            if (!selected[e.path]) selectOnly(i)
            showContext(x, y, false)
            return
        }
        if ((mods & Qt.ShiftModifier) && anchorIndex >= 0) selectRange(anchorIndex, i)
        else if (mods & Qt.ControlModifier) toggle(i)
        else selectOnly(i)
    }

    function sortBy(key) {
        if (backend.sortKey === key) backend.sortAscending = !backend.sortAscending
        else { backend.sortKey = key; backend.sortAscending = true }
    }

    // ---- layout ---------------------------------------------------------------------------
    FocusScope {
        id: main
        anchors.fill: parent
        focus: true

        // Plain item that owns keyboard focus when no text field is being
        // edited. Re-focusing the scope itself would hand focus back to
        // whichever hidden TextInput last had it, and that field would swallow
        // Ctrl+C / Ctrl+V / Delete.
        Item { id: keyTarget; focus: true }

        Keys.onPressed: function (event) {
            var ctrl = (event.modifiers & Qt.ControlModifier) !== 0
            var shift = (event.modifiers & Qt.ShiftModifier) !== 0
            var alt = (event.modifiers & Qt.AltModifier) !== 0
            event.accepted = true
            if (menu.open && event.key === Qt.Key_Escape) menu.open = false
            else if (alt && event.key === Qt.Key_Left) backend.goBack()
            else if (alt && event.key === Qt.Key_Right) backend.goForward()
            else if (alt && event.key === Qt.Key_Up) backend.goUp()
            else if (ctrl && shift && event.key === Qt.Key_N) newFolder()
            else if (ctrl && event.key === Qt.Key_A) selectAll()
            else if (ctrl && event.key === Qt.Key_C) { if (selectedCount > 0) backend.copy(selectedEntries().map(function (e) { return e.path })) }
            else if (ctrl && event.key === Qt.Key_X) { if (selectedCount > 0 && !backend.trashView) backend.cut(selectedEntries().map(function (e) { return e.path })) }
            else if (ctrl && event.key === Qt.Key_V) backend.paste()
            else if (ctrl && event.key === Qt.Key_H) backend.showHidden = !backend.showHidden
            else if (ctrl && event.key === Qt.Key_L) pathBar.beginEdit()
            else if (ctrl && event.key === Qt.Key_F) searchBox.focusInput()
            else if (event.key === Qt.Key_Up) move(-1, shift)
            else if (event.key === Qt.Key_Down) move(1, shift)
            else if (event.key === Qt.Key_PageUp) move(-10, shift)
            else if (event.key === Qt.Key_PageDown) move(10, shift)
            else if (event.key === Qt.Key_Home) move(-100000, shift)
            else if (event.key === Qt.Key_End) move(100000, shift)
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) openSelection()
            else if (event.key === Qt.Key_Delete) deleteSelection()
            else if (event.key === Qt.Key_F2) renameSelected()
            else if (event.key === Qt.Key_F5) backend.refresh()
            else if (event.key === Qt.Key_F4) terminalHere()
            else if (ctrl && event.key === Qt.Key_R) { if (backend.trashView) backend.restore(selectedEntries()) }
            else if (event.key === Qt.Key_Backspace) backend.goUp()
            else if (event.key === Qt.Key_Escape) {
                if (backend.searching) { searchBox.clear(); backend.search("") }
                else setSelection([], -1, -1)
            }
            else event.accepted = false
        }

        // toolbar
        Rectangle {
            id: toolbar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: "transparent"

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.borderSubtle }

            Row {
                id: navButtons
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingMd
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                PanelButton { icon: "arrow-left"; accessibleName: "Back"; available: backend.canGoBack; onClicked: backend.goBack() }
                PanelButton { icon: "arrow-right"; accessibleName: "Forward"; available: backend.canGoForward; onClicked: backend.goForward() }
                PanelButton { icon: "arrow-up"; accessibleName: "Up one folder"; available: backend.canGoUp; onClicked: backend.goUp() }
            }

            Row {
                id: toolButtons
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingMd
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                PanelButton { icon: "plus"; accessibleName: "New folder"; available: !backend.trashView; onClicked: root.newFolder() }
                PanelButton { icon: "eye"; accessibleName: "Show hidden files"; selected: backend.showHidden; available: !backend.trashView; onClicked: backend.showHidden = !backend.showHidden }
                PanelButton { icon: root.viewMode === "list" ? "grid" : "list"; accessibleName: "Switch between list and grid"; onClicked: root.viewMode = root.viewMode === "list" ? "grid" : "list" }
                PanelButton { icon: "terminal"; accessibleName: "Open terminal here"; onClicked: root.terminalHere() }
            }

            SearchField {
                id: searchBox
                anchors.right: toolButtons.left
                anchors.rightMargin: Theme.spacingMd
                anchors.verticalCenter: parent.verticalCenter
                width: 200
                enabled: !backend.trashView
                placeholder: "Search"
                accessibleName: "Search in this folder"
                debounce: 300
                onSearched: function (t) { backend.search(t) }
                onEscaped: keyTarget.forceActiveFocus()
                onSubmitted: keyTarget.forceActiveFocus()
            }

            // Finder-style title: the current folder's name, centred in the toolbar.
            // Navigation stays in the sidebar and the back, forward and up buttons.
            Text {
                id: toolbarTitle
                anchors.centerIn: parent
                width: Math.min(implicitWidth, parent.width - 520)
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                text: backend.trashView ? "Trash" : (Files.baseName(backend.path) || "File System")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
            }
        }

        Sidebar {
            id: sidebar
            anchors.top: toolbar.bottom
            anchors.bottom: statusBar.top
            anchors.left: parent.left
            backend: backend
        }

        // header + list
        Item {
            id: content
            anchors.top: toolbar.bottom
            anchors.bottom: statusBar.top
            anchors.left: sidebar.right
            anchors.right: parent.right

            Row {
                id: header
                visible: root.viewMode === "list"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.spacingSm + Theme.spacingMd
                anchors.rightMargin: Theme.spacingSm + Theme.spacingMd
                height: 30
                spacing: Theme.spacingMd

                Item { width: 20; height: 1 }
                HeaderCell {
                    label: "Name"
                    key: "name"
                    sortKey: backend.sortKey
                    ascending: backend.sortAscending
                    sortable: !backend.trashView
                    onClicked: root.sortBy("name")
                    width: header.width - 20 - Theme.spacingMd
                           - (backend.trashView ? 300 + Theme.spacingMd
                              : root.sizeW + (root.showModified ? root.modifiedW : 0) + (root.showKind ? root.kindW : 0)
                                + Theme.spacingMd * (1 + (root.showModified ? 1 : 0) + (root.showKind ? 1 : 0)))
                }
                HeaderCell { visible: backend.trashView; width: 300; label: "Original location" }
                HeaderCell { visible: !backend.trashView; width: root.sizeW; label: "Size"; key: "size"; align: Text.AlignRight; sortKey: backend.sortKey; ascending: backend.sortAscending; onClicked: root.sortBy("size") }
                HeaderCell { visible: !backend.trashView && root.showModified; width: root.modifiedW; label: "Modified"; key: "modified"; sortKey: backend.sortKey; ascending: backend.sortAscending; onClicked: root.sortBy("modified") }
                HeaderCell { visible: !backend.trashView && root.showKind; width: root.kindW; label: "Kind" }
            }

            Rectangle { visible: root.viewMode === "list"; anchors.top: header.bottom; width: parent.width; height: 1; color: Theme.borderSubtle }

            // Finder-style striped rows behind the list, so the empty space below the
            // files keeps the alternating bands. Drawn before the list (behind it).
            Item {
                id: stripes
                visible: root.viewMode === "list"
                anchors.top: header.bottom
                anchors.topMargin: 1
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.spacingSm
                clip: true
                Column {
                    width: parent.width
                    Repeater {
                        model: Math.ceil(stripes.height / 34) + 1
                        Rectangle {
                            required property int index
                            width: parent.width
                            height: 34
                            color: index % 2 === 0 ? (Theme.light ? "#F1F4F6" : Theme.stateHover) : "transparent"
                        }
                    }
                }
            }

            ListView {
                id: list
                visible: root.viewMode === "list"
                anchors.top: header.bottom
                anchors.topMargin: 1
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.spacingSm
                clip: true
                // Integer model: handing a 10,000-object JS array to the view makes
                // Qt convert every object (seconds in the guest). Rows look their
                // entry up by index instead.
                model: backend.entries.length
                boundsBehavior: Flickable.StopAtBounds
                reuseItems: true

                delegate: FileRow {
                    required property int index
                    readonly property var rowEntry: backend.entries[index]
                    width: ListView.view.width
                    entry: rowEntry
                    selected: rowEntry !== undefined && root.selected[rowEntry.path] === true
                    current: index === root.currentIndex
                    trash: backend.trashView
                    showModified: root.showModified
                    showKind: root.showKind
                    sizeWidth: root.sizeW
                    modifiedWidth: root.modifiedW
                    kindWidth: root.kindW
                    editing: root.viewMode === "list" && rowEntry !== undefined && rowEntry.path === root.editPath
                    existingNames: root.editNames
                    onRenamed: function (name) { root.commitEdit(rowEntry, name) }
                    onEditCancelled: root.cancelEdit()
                    onEditRejected: function (reason) { backend.setMessage(reason, true) }
                    onPressedWith: function (mods, button, x, y) { root.rowPressed(index, mods, button, x, y) }
                    onOpened: root.openEntry(rowEntry)
                }

                // Empty space: clear selection / background context menu.
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onPressed: function (m) {
                        keyTarget.forceActiveFocus()
                        root.setSelection([], -1, -1)
                        if (m.button === Qt.RightButton) {
                            var p = mapToItem(null, m.x, m.y)
                            root.showContext(p.x, p.y, true)
                        }
                    }
                }
            }

            // Grid: icon tiles, same selection and open behaviour as the list.
            GridView {
                id: grid
                visible: root.viewMode === "grid"
                anchors.fill: parent
                anchors.margins: Theme.spacingSm
                clip: true
                cellWidth: 150
                cellHeight: 150
                model: backend.entries.length
                boundsBehavior: Flickable.StopAtBounds
                reuseItems: true

                delegate: Item {
                    required property int index
                    readonly property var tileEntry: backend.entries[index]
                    width: grid.cellWidth
                    height: grid.cellHeight
                    readonly property bool sel: tileEntry !== undefined && root.selected[tileEntry.path] === true
                    // The hidden view must not build an editor too: it would take focus from the visible one.
                    readonly property bool editing: root.viewMode === "grid" && tileEntry !== undefined && tileEntry.path === root.editPath

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: Theme.radiusSurface
                        color: sel ? Theme.stateSelected : tileMouse.containsMouse ? Theme.stateHover : "transparent"
                        border.width: sel ? 1 : 0
                        border.color: Theme.stateSelectedBorder
                    }
                    FileGlyph {
                        id: tileIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 12
                        size: 84
                        entry: tileEntry
                    }
                    Loader {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: tileIcon.bottom
                        anchors.topMargin: 8
                        width: item ? item.width : 0
                        active: editing
                        sourceComponent: InlineName {
                            maxWidth: grid.cellWidth - 12
                            centered: true
                            original: tileEntry.name
                            existing: root.editNames
                            onCommitted: function (name) { root.commitEdit(tileEntry, name) }
                            onCancelled: root.cancelEdit()
                            onRejected: function (reason) { backend.setMessage(reason, true) }
                        }
                    }
                    Text {
                        visible: !editing
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: tileIcon.bottom
                        anchors.topMargin: 10
                        width: parent.width - 16
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideMiddle
                        text: tileEntry ? tileEntry.name : ""
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }
                    MouseArea {
                        id: tileMouse
                        anchors.fill: parent
                        enabled: !editing
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onPressed: function (m) { root.rowPressed(index, m.modifiers, m.button, m.x, m.y) }
                        onDoubleClicked: root.openEntry(tileEntry)
                    }
                }
            }

            Text {
                anchors.centerIn: list
                width: list.width - Theme.spacingXl * 2
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: text.length > 0
                color: backend.error.length > 0 ? Theme.dangerBright : Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLabel
                text: {
                    if (backend.error.length > 0) return backend.error
                    if (backend.loading && backend.entries.length === 0) return "Loading…"
                    if (backend.entries.length > 0) return ""
                    if (backend.searching) return "No results for “" + backend.searchQuery + "”"
                    if (backend.trashView) return "Trash is empty"
                    return backend.rawEntries.length > 0 ? "Only hidden files here (Ctrl+H shows them)" : "This folder is empty"
                }
            }
        }

        // status bar
        Rectangle {
            id: statusBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 28
            color: "transparent"

            Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: Theme.borderSubtle }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingMd
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                text: {
                    var n = backend.entries.length
                    var s = n + (n === 1 ? " item" : " items")
                    if (backend.searching) s += " found"
                    if (root.selectedCount > 0) s += "  ·  " + root.selectedCount + " selected"
                    if (backend.clipboard.paths.length > 0) s += "  ·  " + backend.clipboard.paths.length + (backend.clipboard.mode === "cut" ? " to move" : " to copy")
                    return s
                }
            }

            Text {
                id: messageText
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingMd
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * 0.55
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                text: backend.busy ? "Working…" : backend.message
                color: backend.messageIsError ? Theme.dangerBright : Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }

            Timer { id: messageTimer; interval: 7000; onTriggered: backend.message = "" }
        }

        Connections {
            target: backend
            function onMessageChanged() { if (backend.message.length > 0) messageTimer.restart() }
        }

        ContextMenu {
            id: menu
            onTriggered: function (action) { root.runAction(action) }
            onOpenChanged: if (!open && root.editPath === "") keyTarget.forceActiveFocus()
        }

        ConfirmDialog {
            id: confirm
            property var acceptedAction: null
            onAccepted: { if (acceptedAction) acceptedAction() }
            onOpenChanged: if (!open) keyTarget.forceActiveFocus()
        }

        PropertiesDialog {
            id: props
            onOpenChanged: if (!open) keyTarget.forceActiveFocus()
        }
    }
}
