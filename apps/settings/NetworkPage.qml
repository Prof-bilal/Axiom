import QtQuick
import Quickshell
import Quickshell.Networking
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Network"

    readonly property var devices: Networking.devices ? Networking.devices.values : []
    readonly property var wifiDevices: devices.filter(function (d) { return d.type === DeviceType.Wifi })
    readonly property var wiredDevices: devices.filter(function (d) { return d.type === DeviceType.Wired })
    // SSID awaiting a password, and the secured networks that need one.
    property string askingFor: ""

    function describe(n) {
        var parts = []
        var st = stateText(n)
        if (st) parts.push(st)
        if (secured(n)) parts.push("Secured")
        parts.push(Math.round(n.signalStrength * 100) + "%")
        return parts.join(" · ")
    }
    function secured(n) { return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe }
    function stateText(n) {
        return n.state === ConnectionState.Connected ? "Connected"
             : n.state === ConnectionState.Connecting ? "Connecting…" : (n.known ? "Saved" : "")
    }

    Notice {
        visible: !SystemService.networkAvailable
        warning: true
        text: "The network service (NetworkManager) is not running, so network state and controls are unavailable."
    }

    SettingsCard {
        title: "Wi-Fi"
        visible: SystemService.networkAvailable
        SettingRow {
            first: true
            label: "Wi-Fi"
            description: page.wifiDevices.length === 0 ? "No Wi-Fi adapter detected." : (Networking.wifiHardwareEnabled ? "" : "Turned off by a hardware switch.")
            SwitchControl {
                accessibleName: "Wi-Fi"
                checked: Networking.wifiEnabled
                enabled: page.wifiDevices.length > 0 && Networking.wifiHardwareEnabled
                onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
            }
        }
    }

    Repeater {
        model: Networking.wifiEnabled ? page.wifiDevices : []
        delegate: SettingsCard {
            id: wifiCard
            required property var modelData
            title: "Networks · " + modelData.name
            Component.onCompleted: modelData.scannerEnabled = true
            Component.onDestruction: modelData.scannerEnabled = false

            SettingRow {
                first: true
                visible: modelData.networks.values.length === 0
                label: "No networks found"
                description: "Scanning for nearby networks."
            }

            Repeater {
                model: modelData.networks.values
                delegate: Column {
                    id: net
                    required property var modelData
                    required property int index
                    width: parent.width
                    // A failed join (wrong password: NetworkManager keeps the saved
                    // profile) must let the user type the password again.
                    Connections {
                        target: net.modelData
                        function onConnectionFailed(reason) { page.askingFor = net.modelData.name }
                    }
                    SettingRow {
                        first: net.index === 0
                        label: net.modelData.name
                        description: page.describe(net.modelData)
                        AppButton {
                            visible: !net.modelData.connected && net.modelData.state !== ConnectionState.Connecting
                            text: "Connect"
                            primary: true
                            onClicked: {
                                if (page.secured(net.modelData) && !net.modelData.known) page.askingFor = net.modelData.name
                                else net.modelData.connect()
                            }
                        }
                        AppButton {
                            visible: net.modelData.connected
                            text: "Disconnect"
                            onClicked: net.modelData.disconnect()
                        }
                        AppButton {
                            visible: net.modelData.known && page.secured(net.modelData) && !net.modelData.connected
                            text: "Password…"
                            onClicked: page.askingFor = net.modelData.name
                        }
                        AppButton {
                            visible: net.modelData.known
                            text: "Forget"
                            destructive: true
                            onClicked: net.modelData.forget()
                        }
                    }
                    // Password prompt. The password goes straight to the network
                    // service and is cleared immediately; it is never logged.
                    Item {
                        visible: page.askingFor === net.modelData.name
                        width: parent.width
                        height: visible ? 52 : 0
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingLg
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingSm
                            Rectangle {
                                width: 300; height: 30; radius: Theme.radiusControl
                                color: Theme.surface; border.width: 1; border.color: Theme.border
                                TextInput {
                                    id: psk
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingSm
                                    echoMode: TextInput.Password
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontBody
                                    verticalAlignment: TextInput.AlignVCenter
                                    activeFocusOnPress: true
                                    Accessible.name: "Wi-Fi password"
                                    onVisibleChanged: if (visible) forceActiveFocus()
                                    Keys.onReturnPressed: submit.clicked()
                                }
                            }
                            AppButton {
                                id: submit
                                text: "Join"
                                primary: true
                                enabled: psk.text.length >= 8
                                onClicked: { net.modelData.connectWithPsk(psk.text); psk.text = ""; page.askingFor = "" }
                            }
                            AppButton { text: "Cancel"; onClicked: { psk.text = ""; page.askingFor = "" } }
                        }
                    }
                }
            }
        }
    }

    SettingsCard {
        title: "Wired"
        visible: SystemService.networkAvailable
        SettingRow {
            first: true
            visible: page.wiredDevices.length === 0
            label: "No wired adapter"
        }
        Repeater {
            model: page.wiredDevices
            delegate: SettingRow {
                required property var modelData
                required property int index
                first: index === 0
                label: modelData.name
                description: modelData.address
                value: modelData.connected ? "Connected" : (modelData.hasLink ? "Link up" : "No cable")
            }
        }
    }
}
