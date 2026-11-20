import QtQuick
import "installer.js" as Ins

Item {
    id: page
    property var be
    readonly property string primaryText: "Next"
    readonly property string secondaryText: "Back"
    readonly property bool primaryDanger: false
    readonly property string status: be.pinText.length > 0 ? "Time zone: " + be.form.timezone + ". You can change this later in Settings."
                                                         : "You can change these later in Settings."
    function doPrimary() { be.next() }
    function doSecondary() { be.back() }

    readonly property var cities: page.be.tzGroups[page.be.region] || []
    readonly property var cityNames: {
        var o = {}
        cities.forEach(function (c) { o[c] = Ins.prettyZone(c) })
        return o
    }

    PageHead {
        id: head
        anchors.top: parent.top
        anchors.topMargin: 6
        title: "Where are you?"
        subtitle: "Pick your region and time zone. Axiom sets the clock from it."
    }

    // The pin follows the chosen time zone: Karachi lights up Pakistan.
    WorldMap {
        id: map
        anchors.top: head.bottom
        anchors.topMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 20, 580)
        pin: page.be.pin
        highlight: page.be.pin ? page.be.pin.cc : ""
        label: page.be.pinText
    }

    Row {
        anchors.top: map.bottom
        anchors.topMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        width: map.width
        spacing: 16
        Dropdown {
            be: page.be
            width: (parent.width - 16) / 2
            stacked: true
            label: "Region"
            model: Object.keys(page.be.tzGroups).sort()
            value: page.be.region
            onPicked: function (r) { page.be.setZone(r, page.be.tzGroups[r][0]) }
        }
        Dropdown {
            be: page.be
            width: (parent.width - 16) / 2
            stacked: true
            label: "Time zone"
            model: page.cities
            names: page.cityNames
            value: page.be.city
            onPicked: function (c) { page.be.setZone(page.be.region, c) }
        }
    }
}
