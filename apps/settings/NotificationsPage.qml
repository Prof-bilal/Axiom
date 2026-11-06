import QtQuick
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Notifications"

    SettingsCard {
        SettingRow {
            first: true
            label: "Do Not Disturb"
            description: "Hides pop-ups. Critical notifications still show, and everything stays in the notification centre."
            SwitchControl { accessibleName: "Do Not Disturb"; checked: SettingsService.dnd; onToggled: SettingsService.setDnd(!SettingsService.dnd) }
        }
    }

    SettingsCard {
        title: "Applications"
        SettingRow {
            first: true
            visible: page.allApps.length === 0
            label: "No applications yet"
            description: "Applications appear here once they have sent a notification."
        }
        Repeater {
            model: page.allApps
            delegate: SettingRow {
                required property var modelData
                required property int index
                first: index === 0
                label: modelData
                description: "Mute pop-ups from this application."
                SwitchControl {
                    accessibleName: "Mute " + modelData
                    checked: SettingsService.mutedApps.indexOf(modelData) >= 0
                    onToggled: SettingsService.setAppMuted(modelData, !checked)
                }
            }
        }
    }

    SettingsCard {
        SettingRow {
            first: true
            label: "Notification history"
            description: NotificationService.count + " in the notification centre."
            AppButton { text: "Clear all"; destructive: true; enabled: NotificationService.count > 0; onClicked: NotificationService.dismissAll() }
        }
    }

    // Apps seen in the history plus those already muted, so a muted app can be unmuted.
    readonly property var allApps: {
        var set = {}
        NotificationService.appNames.forEach(function (n) { set[n] = true })
        SettingsService.mutedApps.forEach(function (n) { set[n] = true })
        return Object.keys(set).sort()
    }
}
