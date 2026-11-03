import QtQuick
import qs.src.shared

// "Label  value" line in the detail pane; hidden when the value is empty.
Row {
    id: info

    property string label: ""
    property string value: ""
    property bool mono: false

    visible: value.length > 0
    width: parent ? parent.width : 0
    spacing: Theme.spacingMd

    Text {
        width: 104
        text: info.label
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
    }
    Text {
        width: parent.width - 104 - Theme.spacingMd
        text: info.value
        color: Theme.textPrimary
        font.family: info.mono ? Theme.fontFamilyMono : Theme.fontFamily
        font.pixelSize: info.mono ? Theme.fontCaption : Theme.fontBody
        wrapMode: Text.Wrap
    }
}
