import QtQuick
import Quickshell
import Quickshell.Io
import qs.apps.shared
import "installer.js" as Ins

// All installer state and every call to the system. The UI pages only read these properties and call
// next()/back(). Nothing here runs as root: the one root step is the pkexec helper (InstallRunner).
//
// AXIOM_INSTALLER_DIR / AXIOM_INSTALL_HELPER point a preview at the repo and at tests/installer/fake_backend.py
// so the whole flow can be looked at without touching a disk.
Item {
    id: be

    readonly property string libDir: Quickshell.env("AXIOM_INSTALLER_DIR") || "/usr/local/lib/axiom-installer"
    readonly property string helper: Quickshell.env("AXIOM_INSTALL_HELPER") || ""

    // AXIOM_INSTALLER_PAGE jumps to a page for screenshots; it changes nothing else.
    property int page: parseInt(Quickshell.env("AXIOM_INSTALLER_PAGE") || "0")
    property bool busy: false
    property string formError: ""

    property var form: ({
        fullname: "", username: "", hostname: "axiom", password: "", password2: "",
        timezone: "UTC", keyboard: "us", locale: "en_US", git_name: "", git_email: "",
        luks: false, luks_passphrase: ""
    })
    property string confirmText: ""
    property var tzGroups: ({ UTC: ["UTC"] })
    // Where each time zone is (tzdata zone.tab) and what country it is in, for the map pin.
    property var zoneTable: ({})
    readonly property var pin: zoneTable[form.timezone] || null
    readonly property string pinText: Ins.pinLabel(form.timezone, zoneTable)
    // The shared dropdown list, set by the app window (it draws above every page).
    property var popup: null
    property string region: "UTC"
    property string city: "UTC"

    property var disks: []
    property int diskIndex: 0
    property string disksError: ""
    readonly property var disk: disks.length > 0 ? disks[Math.min(diskIndex, disks.length - 1)] : null

    property bool online: false
    property bool probing: false

    property var progress: Ins.initialProgress()
    property bool installing: false
    property string failure: ""

    function set(key, value) {
        var f = {}
        for (var k in form) f[k] = form[k]
        f[key] = value
        form = f
    }

    function setZone(r, c) {
        region = r
        city = c
        set("timezone", Ins.tzName(r, c))
    }

    function applyZone(name) {
        var i = name.indexOf("/")
        var r = i < 0 ? name : name.slice(0, i)
        var c = i < 0 ? name : name.slice(i + 1)
        if (!tzGroups[r] || tzGroups[r].indexOf(c) < 0) {   // an unknown zone falls back to the first one
            r = Object.keys(tzGroups).sort()[0]
            c = tzGroups[r][0]
        }
        setZone(r, c)
    }

    CommandRunner { id: cmd }

    function load() {
        cmd.run(["timedatectl", "list-timezones"], function (r) {
            if (r.code === 0) tzGroups = Ins.tzGroups(r.out)
            applyZone(Quickshell.env("AXIOM_TZ") || "UTC")
        })
        cmd.run(["cat", "/usr/share/zoneinfo/iso3166.tab"], function (c) {
            cmd.run(["cat", "/usr/share/zoneinfo/zone.tab"], function (z) {
                if (z.code === 0) zoneTable = Ins.parseZoneTab(z.out, c.code === 0 ? Ins.parseCountries(c.out) : {})
            })
        })
        refreshDisks()
        probeOnline()
    }

    function refreshDisks() {
        disksError = ""
        cmd.run(["python3", libDir + "/axiom_install.py", "--list-disks"], function (r) {
            var res = null
            try { res = JSON.parse(r.out) } catch (e) { }
            if (res && res.ok) disks = res.disks
            else { disks = []; disksError = res && res.error ? res.error : "The disk list could not be read." }
        })
    }

    // pacman needs this exact host, so asking it is a truer test than "a cable is plugged in".
    function probeOnline() {
        if (probing) return
        probing = true
        cmd.run(["curl", "-fsI", "--max-time", "6", "https://geo.mirror.pkgbuild.com/core/os/x86_64/core.db"], function (r) {
            online = r.code === 0
            probing = false
        })
    }

    // The backend's own validator (installer/axiom_install.py --validate): one source of truth.
    Process {
        id: val
        property var cb: null
        property string payload: ""
        command: ["python3", be.libDir + "/axiom_install.py", "--validate"]
        stdinEnabled: true
        stdout: StdioCollector {
            onStreamFinished: {
                var res = { ok: false, error: "That could not be checked. Try again." }
                try { res = JSON.parse(text) } catch (e) { }
                var f = val.cb
                val.cb = null
                if (f) f(res)
            }
        }
        onStarted: write(val.payload + "\n")
    }

    function validate(obj, done) {
        if (val.running) return
        val.cb = done
        val.payload = JSON.stringify(obj)
        val.running = true
    }

    function check(obj, to) {
        busy = true
        validate(obj, function (r) {
            busy = false
            if (r.ok) go(to)
            else formError = r.error
        })
    }

    function go(p) {
        formError = ""
        page = p
        if (p === 1 || p === 5) probeOnline()
    }

    function next() {
        if (busy || installing) return
        formError = ""
        if (page <= 1) { go(page + 1); return }
        if (page === 2) { check(Ins.probe(form), 3); return }
        if (page === 3) {
            if (!disk) { formError = disksError || "No usable disk was found."; return }
            if (disk.size < Ins.MIN_DISK) { formError = "This disk is too small. Axiom needs at least 10 GB."; return }
            var p = Ins.probe(form)
            p.luks = !!form.luks
            p.luks_passphrase = form.luks ? form.luks_passphrase : ""
            check(p, 4)
            return
        }
        if (page === 4) {
            if (form.password !== form.password2) { formError = "The two passwords are different."; return }
            check(Ins.probe(form), 5)
            return
        }
        if (page === 5) startInstall()
    }

    function back() {
        if (busy || installing || page === 0 || page === 7) return
        go(page === 6 ? 5 : page - 1)
    }

    function startInstall() {
        if (confirmText !== "ERASE") { formError = "Type ERASE in capital letters to continue."; return }
        if (!online) { formError = "No internet. Go back and connect before installing."; return }
        if (!disk) { formError = "No usable disk was found."; return }
        var pl = Ins.payload(form, disk)
        busy = true
        validate(pl, function (r) {
            busy = false
            if (!r.ok) { formError = r.error; return }
            progress = Ins.initialProgress()
            failure = ""
            installing = true
            go(6)
            runner.start(JSON.stringify(pl))
        })
    }

    function restart() { cmd.run(["systemctl", "reboot"], function () { }) }

    InstallRunner {
        id: runner
        argv: be.helper.length > 0 ? [be.helper] : ["pkexec", "/usr/local/bin/axiom-install-run"]
        onLine: function (text) { be.progress = Ins.reduce(be.progress, text) }
        onFinished: function (code) {
            be.installing = false
            if (code === 0) be.go(7)
            else {
                var firstErr = runner.errText.split("\n")[0]
                be.failure = Ins.friendlyError(be.progress.message || firstErr || ("The installation stopped (error " + code + ")."))
            }
        }
    }
}
