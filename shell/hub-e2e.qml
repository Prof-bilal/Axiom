// Test entry for tests/hub/e2e_hub_backend.py: drives the real HubBackend (search, installed, updates) with no window.
// Not shipped to users. It prints "E2E ..." lines that the runner checks.
//@ pragma AppId org.axiom.HubE2E

import QtQuick
import Quickshell
import qs.apps.hub

ShellRoot {
    id: root
    property int stage: 0
    property int ticks: 0

    HubBackend { id: be }

    function names(list) { return list.slice(0, 5).map(function (a) { return a.name }).join(",") }

    Timer {
        interval: 300; running: true; repeat: true
        onTriggered: {
            root.ticks++
            if (root.ticks > 400) { console.log("E2E TIMEOUT stage=" + root.stage); root.stage = 99 }
            switch (root.stage) {
            case 0:
                be.setQuery("firefox"); root.stage = 1; break
            case 1:
                if (!be.searching && be.query === "firefox") {
                    var ff = be.results.filter(function (a) { return a.name === "Firefox" })[0]
                    console.log("E2E SEARCH count=" + be.results.length + " error=[" + be.searchError + "] firefox=" +
                                (ff ? ff.sources.map(function (s) { return s.type + ":" + s.trust }).join("+") + " icon=" + ff.icon.length : "missing"))
                    be.setQuery("zzzzqqqqnothingxx"); root.stage = 2
                }
                break
            case 2:
                if (!be.searching && be.query === "zzzzqqqqnothingxx") {
                    console.log("E2E EMPTY count=" + be.results.length + " error=[" + be.searchError + "]")
                    be.setQuery("a; touch /tmp/axiom-e2e-pwned $(id) \"q\""); root.stage = 3
                }
                break
            case 3:
                if (!be.searching && be.query.indexOf("touch") >= 0) {
                    console.log("E2E EVIL count=" + be.results.length + " error=[" + be.searchError + "]")
                    be.setQuery(""); be.refreshInstalled(); root.stage = 4
                }
                break
            case 4:
                if (be.installedApps.length > 0) {
                    console.log("E2E INSTALLED count=" + be.installedApps.length + " names=" + root.names(be.installedApps))
                    be.checkUpdates(); root.stage = 5
                }
                break
            case 5:
                if (be.status.indexOf("Checking") < 0) {
                    console.log("E2E UPDATES count=" + be.updates.length + " status=[" + be.status + "]")
                    console.log("E2E DONE"); root.stage = 6
                }
                break
            case 99:
                console.log("E2E DONE"); root.stage = 6; break
            }
        }
    }
}
