import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Displays"

    readonly property var scales: [1, 1.25, 1.5, 2]
    readonly property var rotations: [
        { label: "Normal", value: "normal" }, { label: "90°", value: "90" },
        { label: "180°", value: "180" }, { label: "270°", value: "270" }
    ]

    Component.onCompleted: DisplayService.refresh()

    // A pending change takes keyboard focus onto Keep, so Enter confirms it.
    Connections {
        target: DisplayService
        function onPendingChanged() { if (DisplayService.pending !== null) keepButton.forceActiveFocus() }
    }

    Notice {
        visible: !DisplayService.available
        warning: true
        text: "The compositor's output control is unavailable (" + DisplayService.error + "). The displays below cannot be changed."
    }
    Notice { visible: DisplayService.available && DisplayService.error.length > 0; warning: true; text: DisplayService.error }

    // Confirmation for the last change: it is undone automatically when the timer ends.
    Rectangle {
        visible: DisplayService.pending !== null
        width: parent.width
        height: 56
        radius: Theme.radiusSurface
        color: Theme.stateUrgentWash
        border.width: 1
        border.color: Theme.orangeMuted
        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingLg
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.orangeBright
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            text: DisplayService.pending ? "Keep these display settings? Reverting in " + DisplayService.pending.seconds + " s." : ""
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingLg
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingSm
            AppButton {
                id: keepButton
                text: "Keep"; primary: true
                onClicked: DisplayService.confirm()
                Keys.onReturnPressed: DisplayService.confirm()
            }
            AppButton { text: "Revert"; onClicked: DisplayService.revert() }
        }
    }

    Repeater {
        model: DisplayService.outputs
        delegate: SettingsCard {
            id: card
            required property var modelData
            title: modelData.name + (modelData.model ? " · " + modelData.model : "")
            readonly property bool busy: DisplayService.pending !== null

            SettingRow { first: true; label: "Resolution"; value: modelData.width + " × " + modelData.height + " @ " + modelData.refresh.toFixed(0) + " Hz" }
            SettingRow {
                label: "Change resolution"
                Flow {
                    spacing: Theme.spacingXs
                    Repeater {
                        model: card.modelData.modes.filter(function (m, i, all) {
                            // one entry per resolution: the highest refresh rate
                            for (var j = 0; j < all.length; j++) if (all[j].width === m.width && all[j].height === m.height && all[j].refresh > m.refresh) return false
                            return true
                        }).slice(0, 4)
                        delegate: AppButton {
                            required property var modelData
                            text: modelData.width + "×" + modelData.height
                            primary: modelData.current
                            enabled: !card.busy
                            onClicked: DisplayService.apply(card.modelData.name, { mode: modelData })
                        }
                    }
                }
            }
            SettingRow {
                label: "Scale"
                Row {
                    spacing: Theme.spacingXs
                    Repeater {
                        model: page.scales
                        delegate: AppButton {
                            required property var modelData
                            text: modelData + "×"
                            primary: Math.abs(card.modelData.scale - modelData) < 0.01
                            enabled: !card.busy
                            onClicked: DisplayService.apply(card.modelData.name, { scale: modelData })
                        }
                    }
                }
            }
            SettingRow {
                label: "Rotation"
                Row {
                    spacing: Theme.spacingXs
                    Repeater {
                        model: page.rotations
                        delegate: AppButton {
                            required property var modelData
                            text: modelData.label
                            primary: card.modelData.transform === modelData.value
                            enabled: !card.busy
                            onClicked: DisplayService.apply(card.modelData.name, { transform: modelData.value })
                        }
                    }
                }
            }
        }
    }
}
