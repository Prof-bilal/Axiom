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
    property var templates: []              // optional: [{ label, ext }] shown as pills
    property int templateIndex: 0
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

    // Picking a type swaps the extension of the name, keeping the base name.
    function pickTemplate(i) {
        var old = templates[templateIndex] ? templates[templateIndex].ext : ""
        templateIndex = i
        var nx = templates[i].ext
        var t = field.text
        if (old && t.slice(-old.length) === old) t = t.slice(0, -old.length)
        field.text = t + nx
    }

    function accept() {
        if (problem !== "") return
        var t = field.text
        open = false
        accepted(t)
    }

    onDismissed: open = false

    // "Name" label above the field, as in the macOS save and rename sheets.
    Text {
        width: parent.width
        text: "Name"
        color: Theme.menuText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        font.weight: Font.Medium
    }

    Rectangle {
        width: parent.width
        height: 38
        radius: 10
        color: Theme.background
        border.width: 1
        border.color: field.activeFocus ? Theme.stateSelectedBorder : Theme.menuBorder

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

    // Type pills (Markdown, Rust, TOML, Empty File), shown only for new files.
    Column {
        visible: dlg.templates.length > 0
        width: parent.width
        spacing: Theme.spacingSm
        Text {
            text: "Template / Type"
            color: Theme.menuText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            font.weight: Font.Medium
        }
        Flow {
            width: parent.width
            spacing: 6
            Repeater {
                model: dlg.templates
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool on: dlg.templateIndex === index
                    height: 28
                    width: pillText.implicitWidth + 24
                    radius: 14
                    color: on ? Theme.stateSelected : (pillHit.containsMouse ? Theme.stateHover : "transparent")
                    border.width: 1
                    border.color: on ? Theme.stateSelectedBorder : Theme.menuBorder
                    Text {
                        id: pillText
                        anchors.centerIn: parent
                        text: modelData.label
                        color: parent.on ? Theme.textPrimary : Theme.menuText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                        font.weight: parent.on ? Font.Medium : Font.Normal
                    }
                    MouseArea {
                        id: pillHit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dlg.pickTemplate(index)
                    }
                }
            }
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
