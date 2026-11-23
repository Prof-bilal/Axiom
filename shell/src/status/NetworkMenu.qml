import QtQuick
import Quickshell.Networking
import qs.src.shared
import qs.services
import qs.apps.shared

// Wi-Fi popup: the switch, what you are connected to, and the networks around you. Nothing else; volume,
// Bluetooth and power have their own popups. Airplane mode sits here because it is a radio switch too.
MenuSurface {
    id: menu

    open: UiState.controlCenterOpen && UiState.controlCenterSource === "network"
    anchorX: UiState.controlCenterAnchorX
    alignRight: true
    layerNamespace: "axiom-status-network"
    cardWidth: 340

    readonly property var wifiDevices: (Networking.devices ? Networking.devices.values : [])
        .filter(function (d) { return d.type === DeviceType.Wifi })
    // SSID that is waiting for a password.
    property string askingFor: ""
    function secured(n) { return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe }
    onOpenChanged: if (!open) askingFor = ""

    StatusHeader {
        title: "Wi-Fi"
        subtitle: SystemService.networkLabel
        SwitchControl {
            visible: SystemService.networkAvailable
            accessibleName: "Wi-Fi"
            checked: SystemService.wifiEnabled
            onToggled: SystemService.setWifi(!SystemService.wifiEnabled)
        }
    }

    StatusRow {
        visible: !SystemService.networkAvailable
        title: "Network service not running"
        subtitle: "NetworkManager is not available."
    }

    MenuSeparator { visible: SystemService.networkAvailable && SystemService.wifiEnabled; caption: "Networks" }

    StatusRow {
        visible: SystemService.networkAvailable && SystemService.wifiEnabled && menu.wifiDevices.length === 0
        title: "No Wi-Fi adapter"
        subtitle: "Use a cable, or plug in an adapter."
    }

    // The list scrolls after six rows so a crowded place does not make the popup taller than the screen.
    Flickable {
        id: scroller
        visible: SystemService.networkAvailable && SystemService.wifiEnabled && menu.wifiDevices.length > 0
        width: parent.width
        height: Math.min(netColumn.height, 280)
        contentHeight: netColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: netColumn
            width: scroller.width
            Repeater {
                model: SystemService.wifiEnabled ? menu.wifiDevices : []
                delegate: Column {
                    id: dev
                    required property var modelData
                    width: netColumn.width
                    // Look for networks only while the popup is open.
                    Binding { target: dev.modelData; property: "scannerEnabled"; value: menu.open }
                    StatusRow {
                        visible: dev.modelData.networks.values.length === 0
                        title: "Looking for networks…"
                    }
                    Repeater {
                        model: dev.modelData.networks.values
                        delegate: Column {
                            id: net
                            required property var modelData
                            width: dev.width
                            // A wrong password leaves the saved profile behind: ask again.
                            Connections {
                                target: net.modelData
                                function onConnectionFailed(reason) { menu.askingFor = net.modelData.name }
                            }
                            StatusRow {
                                clickable: !net.modelData.connected
                                current: net.modelData.connected
                                title: net.modelData.name
                                subtitle: (net.modelData.connected ? "Connected"
                                           : net.modelData.state === ConnectionState.Connecting ? "Connecting…"
                                           : net.modelData.known ? "Saved" : "")
                                          + (menu.secured(net.modelData) ? (net.modelData.known || net.modelData.connected ? " · " : "") + "Secured" : "")
                                          + " · " + Math.round(net.modelData.signalStrength * 100) + "%"
                                onClicked: {
                                    if (menu.secured(net.modelData) && !net.modelData.known) menu.askingFor = net.modelData.name
                                    else net.modelData.connect()
                                }
                                StatusButton {
                                    visible: net.modelData.connected
                                    text: "Disconnect"
                                    onClicked: net.modelData.disconnect()
                                }
                            }
                            // Password: goes straight to NetworkManager and is cleared at once, never logged.
                            Item {
                                visible: menu.askingFor === net.modelData.name
                                width: parent.width
                                height: visible ? 44 : 0
                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacingSm
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingXs
                                    Rectangle {
                                        width: 190; height: 30; radius: Theme.radiusControl
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
                                            Accessible.name: "Wi-Fi password"
                                            onVisibleChanged: if (visible) forceActiveFocus()
                                            Keys.onReturnPressed: join.clicked()
                                        }
                                    }
                                    StatusButton {
                                        id: join
                                        text: "Join"
                                        primary: true
                                        enabled: psk.text.length >= 8
                                        onClicked: { net.modelData.connectWithPsk(psk.text); psk.text = ""; menu.askingFor = "" }
                                    }
                                    StatusButton { text: "Cancel"; onClicked: { psk.text = ""; menu.askingFor = "" } }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    MenuSeparator { caption: "Radios" }

    StatusRow {
        title: "Airplane mode"
        subtitle: "Turns off Wi-Fi and Bluetooth"
        SwitchControl {
            accessibleName: "Airplane mode"
            checked: SystemService.airplane
            onToggled: SystemService.setAirplane(!SystemService.airplane)
        }
    }

    StatusLink { text: "Network settings…" }
}
