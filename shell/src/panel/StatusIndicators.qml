import QtQuick
import qs.src.shared
import qs.services

// Right-side system status: network, Bluetooth, audio, battery. Monochrome
// Axiom icons; cyan only while the status menu is open or on hover. Each
// indicator reflects real state from SystemService. Indicators without a
// backend (no BlueZ adapter, no battery) are hidden, not faked.
Row {
    id: status
    spacing: Theme.spacingXxs

    PanelButton {
        anchors.verticalCenter: parent.verticalCenter
        icon: SystemService.networkIcon
        available: SystemService.networkAvailable
        accessibleName: SystemService.networkLabel
        selected: UiState.controlCenterOpen
        onClicked: UiState.toggleControlCenter()
    }

    PanelButton {
        anchors.verticalCenter: parent.verticalCenter
        visible: SystemService.bluetoothAvailable
        icon: "bluetooth"
        active: SystemService.bluetoothEnabled
        accessibleName: SystemService.bluetoothEnabled ? "Bluetooth on" : "Bluetooth off"
        selected: UiState.controlCenterOpen
        onClicked: UiState.toggleControlCenter()
    }

    PanelButton {
        id: volume
        anchors.verticalCenter: parent.verticalCenter
        icon: SystemService.audioIcon
        available: SystemService.audioAvailable
        accessibleName: SystemService.audioAvailable
            ? "Volume " + SystemService.audioVolume + "%" + (SystemService.audioMuted ? ", muted" : "")
            : "Audio unavailable"
        selected: UiState.controlCenterOpen
        onClicked: UiState.toggleControlCenter()

        // Scroll to change the output level in 5% steps.
        WheelHandler {
            enabled: SystemService.audioAvailable
            onWheel: function (event) {
                var step = event.angleDelta.y > 0 ? 5 : -5
                SystemService.setVolume(SystemService.audioVolume + step)
            }
        }
    }

    PanelButton {
        anchors.verticalCenter: parent.verticalCenter
        visible: SystemService.hasBattery
        icon: SystemService.onBattery ? "battery" : "battery-charging"
        level: SystemService.batteryPercent / 100
        label: SystemService.batteryPercent + "%"
        badge: SystemService.onBattery && SystemService.batteryPercent >= 0
            && SystemService.batteryPercent <= 10
        badgeUrgent: true
        accessibleName: "Battery " + SystemService.batteryPercent + "%"
        selected: UiState.controlCenterOpen
        onClicked: UiState.toggleControlCenter()
    }
}
