pragma Singleton

// PowerService — session/power actions through systemd + logind.
// This is a service boundary: UI surfaces call these functions; they never
// build system commands. Requests require the caller to be the active local
// session user; authorization is enforced by polkit/logind, not by the shell.

import Quickshell

Singleton {
    id: power

    readonly property string backend: "systemd-logind"

    function logout() {
        var sid = Quickshell.env("XDG_SESSION_ID")
        if (sid && sid.length > 0) {
            Quickshell.execDetached(["loginctl", "terminate-session", sid])
        } else {
            // Fallback: end the compositor process for the current session.
            Quickshell.execDetached(["loginctl", "terminate-user", Quickshell.env("USER") || ""])
        }
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"])
    }

    function powerOff() {
        Quickshell.execDetached(["systemctl", "poweroff"])
    }

    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"])
    }
}
