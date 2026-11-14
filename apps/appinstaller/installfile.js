.pragma library

// Axiom install-from-file: classify a dropped file and pick where it goes.
// Pure logic, no I/O. Unit-tested with tests/apps/installfile-logic.test.mjs.
// AppImage and Flatpak install as the user; Arch packages go through the
// privileged helper (pkexec + polkit), so they need an admin approval.
// A .deb never touches the Arch system: it installs inside a rootless distrobox
// container (see docs/decisions/028-deb-via-distrobox.md) and its launcher is
// exported to the user's menu.

var KINDS = {
    appimage: { label: "AppImage", root: false },
    flatpak: { label: "Flatpak bundle", root: false },
    arch: { label: "Arch package", root: true },
    deb: { label: "Debian package (in a container)", root: false }
}

// Returns { kind, label, root, supported } or null for unknown file types.
function classify(fileName) {
    var n = (fileName || "").toLowerCase()
    var kind = null
    if (n.endsWith(".appimage")) kind = "appimage"
    else if (n.endsWith(".flatpak") || n.endsWith(".flatpakref")) kind = "flatpak"
    else if (n.endsWith(".pkg.tar.zst") || n.endsWith(".pkg.tar.xz")) kind = "arch"
    else if (n.endsWith(".deb")) kind = "deb"
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

// Friendly app name from a file name: drop the extension, architecture and version
// parts, turn - and _ into spaces. "Foo-Bar-1.2.3-x86_64.AppImage" -> "Foo Bar".
function displayName(fileName) {
    var base = (fileName || "").split("/").pop().replace(/\.(appimage|flatpakref|flatpak|deb|pkg\.tar\.(zst|xz))$/i, "")
    var words = base.split(/[-_ ]+/).filter(function (w) {
        return w.length > 0 && !/^(x86|x86_64|amd64|arm64|aarch64|i386|i686|current|stable|linux)$/i.test(w) && !/^v?\d[\w.+~]*$/.test(w)
    })
    var name = words.join(" ")
    return name.length > 0 ? name.charAt(0).toUpperCase() + name.slice(1) : (fileName || "App")
}

// Human-readable size for the confirmation dialog.
function formatSize(bytes) {
    if (!(bytes >= 0)) return "unknown size"
    var units = ["B", "KB", "MB", "GB"]
    var v = bytes, i = 0
    while (v >= 1024 && i < units.length - 1) { v /= 1024; i++ }
    return (i === 0 ? v.toFixed(0) : v.toFixed(1)) + " " + units[i]
}

// ---- .deb through distrobox (rootless; the container does the apt work) ----

var DEB_CONTAINER = "axiom-debian"
var DEB_IMAGE = "docker.io/library/debian:stable"
var DEB_NAME = /^[a-z0-9][a-z0-9+.-]*$/   // Debian package names

// Where a .deb is staged inside the user's home so the container can see it.
function debStagePath(home, fileName) {
    var base = (fileName || "").split("/").pop().replace(/[^A-Za-z0-9._+-]/g, "_")
    return home.replace(/\/+$/, "") + "/.cache/axiom-debs/" + base
}

// True when `distrobox list` output names the Axiom container.
function containerListed(out) {
    return (out || "").split("\n").some(function (l) {
        return l.split("|").some(function (c) { return c.trim() === DEB_CONTAINER })
    })
}

function validDebName(name) { return DEB_NAME.test((name || "").trim()) }

function debListArgv() { return ["distrobox", "list"] }
function debCreateArgv() { return ["distrobox", "create", "--yes", "--name", DEB_CONTAINER, "--image", DEB_IMAGE] }
function debEnterArgv(cmd) { return ["distrobox", "enter", DEB_CONTAINER, "--"].concat(cmd) }
function debNameArgv(stagedPath) { return debEnterArgv(["dpkg-deb", "-f", stagedPath, "Package"]) }
function debInstallArgv(stagedPath) { return debEnterArgv(["sudo", "apt-get", "install", "-y", stagedPath]) }
// distrobox-export puts the app's launcher in the host's ~/.local/share/applications.
function debExportArgv(pkg) { return debEnterArgv(["distrobox-export", "--app", pkg]) }
