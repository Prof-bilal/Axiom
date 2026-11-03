import QtQuick
import qs.src.shared

// Scrolling page with a title; content stacks in a column.
Flickable {
    id: page

    property string title: ""
    default property alias content: column.data

    contentWidth: width
    contentHeight: column.height + Theme.spacingXl * 2
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: column
        x: Theme.spacingXl
        y: Theme.spacingXl
        width: Math.min(page.width - Theme.spacingXl * 2, 760)
        spacing: Theme.spacingLg

        Text {
            width: parent.width
            text: page.title
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontDisplay + 2
            font.weight: Font.DemiBold
        }
    }
}
