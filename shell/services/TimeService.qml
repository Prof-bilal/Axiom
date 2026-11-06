pragma Singleton

// TimeService — time zone and network time through systemd-timedated
// (timedatectl). Changes are polkit-gated (org.freedesktop.timedate1.*); the
// shell never touches /etc/localtime.

import QtQuick
import Quickshell
import qs.apps.shared

Singleton {
    id: time

    property string timezone: ""
    property bool ntp: false
    property bool ntpAvailable: false
    property bool clockSynced: false
    property var zones: []
    property string error: ""

    CommandRunner { id: runner }

    function refresh() {
        runner.runC(["timedatectl", "show"], function (r) {
            if (r.code !== 0) { time.error = "Time service unavailable"; return }
            var v = {}
            r.out.split("\n").forEach(function (l) { var i = l.indexOf("="); if (i > 0) v[l.substring(0, i)] = l.substring(i + 1) })
            time.timezone = v.Timezone || ""
            time.ntp = v.NTP === "yes"
            time.ntpAvailable = v.CanNTP === "yes"
            time.clockSynced = v.NTPSynchronized === "yes"
            time.error = ""
        })
    }

    function loadZones() {
        if (zones.length > 0) return
        runner.runC(["timedatectl", "list-timezones"], function (r) {
            if (r.code === 0) time.zones = r.out.split("\n").filter(function (z) { return z.length > 0 })
        })
    }

    function setTimezone(zone) {
        // Only a zone timedatectl itself listed may be applied.
        if (zones.indexOf(zone) < 0) { error = "Unknown time zone"; return }
        runner.runC(["timedatectl", "set-timezone", zone], function (r) {
            time.error = r.code === 0 ? "" : (r.err || "Not permitted").trim().split("\n")[0]
            time.refresh()
        })
    }

    function setNtp(on) {
        runner.runC(["timedatectl", "set-ntp", on ? "true" : "false"], function (r) {
            time.error = r.code === 0 ? "" : (r.err || "Not permitted").trim().split("\n")[0]
            time.refresh()
        })
    }

}
