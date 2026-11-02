pragma Singleton

// HostService — read-only identity of the running system for "About Axiom".
// Every value is read from the system (os-release, /proc); nothing is
// hardcoded. Call refresh() before display; uptime is not polled.

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: host

    readonly property string osName: field(osRelease.text(), "PRETTY_NAME")
        || field(osRelease.text(), "NAME") || "Unknown"
    readonly property string kernel: (kernelFile.text() || "").trim()
    readonly property string hostname: (hostnameFile.text() || "").trim()
    property string uptime: ""

    function field(text, key) {
        var lines = (text || "").split("\n")
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].indexOf(key + "=") === 0) {
                return lines[i].substring(key.length + 1).replace(/^"|"$/g, "")
            }
        }
        return ""
    }

    function formatUptime(seconds) {
        var s = Math.floor(seconds)
        var d = Math.floor(s / 86400)
        var h = Math.floor((s % 86400) / 3600)
        var m = Math.floor((s % 3600) / 60)
        if (d > 0) return d + "d " + h + "h " + m + "m"
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }

    function refresh() {
        uptimeFile.reload()
        var t = (uptimeFile.text() || "").trim().split(" ")[0]
        uptime = t.length > 0 ? formatUptime(parseFloat(t)) : ""
    }

    FileView { id: osRelease; path: "/etc/os-release"; blockLoading: true }
    FileView { id: kernelFile; path: "/proc/sys/kernel/osrelease"; blockLoading: true }
    FileView { id: hostnameFile; path: "/proc/sys/kernel/hostname"; blockLoading: true }
    FileView { id: uptimeFile; path: "/proc/uptime"; blockLoading: true }
}
