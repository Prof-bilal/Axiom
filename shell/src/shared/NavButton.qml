import QtQuick
import qs.src.shared

// Text navigation button for the top panel ("Activities", "Apps", "Files",
// "Terminal"), with an optional leading Axiom icon. Selected (its surface is
// open) -> cyan wash with cyan text; hover -> lighter surface.
Item {
    id: nav

    property string text: ""
    property string icon: ""
    property bool selected: false

    signal activated()

    implicitHeight: Theme.panelNavHeight
    implicitWidth: row.implicitWidth + Theme.spacingMd * 2

    Accessible.role: Accessible.Button
    Accessible.name: text

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusControl + 2
        color: nav.selected ? Theme.stateSelected
             : mouse.pressed ? Theme.statePressed
             : mouse.containsMouse ? Theme.stateHover : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacingSm - 1

        AxiomIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: nav.icon.length > 0
            width: 15
            height: 15
            name: nav.icon
            strokeWidth: 1.7
            color: nav.selected ? Theme.cyanBright : Theme.textPrimary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: nav.text
            color: nav.selected ? Theme.cyanBright : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: nav.activated()   // press: see PanelButton
    }
}
