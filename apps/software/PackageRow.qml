import QtQuick
import qs.src.shared

// One row in the Software list: icon, title, one-line description, and
// right-aligned facts (version, size).
Rectangle {
    id: row

    property string title: ""
    property string subtitle: ""
    property string facts: ""
    property string iconSource: ""
    property string glyph: "archive"
    property bool selected: false

    signal activated()

    height: 54
    radius: Theme.radiusControl
    color: selected ? Theme.stateSelected : (mouse.containsMouse ? Theme.stateHover : "transparent")

    Accessible.role: Accessible.ListItem
    Accessible.name: title + (subtitle.length > 0 ? ", " + subtitle : "")
    Accessible.selected: selected

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMd
        anchors.rightMargin: Theme.spacingMd
        spacing: Theme.spacingMd

        Item {
            width: 32
            height: parent.height

            AppIcon {
                anchors.centerIn: parent
                visible: row.iconSource.length > 0
                size: 32
                source: row.iconSource
            }
            AxiomIcon {
                anchors.centerIn: parent
                visible: row.iconSource.length === 0
                width: 24
                height: 24
                name: row.glyph
                color: Theme.textSecondary
                strokeWidth: 1.5
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 32 - factsText.width - Theme.spacingMd * 2
            spacing: 2

            Text {
                width: parent.width
                text: row.title
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                text: row.subtitle
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                elide: Text.ElideRight
            }
        }

        Text {
            id: factsText
            anchors.verticalCenter: parent.verticalCenter
            text: row.facts
            horizontalAlignment: Text.AlignRight
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            font.features: { "tnum": 1 }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.activated()
    }
}
