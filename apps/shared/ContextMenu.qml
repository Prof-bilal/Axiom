import QtQuick
import qs.src.shared

// Context menu inside the app window. `items`: [{ text, action, enabled,
// destructive, separator }]; `action` is the id sent with triggered().
Item {
    id: menu

    property var items: []
    property bool open: false

    signal triggered(string action)

    anchors.fill: parent
    visible: open
    z: 90

    function show(x, y, list) {
        items = list
        card.x = Math.max(4, Math.min(x, menu.width - card.width - 4))
        card.y = Math.max(4, Math.min(y, menu.height - card.height - 4))
        open = true
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: menu.open = false
    }

    Rectangle {
        id: card
        width: 230
        // Never taller than the window: long menus (a list of applications)
        // scroll instead of running off the bottom.
        height: Math.min(col.implicitHeight + Theme.spacingSm * 2, menu.height - 16)
        radius: Theme.radiusOverlay
        color: Theme.overlayBackground
        border.width: 1
        border.color: Theme.overlayBorder
        clip: true

        Flickable {
            anchors.fill: parent
            anchors.margins: Theme.spacingSm
            contentWidth: width
            contentHeight: col.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: col
                width: parent.width
                spacing: 1

                Repeater {
                    model: menu.items
                    delegate: Item {
                        required property var modelData
                        width: col.width
                        height: modelData.separator ? 9 : 30

                        Rectangle {
                            visible: modelData.separator === true
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 1
                            color: Theme.borderSubtle
                        }

                        Rectangle {
                            visible: !modelData.separator
                            anchors.fill: parent
                            radius: Theme.radiusControl
                            color: hit.containsMouse && modelData.enabled !== false ? Theme.stateHover : "transparent"

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacingMd
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.spacingMd
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.text || ""
                                elide: Text.ElideRight
                                color: modelData.enabled === false ? Theme.stateDisabled
                                     : modelData.destructive ? Theme.orangeBright : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontBody
                            }

                            MouseArea {
                                id: hit
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: modelData.enabled !== false
                                onClicked: { menu.open = false; menu.triggered(modelData.action) }
                            }
                        }
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: menu.open = false
}
