import QtQuick
import qs.src.shared

// Search box used by the Axiom apps: magnifier, placeholder, debounced
// `searched(text)`, Escape clears. Enter searches immediately.
Rectangle {
    id: box

    property alias text: input.text
    property string placeholder: "Search"
    property string accessibleName: "Search"
    property int debounce: 250
    readonly property alias inputFocused: input.activeFocus

    signal searched(string text)
    signal escaped()
    signal submitted()

    function focusInput() { input.forceActiveFocus(); input.selectAll() }
    function clear() { input.text = "" }

    implicitWidth: 220
    implicitHeight: 32
    radius: Theme.radiusControl
    color: Theme.background
    border.width: 1
    border.color: input.activeFocus ? Theme.stateFocus : Theme.border
    opacity: enabled ? 1 : 0.45

    AxiomIcon {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        width: 15
        height: 15
        name: "search"
        color: Theme.textSecondary
        strokeWidth: 1.6
    }

    TextInput {
        id: input
        anchors.left: icon.right
        anchors.leftMargin: Theme.spacingSm
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        enabled: box.enabled
        color: Theme.textPrimary
        selectionColor: Theme.cyanMuted
        selectedTextColor: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        clip: true
        onTextChanged: timer.restart()
        Keys.onEscapePressed: { text = ""; timer.stop(); box.searched(""); box.escaped() }
        Keys.onReturnPressed: { timer.stop(); box.searched(text.trim()); box.submitted() }
        Accessible.role: Accessible.EditableText
        Accessible.name: box.accessibleName

        Text {
            visible: input.text.length === 0
            anchors.verticalCenter: parent.verticalCenter
            text: box.placeholder
            color: Theme.textDisabled
            font: input.font
        }
    }

    Timer { id: timer; interval: box.debounce; onTriggered: box.searched(input.text.trim()) }
}
