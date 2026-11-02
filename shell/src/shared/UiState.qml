pragma Singleton

// UiState — shared shell UI state (which overlays are open, search query).
// This is presentation state only; it never mirrors system state, which lives
// in the service singletons.

import Quickshell

Singleton {
    id: ui

    property bool launcherOpen: false
    property string launcherMode: "search"   // "search" (list) | "grid" (Apps)
    property bool sessionMenuOpen: false
    property bool notificationCenterOpen: false
    property bool controlCenterOpen: false
    property bool axiomMenuOpen: false
    property bool activitiesOpen: false
    property string launcherQuery: ""

    function closeAll(except) {
        if (except !== "launcher") launcherOpen = false
        if (except !== "session") sessionMenuOpen = false
        if (except !== "notifications") notificationCenterOpen = false
        if (except !== "control") controlCenterOpen = false
        if (except !== "axiom") axiomMenuOpen = false
        if (except !== "activities") activitiesOpen = false
    }

    // toggleLauncher("grid") opens the Apps grid; no argument / "search"
    // opens the search list. Requesting the other mode while open switches.
    function toggleLauncher(mode) {
        var m = mode === "grid" ? "grid" : "search"
        var next = !(launcherOpen && launcherMode === m)
        closeAll("launcher")
        launcherMode = m
        launcherOpen = next
        if (next) launcherQuery = ""
    }

    function toggleSessionMenu() {
        var next = !sessionMenuOpen
        closeAll("session")
        sessionMenuOpen = next
    }

    function toggleNotificationCenter() {
        var next = !notificationCenterOpen
        closeAll("notifications")
        notificationCenterOpen = next
    }

    function toggleControlCenter() {
        var next = !controlCenterOpen
        closeAll("control")
        controlCenterOpen = next
    }

    function toggleAxiomMenu() {
        var next = !axiomMenuOpen
        closeAll("axiom")
        axiomMenuOpen = next
    }

    function toggleActivities() {
        var next = !activitiesOpen
        closeAll("activities")
        activitiesOpen = next
    }

    function closeAllOverlays() {
        closeAll("")
    }
}
