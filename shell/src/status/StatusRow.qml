import QtQuick
import qs.src.shared

// One row of a status popup: a title, an optional second line, and room on the right for a value or a
// button (put it inside the row). `clickable` rows highlight on hover and emit `clicked`.
Rectangle {
    id: row

    property string title: ""
    property string subtitle: ""
    property bool clickable: false
    property bool current: false       // the connected / selected item: title in the accent colour
    default property alias trailing: right.data
    signal clicked()

    width: parent ? parent.width : 300
    height: subtitle.length > 0 ? 48 : 40
    radius: Theme.radiusControl
    color: clickable && mouse.containsMouse ? Theme.stateHover : "transparent"

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
            textFormat: Text.PlainText
            text: row.title
            color: row.current ? Theme.accent : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: row.current ? Font.DemiBold : Font.Normal
        }
        Text {
            visible: row.subtitle.length > 0
            width: parent.width
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: row.subtitle
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

    MouseArea {
        id: mouse
        anchors.fill: parent
        z: -1
        enabled: row.clickable
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.clicked()
    }
}
