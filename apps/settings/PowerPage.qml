import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Power"

    readonly property var profiles: [
        { label: "Power saver", value: PowerProfile.PowerSaver },
        { label: "Balanced", value: PowerProfile.Balanced },
        { label: "Performance", value: PowerProfile.Performance }
    ]
    readonly property var blankChoices: [0, 5, 10, 15, 30]

    Image {
        width: 96
        height: 96
        anchors.horizontalCenter: undefined
        source: Quickshell.shellPath("assets/mascots/sleeping.png")
        sourceSize.width: 192
        sourceSize.height: 192
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
    }

    SettingsCard {
        title: "Battery"
        SettingRow {
            first: true
            label: "Power source"
            value: SystemService.hasBattery ? (SystemService.onBattery ? "On battery" : "Charging") : "AC power"
        }
        SettingRow {
            label: "Battery"
            value: SystemService.hasBattery ? SystemService.batteryPercent + "%" : "No battery detected"
        }
    }

    SettingsCard {
        title: "Power mode"
        SettingRow {
            first: true
            visible: !SystemService.profilesAvailable
            label: "Power profiles unavailable"
            description: "The power-profiles-daemon service is not running."
        }
        SettingRow {
            visible: SystemService.profilesAvailable
            first: true
            label: "Profile"
            Row {
                spacing: Theme.spacingXs
                Repeater {
                    model: page.profiles
                    delegate: AppButton {
                        required property var modelData
                        text: modelData.label
                        primary: SystemService.powerProfile === modelData.value
                        enabled: modelData.value !== PowerProfile.Performance || SystemService.hasPerformanceProfile
                        onClicked: SystemService.setPowerProfile(modelData.value)
                    }
                }
            }
        }
    }

    SettingsCard {
        title: "Screen"
        SettingRow {
            first: true
            label: "Turn off screen when idle"
            description: "Any key or pointer movement wakes it."
            Row {
                spacing: Theme.spacingXs
                Repeater {
                    model: page.blankChoices
                    delegate: AppButton {
                        required property var modelData
                        text: modelData === 0 ? "Never" : modelData + " min"
                        primary: SettingsService.idleBlankMinutes === modelData
                        onClicked: SettingsService.setIdleBlankMinutes(modelData)
                    }
                }
            }
        }
        SettingRow {
            visible: SystemService.brightnessAvailable
            label: "Brightness"
            SliderControl {
                width: 180
                value: SystemService.brightnessPercent
                onMoved: function (p) { SystemService.setBrightness(p) }
            }
        }
        SettingRow {
            visible: !SystemService.brightnessAvailable
            label: "Brightness"
            value: "No controllable backlight"
        }
    }

    SettingsCard {
        title: "Session"
        SettingRow {
            first: true
            label: "Suspend"
            description: "Suspend is available from the session menu once the hardware reports support."
            AppButton { text: "Suspend now"; onClicked: PowerService.suspend() }
        }
    }
}
