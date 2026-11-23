import QtQuick
import Quickshell
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

    // Rename in place: the name cell becomes an InlineName while `editing`.
    property bool editing: false
    property var existingNames: []

    signal pressedWith(int modifiers, int button, real x, real y)
    signal opened()
    signal renamed(string name)
    signal editCancelled()
    signal editRejected(string reason)

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

        Image {
            id: rowIcon
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22
            sourceSize: Qt.size(22, 22)
            source: entry ? Quickshell.iconPath(Files.themeIcon(entry), "text-x-generic") : ""
            opacity: row.dim ? 0.6 : 1
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Item {
            id: nameCell
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: parent.width - 20 - Theme.spacingMd
                   - (row.trash ? trashOrigin.width + Theme.spacingMd
                      : row.sizeWidth + (row.showModified ? row.modifiedWidth : 0)
                        + (row.showKind ? row.kindWidth : 0) + Theme.spacingMd * (1 + (row.showModified ? 1 : 0) + (row.showKind ? 1 : 0)))

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                visible: !row.editing
                text: entry ? Files.displayName(entry.name) : ""
                maximumLineCount: 1
                color: row.dim ? Theme.textSecondary : Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                elide: Text.ElideMiddle
            }
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                width: item ? item.width : 0
                active: row.editing
                sourceComponent: InlineName {
                    maxWidth: nameCell.width
                    original: row.entry.name
                    existing: row.existingNames
                    onCommitted: function (name) { row.renamed(name) }
                    onCancelled: row.editCancelled()
                    onRejected: function (reason) { row.editRejected(reason) }
                }
            }
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
        enabled: !row.editing   // clicks go to the text box while renaming
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: function (m) {
            var p = mapToItem(null, m.x, m.y)
            row.pressedWith(m.modifiers, m.button, p.x, p.y)
        }
        onDoubleClicked: function (m) { if (m.button === Qt.LeftButton) row.opened() }
    }
}
