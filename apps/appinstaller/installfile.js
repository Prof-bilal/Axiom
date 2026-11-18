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

// ---- Signatures (minisign), policy, sandbox and audit (ADR-032) ----
// The verifier is run through CommandRunner, never a shell. Keys are shipped read-only in
// /usr/share/axiom/keys/. A missing .minisig is "unsigned"; a present one that does not verify is "failed".

var KEY_DIR = "/usr/share/axiom/keys"

function minisignArgv(keyPath, filePath) {
    return ["minisign", "-V", "-p", keyPath, "-m", filePath]
}

// signature: { present: bool, verified: bool }
function signatureState(signature) {
    if (!signature || !signature.present) return "unsigned"
    return signature.verified ? "verified" : "failed"
}

// Decides what the install needs. Returns { blocked, requiresAdmin, reason }.
// System-wide installs always need admin. A failed signature is blocked outright.
// An unsigned user-scope file is allowed, but only after an admin approval.
function installPolicy(kind, scope, sigState) {
    if (sigState === "failed")
        return { blocked: true, requiresAdmin: false, reason: "Signature does not match this file. Install blocked." }
    if (scope === "system" || (KINDS[kind] && KINDS[kind].root))
        return { blocked: false, requiresAdmin: true, reason: "System-wide install needs admin approval." }
    if (sigState === "unsigned")
        return { blocked: false, requiresAdmin: true, reason: "Unsigned source: admin approval required." }
    return { blocked: false, requiresAdmin: false, reason: "Signed and verified: installs in your account." }
}

// Launch argv for an AppImage inside bubblewrap. No home directory is mounted: the app
// sees the system read-only and its own file, so it cannot read ~/.ssh or other files.
function sandboxArgv(appPath) {
    return [
        "bwrap", "--die-with-parent", "--unshare-pid", "--unshare-ipc",
        "--ro-bind", "/usr", "/usr",
        "--ro-bind-try", "/lib", "/lib",
        "--ro-bind-try", "/lib64", "/lib64",
        "--ro-bind-try", "/bin", "/bin",
        "--ro-bind-try", "/etc", "/etc",
        "--proc", "/proc", "--dev", "/dev", "--tmpfs", "/tmp",
        "--ro-bind", appPath, appPath,
        "--", appPath
    ]
}

// One audit line (JSON, no trailing newline). The id is returned to the UI as the audit ID.
function auditLine(record) {
    return JSON.stringify({
        id: record.id, time: record.time, file: record.file, sha256: record.sha256,
        signature: record.signature, policy: record.policy, sandbox: record.sandbox,
        target: record.target, result: record.result
    })
}

function sha256Argv(filePath) { return ["sha256sum", "--", filePath] }

// Admin approval for an unsigned user install: the existing polkit action runs the helper's
// approve verb with the file's SHA-256 (64 hex digits, checked here and in the helper).
function approveArgv(sha256) {
    return ["pkexec", "/usr/local/bin/axiom-pkgd", "approve", sha256]
}
function validSha256(s) { return /^[0-9a-f]{64}$/.test(s || "") }

// Exec line for the desktop entry: the AppImage starts inside the bubblewrap sandbox.
function sandboxExecLine(appPath) {
    return sandboxArgv(appPath).map(quoteExec).join(" ") + " %U"
}
// Desktop entry with a ready-made Exec line (use with sandboxExecLine).
function desktopEntryLine(name, execLine) {
    var safeName = (name || "App").replace(/[\r\n]/g, " ")
    return ["[Desktop Entry]", "Type=Application", "Name=" + safeName, "Exec=" + execLine,
            "Terminal=false", "Categories=Utility;", ""].join("\n")
}

