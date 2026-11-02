pragma Singleton

// SystemService — read-only system state for the panel and status menus.
// Phase 3 exposes the minimum functional surface: audio, network, Bluetooth,
// power. Unsupported backends report an explicit unavailable state instead of
// inventing values; surfaces hide or grey indicators that have no backend.

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth

Singleton {
    id: system

    // --- audio ---
    readonly property bool audioAvailable: Pipewire.ready && sink !== null
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool audioMuted: sink && sink.audio ? sink.audio.muted : false
    readonly property int audioVolume: sink && sink.audio
        ? Math.round(sink.audio.volume * 100) : 0
    readonly property string audioIcon: !audioAvailable || audioMuted || audioVolume === 0
        ? "volume-muted" : (audioVolume > 50 ? "volume-high" : "volume-low")

    // Track the sink so volume/mute bindings stay live.
    PwObjectTracker { objects: system.sink ? [system.sink] : [] }

    function toggleMute() {
        if (sink && sink.audio) sink.audio.muted = !sink.audio.muted
    }

    function setVolume(percent) {
        if (sink && sink.audio) {
            sink.audio.volume = Math.max(0, Math.min(1, percent / 100))
        }
    }

    // --- power ---
    readonly property var powerDevice: UPower.displayDevice
    readonly property bool hasBattery: powerDevice ? powerDevice.isLaptopBattery : false
    readonly property bool onBattery: UPower.onBattery
    readonly property int batteryPercent: powerDevice
        ? Math.round(powerDevice.percentage * 100) : -1

    // --- network ---
    readonly property bool networkAvailable: Networking.backend !== NetworkBackendType.None
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property int connectivity: Networking.connectivity
    readonly property var networkDevices: Networking.devices ? Networking.devices.values : []
    // "wired" | "wifi" | "none" — the kind of the first connected device.
    readonly property string networkKind: {
        var devs = networkDevices
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].connected && devs[i].type === DeviceType.Wired) return "wired"
        }
        for (var j = 0; j < devs.length; j++) {
            if (devs[j].connected && devs[j].type === DeviceType.Wifi) return "wifi"
        }
        return "none"
    }
    readonly property string networkName: {
        var devs = networkDevices
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].connected) return devs[i].name
        }
        return ""
    }
    readonly property string networkIcon: networkKind === "wired" ? "network-wired"
        : networkKind === "wifi" ? "network-wireless" : "network-offline"
    readonly property string networkLabel: !networkAvailable ? "Network service unavailable"
        : networkKind === "wired" ? "Wired connection" + (networkName ? " · " + networkName : "")
        : networkKind === "wifi" ? "Wi-Fi connected" + (networkName ? " · " + networkName : "")
        : "Not connected"

    function setWifi(enabled) {
        Networking.wifiEnabled = enabled
    }

    // --- bluetooth ---
    // Shown only when BlueZ exposes an adapter; there is no fake indicator.
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothAvailable: bluetoothAdapter !== null
    readonly property bool bluetoothEnabled: bluetoothAvailable && bluetoothAdapter.enabled

    function setBluetooth(enabled) {
        if (bluetoothAdapter) bluetoothAdapter.enabled = enabled
    }
}
