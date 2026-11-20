import QtQuick
import "installer.js" as Ins

Item {
    id: page
    property var be
    readonly property bool failed: be.failure.length > 0
    readonly property string primaryText: failed ? "Back" : ""
    readonly property string secondaryText: ""
    readonly property bool primaryDanger: false
    readonly property string status: failed ? "" : "Installing Axiom. Please keep the computer on."
    function doPrimary() { be.back() }
    function doSecondary() { }

    readonly property int stage: Ins.stageIndex(be.progress.stage)

    PageHead {
        id: head
        anchors.top: parent.top
        anchors.topMargin: 6
        title: failed ? "The installation did not finish" : "Installing Axiom"
        subtitle: failed ? "You can go back and try again." : "This takes a few minutes."
    }

    Row {
        anchors.top: head.bottom
        anchors.topMargin: 22
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 40
        visible: !page.failed

        // Our penguin, brightening from grey to full colour as the install advances.
        Item {
            width: 130; height: 130
            Image { anchors.fill: parent; source: "assets/axiom-penguin.png"; fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true; opacity: 0.25 + 0.75 * page.be.progress.pct / 100 }
        }
        Column {
            width: 280
            spacing: 6
            IText { text: Math.round(page.be.progress.pct) + "%"; font.pixelSize: 34; font.weight: Font.Medium; color: "#ffffff" }
            Rectangle {
                width: parent.width; height: 8; radius: 4; color: Ins.C.field
                Rectangle { width: parent.width * page.be.progress.pct / 100; height: parent.height; radius: 4; color: Ins.C.orange; Behavior on width { NumberAnimation { duration: 200 } } }
            }
            IText { text: page.be.progress.stage; color: "#ffb348"; font.weight: Font.Medium; topPadding: 6 }
            IText {
                text: page.be.progress.detail + (page.be.progress.eta ? (page.be.progress.detail ? "  ·  " : "") + "about " + page.be.progress.eta + " min left" : "")
                color: Ins.C.dim; font.pixelSize: 12
                visible: text.length > 0
            }
            Repeater {
                model: Ins.STAGES
                delegate: IText {
                    required property string modelData
                    required property int index
                    text: (index < page.stage ? "✓  " : index === page.stage ? "›  " : "○  ") + modelData
                    color: index < page.stage ? Ins.C.dim : index === page.stage ? "#ffffff" : Ins.C.faint
                    font.pixelSize: 13
                }
            }
        }
    }

    Column {
        anchors.top: head.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 100, 480)
        visible: page.failed
        spacing: 10
        IText { width: parent.width; text: page.be.failure; color: Ins.C.red; horizontalAlignment: Text.AlignHCenter }
        IText { width: parent.width; text: "The full log is in /var/log/axiom-installer.log."; color: Ins.C.dim; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
    }
}
