import QtQuick
import qs.src.shared

// Date and time for the right side of the panel: "Sat, Nov 1  10:24 PM".
// Tabular figures keep the width steady; updates on minute boundaries.
Item {
    id: clock

    property date now: new Date()

    implicitWidth: label.implicitWidth + Theme.spacingMd * 2
    implicitHeight: Theme.panelButtonSize

    Accessible.role: Accessible.StaticText
    Accessible.name: Qt.formatDateTime(clock.now, "dddd d MMMM, h:mm AP")

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.now, "ddd, MMM d") + "  " + Qt.formatDateTime(clock.now, "h:mm AP")
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        font.weight: Font.Medium
        font.features: { "tnum": 1 }
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            var d = new Date()
            if (d.getMinutes() !== clock.now.getMinutes() || d.getHours() !== clock.now.getHours()
                    || d.getDate() !== clock.now.getDate()) {
                clock.now = d
            }
            interval = Math.max(250, (60 - d.getSeconds()) * 1000 - d.getMilliseconds())
        }
    }
}
