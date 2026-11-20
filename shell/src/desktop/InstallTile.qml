import QtQuick
import Quickshell
import Quickshell.Io
import qs.src.shared

// "Install Axiom" icon, shown on the live medium only (the live image has /run/archiso; an installed
// system does not, so the tile never appears there). Double-click opens the installer app
// (apps/liveinstaller, ADR-035), which runs unprivileged and asks pkexec for the one root step.
//
// AXIOM_FORCE_LIVE=1 shows the tile off the live medium, for screenshots only.
Item {
    id: tile

    property bool live: Quickshell.env("AXIOM_FORCE_LIVE") === "1"

    visible: live
    width: 100
    height: 104

    Process {
        command: ["test", "-d", "/run/archiso"]
        running: true
        onExited: function (code) { if (code === 0) tile.live = true }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: Theme.radiusSurface
        color: hit.containsMouse ? Theme.stateHover : "transparent"
    }
    Rectangle {
        id: badge
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        width: 56
        height: 56
        radius: 14
        color: "#20252b"
        border.width: 2
        border.color: "#ff9418"
        Image {
            anchors.centerIn: parent
            width: 44
            height: 44
            source: "../../apps/liveinstaller/assets/axiom-penguin.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
    }
    Text {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 6; rightMargin: 6; bottomMargin: 10 }
        horizontalAlignment: Text.AlignHCenter
        text: "Install Axiom"
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.6)
    }
    MouseArea {
        id: hit
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onDoubleClicked: Quickshell.execDetached(["axiom-app", "installer"])
    }
    Accessible.role: Accessible.Button
    Accessible.name: "Install Axiom"
    Accessible.onPressAction: Quickshell.execDetached(["axiom-app", "installer"])
}
