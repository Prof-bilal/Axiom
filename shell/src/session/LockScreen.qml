import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.src.shared

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
            color: Theme.background

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: field.top
                anchors.bottomMargin: 28
                width: 120; height: 120
                source: Quickshell.shellPath("assets/axiom-penguin.png")
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: field.bottom
                anchors.topMargin: 14
                text: root.message
                color: Theme.orangeBright
                font.pixelSize: 15
            }

            Rectangle {
                id: field
                anchors.centerIn: parent
                width: 320; height: 44; radius: 8
                color: Theme.surfaceElevated
                border.color: Theme.cyan
                border.width: 1

                TextInput {
                    id: input
                    objectName: "lockInput"
                    anchors.fill: parent
                    anchors.margins: 12
                    focus: true
                    echoMode: TextInput.Password
                    color: Theme.textPrimary
                    font.pixelSize: 16
                    verticalAlignment: TextInput.AlignVCenter
                    onAccepted: {
                        if (pam.active || text === "") return
                        root.password = text
                        text = ""
                        root.message = ""
                        pam.start()
                    }
                }
            }
        }
    }
}
