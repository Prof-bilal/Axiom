import QtQuick
import Quickshell.Bluetooth
import qs.src.shared
import qs.services
import qs.apps.shared

// Bluetooth popup: the switch and your devices. Scanning runs only while the popup is open.
MenuSurface {
    id: menu

    open: UiState.controlCenterOpen && UiState.controlCenterSource === "bluetooth"
    anchorX: UiState.controlCenterAnchorX
    alignRight: true
    layerNamespace: "axiom-status-bluetooth"
    cardWidth: 340

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter && adapter.devices ? adapter.devices.values : []
    // Known devices first, then the ones that were just found.
    readonly property var sorted: devices.slice().sort(function (a, b) {
        var ka = a.connected ? 0 : a.paired ? 1 : 2, kb = b.connected ? 0 : b.paired ? 1 : 2
        return ka !== kb ? ka - kb : String(a.name || a.address).localeCompare(String(b.name || b.address))
    })
    function stateText(d) {
        var s = d.pairing ? "Pairing…" : d.connected ? "Connected" : d.paired ? "Paired" : "Available"
        return s + (d.batteryAvailable ? " · " + Math.round(d.battery * 100) + "%" : "")
    }

    Binding { target: menu.adapter; property: "discovering"; value: menu.open && menu.adapter !== null && menu.adapter.enabled; when: menu.adapter !== null }

    StatusHeader {
        title: "Bluetooth"
        subtitle: menu.adapter ? (menu.adapter.state === BluetoothAdapterState.Blocked ? "Blocked by rfkill" : menu.adapter.name) : "No adapter"
        SwitchControl {
            visible: menu.adapter !== null
            accessibleName: "Bluetooth"
            checked: SystemService.bluetoothEnabled
            enabled: menu.adapter !== null && menu.adapter.state !== BluetoothAdapterState.Blocked
            onToggled: SystemService.setBluetooth(!SystemService.bluetoothEnabled)
        }
    }

    StatusRow {
        visible: menu.adapter === null
        title: "No Bluetooth adapter"
        subtitle: "Nothing to show until BlueZ reports one."
    }

    MenuSeparator { visible: menu.adapter !== null && menu.adapter.enabled; caption: "Devices" }

    StatusRow {
        visible: menu.adapter !== null && menu.adapter.enabled && menu.devices.length === 0
        title: "Looking for devices…"
        subtitle: "Make sure the device is in pairing mode."
    }

    Flickable {
        visible: menu.adapter !== null && menu.adapter.enabled && menu.devices.length > 0
        width: parent.width
        height: Math.min(devColumn.height, 280)
        contentHeight: devColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: devColumn
            width: parent.width
            Repeater {
                model: menu.sorted
                delegate: StatusRow {
                    id: devRow
                    required property var modelData
                    width: devColumn.width
                    current: modelData.connected
                    title: modelData.name || modelData.address
                    subtitle: menu.stateText(modelData)
                    StatusButton { visible: !modelData.paired && !modelData.pairing; text: "Pair"; primary: true; onClicked: modelData.pair() }
                    StatusButton { visible: modelData.pairing; text: "Cancel"; onClicked: modelData.cancelPair() }
                    StatusButton { visible: modelData.paired && !modelData.connected; text: "Connect"; primary: true; onClicked: modelData.connect() }
                    StatusButton { visible: modelData.connected; text: "Disconnect"; onClicked: modelData.disconnect() }
                }
            }
        }
    }

    StatusLink { text: "Bluetooth settings…" }
}
