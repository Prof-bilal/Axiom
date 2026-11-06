import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Date & time"

    signal pickApplication(real x, real y, var items, var onPick)

    Component.onCompleted: { TimeService.refresh(); TimeService.loadZones() }

    Notice { visible: TimeService.error.length > 0; warning: true; text: TimeService.error }

    SettingsCard {
        SettingRow {
            first: true
            label: "Set time automatically"
            description: TimeService.ntpAvailable ? (TimeService.clockSynced ? "Clock is synchronised." : "Not synchronised yet; needs a network connection.") : "No time synchronisation service is installed."
            SwitchControl {
                accessibleName: "Set time automatically"
                checked: TimeService.ntp
                enabled: TimeService.ntpAvailable
                onToggled: TimeService.setNtp(!TimeService.ntp)
            }
        }
        SettingRow {
            label: "Time zone"
            AppButton {
                text: TimeService.timezone || "Unknown"
                enabled: TimeService.zones.length > 0
                onClicked: {
                    var p = mapToItem(null, 0, height)
                    page.pickApplication(p.x, p.y, TimeService.zones.map(function (z) { return { text: z, action: z } }), function (z) { TimeService.setTimezone(z) })
                }
            }
        }
        SettingRow { label: "Local time"; value: Qt.formatDateTime(clock.date, "ddd d MMM yyyy, hh:mm") }
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }
}
