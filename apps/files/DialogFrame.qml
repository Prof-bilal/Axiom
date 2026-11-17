import QtQuick
import qs.src.shared

// Modal dialog inside the app window: dimmed backdrop, a solid rounded card,
// title and content. Escape or a click outside the card emits dismissed(); the
// owner closes it.
FocusScope {
    id: frame

    property bool open: false
    property string title: ""
    property int cardWidth: 420
    default property alias content: body.data

    signal dismissed()

    anchors.fill: parent
    visible: open
    z: 100

    Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.55) }
    MouseArea { anchors.fill: parent; onClicked: frame.dismissed() }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(frame.cardWidth, frame.width - 48)
        height: col.implicitHeight + 40
        radius: 16
        color: Theme.menuSurface
        border.width: 1
        border.color: Theme.menuBorder

        MouseArea { anchors.fill: parent }

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20
            spacing: 14

            Text {
                width: parent.width
                text: frame.title
                color: Theme.menuText
                font.family: Theme.fontFamily
                font.pixelSize: 17
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Column {
                id: body
                width: parent.width
                spacing: 14
            }
        }
    }

    Keys.onEscapePressed: frame.dismissed()
}
