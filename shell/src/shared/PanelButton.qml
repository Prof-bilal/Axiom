import QtQuick
import qs.src.shared

// Compact panel/menu button implementing the shared Axiom state language:
// hover -> lighter surface, selected (menu open) -> cyan wash,
// active -> cyan icon, badge -> tiny dot (cyan; orange when urgent),
// disabled -> muted.
Item {
    id: btn

    property string icon: ""
    property real level: 0
    property bool selected: false
    property bool active: false
    property bool badge: false
    property bool badgeUrgent: false
    property bool available: true
    property string label: ""          // optional trailing text (e.g. "92%")
    property string accessibleName: ""

    signal clicked()

    implicitHeight: Theme.panelButtonSize
    implicitWidth: row.implicitWidth + Theme.spacingSm * 2

    Accessible.role: Accessible.Button
    Accessible.name: accessibleName

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusControl
        color: btn.selected ? Theme.stateSelected
             : mouse.pressed ? Theme.statePressed
             : mouse.containsMouse ? Theme.stateHover : "transparent"
        border.width: btn.selected ? 1 : 0
        border.color: Theme.stateSelectedBorder
        Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacingXs + 2

        AxiomIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: btn.icon.length > 0
            name: btn.icon
            level: btn.level
            color: !btn.available ? Theme.stateDisabled
                 : (btn.active || btn.selected || mouse.containsMouse) ? Theme.cyanBright
                 : Theme.textPrimary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: btn.label.length > 0
            text: btn.label
            color: btn.available ? Theme.textPrimary : Theme.stateDisabled
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            font.weight: Font.Medium
            font.features: { "tnum": 1 }
        }
    }

    // Unread / urgent marker: a tiny dot, never a large badge.
    Rectangle {
        visible: btn.badge
        width: 6
        height: 6
        radius: 3
        color: btn.badgeUrgent ? Theme.stateUrgent : Theme.cyan
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 4
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: btn.available
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
