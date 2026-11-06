import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Keyboard"

    property string pickFor: "primary"
    signal pickApplication(real x, real y, var items, var onPick)

    function name(code) {
        var l = KeyboardService.layouts.filter(function (x) { return x.code === code })[0]
        return l ? l.name + " (" + code + ")" : code
    }
    function choose(which, x, y) {
        var items = KeyboardService.layouts.map(function (l) { return { text: l.name + " (" + l.code + ")", action: l.code } })
        pickApplication(x, y, items, function (code) {
            if (which === "primary") KeyboardService.setLayouts(code, KeyboardService.secondary === code ? "" : KeyboardService.secondary)
            else KeyboardService.setLayouts(KeyboardService.primary, code === KeyboardService.primary ? "" : code)
        })
    }

    Notice {
        visible: KeyboardService.layouts.length === 0
        warning: true
        text: "The keyboard layout database (xkeyboard-config) was not found, so layouts cannot be listed."
    }
    Notice {
        visible: KeyboardService.pendingRestart
        text: "The new layout applies the next time you log in. The compositor reads it only when it starts."
    }

    SettingsCard {
        title: "Layouts"
        SettingRow {
            first: true
            label: "Layout"
            description: "Active now: " + KeyboardService.active
            AppButton { text: page.name(KeyboardService.primary); onClicked: { var p = mapToItem(null, 0, height); page.choose("primary", p.x, p.y) } }
        }
        SettingRow {
            label: "Second layout"
            description: KeyboardService.secondary ? "Switch between the two with Alt+Shift." : "Optional."
            AppButton { text: KeyboardService.secondary ? page.name(KeyboardService.secondary) : "None"; onClicked: { var p = mapToItem(null, 0, height); page.choose("secondary", p.x, p.y) } }
            AppButton { visible: KeyboardService.secondary.length > 0; text: "Remove"; destructive: true; onClicked: KeyboardService.setLayouts(KeyboardService.primary, "") }
        }
    }

    SettingsCard {
        title: "Shortcuts"
        SettingRow { first: true; label: "Terminal"; value: "Super + Enter" }
        SettingRow { label: "Axiom menu"; value: "Super + A" }
        SettingRow { label: "Maximise window"; value: "Super + M" }
        SettingRow { label: "Switch layout"; value: KeyboardService.secondary ? "Alt + Shift" : "Needs a second layout" }
    }
}
