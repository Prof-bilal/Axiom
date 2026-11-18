import QtQuick
import qs.src.shared

// Context menu (app windows and the desktop), in the macOS style: a rounded
// panel, compact rows, a full-width Axiom accent (cyan) on the hovered row, the
// shortcut on the right and a chevron for submenus. Destructive rows are orange.
// `items`: [{ text, action, enabled, destructive, separator, shortcut, submenu }];
// `action` is the id sent with triggered().
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
        card.x = Math.max(6, Math.min(x, menu.width - card.width - 6))
        card.y = Math.max(6, Math.min(y, menu.height - card.height - 6))
        open = true
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: menu.open = false
    }

    Rectangle {
        id: card
        width: 240
        // Never taller than the window: long menus scroll instead of running off the bottom.
        height: Math.min(col.implicitHeight + 8, menu.height - 16)
        radius: 10
        color: Theme.menuSurface
        border.width: 1
        border.color: Theme.menuBorder
        clip: true

        Flickable {
            anchors.fill: parent
            anchors.margins: 4
            contentWidth: width
            contentHeight: col.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: col
                width: parent.width
                spacing: 0

                Repeater {
                    model: menu.items
                    delegate: Item {
                        required property var modelData
                        width: col.width
                        height: modelData.separator ? 9 : 24

                        Rectangle {
                            visible: modelData.separator === true
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            height: 1
                            color: Theme.menuBorder
                        }

                        Rectangle {
                            id: row
                            visible: !modelData.separator
                            anchors.fill: parent
                            radius: 5
                            // Full-width accent on hover, like the macOS selection.
                            color: hit.containsMouse && modelData.enabled !== false
                                   ? (modelData.destructive ? Theme.orange : Theme.cyan) : "transparent"
                            Behavior on color { ColorAnimation { duration: 90 } }

                            readonly property bool lit: hit.containsMouse && modelData.enabled !== false

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.right: shortcutText.left
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.text || ""
                                elide: Text.ElideRight
                                color: row.lit ? "#06181A"
                                     : modelData.enabled === false ? Theme.menuTextDisabled
                                     : modelData.destructive ? Theme.orangeBright
                                     : Theme.menuText
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontBody
                            }

                            // Shortcut (right) or a submenu chevron.
                            Text {
                                id: shortcutText
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.submenu ? "\u203A" : (modelData.shortcut || "")
                                color: row.lit ? "#06181A" : Theme.menuTextDisabled
                                font.family: Theme.fontFamily
                                font.pixelSize: modelData.submenu ? Theme.fontBody + 2 : Theme.fontCaption
                            }

                            MouseArea {
                                id: hit
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: modelData.enabled !== false
                                cursorShape: Qt.PointingHandCursor
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
