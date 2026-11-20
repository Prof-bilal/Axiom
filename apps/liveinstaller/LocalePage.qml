import QtQuick
import "installer.js" as Ins

Item {
    id: page
    property var be
    readonly property string primaryText: "Next"
    readonly property string secondaryText: "Back"
    readonly property bool primaryDanger: false
    readonly property string status: "You can change these later in Settings."
    function doPrimary() { be.next() }
    function doSecondary() { be.back() }

    PageHead {
        id: head
        anchors.top: parent.top
        anchors.topMargin: 6
        title: "Where are you?"
        subtitle: "Axiom uses this to set the clock and regional formats."
    }
    Column {
        anchors.top: head.bottom
        anchors.topMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 80, 460)
        spacing: 12
        Chooser {
            width: parent.width
            label: "Region"
            model: Object.keys(page.be.tzGroups).sort()
            value: page.be.region
            onPicked: function (r) { page.be.setZone(r, page.be.tzGroups[r][0]) }
        }
        Chooser {
            width: parent.width
            label: "Time zone"
            model: page.be.tzGroups[page.be.region] || []
            value: page.be.city
            onPicked: function (c) { page.be.setZone(page.be.region, c) }
        }
        Rectangle {
            width: parent.width
            height: 58
            radius: 10
            color: Ins.C.card
            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
                IText { text: Qt.formatDateTime(new Date(), "hh:mm AP, dddd d MMMM"); font.weight: Font.Medium; color: "#ffffff" }
                IText { text: page.be.form.timezone; color: Ins.C.dim; font.pixelSize: 12 }
            }
        }
    }
}
