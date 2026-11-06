import QtQuick
import Quickshell.Services.Pipewire
import qs.src.shared
import qs.services

// Axiom status menu — compact menu opened from the panel's network, Bluetooth,
// volume and battery indicators. Each section is backed by a real service and
// states plainly when a backend is unavailable.
MenuSurface {
    id: menu

    open: UiState.controlCenterOpen
    alignRight: true
    layerNamespace: "axiom-control-center"
    cardWidth: 300

    // --- network ---
    MenuSeparator { caption: "Network" }

    Item {
        width: parent.width
        height: 34
        AxiomIcon {
            id: netIcon
            x: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            width: 18; height: 18
            name: SystemService.networkIcon
            color: SystemService.networkKind !== "none" ? Theme.cyan : Theme.textSecondary
        }
        Text {
            anchors.left: netIcon.right
            anchors.leftMargin: Theme.spacingSm + 2
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: SystemService.networkLabel
            elide: Text.ElideRight
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
    }

    ToggleRow {
        visible: SystemService.networkAvailable
        text: "Wi-Fi"
        icon: "network-wireless"
        checked: SystemService.wifiEnabled
        onToggled: SystemService.setWifi(!SystemService.wifiEnabled)
    }

    ToggleRow {
        visible: SystemService.bluetoothAvailable
        text: "Bluetooth"
        icon: "bluetooth"
        checked: SystemService.bluetoothEnabled
        onToggled: SystemService.setBluetooth(!SystemService.bluetoothEnabled)
    }

    // --- audio ---
    MenuSeparator { caption: "Sound" }

    Item {
        width: parent.width
        height: 38

        PanelButton {
            id: muteButton
            x: Theme.spacingXs
            anchors.verticalCenter: parent.verticalCenter
            icon: SystemService.audioIcon
            available: SystemService.audioAvailable
            active: !SystemService.audioMuted && SystemService.audioAvailable
            accessibleName: SystemService.audioMuted ? "Unmute" : "Mute"
            onClicked: SystemService.toggleMute()
        }

        Text {
            visible: !SystemService.audioAvailable
            anchors.left: muteButton.right
            anchors.leftMargin: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            text: Pipewire.ready ? "No audio device found" : "Audio service unavailable"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }

        // Pointer slider — no QtQuick.Controls dependency.
        Item {
            id: slider
            visible: SystemService.audioAvailable
            anchors.left: muteButton.right
            anchors.leftMargin: Theme.spacingSm
            anchors.right: pct.left
            anchors.rightMargin: Theme.spacingMd
            anchors.verticalCenter: parent.verticalCenter
            height: 20

            readonly property real frac: SystemService.audioVolume / 100

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 4
                radius: 2
                color: Theme.surfaceHover
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * Math.min(1, slider.frac)
                height: 4
                radius: 2
                color: SystemService.audioMuted ? Theme.textDisabled : Theme.cyan
            }
            Rectangle {
                x: Math.max(0, Math.min(parent.width - width, parent.width * slider.frac - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                width: 14; height: 14; radius: 7
                color: Theme.textPrimary
                border.width: 2
                border.color: SystemService.audioMuted ? Theme.textDisabled : Theme.cyan
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                function apply(mouse) {
                    SystemService.setVolume(Math.round(100 * (mouse.x - 6) / slider.width))
                }
                onPressed: function (mouse) { apply(mouse) }
                onPositionChanged: function (mouse) { if (pressed) apply(mouse) }
            }
        }

        Text {
            id: pct
            visible: SystemService.audioAvailable
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            horizontalAlignment: Text.AlignRight
            text: SystemService.audioMuted ? "Muted" : SystemService.audioVolume + "%"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            font.features: { "tnum": 1 }
        }
    }

    // --- power ---
    MenuSeparator { caption: "Power" }

    Item {
        width: parent.width
        height: 34
        AxiomIcon {
            id: batIcon
            x: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            width: 18; height: 18
            name: SystemService.hasBattery && SystemService.onBattery ? "battery" : "battery-charging"
            level: SystemService.batteryPercent / 100
            color: Theme.textSecondary
        }
        Text {
            anchors.left: batIcon.right
            anchors.leftMargin: Theme.spacingSm + 2
            anchors.verticalCenter: parent.verticalCenter
            text: SystemService.hasBattery
                ? ("Battery " + SystemService.batteryPercent + "%"
                    + (SystemService.onBattery ? " · on battery" : " · charging"))
                : "AC power · no battery detected"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
    }

    // Toggle row used for Wi-Fi / Bluetooth.
    component ToggleRow: MenuItem {
        id: toggle
        property bool checked: false
        signal toggled()
        onTriggered: toggled()

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            width: 30; height: 16; radius: 8
            color: toggle.checked ? Theme.cyanMuted : Theme.surfaceHover
            border.width: 1
            border.color: toggle.checked ? Theme.cyan : Theme.border
            Rectangle {
                width: 10; height: 10; radius: 5
                anchors.verticalCenter: parent.verticalCenter
                x: toggle.checked ? parent.width - width - 3 : 3
                color: toggle.checked ? Theme.textPrimary : Theme.textSecondary
                Behavior on x { NumberAnimation { duration: Theme.motionFeedback } }
            }
        }
    }
}
