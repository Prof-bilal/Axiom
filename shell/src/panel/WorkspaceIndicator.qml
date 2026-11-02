import QtQuick
import qs.src.shared
import qs.services

// Workspace switcher (panel centre) — real compositor workspaces via
// WorkspaceService (ext-workspace). Active: solid Axiom cyan tile with dark
// numeral. Others: dark graphite tiles. Urgent: orange numeral and border.
Row {
    id: indicator
    spacing: Theme.spacingXs + 2

    Repeater {
        model: WorkspaceService.list

        Rectangle {
            id: chip
            required property var modelData
            readonly property bool active: modelData.active
            readonly property bool urgent: modelData.urgent

            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(Theme.workspaceButtonWidth, label.implicitWidth + Theme.spacingMd)
            height: Theme.workspaceButtonHeight
            radius: Theme.radiusControl
            color: active ? Theme.cyan
                 : mouse.containsMouse ? Theme.surfaceHover : Theme.surfaceElevated
            border.width: urgent && !active ? 1 : 0
            border.color: Theme.stateUrgent
            Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }

            Accessible.role: Accessible.Button
            Accessible.name: "Workspace " + modelData.name + (active ? ", current" : "")

            Text {
                id: label
                anchors.centerIn: parent
                text: chip.modelData.name
                color: chip.active ? Theme.background
                     : chip.urgent ? Theme.stateUrgent : Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: chip.active ? Font.Bold : Font.DemiBold
                font.features: { "tnum": 1 }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: WorkspaceService.activate(chip.modelData)
            }
        }
    }

    // Scroll over the switcher to move between workspaces.
    WheelHandler {
        onWheel: function (event) {
            if (event.angleDelta.y > 0) WorkspaceService.previous()
            else WorkspaceService.next()
        }
    }
}
