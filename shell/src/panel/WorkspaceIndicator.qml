import QtQuick
import qs.src.shared
import qs.services

// Workspace switcher (panel centre): one rounded pill holding a chip per
// compositor workspace (ext-workspace via WorkspaceService). The current
// workspace is a cyan chip with a dark numeral; the others are quiet text on
// the pill and brighten on hover. A workspace with an urgent window gets an
// orange dot. Scroll over it to move between workspaces.
Rectangle {
    id: pill
    readonly property int chipHeight: Theme.workspaceButtonHeight - 6
    readonly property int chipWidth: chipHeight + 4

    width: row.implicitWidth + Theme.spacingXs * 2
    height: Theme.workspaceButtonHeight
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    radius: height / 2
    color: Theme.surface
    border.width: 1
    border.color: Theme.borderSubtle

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: WorkspaceService.list

            Item {
                id: chip
                required property var modelData
                readonly property bool active: modelData.active
                readonly property bool urgent: modelData.urgent

                width: Math.max(pill.chipWidth, label.implicitWidth + Theme.spacingMd)
                height: pill.chipHeight
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: chip.active ? Theme.accent
                         : mouse.containsMouse ? Theme.stateHover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }
                }

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: chip.modelData.name
                    color: chip.active ? Theme.background
                         : mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.weight: chip.active ? Font.DemiBold : Font.Normal
                }

                // Urgent window on a workspace that is not shown.
                Rectangle {
                    visible: chip.urgent && !chip.active
                    width: 5; height: 5; radius: 3
                    color: Theme.stateUrgent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                }

                Accessible.role: Accessible.Button
                Accessible.name: "Workspace " + chip.modelData.name + (chip.active ? ", current" : "")

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WorkspaceService.activate(chip.modelData)
                }
            }
        }
    }

    WheelHandler {
        onWheel: function (event) {
            if (event.angleDelta.y > 0) WorkspaceService.previous()
            else WorkspaceService.next()
        }
    }
}
