import QtQuick
import "installer.js" as Ins

Item {
    id: page
    property var be
    readonly property string primaryText: "Next"
    readonly property string secondaryText: "Back"
    readonly property bool primaryDanger: false
    readonly property string status: "Leave the Git fields empty if you do not use Git."
    function doPrimary() { be.next() }
    function doSecondary() { be.back() }

    PageHead {
        id: head
        anchors.top: parent.top
        anchors.topMargin: 6
        title: "Create your account"
        subtitle: "This account can manage the computer. The built-in administrator stays locked."
    }
    Column {
        anchors.top: head.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 60, 540)
        spacing: 6

        InstallerField { width: parent.width; label: "Your name"; text: page.be.form.fullname; onTextChanged: if (text !== page.be.form.fullname) page.be.set("fullname", text) }
        InstallerField { width: parent.width; label: "Username"; text: page.be.form.username; onTextChanged: if (text !== page.be.form.username) page.be.set("username", text) }
        InstallerField { width: parent.width; label: "Computer name"; text: page.be.form.hostname; onTextChanged: if (text !== page.be.form.hostname) page.be.set("hostname", text) }
        InstallerField { width: parent.width; label: "Password"; password: true; text: page.be.form.password; onTextChanged: if (text !== page.be.form.password) page.be.set("password", text) }
        InstallerField {
            width: parent.width; label: "Repeat password"; password: true
            invalid: page.be.form.password2.length > 0 && page.be.form.password2 !== page.be.form.password
            text: page.be.form.password2
            onTextChanged: if (text !== page.be.form.password2) page.be.set("password2", text)
            onAccepted: page.be.next()
        }
        IText { text: "Git identity (optional)"; color: Ins.C.dim; font.pixelSize: 12; topPadding: 6 }
        InstallerField { width: parent.width; label: "Name for Git"; text: page.be.form.git_name; onTextChanged: if (text !== page.be.form.git_name) page.be.set("git_name", text) }
        InstallerField { width: parent.width; label: "Email for Git"; text: page.be.form.git_email; onTextChanged: if (text !== page.be.form.git_email) page.be.set("git_email", text); onAccepted: page.be.next() }
    }
}
