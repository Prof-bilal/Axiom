import QtQuick
import "installer.js" as Ins

Item {
    id: page
    property var be
    readonly property string primaryText: be.online ? "Erase and install" : "Connect first"
    readonly property string secondaryText: "Back"
    readonly property bool primaryDanger: be.online
    readonly property string status: "Nothing has been changed on the disk yet."
    function doPrimary() { if (be.online) be.next(); else be.go(1) }
    function doSecondary() { be.back() }

    PageHead {
        id: head
        anchors.top: parent.top
        anchors.topMargin: 6
        title: "Ready to install"
        subtitle: "Check these details. This is the last step before the disk is erased."
    }
    Column {
        anchors.top: head.bottom
        anchors.topMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 60, 540)
        spacing: 10

        Rectangle {
            width: parent.width
            height: 38
            radius: 8
            color: page.be.online ? "#16281d" : "#2a2016"
            IText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: 12
                anchors.right: parent.right; anchors.rightMargin: 12
                color: page.be.online ? Ins.C.green : "#f9b062"
                text: page.be.online ? "Internet is connected. The install downloads about 3 GB."
                                     : "No internet. Axiom needs it to download packages. Go back and connect."
            }
        }
        Column {
            width: parent.width
            spacing: 3
            Repeater {
                model: [
                    ["Disk", page.be.disk ? page.be.disk.path + ", " + Math.round(page.be.disk.size / Math.pow(2, 30)) + " GB, will be erased" + (page.be.form.luks ? ", encrypted" : "") : "None"],
                    ["Account", page.be.form.fullname + " (" + page.be.form.username + ")"],
                    ["Computer", page.be.form.hostname],
                    ["Language", Ins.nameOf(Ins.LOCALE_NAMES, page.be.form.locale) + ", keyboard " + page.be.form.keyboard],
                    ["Time zone", page.be.form.timezone],
                    ["Git", page.be.form.git_name ? page.be.form.git_name + " <" + page.be.form.git_email + ">" : "Not set"]
                ]
                delegate: Row {
                    required property var modelData
                    spacing: 12
                    IText { width: 90; text: modelData[0]; color: Ins.C.dim; font.pixelSize: 13; wrapMode: Text.NoWrap }
                    IText { width: 430; text: modelData[1]; font.pixelSize: 13; color: modelData[0] === "Disk" ? "#ff9a9a" : Ins.C.text; elide: Text.ElideRight; wrapMode: Text.NoWrap }
                }
            }
        }
        InstallerField {
            width: parent.width
            label: "Type ERASE to start"
            text: page.be.confirmText
            invalid: page.be.formError.indexOf("ERASE") >= 0
            onTextChanged: if (text !== page.be.confirmText) page.be.confirmText = text
            onAccepted: page.doPrimary()
        }
    }
}
