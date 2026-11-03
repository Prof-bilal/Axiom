.pragma library

// Axiom Settings: pure logic (no QML, no I/O). Parsing of `gio mime` and /proc
// text, dock pin editing and wallpaper helpers. Unit-tested on the host with
// tests/apps/settings-logic.test.mjs.

// ---- default applications ----------------------------------------------------

// `gio mime TYPE` (LC_ALL=C):
//   Default application for "text/plain": org.xfce.mousepad.desktop
//   Registered applications:
//   <TAB>org.xfce.mousepad.desktop
//   Recommended applications:
//   <TAB>...
// Quote characters vary by locale, so match loosely. "No default applications
// for ..." means none is set.
function parseMime(text) {
    var out = { defaultId: "", registered: [] }
    var lines = text.split("\n")
    var section = ""
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i]
        var d = /^Default application for .*?: (\S+\.desktop)\s*$/.exec(line)
        if (d) { out.defaultId = d[1]; continue }
        if (/^Registered applications:/.test(line)) { section = "reg"; continue }
        if (/^Recommended applications:/.test(line)) { section = "rec"; continue }
        var a = /^\s+(\S+\.desktop)\s*$/.exec(line)
        if (a && section !== "" && out.registered.indexOf(a[1]) < 0) out.registered.push(a[1])
    }
    return out
}

// A desktop-file id without its suffix, as ApplicationService expects it.
function entryId(desktopFile) { return desktopFile.replace(/\.desktop$/, "") }

// ---- dock pins -----------------------------------------------------------------

function movePin(pins, index, delta) {
    var to = index + delta
    if (index < 0 || index >= pins.length || to < 0 || to >= pins.length) return pins.slice()
    var out = pins.slice()
    var tmp = out[index]; out[index] = out[to]; out[to] = tmp
    return out
}

function removePin(pins, index) {
    if (index < 0 || index >= pins.length) return pins.slice()
    var out = pins.slice(); out.splice(index, 1); return out
}

function addPin(pins, id) {
    if (!id || pins.indexOf(id) >= 0) return pins.slice()
    return pins.concat([id])
}

// ---- wallpapers -------------------------------------------------------------------

var IMAGE_EXT = ["png", "jpg", "jpeg", "webp", "bmp", "avif"]

function isImageName(name) {
    var dot = name.lastIndexOf(".")
    return dot > 0 && IMAGE_EXT.indexOf(name.substring(dot + 1).toLowerCase()) >= 0
}

function label(path) {
    var base = path.substring(path.lastIndexOf("/") + 1)
    var dot = base.lastIndexOf(".")
    return dot > 0 ? base.substring(0, dot) : base
}

// Newline-separated absolute paths (from `find`), filtered to images, sorted.
function parseImagePaths(text) {
    return text.split("\n").filter(function (p) {
        return p.charAt(0) === "/" && isImageName(p.substring(p.lastIndexOf("/") + 1))
    }).sort()
}

// ---- system information ---------------------------------------------------------------

function parseCpuModel(cpuinfo) {
    var m = /^model name\s*:\s*(.+)$/m.exec(cpuinfo)
    return m ? m[1].trim().replace(/\s+/g, " ") : ""
}

function parseMemTotalKb(meminfo) {
    var m = /^MemTotal:\s+(\d+)\s*kB/m.exec(meminfo)
    return m ? parseInt(m[1], 10) : 0
}

function formatKb(kb) {
    if (kb <= 0) return ""
    var gib = kb / 1048576
    return gib >= 1 ? gib.toFixed(gib < 10 ? 1 : 0) + " GiB" : Math.round(kb / 1024) + " MiB"
}

function firstLine(text) { return String(text).split("\n")[0].trim() }

// "quickshell 0.3.2, revision abc, distributed by Arch Linux" -> "quickshell 0.3.2"
// "labwc 0.20.2 (+xwayland +nls)" -> "labwc 0.20.2"
function shortVersion(text) { return String(text).split("\n")[0].split(/[,(]/)[0].trim() }
