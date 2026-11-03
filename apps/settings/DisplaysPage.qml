import QtQuick
import Quickshell
import qs.src.shared

PageFrame {
    id: page
    title: "Displays"

    Text {
        width: parent.width
        wrapMode: Text.Wrap
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        text: "The outputs the compositor reports. Changing resolution, scale or layout arrives with the display service in a later phase."
    }

    Repeater {
        model: Quickshell.screens
        delegate: SettingsCard {
            required property var modelData
            title: modelData.name
            SettingRow { first: true; label: "Resolution"; value: modelData.width + " × " + modelData.height }
            SettingRow { label: "Scale"; value: modelData.devicePixelRatio.toFixed(2) + "×" }
            SettingRow { label: "Position"; value: modelData.x + ", " + modelData.y }
            SettingRow { label: "Model"; value: modelData.model && modelData.model.length > 0 ? modelData.model : "" }
        }
    }
}
