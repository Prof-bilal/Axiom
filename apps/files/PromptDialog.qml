import QtQuick
import qs.src.shared
import qs.apps.shared
import "files.js" as Files

// Ask for a file or folder name (new folder, new file, rename). The name is
// validated as it is typed; the accept button stays disabled while invalid.
DialogFrame {
    id: dlg

    property string acceptText: "OK"
    property string existingError: ""       // set by the owner for name clashes
    readonly property string problem: Files.validateName(field.text)

    signal accepted(string text)

    function show(titleText, initial, button) {
        title = titleText
        acceptText = button
        field.text = initial
        open = true
        field.forceActiveFocus()
        var dot = initial.lastIndexOf(".")
        field.select(0, dot > 0 ? dot : initial.length)
    }

    function accept() {
        if (problem !== "") return
        var t = field.text
        open = false
        accepted(t)
    }

    onDismissed: open = false

    Rectangle {
        width: parent.width
        height: 36
        radius: Theme.radiusControl
        color: Theme.background
        border.width: 1
        border.color: field.activeFocus ? Theme.stateFocus : Theme.border

        TextInput {
            id: field
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingMd
            anchors.rightMargin: Theme.spacingMd
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.textPrimary
            selectionColor: Theme.cyanMuted
            selectedTextColor: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            clip: true
            Keys.onReturnPressed: dlg.accept()
            Keys.onEnterPressed: dlg.accept()
            Accessible.role: Accessible.EditableText
            Accessible.name: dlg.title
        }
    }

    Text {
        width: parent.width
        visible: field.text.length > 0 && dlg.problem !== ""
        text: dlg.problem
        color: Theme.orangeBright
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        wrapMode: Text.Wrap
    }

    Row {
        anchors.right: parent.right
        spacing: Theme.spacingSm
        AppButton { text: "Cancel"; onClicked: dlg.open = false }
        AppButton { text: dlg.acceptText; primary: true; enabled: dlg.problem === ""; onClicked: dlg.accept() }
    }
}
