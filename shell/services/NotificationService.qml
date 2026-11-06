pragma Singleton

// NotificationService — Axiom owns the notification presentation; this wraps
// a freedesktop.org Desktop Notifications server bound to the session bus.
// Untrusted notification content is rendered by the UI, never executed here.

import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: notifications

    readonly property string backend: "org.freedesktop.Notifications"
    readonly property var tracked: server.trackedNotifications
    readonly property int count: tracked ? tracked.values.length : 0
    readonly property bool hasCritical: {
        if (!tracked) return false
        var items = tracked.values
        for (var i = 0; i < items.length; i++) {
            if (items[i].urgency === NotificationUrgency.Critical) return true
        }
        return false
    }

    // Toasts: newest first, minus muted apps, and nothing at all under Do Not
    // Disturb except critical notifications. The history list uses `tracked`.
    readonly property var toastItems: {
        if (!tracked) return []
        var out = []
        var items = tracked.values
        for (var i = items.length - 1; i >= 0 && out.length < 4; i--) {
            var n = items[i]
            var critical = n.urgency === NotificationUrgency.Critical
            if (critical || (!SettingsService.dnd && SettingsService.mutedApps.indexOf(n.appName) < 0)) out.push(n)
        }
        return out
    }

    // Distinct application names currently in the history, for the mute list.
    readonly property var appNames: {
        var seen = {}
        if (tracked) tracked.values.forEach(function (n) { if (n.appName) seen[n.appName] = true })
        return Object.keys(seen).sort()
    }

    function dismiss(notification) {
        if (notification) notification.dismiss()
    }

    function invoke(action) {
        if (action) action.invoke()
    }

    function dismissAll() {
        if (!tracked) return
        var items = tracked.values.slice()
        for (var i = 0; i < items.length; i++) items[i].dismiss()
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        persistenceSupported: false

        // Quickshell only retains (and exposes through `trackedNotifications`)
        // notifications that are explicitly tracked. Without this nothing is
        // ever shown: no toast and no history entry.
        onNotification: function (notification) {
            notification.tracked = true
        }
    }
}
