pragma Singleton

// SystemService — read-only system state for the panel and status menus.
// Phase 3 exposes the minimum functional surface: audio, network, Bluetooth,
// power. Unsupported backends report an explicit unavailable state instead of
// inventing values; surfaces hide or grey indicators that have no backend.

import Quickshell
import Quickshell.Io
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

    // --- power profile (power-profiles-daemon through UPower's PowerProfiles) ---
    // The singleton exists even without the daemon, so probe the bus name
    // (bus activation starts the daemon if it is installed).
    property bool profilesAvailable: false
    Process {
        id: profilesProbe
        running: true
        command: ["busctl", "--system", "--no-pager", "introspect", "org.freedesktop.UPower.PowerProfiles", "/org/freedesktop/UPower/PowerProfiles"]
        onExited: function (code) { system.profilesAvailable = code === 0 }
    }
    readonly property int powerProfile: PowerProfiles.profile
    readonly property bool hasPerformanceProfile: PowerProfiles.hasPerformanceProfile
    // Quickshell's own PowerProfiles.profile write is refused by the daemon
    // (AccessDenied, switch-profile) while the same write from a session process
    // succeeds, so set it with busctl (argv, no shell), like the other services.
    readonly property var profileNames: ({ [PowerProfile.PowerSaver]: "power-saver", [PowerProfile.Balanced]: "balanced", [PowerProfile.Performance]: "performance" })
    Process {
        id: profileSetter
        property string target: ""
        command: ["busctl", "--system", "--no-pager", "set-property", "org.freedesktop.UPower.PowerProfiles",
                  "/org/freedesktop/UPower/PowerProfiles", "org.freedesktop.UPower.PowerProfiles", "ActiveProfile", "s", target]
    }
    function setPowerProfile(p) {
        var name = system.profileNames[p]
        if (!name || profileSetter.running) return
        profileSetter.target = name
        profileSetter.running = true
    }

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

    // --- brightness (backlight class devices, through brightnessctl/logind) ---
    property int brightnessPercent: -1       // -1 = no controllable backlight
    readonly property bool brightnessAvailable: brightnessPercent >= 0
    function refreshBrightness() { brightnessProbe.running = false; brightnessProbe.running = true }
    function setBrightness(percent) {
        var p = Math.max(1, Math.min(100, Math.round(percent)))
        brightnessPercent = p
        Quickshell.execDetached(["brightnessctl", "-q", "set", p + "%"])
    }
    Process {
        id: brightnessProbe
        running: true
        command: ["brightnessctl", "-m", "-c", "backlight", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                // machine format: device,class,current,percent%,max
                var f = text.trim().split(",")
                system.brightnessPercent = f.length >= 5 ? parseInt(f[3]) : -1
            }
        }
        onExited: function (code) { if (code !== 0) system.brightnessPercent = -1 }
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
