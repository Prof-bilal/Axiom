import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.src.shared
import qs.services

// Screen lock (Phase 6): ext-session-lock-v1 via WlSessionLock, password checked
// by PAM (/etc/pam.d/axiom-lock). The compositor itself blanks and refuses input
// to other clients while locked, so this surface is the only way back in.
Scope {
    id: root
    property bool locked: false
    property string password: ""
    property string message: ""

    function lock() {
        password = ""
        message = ""
        UiState.closeAllOverlays()
        locked = true
    }

    Connections {
        target: UiState
        function onLockRequested() { root.lock() }
    }

    PamContext {
        id: pam
        config: "axiom-lock"
        user: Quickshell.env("USER")
        onResponseRequiredChanged: {
            if (responseRequired) { respond(root.password); root.password = "" }
        }
        onCompleted: result => {
            if (result === PamResult.Success) {
                root.locked = false
            } else {
                root.message = "Incorrect password"
            }
        }
        onError: root.message = "Authentication error"
    }

    WlSessionLock {
        locked: root.locked

        WlSessionLockSurface {
            id: surface
            color: Theme.background

            // The desktop wallpaper, darkened. Not blurred: the lock surface has
            // no compositor blur behind it.
            Image {
                anchors.fill: parent
                source: SettingsService.wallpaper.length > 0 ? "file://" + SettingsService.wallpaper
                                                            : Quickshell.shellPath("assets/wallpaper.png")
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: surface.width
                sourceSize.height: surface.height
            }
            Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.5) }

            // Date and time, top right.
            Text {
                id: clock
                anchors { top: parent.top; right: parent.right; topMargin: 22; rightMargin: 28 }
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                text: Qt.formatDateTime(now.date, "ddd, MMM d, h:mm AP")
                QtObject { id: now; property date date: new Date() }
                Timer { interval: 15000; running: true; repeat: true; onTriggered: now.date = new Date() }
            }

            // The sign-in card: avatar, name, password field with an arrow.
            SolidSurface {
                id: card
                anchors.centerIn: parent
                width: 320
                height: 300
                radius: Theme.radiusWindow + 8
                strong: true

                Rectangle {
                    id: avatar
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 28
                    width: 96; height: 96; radius: 48
                    color: Theme.surfaceElevated
                    border.width: 2
                    border.color: Theme.stateSelectedBorder
                    clip: true
                    Image {
                        anchors.fill: parent
                        anchors.margins: 10
                        source: Quickshell.shellPath("assets/axiom-penguin.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: avatar.bottom
                    anchors.topMargin: 14
                    text: AccountService.current
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTitle
                }

                Rectangle {
                    id: field
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 56 }
                    width: 240; height: 40; radius: 20
                    color: Theme.light ? "#F4F6F7" : "#0A1215"
                    border.color: Theme.accent
                    border.width: 1

                    TextInput {
                        id: input
                        objectName: "lockInput"
                        anchors { fill: parent; leftMargin: 18; rightMargin: 44 }
                        focus: true
                        echoMode: TextInput.Password
                        color: Theme.textPrimary
                        font.pixelSize: 16
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        onAccepted: root.attempt(input)
                    }

                    // Arrow button: same as pressing Enter.
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                        width: 32; height: 32; radius: 16
                        color: arrowArea.containsMouse ? Theme.accentBright : Theme.accent
                        AxiomIcon { anchors.centerIn: parent; width: 16; height: 16; name: "arrow-right"; color: "#06161A" }
                        MouseArea { id: arrowArea; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor; onClicked: root.attempt(input) }
                    }
                }

                Text {
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 22 }
                    text: root.message
                    color: Theme.dangerBright
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
            }

            // Power actions stay available on the lock screen.
            SolidSurface {
                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 36 }
                width: 168; height: 52
                radius: 26
                strong: true
                Row {
                    anchors.centerIn: parent
                    spacing: 18
                    Repeater {
                        model: [ { icon: "power", act: "off" }, { icon: "restart", act: "reboot" }, { icon: "moon", act: "suspend" } ]
                        delegate: Item {
                            required property var modelData
                            width: 36; height: 36
                            Rectangle { anchors.fill: parent; radius: 18
                                        color: pa.containsMouse ? Theme.stateHover : "transparent" }
                            AxiomIcon { visible: modelData.icon !== "moon"; anchors.centerIn: parent; width: 20; height: 20
                                        name: modelData.icon !== "moon" ? modelData.icon : "power"; color: Theme.textPrimary }
                            MoonIcon { visible: modelData.icon === "moon"; anchors.centerIn: parent; width: 20; height: 20; color: Theme.textPrimary }
                            MouseArea {
                                id: pa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.act === "off") PowerService.powerOff()
                                    else if (modelData.act === "reboot") PowerService.reboot()
                                    else PowerService.suspend()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Start a PAM attempt with what was typed (Enter or the arrow button).
    function attempt(field) {
        if (pam.active || field.text === "") return
        password = field.text
        field.text = ""
        message = ""
        pam.start()
    }
}
