import QtQuick
import qs.src.shared
import qs.services
import qs.apps.shared
import "settings.js" as St

PageFrame {
    id: page
    title: "Dock"

    // The dock page asks the window to show a menu of applications to add.
    signal pickApplication(real x, real y, var items, var onPick)

    readonly property var pins: SettingsService.dockPins

    function addable() {
        // Pins may use short ids ("foot") for entries whose real id is longer
        // ("org.xfce.mousepad"), so compare the resolved entries.
        var pinned = {}
        page.pins.forEach(function (id) {
            var e = ApplicationService.entryForAppId(id)
            pinned[e ? e.id : id] = true
        })
        var out = []
        ApplicationService.all.forEach(function (e) {
            if (e.noDisplay || pinned[e.id]) return
            out.push({ text: e.name, action: e.id })
        })
        out.sort(function (a, b) { return a.text.toLowerCase() < b.text.toLowerCase() ? -1 : 1 })
        return out
    }

    Text {
        width: parent.width
        wrapMode: Text.Wrap
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        text: "Pinned applications stay in the dock. Applications that are running but not pinned appear after them."
    }

    SettingsCard {
        title: "Pinned applications"

        Repeater {
            model: page.pins
            delegate: SettingRow {
                required property string modelData
                required property int index
                readonly property var entry: ApplicationService.entryForAppId(modelData)
                first: index === 0
                label: entry ? entry.name : modelData
                description: entry ? "" : "Not installed, so it is not shown in the dock"

                AppButton { text: "Up"; enabled: index > 0; onClicked: SettingsService.setDockPins(St.movePin(page.pins, index, -1)) }
                AppButton { text: "Down"; enabled: index < page.pins.length - 1; onClicked: SettingsService.setDockPins(St.movePin(page.pins, index, 1)) }
                AppButton { text: "Remove"; onClicked: SettingsService.setDockPins(St.removePin(page.pins, index)) }
            }
        }

        SettingRow {
            visible: page.pins.length === 0
            first: true
            label: "Nothing is pinned"
            description: "Add an application below."
        }
    }

    Row {
        spacing: Theme.spacingSm

        AppButton {
            id: addButton
            text: "Add application…"
            primary: true
            onClicked: {
                var p = addButton.mapToItem(null, 0, addButton.height + 4)
                page.pickApplication(p.x, p.y, page.addable(), function (id) { SettingsService.setDockPins(St.addPin(page.pins, id)) })
            }
        }
        AppButton {
            text: "Reset to defaults"
            enabled: SettingsService.dockCustom
            onClicked: SettingsService.resetDock()
        }
    }
}
