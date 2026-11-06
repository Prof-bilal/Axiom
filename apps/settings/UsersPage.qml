import QtQuick
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Users"

    Component.onCompleted: AccountService.refresh()

    Notice {
        text: "Axiom lists the accounts on this computer. Creating accounts, removing them and changing passwords need a privileged helper that checks who is asking and what they change; that arrives with the permission layer. Settings never runs as root."
    }

    SettingsCard {
        title: "Accounts"
        Repeater {
            model: AccountService.users
            delegate: SettingRow {
                required property var modelData
                required property int index
                first: index === 0
                label: (modelData.fullName || modelData.name) + (modelData.current ? " (you)" : "")
                description: modelData.name + " · " + modelData.home
                value: "uid " + modelData.uid
            }
        }
    }
}
