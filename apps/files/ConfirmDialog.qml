import QtQuick
import qs.src.shared
import qs.apps.shared

// Confirm a destructive action. Enter confirms only when `destructive` is
// false, so a stray Enter cannot delete anything permanently.
DialogFrame {
    id: dlg

    property string body: ""
    property string acceptText: "OK"
    property bool destructive: false

    signal accepted()

    function show(titleText, bodyText, button, isDestructive) {
        title = titleText
        body = bodyText
        acceptText = button
        destructive = !!isDestructive
        open = true
        forceActiveFocus()
    }

    onDismissed: open = false

    Text {
        width: parent.width
        text: dlg.body
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        wrapMode: Text.Wrap
    }

    Text {
        width: parent.width
        visible: dlg.destructive
        text: "Ctrl+Enter confirms, Esc cancels."
        color: Theme.textDisabled
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
    }

    Row {
        anchors.right: parent.right
        spacing: Theme.spacingSm
        AppButton { text: "Cancel"; onClicked: dlg.open = false }
        AppButton {
            text: dlg.acceptText
            primary: !dlg.destructive
            destructive: dlg.destructive
            onClicked: { dlg.open = false; dlg.accepted() }
        }
    }

    // Enter confirms ordinary dialogs; a destructive one needs Ctrl+Enter so a
    // stray Enter cannot delete anything.
    Keys.onReturnPressed: function (event) {
        if (!dlg.destructive || (event.modifiers & Qt.ControlModifier)) { dlg.open = false; dlg.accepted() }
    }
    Keys.onEnterPressed: function (event) {
        if (!dlg.destructive || (event.modifiers & Qt.ControlModifier)) { dlg.open = false; dlg.accepted() }
    }
}
