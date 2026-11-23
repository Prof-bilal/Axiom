import QtQuick
import Quickshell
import qs.src.shared

// Footer row of a status popup: opens the matching page of Axiom Settings for everything the popup leaves out.
Item {
    id: link

    property string text: "Settings…"

    width: parent ? parent.width : 300
    height: 38

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: Theme.radiusControl
        color: mouse.containsMouse ? Theme.stateHover : "transparent"
        Text {
            anchors.verticalCenter: parent.verticalCenter
            x: Theme.spacingSm
            text: link.text
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { UiState.closeAllOverlays(); Quickshell.execDetached(["axiom-app", "settings"]) }
        }
    }
}
