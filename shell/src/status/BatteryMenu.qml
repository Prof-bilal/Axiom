import QtQuick
import Quickshell.Services.UPower
import qs.src.shared
import qs.services
import qs.apps.shared

// Power popup: the charge, the power mode and the screen brightness. Orange at 20 % or less on battery.
MenuSurface {
    id: menu

    open: UiState.controlCenterOpen && UiState.controlCenterSource === "battery"
    anchorX: UiState.controlCenterAnchorX
    alignRight: true
    layerNamespace: "axiom-status-battery"
    cardWidth: 320

    readonly property var profiles: [
        { label: "Saver", value: PowerProfile.PowerSaver },
        { label: "Balanced", value: PowerProfile.Balanced },
        { label: "Performance", value: PowerProfile.Performance }
    ]

    StatusHeader {
        title: "Power"
        subtitle: SystemService.hasBattery
            ? (SystemService.onBattery ? "On battery" : "Charging") : "AC power, no battery detected"
    }

    StatusSlider {
        visible: SystemService.hasBattery
        caption: "Battery"
        enabledControl: false
        value: SystemService.batteryPercent
        fillColor: SystemService.onBattery && SystemService.batteryPercent <= 20 ? Theme.danger : Theme.accent
    }

    MenuSeparator { visible: SystemService.profilesAvailable; caption: "Power mode" }

    Item {
        visible: SystemService.profilesAvailable
        width: parent.width
        height: 40
        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingXs
            Repeater {
                model: menu.profiles
                delegate: StatusButton {
                    required property var modelData
                    text: modelData.label
                    selected: SystemService.powerProfile === modelData.value
                    enabled: modelData.value !== PowerProfile.Performance || SystemService.hasPerformanceProfile
                    onClicked: SystemService.setPowerProfile(modelData.value)
                }
            }
        }
    }

    StatusRow {
        visible: !SystemService.profilesAvailable
        title: "Power modes unavailable"
        subtitle: "power-profiles-daemon is not running."
    }

    MenuSeparator { visible: SystemService.brightnessAvailable; caption: "Display" }

    StatusSlider {
        visible: SystemService.brightnessAvailable
        caption: "Brightness"
        value: SystemService.brightnessPercent
        onMoved: function (v) { SystemService.setBrightness(v) }
    }

    StatusLink { text: "Power settings…" }
}
