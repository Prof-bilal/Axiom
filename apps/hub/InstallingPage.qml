import QtQuick
import "hubstyle.js" as S
import "backends.js" as B

// Progress for one install, update or removal: a ring, the step list, and Cancel/Done.
Item {
    id: page

    property var hub: null
    readonly property var be: hub.be
    readonly property bool known: be.percent >= 0
    readonly property string verb: be.action === "remove" ? "Removing" : be.action === "update" ? "Updating" : "Installing"

    Column {
        anchors.centerIn: parent
        spacing: 16
        width: Math.min(parent.width - 40, 420)

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 170; height: 170

            Canvas {
                id: ring
                anchors.fill: parent
                property real spin: 0
                onSpinChanged: requestPaint()
                Connections { target: page.be; function onPercentChanged() { ring.requestPaint() } }
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.lineWidth = 8
                    ctx.lineCap = "round"
                    ctx.strokeStyle = S.border
                    ctx.beginPath(); ctx.arc(width / 2, height / 2, 72, 0, Math.PI * 2); ctx.stroke()
                    ctx.strokeStyle = page.be.error.length > 0 ? S.bad : S.accent
                    ctx.beginPath()
                    if (page.known || page.be.done) {
                        var p = page.be.done && page.be.error.length === 0 ? 100 : Math.max(page.be.percent, 1)
                        ctx.arc(width / 2, height / 2, 72, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * p / 100)
                    } else {
                        ctx.arc(width / 2, height / 2, 72, spin, spin + Math.PI * 0.6)
                    }
                    ctx.stroke()
                }
                NumberAnimation on spin { running: page.be.busy && !page.known; from: 0; to: Math.PI * 2; duration: 1200; loops: Animation.Infinite }
            }
            Column {
                anchors.centerIn: parent
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "⤓"; color: S.accent; font.pixelSize: 22 }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: page.known ? page.be.percent + "%" : (page.be.done ? (page.be.error.length > 0 ? "!" : "✓") : "…")
                    color: S.text; font.family: S.font; font.pixelSize: 26; font.weight: Font.DemiBold
                }
            }
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: page.be.done ? (page.be.error.length > 0 ? "Something went wrong" : "All done") : page.verb + " " + (page.be.current ? page.be.current.name : "") + "..."
            color: S.text; font.family: S.font; font.pixelSize: 16; font.weight: Font.DemiBold
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: page.be.error.length > 0 ? page.be.error : "Setting up dependencies and integrating with your system."
            color: page.be.error.length > 0 ? S.bad : S.muted; font.family: S.font; font.pixelSize: 12
        }

        Column {
            spacing: 6
            anchors.horizontalCenter: parent.horizontalCenter
            Repeater {
                model: B.STEPS
                delegate: Row {
                    required property string modelData
                    required property int index
                    readonly property bool finished: page.be.done ? page.be.error.length === 0 : index < page.be.step
                    readonly property bool active: !page.be.done && index === page.be.step
                    spacing: 10
                    Text { text: finished ? "✔" : (active ? "◐" : "○"); color: finished ? S.ok : (active ? S.accent : S.border); font.pixelSize: 13 }
                    Text { text: modelData; color: finished || active ? S.text : S.muted; font.family: S.font; font.pixelSize: 12 }
                }
            }
        }

        Row {
            anchors.right: parent.right
            spacing: 10
            topPadding: 8
            HubButton { visible: page.be.busy; enabled: page.be.cancellable; primary: false; text: "Cancel"; onClicked: page.be.cancel() }
            HubButton { visible: page.be.done; text: "Done"; onClicked: hub.open("installed") }
        }
    }
}
