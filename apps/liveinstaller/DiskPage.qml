import QtQuick
import "installer.js" as Ins

Item {
    id: page
    property var be
    readonly property string primaryText: "Next"
    readonly property string secondaryText: "Back"
    readonly property bool primaryDanger: false
    readonly property string status: "Axiom makes a boot partition and one btrfs partition with snapshots."
    function doPrimary() { be.next() }
    function doSecondary() { be.back() }
    Component.onCompleted: be.refreshDisks()

    PageHead {
        id: head
        anchors.top: parent.top
        anchors.topMargin: 6
        title: "Choose a disk"
        subtitle: "Axiom uses the whole disk. Everything on it will be erased."
    }
    Column {
        anchors.top: head.bottom
        anchors.topMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 80, 480)
        spacing: 8

        IText {
            visible: page.be.disks.length === 0
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: Ins.C.red
            text: page.be.disksError || "No usable disk was found. Disks that are in use, removable or read-only are hidden."
        }
        Repeater {
            model: page.be.disks
            delegate: Rectangle {
                required property var modelData
                required property int index
                width: parent.width
                height: 54
                radius: 10
                color: index === page.be.diskIndex ? "#2a2218" : Ins.C.card
                border.width: index === page.be.diskIndex ? 1 : 0
                border.color: Ins.C.orange
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    IText { text: modelData.path; color: "#ffffff" }
                    IText { text: Math.round(modelData.size / Math.pow(2, 30)) + " GB" + (modelData.model ? ", " + modelData.model : ""); color: Ins.C.dim; font.pixelSize: 12 }
                }
                IText { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; visible: index === page.be.diskIndex; text: "●"; color: Ins.C.orange }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: page.be.diskIndex = index }
            }
        }
        Rectangle {
            width: parent.width
            height: 54
            radius: 10
            color: Ins.C.card
            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
                IText { text: "Protect with a password"; color: "#ffffff" }
                IText { text: "Nobody can read your files without it."; color: Ins.C.dim; font.pixelSize: 12 }
            }
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                width: 42; height: 24; radius: 12
                color: page.be.form.luks ? Ins.C.orange : Ins.C.field
                Rectangle { y: 3; x: page.be.form.luks ? 21 : 3; width: 18; height: 18; radius: 9; color: page.be.form.luks ? Ins.C.orangeInk : Ins.C.dim }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: page.be.set("luks", !page.be.form.luks) }
        }
        InstallerField {
            visible: page.be.form.luks
            width: parent.width
            label: "Disk password"
            password: true
            text: page.be.form.luks_passphrase
            onTextChanged: if (text !== page.be.form.luks_passphrase) page.be.set("luks_passphrase", text)
            onAccepted: page.be.next()
        }
        IText {
            visible: page.be.form.luks
            width: parent.width
            color: Ins.C.dim
            font.pixelSize: 12
            text: "You type this every time the computer starts. If you forget it, your files cannot be recovered."
        }
    }
}
