import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Polkit
import qs.src.shared
import qs.apps.shared

// Authentication prompt for administrator actions (pkexec, Software installs),
// in the Axiom look. The shell is the session's polkit agent; the
// password goes straight to polkit through AuthFlow.submit and is never stored,
// logged or kept in a property after it is sent. The labwc fallback session
// starts polkit-gnome itself (labwc autostart); this shell never starts a second
// agent, because a second one blocks the first on the next start.
Scope {
    id: dialog

    PolkitAgent { id: agent }

    readonly property var flow: agent.flow
    readonly property bool showing: agent.isActive && flow !== null

    PanelWindow {
        id: win
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: dialog.showing
        WlrLayershell.namespace: "axiom-polkit"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: dialog.showing ? WlrLayershell.Exclusive : WlrLayershell.None

        onVisibleChanged: if (visible) { field.text = ""; field.forceActiveFocus() }

        Rectangle { anchors.fill: parent; color: Theme.scrim }
        MouseArea { anchors.fill: parent }

        Rectangle {
            anchors.centerIn: parent
            width: 440
            height: col.implicitHeight + Theme.spacingXl * 2
            radius: Theme.radiusWindow
            color: Theme.menuSurface
            border.width: 1
            border.color: Theme.menuBorder

            Column {
                id: col
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.spacingXl }
                spacing: Theme.spacingMd

                AxiomIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 44; height: 44
                    name: "lock"
                    color: Theme.orangeBright
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: "Authentication required"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTitle
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                    text: dialog.flow ? dialog.flow.message : ""
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    visible: text.length > 0
                    textFormat: Text.PlainText
                    text: dialog.flow && dialog.flow.selectedIdentity && dialog.flow.selectedIdentity.displayName
                          ? dialog.flow.selectedIdentity.displayName : ""
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    width: parent.width
                    height: 38
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
                        echoMode: dialog.flow && dialog.flow.responseVisible ? TextInput.Normal : TextInput.Password
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                        clip: true
                        Keys.onReturnPressed: dialog.send()
                        Keys.onEnterPressed: dialog.send()
                        Keys.onEscapePressed: dialog.cancel()
                    }
                    Text {
                        anchors { left: parent.left; leftMargin: Theme.spacingMd; verticalCenter: parent.verticalCenter }
                        visible: field.text.length === 0
                        text: dialog.flow && dialog.flow.inputPrompt ? dialog.flow.inputPrompt : "Password"
                        color: Theme.textDisabled
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }
                }

                Text {
                    width: parent.width
                    visible: text.length > 0
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                    text: dialog.flow ? dialog.flow.supplementaryMessage : ""
                    color: dialog.flow && dialog.flow.supplementaryIsError ? Theme.orangeBright : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }

                Row {
                    anchors.right: parent.right
                    spacing: Theme.spacingSm
                    AppButton { text: "Cancel"; onClicked: dialog.cancel() }
                    AppButton { text: "Authenticate"; primary: true; onClicked: dialog.send() }
                }
            }
        }
    }

    function send() {
        if (!flow) return
        var value = field.text
        field.text = ""
        flow.submit(value)
    }

    function cancel() {
        field.text = ""
        if (flow) flow.cancelAuthenticationRequest()
    }
}
