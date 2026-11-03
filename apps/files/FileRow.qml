import QtQuick
import qs.src.shared
import "files.js" as Files

// One row of the file list: icon, name, size, modified, kind. In the Trash the
// size/modified/kind columns show where the item came from instead.
Rectangle {
    id: row

    property var entry
    property bool selected: false
    property bool current: false
    property bool trash: false
    property bool showModified: true
    property bool showKind: true
    property real sizeWidth: 90
    property real modifiedWidth: 150
    property real kindWidth: 150

    signal pressedWith(int modifiers, int button, real x, real y)
    signal opened()

    height: 34
    radius: Theme.radiusControl
    color: selected ? Theme.stateSelected : (mouse.containsMouse ? Theme.stateHover : "transparent")
    border.width: current && !selected ? 1 : 0
    border.color: Theme.stateSelectedBorder

    Accessible.role: Accessible.ListItem
    Accessible.name: entry ? entry.name : ""
    Accessible.selected: selected

    readonly property bool dim: entry && entry.name.charAt(0) === "."

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMd
        anchors.rightMargin: Theme.spacingMd
        spacing: Theme.spacingMd

        AxiomIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            name: entry ? Files.iconName(entry) : "file"
            color: entry && entry.isDir ? Theme.cyan : (entry && entry.broken ? Theme.orange : Theme.textSecondary)
            strokeWidth: 1.5
            opacity: row.dim ? 0.6 : 1
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 20 - Theme.spacingMd
                   - (row.trash ? trashOrigin.width + Theme.spacingMd
                      : row.sizeWidth + (row.showModified ? row.modifiedWidth : 0)
                        + (row.showKind ? row.kindWidth : 0) + Theme.spacingMd * (1 + (row.showModified ? 1 : 0) + (row.showKind ? 1 : 0)))
            text: entry ? Files.displayName(entry.name) : ""
            maximumLineCount: 1
            color: row.dim ? Theme.textSecondary : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            elide: Text.ElideMiddle
        }

        Text {
            id: trashOrigin
            visible: row.trash
            anchors.verticalCenter: parent.verticalCenter
            width: 300
            text: entry && entry.origin ? entry.origin : ""
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            elide: Text.ElideMiddle
        }

        Text {
            visible: !row.trash
            anchors.verticalCenter: parent.verticalCenter
            width: row.sizeWidth
            horizontalAlignment: Text.AlignRight
            text: entry && !entry.isDir ? Files.humanSize(entry.size) : ""
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            font.features: { "tnum": 1 }
        }

        Text {
            visible: !row.trash && row.showModified
            anchors.verticalCenter: parent.verticalCenter
            width: row.modifiedWidth
            text: entry ? Files.formatDate(entry.mtime) : ""
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
        }

        Text {
            visible: !row.trash && row.showKind
            anchors.verticalCenter: parent.verticalCenter
            width: row.kindWidth
            text: entry ? Files.kindLabel(entry) : ""
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: function (m) {
            var p = mapToItem(null, m.x, m.y)
            row.pressedWith(m.modifiers, m.button, p.x, p.y)
        }
        onDoubleClicked: function (m) { if (m.button === Qt.LeftButton) row.opened() }
    }
}
