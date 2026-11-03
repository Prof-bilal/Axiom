.pragma library

// Axiom Files: pure logic (no QML, no I/O). Parsing of `find`/`gio` output,
// sorting, naming rules and display formatting. Unit-tested on the host with
// tests/apps/files-logic.test.mjs; keep it free of QML imports.

// ---- paths -----------------------------------------------------------------

function joinPath(dir, name) {
    if (dir === "/") return "/" + name
    return dir.replace(/\/+$/, "") + "/" + name
}

function parentPath(path) {
    var p = path.replace(/\/+$/, "")
    var i = p.lastIndexOf("/")
    if (i <= 0) return "/"
    return p.substring(0, i)
}

function baseName(path) {
    var p = path.replace(/\/+$/, "")
    return p.substring(p.lastIndexOf("/") + 1)
}

// [{name, path}] from "/" to path, for the breadcrumb bar.
function segments(path) {
    var out = [{ name: "/", path: "/" }]
    var acc = ""
    var parts = path.split("/")
    for (var i = 0; i < parts.length; i++) {
        if (parts[i] === "") continue
        acc += "/" + parts[i]
        out.push({ name: parts[i], path: acc })
    }
    return out
}

// Normalise a user-typed path: expand ~, resolve ./.. without touching disk.
function normalize(input, home, cwd) {
    var p = String(input).trim()
    if (p === "~") p = home
    else if (p.indexOf("~/") === 0) p = home + p.substring(1)
    else if (p.charAt(0) !== "/") p = joinPath(cwd, p)
    var out = []
    var parts = p.split("/")
    for (var i = 0; i < parts.length; i++) {
        if (parts[i] === "" || parts[i] === ".") continue
        if (parts[i] === "..") { out.pop(); continue }
        out.push(parts[i])
    }
    return "/" + out.join("/")
}

// ---- parsing -----------------------------------------------------------------

// Output of: find DIR -mindepth 1 -maxdepth 1
//   -printf '%y\0%Y\0%f\0%s\0%T@\0%m\0%l\0'
// Seven NUL-terminated fields per entry; names may contain any byte except NUL.
function parseFind(text, dir) {
    var f = text.split("\u0000")
    var out = []
    for (var i = 0; i + 6 < f.length; i += 7) {
        var type = f[i], follow = f[i + 1], name = f[i + 2]
        out.push({
            name: name,
            path: joinPath(dir, name),
            isLink: type === "l",
            isDir: type === "d" || (type === "l" && follow === "d"),
            broken: type === "l" && (follow === "N" || follow === "L" || follow === "?"),
            size: parseInt(f[i + 3], 10) || 0,
            mtime: parseFloat(f[i + 4]) || 0,
            mode: f[i + 5],
            target: f[i + 6]
        })
    }
    return out
}

// Output of `gio trash --list`: "trash:///<uri-escaped name>\t<original path>"
// per item. An original path containing a newline continues on the next line.
function parseTrashList(text) {
    var lines = text.split("\n")
    var items = []
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i]
        if (line.indexOf("trash:///") === 0) {
            var tab = line.indexOf("\t")
            if (tab < 0) continue
            var uri = line.substring(0, tab)
            items.push({
                uri: uri,
                name: uriUnescape(uri.substring("trash:///".length)),
                origin: line.substring(tab + 1),
                isTrash: true
            })
        } else if (items.length > 0 && line !== "") {
            items[items.length - 1].origin += "\n" + line
        }
    }
    for (var j = 0; j < items.length; j++) {
        items[j].path = items[j].uri
        items[j].isDir = false
        items[j].isLink = false
        items[j].size = 0
        items[j].mtime = 0
    }
    return items
}

function uriUnescape(s) {
    try { return decodeURIComponent(s) } catch (e) { return s }
}

// ---- sorting ------------------------------------------------------------------

// Natural-order sort key, computed once per entry: lower-cased, with every
// run of digits left-padded to 20 characters so a plain string compare orders
// "file2" before "file10". Far cheaper than comparing token by token with a
// regex (that took 2.6 s for 10,000 entries in the guest).
var ZEROS = "00000000000000000000"

function sortKey(name) {
    return name.toLowerCase().replace(/\d+/g, function (m) {
        return m.length < 20 ? ZEROS.substring(m.length) + m : m
    })
}

function padNumber(n, width) {
    var t = String(n)
    return t.length >= width ? t : ZEROS.substring(0, width - t.length) + t
}

// key: "name" | "size" | "modified"; folders always sort before files.
//
// No comparator callback: the QML engine runs them ~100x slower than a native
// compare (1.7 s for 10,000 entries). Instead every entry becomes one string,
// "<sort key>\0<name>\0<index>", the array of strings is sorted with the
// engine's native default sort (code-unit order), and the index recovers the
// entry. Folders and files are sorted separately so reversing keeps folders
// first.
function sortEntries(entries, key, ascending, hidden) {
    var dirKeys = [], fileKeys = []
    for (var i = 0; i < entries.length; i++) {
        var e = entries[i]
        if (!hidden && e.name.charAt(0) === ".") continue
        if (e.key === undefined) e.key = sortKey(e.name)
        var k = key === "size" ? padNumber(e.size, 20) + e.key
              : key === "modified" ? padNumber(Math.floor(e.mtime), 14) + e.key
              : e.key
        ;(e.isDir ? dirKeys : fileKeys).push(k + "\u0000" + e.name + "\u0000" + i)
    }
    dirKeys.sort()
    fileKeys.sort()
    if (!ascending) { dirKeys.reverse(); fileKeys.reverse() }
    var all = dirKeys.concat(fileKeys)
    var out = new Array(all.length)
    for (var j = 0; j < all.length; j++) {
        var s = all[j]
        out[j] = entries[parseInt(s.substring(s.lastIndexOf("\u0000") + 1), 10)]
    }
    return out
}

// ---- names ----------------------------------------------------------------------

// "" when valid, otherwise a user-facing reason.
function validateName(name) {
    if (name.length === 0) return "A name is required."
    if (name === "." || name === "..") return "That name is reserved."
    if (name.indexOf("/") >= 0) return "A name cannot contain \"/\"."
    if (name.indexOf("\u0000") >= 0) return "A name cannot contain a null character."
    if (name.length > 255) return "That name is too long."
    return ""
}

// "New folder", "New folder 2", ... not present in `existing` (an array of
// names). Used for new items.
function uniqueNewName(base, existing) {
    var set = {}
    existing.forEach(function (n) { set[n] = true })
    if (!set[base]) return base
    for (var i = 2; i < 10000; i++) {
        var c = base + " " + i
        if (!set[c]) return c
    }
    return base + " " + Date.now()
}

// Name for a pasted copy: "doc.txt" -> "doc (copy).txt" -> "doc (copy 2).txt".
function uniqueCopyName(name, existing) {
    var set = {}
    existing.forEach(function (n) { set[n] = true })
    if (!set[name]) return name
    var dot = name.lastIndexOf(".")
    var stem = dot > 0 ? name.substring(0, dot) : name
    var ext = dot > 0 ? name.substring(dot) : ""
    var c = stem + " (copy)" + ext
    if (!set[c]) return c
    for (var i = 2; i < 10000; i++) {
        c = stem + " (copy " + i + ")" + ext
        if (!set[c]) return c
    }
    return stem + " (copy " + Date.now() + ")" + ext
}

// ---- display ----

// A name as shown in a row: control characters become visible symbols so a
// newline cannot wrap the row, and bidirectional override characters (which
// can make "evil\u202Etxt.exe" read as a harmless name) become U+FFFD.
function displayName(name) {
    return name
        .replace(/\n/g, "\u23CE")
        .replace(/\t/g, "\u21E5")
        .replace(/[\u0000-\u001f\u007f]/g, "\uFFFD")
        .replace(/[\u202A-\u202E\u2066-\u2069]/g, "\uFFFD")
}

function humanSize(bytes) {
    if (bytes < 1000) return bytes + " B"
    var units = ["kB", "MB", "GB", "TB"]
    var v = bytes
    for (var i = 0; i < units.length; i++) {
        v /= 1000
        if (v < 1000 || i === units.length - 1) {
            return (v < 10 ? v.toFixed(1) : Math.round(v)) + " " + units[i]
        }
    }
    return bytes + " B"
}

function pad2(n) { return n < 10 ? "0" + n : "" + n }

// Compact local date: "Nov 3, 14:05" this year, "Nov 3, 2025" otherwise.
function formatDate(epochSeconds, now) {
    if (!epochSeconds) return ""
    var d = new Date(epochSeconds * 1000)
    var n = now ? new Date(now) : new Date()
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var base = months[d.getMonth()] + " " + d.getDate()
    if (d.getFullYear() === n.getFullYear()) return base + ", " + pad2(d.getHours()) + ":" + pad2(d.getMinutes())
    return base + ", " + d.getFullYear()
}

var EXT = {
    image: ["png", "jpg", "jpeg", "gif", "webp", "svg", "bmp", "ico", "tif", "tiff", "avif"],
    audio: ["mp3", "flac", "ogg", "opus", "wav", "m4a", "aac"],
    video: ["mp4", "mkv", "webm", "mov", "avi", "m4v"],
    archive: ["zip", "tar", "gz", "xz", "bz2", "zst", "7z", "rar", "tgz", "iso"],
    document: ["pdf", "odt", "ods", "odp", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "epub"],
    code: ["c", "h", "cpp", "hpp", "rs", "go", "py", "js", "ts", "qml", "sh", "rb", "java", "css", "html", "json", "toml", "yaml", "yml", "xml", "md"],
    text: ["txt", "log", "conf", "ini", "cfg", "csv"]
}

function extension(name) {
    var dot = name.lastIndexOf(".")
    return dot > 0 ? name.substring(dot + 1).toLowerCase() : ""
}

// Coarse category used for the icon and the "Kind" column. Derived from the
// file name only; the real content type is read with `gio info` on demand.
function category(entry) {
    if (entry.isTrash) return entry.isDir ? "folder" : categoryOfName(entry.name)
    if (entry.broken) return "broken"
    if (entry.isDir) return "folder"
    return categoryOfName(entry.name)
}

function categoryOfName(name) {
    var e = extension(name)
    for (var k in EXT) if (EXT[k].indexOf(e) >= 0) return k
    return "file"
}

// Names from the shell's AxiomIcon glyph set (shell/src/shared/AxiomIcon.qml).
var ICONS = {
    folder: "folder", image: "image", audio: "audio", video: "video",
    archive: "archive", document: "document", code: "code", text: "document",
    file: "file", broken: "broken-link"
}

function iconName(entry) { return ICONS[category(entry)] }

var KIND = {
    folder: "Folder", image: "Image", audio: "Audio", video: "Video",
    archive: "Archive", document: "Document", code: "Source / data",
    text: "Text", file: "File", broken: "Broken link"
}

function kindLabel(entry) {
    var k = KIND[category(entry)]
    return entry.isLink && !entry.broken ? k + " (link)" : k
}
