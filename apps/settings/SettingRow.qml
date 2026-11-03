import QtQuick
import qs.src.shared

// One row in a card: a label (and optional description) on the left, the
// control on the right. Rows separate themselves with a hairline.
Item {
    id: row

    property string label: ""
    property string description: ""
    property string value: ""            // plain read-only value text
    property bool mono: false
    property bool first: false
    default property alias control: controlArea.data

    width: parent ? parent.width : 0
    height: Math.max(52, textColumn.height + Theme.spacingMd * 2)

    Rectangle {
        visible: !row.first
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.spacingLg
        height: 1
        color: Theme.borderSubtle
    }

    Column {
        id: textColumn
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingLg
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.5 - Theme.spacingLg
        spacing: 2

        Text {
            width: parent.width
            text: row.label
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            elide: Text.ElideRight
        }
        Text {
            visible: row.description.length > 0
            width: parent.width
            text: row.description
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            wrapMode: Text.Wrap
        }
    }

    Text {
        visible: row.value.length > 0
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingLg
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.5 - Theme.spacingLg
        horizontalAlignment: Text.AlignRight
        text: row.value
        color: Theme.textSecondary
        font.family: row.mono ? Theme.fontFamilyMono : Theme.fontFamily
        font.pixelSize: row.mono ? Theme.fontCaption : Theme.fontBody
        wrapMode: Text.Wrap
    }

    Row {
        id: controlArea
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingLg
        anchors.verticalCenter: parent.verticalCenter
        height: 30
        spacing: Theme.spacingSm
    }
}
