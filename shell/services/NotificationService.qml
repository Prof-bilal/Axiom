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
    }
}
