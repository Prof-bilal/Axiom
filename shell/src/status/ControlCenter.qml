import QtQuick
import Quickshell.Services.Pipewire
import qs.src.shared
import qs.services

// Axiom control centre (reference style): large toggle tiles for Wi-Fi and
// Bluetooth, then brightness and volume sliders, then network and battery.
// Every control is backed by a real service: SystemService (radios, airplane
// mode, brightness, volume), SettingsService (Do Not Disturb) and MediaService
// (MPRIS). The media card only shows while a player is running.
MenuSurface {
    id: menu

    open: UiState.controlCenterOpen
    alignRight: true
    layerNamespace: "axiom-control-center"
    cardWidth: 320

    // --- toggle tiles ---
    Item {
        width: parent.width
        height: 64

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingSm

            Tile {
                visible: SystemService.networkAvailable
                width: (parent.width - Theme.spacingSm) / 2
                label: "Wi-Fi"
                icon: "network-wireless"
                active: SystemService.wifiEnabled
                onActivated: SystemService.setWifi(!SystemService.wifiEnabled)
            }
            Tile {
                visible: SystemService.bluetoothAvailable
                width: (parent.width - Theme.spacingSm) / 2
                label: "Bluetooth"
                icon: "bluetooth"
                active: SystemService.bluetoothEnabled
                onActivated: SystemService.setBluetooth(!SystemService.bluetoothEnabled)
            }
        }
    }

    Item {
        width: parent.width
        height: 64

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingSm

            Tile {
                width: (parent.width - Theme.spacingSm) / 2
                label: "Airplane Mode"
                icon: "network-offline"
                active: SystemService.airplane
                onActivated: SystemService.setAirplane(!SystemService.airplane)
            }
            Tile {
                width: (parent.width - Theme.spacingSm) / 2
                label: "Do Not Disturb"
                icon: "bell"
                active: SettingsService.dnd
                onActivated: SettingsService.setDnd(!SettingsService.dnd)
            }
        }
    }

    // --- brightness and volume: one solid card each ---
    Item {
        width: parent.width
        height: 88
        visible: SystemService.brightnessAvailable

        SliderCard {
            anchors.fill: parent
            anchors.margins: Theme.spacingSm
            caption: "Display Brightness"
            sun: true
            value: SystemService.brightnessPercent
            onMoved: function (v) { SystemService.setBrightness(v) }
        }
    }

    Item {
        width: parent.width
        height: 88

        SliderCard {
            anchors.fill: parent
            anchors.margins: Theme.spacingSm
            caption: SystemService.audioAvailable ? "Volume" : "Volume \u00b7 no audio device"
            sun: false
            leftIcon: SystemService.audioMuted ? "volume-muted" : "volume-low"
            rightIcon: "volume-high"
            enabledControl: SystemService.audioAvailable
            dim: SystemService.audioMuted || !SystemService.audioAvailable
            value: SystemService.audioAvailable ? SystemService.audioVolume : 0
            onMoved: function (v) { SystemService.setVolume(v) }
        }
    }

    // --- media card (only while an MPRIS player is running) ---
    Item {
        width: parent.width
        height: MediaService.available ? 84 : 0
        visible: MediaService.available

        Rectangle {
            anchors.fill: parent
            anchors.margins: Theme.spacingSm
            radius: 18
            color: Theme.cardFill
            border.width: 1
            border.color: Theme.borderSubtle

            Rectangle {
                id: art
                x: Theme.spacingSm
                anchors.verticalCenter: parent.verticalCenter
                width: 52; height: 52; radius: 12
                color: Theme.cyanMuted
                clip: true
                Image {
                    anchors.fill: parent
                    source: MediaService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: MediaService.artUrl.length > 0
                }
            }

            Column {
                anchors.left: art.right
                anchors.leftMargin: Theme.spacingSm
                anchors.right: controls.left
                anchors.rightMargin: Theme.spacingSm
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    text: MediaService.title.length > 0 ? MediaService.title : "Unknown track"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    text: MediaService.artist
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }
            }

            Row {
                id: controls
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingSm
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingXs

                Repeater {
                    model: [
                        { glyph: "\u25C0\u25C0", action: "previous" },
                        { glyph: MediaService.playing ? "\u275A\u275A" : "\u25B6", action: "toggle" },
                        { glyph: "\u25B6\u25B6", action: "next" }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        width: 28; height: 28; radius: 14
                        color: mediaHit.containsMouse ? Theme.stateHover : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: modelData.glyph
                            color: Theme.textPrimary
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: mediaHit
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MediaService[modelData.action]()
                        }
                    }
                }
            }
        }
    }

    MenuSeparator { caption: "Status" }

    Item {
        width: parent.width
        height: 34
        Text {
            x: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.spacingSm * 2
            elide: Text.ElideRight
            text: SystemService.networkLabel
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
    }

    // Battery: a card like brightness, showing the charge level (read only).
    // Orange at 20 % or less while on battery. Machines without a battery get a
    // plain line instead.
    Item {
        width: parent.width
        height: SystemService.hasBattery ? 88 : 34

        SliderCard {
            visible: SystemService.hasBattery
            anchors.fill: parent
            anchors.margins: Theme.spacingSm
            caption: "Battery \u00b7 " + SystemService.batteryPercent + "%"
                + (SystemService.onBattery ? " \u00b7 on battery" : " \u00b7 charging")
            leftIcon: "battery"
            rightIcon: "battery-charging"
            value: SystemService.batteryPercent
            enabledControl: false
            fillColor: SystemService.onBattery && SystemService.batteryPercent <= 20
                ? Theme.orange : Theme.cyan
        }

        Text {
            visible: !SystemService.hasBattery
            x: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            text: "AC power \u00b7 no battery detected"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
    }

    // A rounded toggle tile: active tiles are filled with the cyan accent.
    component Tile: Rectangle {
        id: tile
        property string label: ""
        property string icon: ""
        property bool active: false
        signal activated()

        height: 56
        radius: height / 2
        // On: bright cyan with dark icon and label (readable on the fill).
        color: active ? Theme.cyan : (tileMouse.containsMouse ? Theme.stateHover : Theme.cardFill)
        border.width: 1
        border.color: active ? Theme.cyanBright : Theme.borderSubtle

        AxiomIcon {
            x: Theme.spacingLg
            anchors.verticalCenter: parent.verticalCenter
            width: 22; height: 22
            name: tile.icon
            color: tile.active ? "#06181A" : Theme.textPrimary
        }
        Text {
            x: Theme.spacingLg + 30
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x - Theme.spacingMd
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            lineHeight: 0.95
            text: tile.label
            color: tile.active ? "#06181A" : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: Font.DemiBold
        }
        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.activated()
        }
    }

    // A card with a caption, a slider and an end mark on each side (a sun
    // pair for brightness, volume icons for sound), like the reference.
    component SliderCard: Rectangle {
        id: card
        property string caption: ""
        property bool sun: false
        property string leftIcon: ""
        property string rightIcon: ""
        property real value: 0
        property bool dim: false
        property bool enabledControl: true
        property color fillColor: Theme.cyan
        signal moved(int v)

        radius: 18
        color: Theme.cardFill
        border.width: 1
        border.color: Theme.borderSubtle

        Text {
            x: Theme.spacingMd
            y: Theme.spacingSm + 2
            text: card.caption
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: Font.Medium
        }

        // left end mark
        AxiomIcon {
            visible: !card.sun
            x: Theme.spacingMd
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacingMd + 1
            width: 14; height: 14
            name: card.leftIcon
            color: Theme.textPrimary
        }
        Rectangle {
            visible: card.sun
            x: Theme.spacingMd + 3
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacingMd + 4
            width: 7; height: 7; radius: 3.5
            color: "transparent"
            border.width: 1.5
            border.color: Theme.textPrimary
        }

        // right end mark
        AxiomIcon {
            visible: !card.sun
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingMd
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacingMd + 1
            width: 14; height: 14
            name: card.rightIcon
            color: Theme.textPrimary
        }
        Rectangle {
            visible: card.sun
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingMd
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacingMd + 1
            width: 14; height: 14; radius: 7
            color: "transparent"
            border.width: 1.5
            border.color: Theme.textPrimary
        }

        Rectangle {
            id: track
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingMd + 24
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingMd + 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacingMd
            height: 16
            radius: height / 2
            color: Theme.stateHover
            border.width: 1
            border.color: Theme.borderSubtle

            Rectangle {
                height: parent.height
                radius: height / 2
                width: Math.max(height, parent.width * Math.min(1, card.value / 100))
                color: card.dim ? Theme.textDisabled : card.fillColor
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                enabled: card.enabledControl
                cursorShape: Qt.PointingHandCursor
                function apply(mouse) {
                    card.moved(Math.max(0, Math.min(100, Math.round(100 * (mouse.x - 6) / track.width))))
                }
                onPressed: function (mouse) { apply(mouse) }
                onPositionChanged: function (mouse) { if (pressed) apply(mouse) }
            }
        }
    }
}
