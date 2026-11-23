import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.services

// Axiom session dialog (panel power button, Super+Shift+E): shut down, restart,
// sleep or log out through PowerService (systemd + logind), in the reference's
// centred solid card. Each action needs a second click to confirm (the label
// turns orange), so a stray click cannot end the session. Lock is a text link.
PanelWindow {
    id: menu

    property bool open: UiState.sessionMenuOpen

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: open
    WlrLayershell.namespace: "axiom-session-menu"
    WlrLayershell.layer: WlrLayershell.Overlay
    // Exclusive keyboard so Escape closes it (see MenuSurface for why not focusable:).
    WlrLayershell.keyboardFocus: open ? WlrLayershell.Exclusive : WlrLayershell.None

    property string armed: ""      // "off" | "reboot" | "suspend" | "logout"

    onOpenChanged: if (open) { armed = ""; keys.forceActiveFocus() }
    Timer { id: disarm; interval: 4000; onTriggered: menu.armed = "" }

    function activate(act) {
        if (armed !== act) { armed = act; disarm.restart(); return }
        armed = ""
        UiState.closeAllOverlays()
        if (act === "off") PowerService.powerOff()
        else if (act === "reboot") PowerService.reboot()
        else if (act === "suspend") PowerService.suspend()
        else PowerService.logout()
    }

    Rectangle { anchors.fill: parent; color: Theme.scrim }
    MouseArea { anchors.fill: parent; onClicked: UiState.closeAllOverlays() }
    Item { id: keys; anchors.fill: parent; focus: true; Keys.onEscapePressed: UiState.closeAllOverlays() }

    SolidSurface {
        anchors.centerIn: parent
        width: 460
        height: 308
        radius: Theme.radiusWindow
        strong: true
        MouseArea { anchors.fill: parent }

        Image {
            id: logo
            anchors.horizontalCenter: parent.horizontalCenter
            y: 18
            width: 56; height: 56
            source: Quickshell.shellPath("assets/axiom-penguin.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            id: title
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logo.bottom
            anchors.topMargin: 6
            text: "Axiom OS"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontTitle + 4
            font.weight: Font.DemiBold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: title.bottom
            text: "What would you like to do?"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }

        Row {
            id: actions
            anchors.horizontalCenter: parent.horizontalCenter
            y: 128
            spacing: 22

            Repeater {
                model: [
                    { act: "off", label: "Shut Down", tint: "#FF5252" },
                    { act: "reboot", label: "Restart", tint: "#FFB348" },
                    { act: "suspend", label: "Sleep", tint: "#FFB348" },
                    { act: "logout", label: "Log Out", tint: "#B8C4C8" }
                ]
                delegate: Item {
                    id: btn
                    required property var modelData
                    readonly property bool isArmed: menu.armed === modelData.act
                    width: 84; height: 108

                    Rectangle {
                        id: disc
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 64; height: 64; radius: 32
                        color: Qt.rgba(Qt.color(btn.modelData.tint).r, Qt.color(btn.modelData.tint).g,
                                       Qt.color(btn.modelData.tint).b, area.containsMouse || btn.isArmed ? 0.34 : 0.20)
                        border.width: btn.isArmed ? 2 : 1
                        border.color: btn.isArmed ? Theme.dangerBright : btn.modelData.tint
                        AxiomIcon {
                            visible: btn.modelData.act !== "suspend"
                            anchors.centerIn: parent
                            width: 28; height: 28
                            name: btn.modelData.act === "off" ? "power" : btn.modelData.act === "reboot" ? "restart" : "logout"
                            color: btn.modelData.tint
                        }
                        MoonIcon {
                            visible: btn.modelData.act === "suspend"
                            anchors.centerIn: parent
                            width: 28; height: 28
                            color: btn.modelData.tint
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: disc.bottom
                        anchors.topMargin: 10
                        text: btn.isArmed ? "Click again" : btn.modelData.label
                        color: btn.isArmed ? Theme.dangerBright : Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                        font.weight: btn.isArmed ? Font.DemiBold : Font.Normal
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: menu.activate(btn.modelData.act)
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: btn.isArmed ? "Confirm " + btn.modelData.label : btn.modelData.label
                }
            }
        }

        Row {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 20 }
            spacing: Theme.spacingMd

            Rectangle {
                width: 110; height: 32; radius: 16
                color: lockArea.containsMouse ? Theme.stateHover : "transparent"
                border.width: 1; border.color: Theme.border
                Text { anchors.centerIn: parent; text: "Lock screen"; color: Theme.textPrimary
                       font.family: Theme.fontFamily; font.pixelSize: Theme.fontBody }
                MouseArea { id: lockArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { UiState.closeAllOverlays(); UiState.lockRequested() } }
            }
            Rectangle {
                width: 110; height: 32; radius: 16
                color: cancelArea.containsMouse ? Theme.stateHover : Theme.cardFill
                border.width: 1; border.color: Theme.border
                Text { anchors.centerIn: parent; text: "Cancel"; color: Theme.textPrimary
                       font.family: Theme.fontFamily; font.pixelSize: Theme.fontBody }
                MouseArea { id: cancelArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: UiState.closeAllOverlays() }
            }
        }
    }
}
