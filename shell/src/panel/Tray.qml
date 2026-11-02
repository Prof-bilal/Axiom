import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.src.shared

// System tray — StatusNotifierItem host. Icons come from real registered items.
RowLayout {
    id: tray
    spacing: Theme.spacingXs
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Item {
            required property var modelData
            implicitWidth: 18
            implicitHeight: 18

            Image {
                anchors.fill: parent
                source: modelData.icon
                sourceSize.width: 18
                sourceSize.height: 18
                smooth: true
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: function (mouse) {
                    if (mouse.button === Qt.LeftButton) modelData.activate()
                    else if (mouse.button === Qt.MiddleButton) modelData.secondaryActivate()
                    else modelData.display(parent, mouse.x, mouse.y)
                }
            }
        }
    }
}
