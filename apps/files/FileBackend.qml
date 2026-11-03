import QtQuick
import Quickshell
import Quickshell.Io
import "files.js" as Files

// Files backend: current location, listing, change monitoring and every file
// operation. Everything that touches the system is an argv-array process
// (find, gio, mkdir, cp, mv, stat); paths and names are passed as positional
// arguments, never spliced into a shell string. The few `sh -c` scripts are
// constant text that receive their inputs as "$1", "$2".
Item {
    id: backend

    readonly property string trashUri: "trash:///"

    // ---- state --------------------------------------------------------------
    property string home: Quickshell.env("HOME")
    property string path: home
    readonly property bool trashView: path === trashUri
    property var rawEntries: []
    property var entries: []              // sorted, hidden-filtered view of rawEntries
    property bool showHidden: false
    property string sortKey: "name"
    property bool sortAscending: true
    property bool loading: false
    property string error: ""            // listing error for the current location
    property string message: ""          // last operation result
    property bool messageIsError: false
    property bool busy: operationsRunning > 0
    property int operationsRunning: 0
    property var clipboard: ({ mode: "", paths: [] })
    property string searchQuery: ""
    readonly property bool searching: searchQuery.length > 0

    // Back/forward history of locations.
    property var backStack: []
    property var forwardStack: []
    readonly property bool canGoBack: backStack.length > 0
    readonly property bool canGoForward: forwardStack.length > 0
    readonly property bool canGoUp: !trashView && path !== "/"

    signal listed()

    onShowHiddenChanged: { applyView(); scheduleSave() }
    onSortKeyChanged: { applyView(); scheduleSave() }
    onSortAscendingChanged: { applyView(); scheduleSave() }

    function applyView() {
        entries = Files.sortEntries(rawEntries, sortKey, sortAscending, showHidden || trashView)
    }

    function setMessage(text, isError) {
        message = text
        messageIsError = !!isError
    }

    // ---- navigation ------------------------------------------------------------
    function navigate(target, fromHistory) {
        var t = target === trashUri ? trashUri : Files.normalize(target, home, trashView ? home : path)
        if (!fromHistory && t !== path) {
            backStack = backStack.concat([path])
            forwardStack = []
        }
        cancelSearch()
        searchQuery = ""
        path = t
        error = ""
        rawEntries = []
        applyView()
        refresh()
        restartMonitor()
    }

    function goBack() {
        if (!canGoBack) return
        var prev = backStack[backStack.length - 1]
        backStack = backStack.slice(0, -1)
        forwardStack = forwardStack.concat([path])
        navigate(prev, true)
    }

    function goForward() {
        if (!canGoForward) return
        var next = forwardStack[forwardStack.length - 1]
        forwardStack = forwardStack.slice(0, -1)
        backStack = backStack.concat([path])
        navigate(next, true)
    }

    function goUp() { if (canGoUp) navigate(Files.parentPath(path)) }

    // ---- listing ------------------------------------------------------------------
    property bool listPending: false

    function refresh() {
        if (searching) return
        if (lister.running) { listPending = true; return }
        loading = true
        lister.listDir = path
        lister.command = trashView
            ? ["gio", "trash", "--list"]
            : ["find", "-H", path, "-mindepth", "1", "-maxdepth", "1",
               "-printf", "%y\\0%Y\\0%f\\0%s\\0%T@\\0%m\\0%l\\0"]
        lister.running = true
    }

    Process {
        id: lister
        property string listDir: ""
        property string out: ""
        property string err: ""
        property bool outDone: false
        property bool errDone: false
        property int code: -1
        property bool exited: false
        stdout: StdioCollector { onStreamFinished: { lister.out = text; lister.outDone = true; lister.maybeFinish() } }
        stderr: StdioCollector { onStreamFinished: { lister.err = text; lister.errDone = true; lister.maybeFinish() } }
        onStarted: { outDone = false; errDone = false; exited = false; out = ""; err = "" }
        onExited: function (exitCode) { code = exitCode; exited = true; maybeFinish() }

        function maybeFinish() {
            if (!(outDone && errDone && exited)) return
            // A location change while this ran makes the result stale.
            if (listDir === backend.path) {
                var t0 = Date.now()
                if (backend.trashView) {
                    backend.rawEntries = code === 0 ? Files.parseTrashList(out) : []
                    backend.error = code === 0 ? "" : firstLine(err, "Trash is not available.")
                } else {
                    // find exits 1 on partial errors but still prints what it read.
                    backend.rawEntries = Files.parseFind(out, listDir)
                    backend.error = (code !== 0 && backend.rawEntries.length === 0)
                        ? friendlyError(err, listDir) : ""
                }
                var t1 = Date.now()
                if (backend.restoring) {
                    backend.restoring = false
                    if (backend.error.length > 0) { backend.loading = false; backend.navigate(backend.home, true); return }
                }
                backend.applyView()
                var t2 = Date.now()
                backend.listed()
                if (backend.debugTiming) console.log("files: listed " + backend.rawEntries.length + " entries: parse " + (t1 - t0)
                            + " ms, sort " + (t2 - t1) + " ms, selection " + (Date.now() - t2) + " ms, bytes " + out.length)
            }
            backend.loading = false
            outDone = errDone = exited = false
            if (backend.listPending) { backend.listPending = false; backend.refresh() }
        }
    }

    function firstLine(text, fallback) {
        var l = String(text).split("\n")[0].trim()
        return l.length > 0 ? l : fallback
    }

    function friendlyError(stderr, where) {
        var s = String(stderr)
        if (s.indexOf("Permission denied") >= 0) return "You don't have permission to open this folder."
        if (s.indexOf("No such file") >= 0) return "This folder no longer exists."
        if (s.indexOf("Not a directory") >= 0) return "This location is not a folder."
        return firstLine(s, "This folder could not be read.")
    }

    // ---- change monitoring -----------------------------------------------------------
    // `gio monitor` reports changes; the response is always a full rescan, so a
    // missed or coalesced event cannot leave the list stale.
    Timer { id: rescan; interval: 150; onTriggered: backend.refresh() }

    Process {
        id: monitor
        stdout: SplitParser { onRead: rescan.restart() }
    }

    function restartMonitor() {
        monitor.running = false
        monitor.command = trashView ? ["gio", "monitor", "-d", trashUri] : ["gio", "monitor", "-d", path]
        monitorStart.restart()
    }
    Timer { id: monitorStart; interval: 50; onTriggered: monitor.running = true }

    // ---- operations ------------------------------------------------------------------
    Component {
        id: opComponent
        Process {
            id: op
            property var doneFn: null
            property string err: ""
            property bool errDone: false
            property int code: -1
            property bool exited: false
            stdout: StdioCollector {}
            stderr: StdioCollector { onStreamFinished: { op.err = text; op.errDone = true; op.maybeFinish() } }
            onExited: function (exitCode) { code = exitCode; exited = true; maybeFinish() }
            function maybeFinish() {
                if (!(errDone && exited)) return
                backend.operationsRunning--
                if (doneFn) doneFn(code, err)
                destroy()
            }
        }
    }

    // Run argv; callback(code, stderr) when finished.
    function run(argv, callback) {
        operationsRunning++
        var p = opComponent.createObject(backend, { command: argv, doneFn: callback })
        p.running = true
    }

    function finish(okText, code, err) {
        if (code === 0) setMessage(okText, false)
        else setMessage(firstLine(err, "The operation failed."), true)
        refresh()
    }

    function entryNames() { return rawEntries.map(function (e) { return e.name }) }

    function createFolder(name) {
        var bad = Files.validateName(name)
        if (bad) { setMessage(bad, true); return }
        var full = Files.joinPath(path, name)
        run(["mkdir", "--", full], function (code, err) { finish("Created folder “" + name + "”", code, err) })
    }

    function createFile(name) {
        var bad = Files.validateName(name)
        if (bad) { setMessage(bad, true); return }
        var full = Files.joinPath(path, name)
        // noclobber: fails instead of truncating an existing file.
        run(["sh", "-c", "set -C; : > \"$1\"", "_", full],
            function (code, err) { finish("Created file “" + name + "”", code, err) })
    }

    function rename(entry, newName) {
        var bad = Files.validateName(newName)
        if (bad) { setMessage(bad, true); return }
        if (newName === entry.name) return
        var dest = Files.joinPath(Files.parentPath(entry.path), newName)
        run(["sh", "-c",
             "if [ -e \"$2\" ] || [ -L \"$2\" ]; then echo 'A file with that name already exists.' >&2; exit 17; fi; exec mv -T -- \"$1\" \"$2\"",
             "_", entry.path, dest],
            function (code, err) { finish("Renamed to “" + newName + "”", code, err) })
    }

    function trash(paths) {
        if (paths.length === 0) return
        run(["gio", "trash"].concat(paths), function (code, err) {
            finish(paths.length === 1 ? "Moved “" + Files.baseName(paths[0]) + "” to Trash"
                                      : "Moved " + paths.length + " items to Trash", code, err)
        })
    }

    function restore(items) {
        var uris = items.filter(function (e) { return e.isTrash }).map(function (e) { return e.uri })
        if (uris.length === 0) return
        run(["gio", "trash", "--restore"].concat(uris), function (code, err) {
            if (code !== 0 && String(err).indexOf("exists") >= 0)
                err = "Can't restore: a file with that name already exists in the original folder."
            finish(uris.length === 1 ? "Restored to its original location" : "Restored " + uris.length + " items", code, err)
        })
    }

    function deletePermanently(items) {
        var uris = items.filter(function (e) { return e.isTrash }).map(function (e) { return e.uri })
        if (uris.length === 0) return
        run(["gio", "remove"].concat(uris), function (code, err) {
            finish(uris.length === 1 ? "Deleted permanently" : "Deleted " + uris.length + " items permanently", code, err)
        })
    }

    function emptyTrash() {
        run(["gio", "trash", "--empty"], function (code, err) { finish("Trash emptied", code, err) })
    }

    // ---- clipboard (internal to Files) --------------------------------------------------
    function copy(paths) { clipboard = { mode: "copy", paths: paths }; setMessage(paths.length + (paths.length === 1 ? " item copied" : " items copied"), false) }
    function cut(paths) { clipboard = { mode: "cut", paths: paths }; setMessage(paths.length + (paths.length === 1 ? " item cut" : " items cut"), false) }
    readonly property bool canPaste: clipboard.paths.length > 0 && !trashView && !searching

    function paste() {
        if (!canPaste) return
        var items = clipboard.paths.slice()
        var mode = clipboard.mode
        var taken = entryNames()
        var done = 0, failed = 0, lastErr = ""
        function next(i) {
            if (i >= items.length) {
                if (mode === "cut") clipboard = { mode: "", paths: [] }
                if (failed > 0) setMessage(lastErr, true)
                else setMessage((mode === "cut" ? "Moved " : "Copied ") + done + (done === 1 ? " item" : " items"), false)
                refresh()
                return
            }
            tryPaste(items[i], mode, taken, 0, function (ok, err, usedName) {
                if (ok) { done++; taken.push(usedName) } else { failed++; lastErr = err }
                next(i + 1)
            })
        }
        next(0)
    }

    // Paste one item; on a name clash (exit 17) pick the next free name.
    function tryPaste(src, mode, taken, attempt, cb) {
        var base = Files.baseName(src)
        // Moving an item onto itself in the same folder is a no-op.
        if (mode === "cut" && Files.parentPath(src) === path) { cb(true, "", base); return }
        var name = Files.uniqueCopyName(base, taken)
        var dest = Files.joinPath(path, name)
        var verb = mode === "cut" ? "mv" : "cp -a"
        var script = "if [ -e \"$2\" ] || [ -L \"$2\" ]; then exit 17; fi; exec " + verb + " -T -- \"$1\" \"$2\""
        run(["sh", "-c", script, "_", src, dest], function (code, err) {
            if (code === 17 && attempt < 20) { taken.push(name); tryPaste(src, mode, taken, attempt + 1, cb); return }
            cb(code === 0, code === 0 ? "" : firstLine(err, "Could not paste “" + base + "”."), name)
        })
    }

    // ---- places and devices ---------------------------------------------------------------
    property var places: []
    property var devices: []

    Component {
        id: capComponent
        Process {
            id: cap
            property var textFn: null
            stdout: StdioCollector { onStreamFinished: { if (cap.textFn) cap.textFn(text); cap.destroy() } }
        }
    }

    function capture(argv, cb) {
        var p = capComponent.createObject(backend, { command: argv, textFn: cb })
        p.running = true
    }

    function loadPlaces() {
        var names = ["Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos"]
        capture(["find", "-H", home, "-mindepth", "1", "-maxdepth", "1", "-type", "d",
                 "(", "-name", "Desktop", "-o", "-name", "Documents", "-o", "-name", "Downloads",
                 "-o", "-name", "Music", "-o", "-name", "Pictures", "-o", "-name", "Videos", ")",
                 "-printf", "%f\\n"], function (text) {
            var have = {}
            text.split("\n").forEach(function (n) { if (n) have[n] = true })
            places = names.filter(function (n) { return have[n] })
                          .map(function (n) { return { name: n, path: Files.joinPath(home, n) } })
        })
        capture(["findmnt", "-rn", "-o", "TARGET"], function (text) {
            var out = []
            text.split("\n").forEach(function (t) {
                t = t.replace(/\\x20/g, " ")
                if (/^\/(run\/media|media|mnt)\/./.test(t)) out.push({ name: Files.baseName(t), path: t })
            })
            devices = out
        })
    }

    // ---- startup location and remembered state --------------------------------------------
    // Opened with an argument (axiom-app files PATH | file://URI | trash:///):
    // go there. Otherwise reopen where the user left off, from
    // ~/.local/state/axiom/files.json (a missing or unreadable file means home).
    readonly property string startArg: Quickshell.env("AXIOM_APP_ARG") || ""
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (home + "/.local/state")) + "/axiom"
    property bool restoring: false
    property bool restoreApplied: false   // the saved folder was opened; the default start must not override it
    readonly property bool debugTiming: Quickshell.env("AXIOM_FILES_DEBUG") === "1"

    function argToPath(arg) {
        if (arg === "trash:///" || arg === "trash:") return trashUri
        if (arg.indexOf("file://") === 0) return Files.uriUnescape(arg.substring(7))
        return arg
    }

    FileView {
        id: stateFile
        path: backend.stateDir + "/files.json"
        printErrors: false
        adapter: JsonAdapter {
            id: saved
            property int version: 1
            property string path: ""
            property bool showHidden: false
            property string sortKey: "name"
            property bool sortAscending: true
        }
        onLoaded: {
            backend.showHidden = saved.showHidden
            backend.sortKey = saved.sortKey === "size" || saved.sortKey === "modified" ? saved.sortKey : "name"
            backend.sortAscending = saved.sortAscending
            if (backend.startArg.length === 0 && saved.path.length > 0) {
                backend.restoring = true
                backend.restoreApplied = true
                backend.navigate(saved.path, true)
            }
            stateReady.start()
        }
        onLoadFailed: stateReady.start()
    }

    // Only start saving once the saved state has been read, so the defaults
    // never overwrite it.
    property bool saving: false
    Timer { id: stateReady; interval: 10; onTriggered: backend.saving = true }

    function scheduleSave() { if (saving) saveTimer.restart() }
    Timer { id: saveTimer; interval: 1000; onTriggered: makeStateDir.running = true }
    Process {
        id: makeStateDir
        command: ["mkdir", "-p", "--", backend.stateDir]
        onExited: function (code) {
            if (code !== 0) return
            saved.path = backend.trashView ? saved.path : backend.path
            saved.showHidden = backend.showHidden
            saved.sortKey = backend.sortKey
            saved.sortAscending = backend.sortAscending
            stateFile.writeAdapter()
        }
    }

    onPathChanged: scheduleSave()

    // Safeguard for sessions that did not start through axiom-session: the
    // Trash directories must exist before anything lists or monitors the trash
    // (a GVfs daemon that starts without them never sees later items).
    readonly property string dataDir: Quickshell.env("XDG_DATA_HOME") || (home + "/.local/share")
    Process {
        id: trashDirs
        command: ["sh", "-c", "umask 077; mkdir -p -- \"$1/Trash/files\" \"$1/Trash/info\"", "_", backend.dataDir]
        onExited: backend.begin()
    }

    function begin() {
        if (restoreApplied) return
        navigate(startArg.length > 0 ? argToPath(startArg) : home, true)
    }

    Component.onCompleted: {
        loadPlaces()
        trashDirs.running = true
    }

    // ---- open ------------------------------------------------------------------------------
    function open(entry) {
        if (entry.isTrash) { setMessage("Restore the item to open it.", true); return }
        if (entry.isDir) { navigate(entry.path); return }
        Quickshell.execDetached(["gio", "open", entry.path])
        setMessage("Opening “" + entry.name + "”…", false)
    }

    // ---- search -------------------------------------------------------------------------------
    function globEscape(s) { return s.replace(/[\\*?\[\]]/g, function (c) { return "\\" + c }) }

    function search(query) {
        cancelSearch()
        searchQuery = query
        if (query.length === 0 || trashView) { refresh(); return }
        loading = true
        searcher.searchDir = path
        searcher.command = ["sh", "-c",
            "find -H \"$1\" -mindepth 1 -maxdepth 6 -iname \"$2\" -printf '%y\\0%Y\\0%P\\0%s\\0%T@\\0%m\\0%l\\0' | head -c 800000",
            "_", path, "*" + globEscape(query) + "*"]
        searcher.running = true
    }

    function cancelSearch() { if (searcher.running) searcher.running = false }

    Process {
        id: searcher
        property string searchDir: ""
        stdout: StdioCollector {
            onStreamFinished: {
                if (!backend.searching || searcher.searchDir !== backend.path) return
                var found = Files.parseFind(text, searcher.searchDir)
                if (!backend.showHidden)
                    found = found.filter(function (e) { return !/(^|\/)\./.test(e.name) })
                backend.rawEntries = found
                backend.applyView()
                backend.loading = false
                backend.error = ""
                backend.listed()
            }
        }
    }

    // ---- properties ---------------------------------------------------------------------------
    // Reads the real content type and permissions with stat/gio; calls cb(info).
    function properties(entry, cb) {
        var info = { name: entry.name, path: entry.path, kind: Files.kindLabel(entry),
                     size: entry.size, mtime: entry.mtime, mode: entry.mode, target: entry.target,
                     isDir: entry.isDir, contentType: "", owner: "" }
        if (entry.isTrash) { info.path = entry.origin; cb(info); return }
        var p = propsComponent.createObject(backend, { command: ["stat", "-L", "--printf", "%U:%G\\0%A\\0%s\\0%y", entry.path], info: info, doneFn: cb })
        p.running = true
    }

    Component {
        id: propsComponent
        Process {
            id: pp
            property var info: ({})
            property var doneFn: null
            stdout: StdioCollector {
                onStreamFinished: {
                    var f = text.split("\u0000")
                    if (f.length >= 4) { pp.info.owner = f[0]; pp.info.perms = f[1]; pp.info.sizeExact = parseInt(f[2], 10); pp.info.modified = f[3] }
                    pp.next()
                }
            }
            function next() {
                var t = typeComponent.createObject(backend, { command: ["gio", "info", "-a", "standard::content-type", info.path], info: info, doneFn: pp.doneFn })
                t.running = true
                pp.destroy()
            }
        }
    }

    Component {
        id: typeComponent
        Process {
            id: tp
            property var info: ({})
            property var doneFn: null
            stdout: StdioCollector {
                onStreamFinished: {
                    var m = /standard::content-type: (.+)/.exec(text)
                    if (m) tp.info.contentType = m[1].trim()
                    if (tp.doneFn) tp.doneFn(tp.info)
                    tp.destroy()
                }
            }
        }
    }
}
