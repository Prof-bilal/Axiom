import QtQuick
import qs.src.shared

// One row in an Axiom menu. Uses the shared state language: hover -> lighter
// surface, selected -> cyan wash, destructive -> orange.
//
// `confirm: true` makes the row two-step: the first activation arms it (the
// label changes to `confirmText` in orange) and a second activation within
// four seconds triggers it. Used for log out / restart / shut down so a stray
// click cannot end the session.
Rectangle {
    id: row

    property string text: ""
    property string hint: ""
    property string icon: ""          // AxiomIcon name
    property string iconSource: ""    // or an application icon path
    property bool useAppIcon: false
    property bool selected: false
    property bool destructive: false
    property bool confirm: false
    property string confirmText: "Click again to confirm"
    property bool armed: false

    signal triggered()

    width: parent ? parent.width : 0
    implicitHeight: 34
    radius: Theme.radiusControl
    color: armed ? Theme.stateUrgentWash
         : selected ? Theme.stateSelected
         : mouse.pressed ? Theme.statePressed
         : mouse.containsMouse ? Theme.stateHover : "transparent"
    Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }

    Accessible.role: Accessible.MenuItem
    Accessible.name: armed ? confirmText : text

    function activate() {
        if (confirm && !armed) {
            armed = true
            disarm.restart()
            return
        }
        armed = false
        triggered()
    }

    Timer { id: disarm; interval: 4000; onTriggered: row.armed = false }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingSm + 2

        Item {
            width: 18
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            visible: row.icon.length > 0 || row.useAppIcon

            AxiomIcon {
                anchors.fill: parent
                visible: !row.useAppIcon
                name: row.icon
                color: row.armed || row.destructive && mouse.containsMouse ? Theme.orange
                     : row.selected || mouse.containsMouse ? Theme.cyanBright
                     : Theme.textSecondary
            }

            AppIcon {
                anchors.fill: parent
                visible: row.useAppIcon
                size: 18
                source: row.iconSource
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: row.armed ? row.confirmText : row.text
            color: row.armed ? Theme.orangeBright : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: row.armed ? Font.DemiBold : Font.Normal
        }
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        visible: row.hint.length > 0 && !row.armed
        text: row.hint
        color: Theme.textDisabled
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.activate()
    }
}
