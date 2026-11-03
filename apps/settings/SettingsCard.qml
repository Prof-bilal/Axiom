import QtQuick
import qs.src.shared

// Grouped settings on a raised surface, with an optional title above it.
Column {
    id: group

    property string title: ""
    default property alias content: card.data

    width: parent ? parent.width : 0
    spacing: Theme.spacingSm

    Text {
        visible: group.title.length > 0
        width: parent.width
        text: group.title
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        font.weight: Font.DemiBold
        leftPadding: Theme.spacingXs
    }

    Rectangle {
        width: parent.width
        height: card.height
        radius: Theme.radiusSurface
        color: Theme.surfaceElevated
        border.width: 1
        border.color: Theme.borderSubtle

        Column {
            id: card
            width: parent.width
            padding: 0
        }
    }
}
