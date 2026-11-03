import QtQuick
import qs.src.shared

// Column header cell; clickable when it has a sort key.
Item {
    id: cell

    property string label: ""
    property string key: ""
    property string sortKey: ""
    property bool ascending: true
    property bool sortable: key.length > 0
    property int align: Text.AlignLeft

    signal clicked()

    height: 30

    Text {
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: cell.align
        text: cell.label + (cell.sortKey === cell.key && cell.key.length > 0 ? (cell.ascending ? "  ▲" : "  ▼") : "")
        color: cell.sortKey === cell.key && cell.key.length > 0 ? Theme.cyanBright : Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        font.weight: Font.Medium
    }

    MouseArea {
        anchors.fill: parent
        enabled: cell.sortable
        cursorShape: Qt.PointingHandCursor
        onClicked: cell.clicked()
    }
}
