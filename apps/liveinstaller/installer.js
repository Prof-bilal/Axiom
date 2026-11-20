.pragma library

// Axiom live-desktop installer: pure logic. No QML, no I/O (ADR-035). The install form is validated by
// the backend (installer/axiom_install.py --validate), never by a second copy of its rules here.
// Unit-tested on the host with tests/apps/installer-logic.test.mjs.

var C = {
    bg: "#181b1f", side: "#14171a", bar: "#1f2328", card: "#1d2227", field: "#2a2f35",
    line: "#2b3036", text: "#e4e8ec", dim: "#9aa2aa", faint: "#5d656d",
    orange: "#ff9418", orangeInk: "#1a0e00", green: "#4ade80", red: "#ff6b6b"
}

var STEPS = ["Welcome", "Network", "Locale", "Partitioning", "Identity", "Installation", "Finish"]
// Page index -> sidebar step. Confirm and Progress both belong to "Installation".
var PAGES = ["welcome", "network", "locale", "disk", "identity", "confirm", "progress", "finish"]
var PAGE_STEP = [0, 1, 2, 3, 4, 5, 5, 6]

var LOCALES = ["en_US", "en_GB", "de_DE", "fr_FR", "es_ES", "it_IT", "pt_BR", "nl_NL", "pl_PL", "ru_RU", "tr_TR", "ja_JP", "zh_CN"]
var LOCALE_NAMES = {
    en_US: "English (United States)", en_GB: "English (United Kingdom)", de_DE: "German", fr_FR: "French",
    es_ES: "Spanish", it_IT: "Italian", pt_BR: "Portuguese (Brazil)", nl_NL: "Dutch", pl_PL: "Polish",
    ru_RU: "Russian", tr_TR: "Turkish", ja_JP: "Japanese", zh_CN: "Chinese (Simplified)"
}
// The backend only accepts layout codes without a hyphen, so the Brazilian layout is "br".
var KEYMAPS = ["us", "uk", "de", "fr", "es", "it", "br"]
var KEYMAP_NAMES = {
    us: "English (US)", uk: "English (UK)", de: "German", fr: "French", es: "Spanish", it: "Italian", br: "Portuguese (Brazil)"
}

function nameOf(names, code) { return names[code] || code }

// `timedatectl list-timezones` output -> { Region: [City, ...] }. "UTC" has no region and stays flat.
function tzGroups(text) {
    var groups = {}
    String(text || "").split(/\s+/).forEach(function (zone) {
        if (!zone) return
        var i = zone.indexOf("/")
        var region = i < 0 ? zone : zone.slice(0, i)
        var city = i < 0 ? zone : zone.slice(i + 1)
        if (!groups[region]) groups[region] = []
        groups[region].push(city)
    })
    if (Object.keys(groups).length === 0) groups = { UTC: ["UTC"] }
    Object.keys(groups).forEach(function (r) { groups[r].sort() })
    return groups
}

function tzName(region, city) { return region === city ? region : region + "/" + city }

// Step through a list with wrap-around (the arrows on a chooser).
function cycle(list, value, delta) {
    if (list.length === 0) return value
    var i = list.indexOf(value)
    if (i < 0) i = 0
    return list[(i + delta + list.length * 2) % list.length]
}

function diskLabel(d) {
    return d.path + "   " + Math.round(d.size / Math.pow(2, 30)) + " GB" + (d.model ? "   " + d.model : "")
}

var MIN_DISK = 10 * Math.pow(2, 30)

// A fully valid base so one screen's validation only checks the fields it owns (the same trick the
// text installer uses). The placeholders never leave this function: they are only sent to --validate.
function probe(f) {
    return {
        username: f.username || "probe", fullname: f.fullname || "Probe", hostname: f.hostname || "axiom",
        password: f.password || "probe-password-1", timezone: f.timezone, keyboard: f.keyboard, locale: f.locale,
        git_name: f.git_name, git_email: f.git_email, luks: false, luks_passphrase: "", hub: []
    }
}

// The payload sent to the root helper. Starts from the form, never includes the repeat field.
function payload(f, disk) {
    return {
        username: f.username, fullname: f.fullname, hostname: f.hostname, password: f.password,
        timezone: f.timezone, keyboard: f.keyboard, locale: f.locale, git_name: f.git_name, git_email: f.git_email,
        luks: !!f.luks, luks_passphrase: f.luks ? f.luks_passphrase : "", hub: [],
        disk: disk.path, disk_bytes: disk.size
    }
}

// One JSON line from the helper -> new progress state. Unknown or broken lines change nothing.
function reduce(state, line) {
    var ev
    try { ev = JSON.parse(line) } catch (e) { return state }
    if (!ev || typeof ev !== "object") return state
    var s = {
        pct: state.pct, stage: state.stage, detail: state.detail, eta: state.eta,
        message: state.message, done: state.done
    }
    if (ev.event === "progress") {
        if (typeof ev.pct === "number") s.pct = Math.max(state.pct, Math.min(100, ev.pct))
        if (ev.stage) s.stage = ev.stage
        s.detail = ev.detail !== undefined ? ev.detail : state.detail
        s.eta = ev.eta_min !== undefined ? ev.eta_min : state.eta
    } else if (ev.event === "error") {
        s.message = ev.message || state.message
    } else if (ev.event === "done") {
        s.pct = 100
        s.done = true
    }
    return s
}

function initialProgress() { return { pct: 0, stage: "Preparing the disk", detail: "", eta: null, message: "", done: false } }

// Four visible stages, in the order the backend reports them.
var STAGES = ["Preparing the disk", "Downloading Axiom", "Installing the system", "Setting up startup"]

function stageIndex(stage) {
    var i = STAGES.indexOf(stage)
    if (i >= 0) return i
    return /desktop|account|finishing/i.test(stage) ? 3 : 0
}

// Turn a raw failure line from the installer into one plain sentence the user can act on.
// The default returns the raw text; the helper's stderr is a better source than the generic
// "error 1" message when it is available.
function friendlyError(message) {
    // TODO(human): map the failures people actually hit to a plain sentence plus what to do next.
    // Seen so far: pacman's "Operation too slow" (slow link), "could not resolve host" / "failed
    // retrieving file" (no internet), "No space left on device" (disk full).
    return message || "Something went wrong."
}
