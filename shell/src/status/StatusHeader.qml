import QtQuick
import qs.src.shared

// Title of a status popup, with an on/off switch (or other control) on the right.
Item {
    id: head

    property string title: ""
    property string subtitle: ""
    default property alias trailing: right.data

    width: parent ? parent.width : 300
    height: 52

    Column {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingSm
        anchors.right: right.left
        anchors.rightMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1
        Text {
            width: parent.width
            elide: Text.ElideRight
            text: head.title
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontTitle
            font.weight: Font.DemiBold
        }
        Text {
            visible: head.subtitle.length > 0
            width: parent.width
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: head.subtitle
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
        }
    }
    Row {
        id: right
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXs
    }
}
