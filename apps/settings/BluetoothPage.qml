import QtQuick
import Quickshell.Bluetooth
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Bluetooth"

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter && adapter.devices ? adapter.devices.values : []

    function stateText(d) {
        return d.pairing ? "Pairing…" : d.connected ? "Connected" : d.paired ? "Paired" : ""
    }

    Notice {
        visible: page.adapter === null
        warning: true
        text: "No Bluetooth adapter was found, or the Bluetooth service is not running. Nothing is shown here until BlueZ reports an adapter."
    }

    SettingsCard {
        visible: page.adapter !== null
        SettingRow {
            first: true
            label: "Bluetooth"
            description: page.adapter && page.adapter.state === BluetoothAdapterState.Blocked ? "Blocked (rfkill or hardware switch)." : (page.adapter ? page.adapter.name : "")
            SwitchControl {
                accessibleName: "Bluetooth"
                checked: page.adapter !== null && page.adapter.enabled
                enabled: page.adapter !== null && page.adapter.state !== BluetoothAdapterState.Blocked
                onToggled: page.adapter.enabled = !page.adapter.enabled
            }
        }
        SettingRow {
            visible: page.adapter !== null && page.adapter.enabled
            label: "Look for devices"
            description: "Scanning stops when you turn it off or leave this page."
            SwitchControl {
                accessibleName: "Scan for devices"
                checked: page.adapter !== null && page.adapter.discovering
                onToggled: page.adapter.discovering = !page.adapter.discovering
            }
        }
    }

    SettingsCard {
        title: "Devices"
        visible: page.adapter !== null && page.adapter.enabled
        SettingRow {
            first: true
            visible: page.devices.length === 0
            label: "No devices"
            description: "Turn on scanning to find nearby devices."
        }
        Repeater {
            model: page.devices
            delegate: SettingRow {
                id: dev
                required property var modelData
                required property int index
                first: index === 0
                label: modelData.name || modelData.address
                description: page.stateText(modelData) + (page.stateText(modelData) && modelData.batteryAvailable ? " · " : "") + (modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : "")
                AppButton { visible: !modelData.paired && !modelData.pairing; text: "Pair"; primary: true; onClicked: modelData.pair() }
                AppButton { visible: modelData.pairing; text: "Cancel"; onClicked: modelData.cancelPair() }
                AppButton { visible: modelData.paired && !modelData.connected; text: "Connect"; primary: true; onClicked: modelData.connect() }
                AppButton { visible: modelData.connected; text: "Disconnect"; onClicked: modelData.disconnect() }
                AppButton { visible: modelData.paired; text: "Forget"; destructive: true; onClicked: modelData.forget() }
            }
        }
    }

    Component.onDestruction: if (adapter) adapter.discovering = false
}
