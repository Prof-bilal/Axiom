import QtQuick
import "hubstyle.js" as S
import "backends.js" as B

// Progress card for one install, update or removal. Shown as a modal over the
// current page (HubApp.progressOpen), so the screen itself does not change.
// The percentage is the real one when the command reports it, otherwise an
// estimate from the step, so the bar always moves.
Item {
    id: page

    property var hub: null
    readonly property var be: hub.be
    readonly property string verb: be.action === "remove" ? "Removing" : be.action === "update" ? "Updating" : "Installing"
    readonly property bool failed: be.done && be.error.length > 0
    readonly property int shownPct: be.done ? (failed ? Math.max(0, be.percent) : 100)
                                            : (be.percent >= 0 ? be.percent : Math.round((be.step + 0.5) * 100 / B.STEPS.length))

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: 14

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 150; height: 150

            Canvas {
                id: ring
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.lineWidth = 8
                    ctx.lineCap = "round"
                    ctx.strokeStyle = S.border
                    ctx.beginPath(); ctx.arc(width / 2, height / 2, 66, 0, Math.PI * 2); ctx.stroke()
                    ctx.strokeStyle = page.failed ? S.bad : S.accent
                    ctx.beginPath()
                    ctx.arc(width / 2, height / 2, 66, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.max(page.shownPct, 2) / 100)
                    ctx.stroke()
                }
                Connections { target: page; function onShownPctChanged() { ring.requestPaint() } }
                Connections { target: page; function onFailedChanged() { ring.requestPaint() } }
            }
            Column {
                anchors.centerIn: parent
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: page.failed ? "!" : page.be.done ? "✓" : page.shownPct + "%"
                    color: S.text; font.family: S.font; font.pixelSize: 26; font.weight: Font.DemiBold
                }
            }
        }

        // Linear bar: the same percentage, easy to read at a glance.
        Rectangle {
            width: parent.width; height: 6; radius: 3
            color: S.border
            Rectangle {
                height: parent.height; radius: 3
                color: page.failed ? S.bad : S.accent
                width: parent.width * page.shownPct / 100
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: page.be.done ? (page.failed ? "Something went wrong" : "All done")
                               : page.verb + " " + (page.be.current ? page.be.current.name : "") + "…"
            color: S.text; font.family: S.font; font.pixelSize: 16; font.weight: Font.DemiBold
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            text: page.failed ? page.be.error
                              : page.be.done ? (page.be.action === "remove" ? "Removed from this system." : "Ready to use.")
                              : "Setting up dependencies and integrating with your system."
            color: page.failed ? S.bad : S.muted; font.family: S.font; font.pixelSize: 12
        }

        Column {
            spacing: 6
            anchors.horizontalCenter: parent.horizontalCenter
            Repeater {
                model: B.STEPS
                delegate: Row {
                    required property string modelData
                    required property int index
                    readonly property bool finished: page.be.done ? !page.failed : index < page.be.step
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
            topPadding: 6
            HubButton { visible: page.be.busy; enabled: page.be.cancellable; primary: false; text: "Cancel"; onClicked: page.be.cancel() }
            HubButton { visible: page.be.done; text: page.failed ? "Close" : "Done"; onClicked: hub.closeProgress() }
        }
    }
}
