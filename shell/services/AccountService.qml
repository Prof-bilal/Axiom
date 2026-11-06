pragma Singleton

// AccountService — read-only list of local login accounts from the system
// user database (getent). Creating, removing or changing accounts needs a
// polkit-gated privileged helper that does not exist yet (Phase 6); the UI
// says so instead of offering a control that cannot work.

import QtQuick
import Quickshell
import qs.apps.shared

Singleton {
    id: accounts

    property var users: []       // [{name, uid, fullName, home, shell, current}]
    property string current: Quickshell.env("USER") || ""

    CommandRunner { id: runner }

    function refresh() {
        runner.runC(["getent", "passwd"], function (r) {
            if (r.code !== 0) { accounts.users = []; return }
            accounts.users = accounts.parse(r.out, accounts.current)
        })
    }

    // Login accounts: uid >= 1000 (or the current user) with a real shell.
    function parse(text, current) {
        var out = []
        text.split("\n").forEach(function (line) {
            var f = line.split(":")
            if (f.length < 7) return
            var uid = parseInt(f[2])
            var shell = f[6]
            var login = shell.length > 0 && !/(nologin|false)$/.test(shell)
            if (f[0] === "nobody") return
            if (!(uid >= 1000 || f[0] === current) || !login) return
            out.push({ name: f[0], uid: uid, fullName: (f[4] || "").split(",")[0], home: f[5], shell: shell, current: f[0] === current })
        })
        return out
    }

}
