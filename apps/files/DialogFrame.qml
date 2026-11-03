import QtQuick
import qs.src.shared

// Modal dialog inside the app window: scrim, centred card, title, content.
// Escape or a click outside the card emits dismissed(); the owner closes it.
FocusScope {
    id: frame

    property bool open: false
    property string title: ""
    property int cardWidth: 440
    default property alias content: body.data

    signal dismissed()

    anchors.fill: parent
    visible: open
    z: 100

    Rectangle { anchors.fill: parent; color: Theme.scrim }
    MouseArea { anchors.fill: parent; onClicked: frame.dismissed() }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(frame.cardWidth, frame.width - 48)
        height: col.implicitHeight + Theme.spacingXl * 2
        radius: Theme.radiusOverlay
        color: Theme.overlayBackground
        border.width: 1
        border.color: Theme.overlayBorder

        MouseArea { anchors.fill: parent }

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingXl
            spacing: Theme.spacingMd

            Text {
                width: parent.width
                text: frame.title
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontTitle
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Column {
                id: body
                width: parent.width
                spacing: Theme.spacingMd
            }
        }
    }

    Keys.onEscapePressed: frame.dismissed()
}
