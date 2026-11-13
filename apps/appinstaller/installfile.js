.pragma library

// Axiom install-from-file: classify a dropped file and pick where it goes.
// Pure logic, no I/O. Unit-tested with tests/apps/installfile-logic.test.mjs.
// AppImage and Flatpak install as the user; Arch packages go through the
// privileged helper (pkexec + polkit), so they need an admin approval.

var KINDS = {
    appimage: { label: "AppImage", root: false },
    flatpak: { label: "Flatpak bundle", root: false },
    arch: { label: "Arch package", root: true }
}

// Returns { kind, label, root, supported } or null for unknown file types.
function classify(fileName) {
    var n = (fileName || "").toLowerCase()
    var kind = null
    if (n.endsWith(".appimage")) kind = "appimage"
    else if (n.endsWith(".flatpak") || n.endsWith(".flatpakref")) kind = "flatpak"
    else if (n.endsWith(".pkg.tar.zst") || n.endsWith(".pkg.tar.xz")) kind = "arch"
    if (!kind) return null
    return { kind: kind, label: KINDS[kind].label, root: KINDS[kind].root }
}

// Per-user destination for AppImage files (no root).
function appImageTarget(home, fileName) {
    var base = (fileName || "").split("/").pop().replace(/[^A-Za-z0-9._-]/g, "_")
    return home.replace(/\/+$/, "") + "/Applications/" + base
}
// Desktop Exec values: quote and escape so a path with spaces or $ stays one argument.
function quoteExec(path) {
    return '"' + (path || "").replace(/(["\\`$])/g, "\\$1") + '"'
}

// Desktop entry for an installed AppImage, written to the user's applications dir.
function desktopEntry(name, execPath) {
    var safeName = (name || "App").replace(/[\r\n]/g, " ")
    return [
        "[Desktop Entry]",
        "Type=Application",
        "Name=" + safeName,
        "Exec=" + quoteExec(execPath) + " %U",
        "Terminal=false",
        "Categories=Utility;",
        ""
    ].join("\n")
}

// argv for a no-root Flatpak install (run with CommandRunner, never a shell).
function flatpakArgv(path) {
    return ["flatpak", "install", "--user", "--noninteractive", path]
}

// Human-readable size for the confirmation dialog.
function formatSize(bytes) {
    if (!(bytes >= 0)) return "unknown size"
    var units = ["B", "KB", "MB", "GB"]
    var v = bytes, i = 0
    while (v >= 1024 && i < units.length - 1) { v /= 1024; i++ }
    return (i === 0 ? v.toFixed(0) : v.toFixed(1)) + " " + units[i]
}

