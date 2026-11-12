// Axiom login screen (Phase 6): a Quickshell greeter over greetd.
//
// greetd starts this with GREETD_SOCK set, inside a PAM session for the
// unprivileged `greeter` user; labwc is the throwaway compositor. The password
// only moves from the text field to Greetd.respond() in memory: it is never
// written, logged or put in an environment variable. Accounts come from the
// passwd list that axiom-greeter snapshots before it starts this shell.
//
// Look follows shell/src/session/LockScreen.qml (same palette, same card
// proportions) without importing the shell's services, because the greeter
// must run without a user session or session bus.
//@ pragma AppId org.axiom.Greeter

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd
import Quickshell.Wayland

ShellRoot {
    id: root

    // --- design tokens (kept in step with shell/src/shared/Theme.qml) ---
    readonly property color background: "#070B0D"
    readonly property color surfaceElevated: "#11191D"
    readonly property color border: "#233238"
    readonly property color textPrimary: "#EDF5F5"
    readonly property color textSecondary: "#8EA2A5"
    readonly property color cyan: "#20D6D2"
    readonly property color orangeBright: "#FFB348"

    readonly property string wrongPassword: "That password didn't work. Try again."
    readonly property string lockedOut: "Too many wrong tries. Please wait a few minutes and try again."
    readonly property string readyPath: Quickshell.env("AXIOM_GREETER_READY") || ""
    readonly property var sessionCommand: ["/usr/local/bin/axiom-session"]
    readonly property var sessionEnv: [
        "XDG_SESSION_TYPE=wayland",
        "XDG_SESSION_DESKTOP=axiom",
        "XDG_CURRENT_DESKTOP=Axiom"
    ]

    property var accounts: []
    property int selected: 0
    property string pending: ""
    property bool awaiting: false
    property string prompt: "Password"
    property bool secret: true
    property string message: ""
    property bool messageIsError: false
    property bool busy: false
    property bool greeting: false
    property bool authFailed: false

    function account() {
        if (accounts.length === 0) return null
        return accounts[Math.max(0, Math.min(selected, accounts.length - 1))]
    }

    function friendly(text) {
        var low = (text || "").toLowerCase()
        if (low.indexOf("lock") >= 0 || low.indexOf("too many") >= 0 || low.indexOf("temporar") >= 0)
            return lockedOut
        return wrongPassword
    }

    function resetPrompt() {
        pending = ""
        awaiting = false
        prompt = "Password"
        secret = true
        input.text = ""
    }

    function submit() {
        if (busy || greeting || !Greetd.available || accounts.length === 0) return
        var typed = input.text
        input.text = ""
        message = ""
        authFailed = false
        if (awaiting) {
            // A non-secret PAM prompt (for example a one-time code) is waiting.
            awaiting = false
            busy = true
            Greetd.respond(typed)
            return
        }
        if (typed.length === 0) return
        // createSession triggers the PAM prompt; the answer is held only until
        // greetd asks for it, then cleared.
        pending = typed
        busy = true
        Greetd.createSession(account().name)
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            root.messageIsError = error
            if (!responseRequired) {
                // Informative PAM text (fingerprint retries, expiry warnings).
                root.message = message
                return
            }
            if (root.pending.length > 0) {
                // The usual path: answer the secret prompt with the typed password.
                const answer = root.pending
                root.pending = ""
                root.awaiting = false
                root.secret = true
                Greetd.respond(answer)
                return
            }
            root.awaiting = true
            root.secret = !echoResponse
            root.prompt = (message || "Password").trim()
            root.message = ""
            input.forceActiveFocus()
        }

        function onAuthFailure(message) {
            root.busy = false
            root.resetPrompt()
            root.authFailed = true
            root.messageIsError = true
            root.message = root.friendly(message)
            input.forceActiveFocus()
        }

        function onReadyToLaunch() {
            root.greeting = true
            root.messageIsError = false
            root.message = "Signing in..."
            // greetd exits this greeter as soon as it has the session request.
            Greetd.launch(root.sessionCommand, root.sessionEnv)
        }

        function onError(error) {
            // A bad password is authFailure, but greetd can also end the attempt with a
            // generic error (and may report both). Anything that arrives while we are
            // authenticating is a failed sign-in, not a broken login service.
            const duringAuth = root.busy || root.awaiting || root.pending.length > 0
                || root.authFailed
            root.busy = false
            root.resetPrompt()
            root.messageIsError = true
            root.message = duringAuth ? root.friendly(error)
                                     : "Sign-in is not available right now. Try again."
            input.forceActiveFocus()
        }
    }

    // Readiness marker: the dispatcher trusts this graphical greeter only if the
    // QML actually loaded; without it, a compositor that exits cleanly after a
    // QML failure would otherwise never reach the curses fallback.
    Process {
        running: root.readyPath.length > 0
        command: ["/usr/bin/touch", root.readyPath]
    }

    // axiom-greeter writes this before starting the compositor: login name and
    // full name only, nothing secret.
    FileView {
        id: accountsFile
        path: Quickshell.env("AXIOM_GREETER_USERS") || ""
        watchChanges: false
        onLoaded: {
            try {
                root.accounts = JSON.parse(accountsFile.text())
                root.selected = 0
            } catch (e) {
                root.accounts = []
                root.messageIsError = true
                root.message = "The account list could not be read."
            }
        }
        onLoadFailed: {
            root.messageIsError = true
            root.message = "The account list could not be read."
        }
    }

    PanelWindow {
        id: window
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; left: true; right: true; bottom: true }
        exclusionMode: ExclusionMode.Ignore
        color: root.background
        WlrLayershell.namespace: "axiom-greeter"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrLayershell.Exclusive

        Item {
            id: page
            anchors.fill: parent
            focus: true

            // Penguin with a gentle bob (about 6 px, 2 s period), matching the Plymouth splash.
            Image {
                id: penguin
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 2 - 250
                width: 140; height: 140
                source: Qt.resolvedUrl("assets/axiom-penguin.png")
                fillMode: Image.PreserveAspectFit
                smooth: true
                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation { to: page.height / 2 - 258; duration: 1000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: page.height / 2 - 242; duration: 1000; easing.type: Easing.InOutSine }
                }
            }

            // Big Axiom wordmark under the penguin, as on the installer and lock screen.
            Image {
                id: nameLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: penguin.bottom
                anchors.topMargin: 18
                height: 76
                fillMode: Image.PreserveAspectFit
                source: Qt.resolvedUrl("assets/axiom-wordmark.png")
                smooth: true
            }

            Text {
                id: userLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: nameLabel.bottom
                anchors.topMargin: 14
                text: root.account()
                      ? (root.accounts.length > 1 ? "< " : "") + root.account().display + (root.accounts.length > 1 ? " >" : "")
                      : "No local accounts are available."
                color: root.textSecondary
                font.pixelSize: 13
            }

            Rectangle {
                id: field
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: userLabel.bottom
                anchors.topMargin: 22
                width: 320; height: 44; radius: 8
                color: root.surfaceElevated
                border.color: root.authFailed ? root.orangeBright : root.cyan
                border.width: 1
                opacity: root.account() ? 1 : 0.5

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.textPrimary
                    font.pixelSize: 16
                    echoMode: root.secret ? TextInput.Password : TextInput.Normal
                    passwordCharacter: "*"
                    readOnly: root.busy || root.greeting || !root.account()
                    enabled: root.account() !== null
                    focus: true
                    onAccepted: root.submit()
                    Keys.onEscapePressed: root.resetPrompt()
                    // Left/Right switch the account when there is more than one (TextInput would
                    // otherwise use them for cursor movement; BeforeItem lets this run first).
                    Keys.priority: Keys.BeforeItem
                    Keys.onLeftPressed: (event) => { if (root.accounts.length > 1 && !root.busy && !root.greeting && input.text.length === 0) { root.selected = (root.selected + root.accounts.length - 1) % root.accounts.length; event.accepted = true } }
                    Keys.onRightPressed: (event) => { if (root.accounts.length > 1 && !root.busy && !root.greeting && input.text.length === 0) { root.selected = (root.selected + 1) % root.accounts.length; event.accepted = true } }
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: input.text.length === 0
                        text: root.awaiting ? root.prompt : "Password"
                        color: root.textSecondary
                        font.pixelSize: 16
                    }
                }
            }

            Text {
                id: messageLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: field.bottom
                anchors.topMargin: 14
                width: 420
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: root.message
                color: root.messageIsError ? root.orangeBright : root.textSecondary
                font.pixelSize: 14
            }
        }

        Component.onCompleted: input.forceActiveFocus()
    }
}
