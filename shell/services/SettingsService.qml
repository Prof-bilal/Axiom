pragma Singleton

// SettingsService — Axiom's per-user settings (ADR-018). One JSON file,
// ~/.config/axiom/settings.json, read and watched by the shell and every app;
// the Settings app is the only writer. A change written by one process shows
// up in the others through file watching, with no daemon in between.
//
// Missing keys use the defaults below. An unreadable or invalid file falls
// back to defaults and is reported in `loadError`; it is replaced only when
// the user changes a setting.

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: settings

    readonly property string dir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/axiom"
    readonly property string path: dir + "/settings.json"

    // Pinned dock applications when the user has not customised the dock.
    readonly property var defaultDockPins: ["foot", "axiom-files", "firefox", "code-oss", "axiom-trash"]

    // ---- effective values ---------------------------------------------------
    // Absolute path of the chosen wallpaper image, or "" for the Axiom default.
    readonly property string wallpaper: store.wallpaper
    // Desktop-entry ids pinned to the dock, in order.
    readonly property var dockPins: store.dockCustom ? store.dockPins : defaultDockPins
    readonly property bool dockCustom: store.dockCustom
    // Multiplier for every text size in the shell and the apps (1.0 default).
    readonly property real textScale: Math.max(0.9, Math.min(1.5, store.textScale))

    // "" when the file loaded (or does not exist yet); otherwise why it did not.
    property string loadError: ""

    // ---- changes (called by the Settings app) ---------------------------------
    function setWallpaper(imagePath) {
        store.wallpaper = imagePath
        save()
    }

    function setDockPins(ids) {
        store.dockPins = ids
        store.dockCustom = true
        save()
    }

    function setTextScale(scale) {
        store.textScale = scale
        save()
    }

    function resetDock() {
        store.dockPins = []
        store.dockCustom = false
        save()
    }

    // ---- persistence ------------------------------------------------------------
    function save() {
        makeDir.running = false
        makeDir.running = true
    }

    // File watching only works on a file that exists, so while there is none
    // (fresh account, or the file was deleted) look for it every 1.5 s. The
    // cost is one failed open() per tick, and it stops as soon as the file loads.
    property bool fileKnown: false
    Timer {
        interval: 1500
        repeat: true
        running: !settings.fileKnown
        onTriggered: file.reload()
    }

    // The directory may not exist on a fresh account.
    Process {
        id: makeDir
        command: ["mkdir", "-p", "--", settings.dir]
        onExited: function (code) { if (code === 0) file.writeAdapter() }
    }

    FileView {
        id: file
        path: settings.path
        watchChanges: true
        printErrors: false   // a missing file is normal on a fresh account
        onFileChanged: reload()
        onLoaded: { settings.loadError = ""; settings.fileKnown = true }
        onLoadFailed: function (error) {
            settings.fileKnown = false
            settings.loadError = error === FileViewError.FileNotFound ? "" : "Settings could not be read (" + error + "); using defaults."
        }

        adapter: JsonAdapter {
            id: store
            property int version: 1
            property string wallpaper: ""
            property bool dockCustom: false
            property var dockPins: []
            property real textScale: 1.0
        }
    }
}
