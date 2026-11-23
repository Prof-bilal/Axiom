import QtQuick
import qs.src.shared
import qs.services
import qs.apps.shared

// Sound popup: output volume with a mute switch, the output device, and the media player when one is running.
MenuSurface {
    id: menu

    open: UiState.controlCenterOpen && UiState.controlCenterSource === "audio"
    anchorX: UiState.controlCenterAnchorX
    alignRight: true
    layerNamespace: "axiom-status-audio"
    cardWidth: 320

    readonly property string device: SystemService.sink
        ? (SystemService.sink.nickname || SystemService.sink.description || SystemService.sink.name || "") : ""

    StatusHeader {
        title: "Sound"
        subtitle: SystemService.audioAvailable ? menu.device : "No audio device"
        SwitchControl {
            visible: SystemService.audioAvailable
            accessibleName: "Sound on"
            checked: !SystemService.audioMuted
            onToggled: SystemService.toggleMute()
        }
    }

    StatusSlider {
        caption: SystemService.audioMuted ? "Volume · muted" : "Volume"
        enabledControl: SystemService.audioAvailable
        dim: SystemService.audioMuted || !SystemService.audioAvailable
        value: SystemService.audioAvailable ? SystemService.audioVolume : 0
        onMoved: function (v) { SystemService.setVolume(v) }
    }

    // Media card, only while an MPRIS player is running.
    Item {
        width: parent.width
        height: MediaService.available ? 76 : 0
        visible: MediaService.available

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: 16
            color: Theme.cardFill
            border.width: 1
            border.color: Theme.borderSubtle

            Rectangle {
                id: art
                x: Theme.spacingSm
                anchors.verticalCenter: parent.verticalCenter
                width: 48; height: 48; radius: 10
                color: Theme.accentMuted
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
                anchors.rightMargin: Theme.spacingXs
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
                spacing: 2
                Repeater {
                    model: [
                        { glyph: "◀◀", action: "previous" },
                        { glyph: MediaService.playing ? "❚❚" : "▶", action: "toggle" },
                        { glyph: "▶▶", action: "next" }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        width: 28; height: 28; radius: 14
                        color: mediaHit.containsMouse ? Theme.stateHover : "transparent"
                        Text { anchors.centerIn: parent; text: modelData.glyph; color: Theme.textPrimary; font.pixelSize: 11 }
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

    StatusLink { text: "Sound settings…" }
}
