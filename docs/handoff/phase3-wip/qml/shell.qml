// Axiom installer (Phase 3, ADR 026): the curses installer's layout, drawn with Quickshell.
//
// Layout follows the reference screen: wordmark, step bar, title, rows with "< value >", Continue,
// hint line, key footer. The installer runs as the live user `axiom`; the root work goes through the
// socket to axiom-installd. Passwords are sent, never stored or logged.
// Keys: Up/Down move, Left/Right change a value, type on text rows, Enter continue, Esc back.
//@ pragma AppId org.axiom.Installer

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    readonly property color background: "#070B0D"
    readonly property color rowBg: "#2A373D"
    readonly property color textPrimary: "#EDF5F5"
    readonly property color textSecondary: "#8EA2A5"
    readonly property color cyan: "#20D6D2"
    readonly property color orangeBright: "#FFB348"

    readonly property var stepNames: ["Language and time", "Your computer", "Choose a disk", "Confirm", "Installing", "Done"]
    readonly property var stepIntros: [
        "Tell Axiom how you type and where you are. You can change these later in Settings.",
        "Name this computer and create the account you will sign in with.",
        "Pick the disk Axiom will be installed on. Everything on it will be erased.",
        "Type ERASE (in capitals) to confirm. This cannot be undone.",
        "Installing Axiom. Please keep the computer on.",
        "Axiom is installed. Remove the install medium and restart."
    ]
    readonly property var stepHints: [
        "Left/Right change. Pick the layout printed on your keys.",
        "At least 10 characters. Avoid common words.",
        "Left/Right change the disk.",
        "Type ERASE to continue.",
        "",
        ""
    ]

    readonly property var locales: ["en_US", "en_GB", "de_DE", "fr_FR", "es_ES", "it_IT", "pt_BR", "nl_NL", "pl_PL", "ru_RU", "tr_TR", "ja_JP", "zh_CN"]
    readonly property var keymaps: ["us", "uk", "de", "fr", "es", "it", "br"]
    readonly property var regions: ["UTC", "Europe", "America", "Asia", "Australia", "Africa"]
    readonly property var cities: ({
        "UTC": ["UTC"],
        "Europe": ["Berlin", "London", "Paris"],
        "America": ["New_York", "Chicago", "Los_Angeles"],
        "Asia": ["Karachi", "Kolkata", "Tokyo"],
        "Australia": ["Sydney"],
        "Africa": ["Cairo"]
    })

    property int step: 0
    property int focusRow: 0
    property string message: ""
    property bool messageIsError: false
    property bool busy: false

    property var values: ({
        locale: "en_US", keyboard: "us", region: "UTC", city: "UTC",
        hostname: "axiom", fullname: "", username: "", password: "", password_confirm: "",
        git_name: "", git_email: ""
    })
    property var disks: []
    property int diskIndex: 0
    property string confirmText: ""
    property int pct: 0
    property string stage: ""
    property string detail: ""
    property int eventsSeen: 0
    property int etaMin: -1

    // ---- backend socket ---------------------------------------------------------------------------
    Socket {
        id: link
        path: "/run/axiom/installd.sock"
        connected: true
        parser: SplitParser {
            splitMarker: "\n"
            onRead: data => root.onReply(data)
        }
    }

    function send(req) {
        link.write(JSON.stringify(req) + "\n")
        link.flush()
    }

    function onReply(line) {
        var r
        try { r = JSON.parse(line) } catch (e) { fail("The installer service sent an unreadable reply."); return }
        if (r.ok === false) { fail(r.error || "The installer service refused the request."); return }
        if (r.disks !== undefined) { disks = r.disks; busy = false; return }
        if (r.events !== undefined) {
            for (var i = 0; i < r.events.length; i++) onEvent(r.events[i])
            eventsSeen += r.events.length
        }
    }

    function onEvent(ev) {
        if (ev.event === "progress") { pct = ev.pct; stage = ev.stage; detail = ev.detail || ""; etaMin = (ev.eta_min === undefined) ? -1 : ev.eta_min }
        else if (ev.event === "done") { pct = 100; step = 5; focusRow = 0 }
        else if (ev.event === "error") fail(ev.message || "The installation stopped.")
    }

    function fail(text) {
        busy = false
        messageIsError = true
        message = text
    }

    Timer {
        id: poll
        interval: 1000
        repeat: true
        running: root.step === 4
        onTriggered: root.send({ op: "status", since: root.eventsSeen })
    }

    // ---- rows per step ----------------------------------------------------------------------------
    // kind: choice (arrows), text (typing), disk (arrows), action (Continue)
    function rows() {
        if (step === 0) return [
            { kind: "choice", key: "locale", label: "Language", list: locales },
            { kind: "choice", key: "keyboard", label: "Keyboard", list: keymaps },
            { kind: "choice", key: "region", label: "Region", list: regions },
            { kind: "choice", key: "city", label: "Time zone", list: cities[values.region] || ["UTC"] },
            { kind: "action", label: "Continue" }
        ]
        if (step === 1) return [
            { kind: "text", key: "hostname", label: "PC name" },
            { kind: "text", key: "fullname", label: "Your name" },
            { kind: "text", key: "username", label: "Username" },
            { kind: "text", key: "password", label: "Password", secret: true },
            { kind: "text", key: "password_confirm", label: "Repeat password", secret: true },
            { kind: "action", label: "Continue" }
        ]
        if (step === 2) {
            var r = []
            r.push({ kind: "disk", label: "Disk" })
            r.push({ kind: "action", label: "Continue" })
            return r
        }
        if (step === 3) return [
            { kind: "text", key: "confirm", label: "Type ERASE" },
            { kind: "action", label: "Continue" }
        ]
        return []
    }

    function currentList(r) {
        return r.list
    }

    function setChoice(r, dir) {
        var i = r.list.indexOf(values[r.key])
        i = (i + dir + r.list.length) % r.list.length
        var v = Object.assign({}, values)
        v[r.key] = r.list[i]
        if (r.key === "region") v.city = (cities[v.region] || ["UTC"])[0]
        values = v
    }

    function textOf(key) { return key === "confirm" ? confirmText : values[key] }

    function setText(key, text) {
        if (key === "confirm") { confirmText = text; return }
        var v = Object.assign({}, values)
        v[key] = text
        values = v
    }

    function timezoneName() {
        return values.region === "UTC" ? "UTC" : values.region + "/" + values.city
    }

    function formPayload() {
        var f = Object.assign({}, values)
        delete f.password_confirm
        delete f.region
        delete f.city
        f.timezone = timezoneName()
        f.luks = false
        f.hub = []
        return f
    }

    function next() {
        message = ""
        messageIsError = false
        if (step === 0) { step = 1; focusRow = 0; return }
        if (step === 1) {
            if (values.password !== values.password_confirm) { fail("The two passwords do not match."); return }
            busy = true
            send({ op: "validate", form: formPayload() })
            step = 2
            focusRow = 0
            send({ op: "list_disks" })
            return
        }
        if (step === 2) {
            if (disks.length === 0) { fail("No disk found. Attach a disk and try again."); return }
            step = 3
            focusRow = 0
            return
        }
        if (step === 3) {
            if (confirmText !== "ERASE") { fail("Type ERASE (in capitals) to confirm the install."); return }
            var d = disks[diskIndex]
            busy = true
            // Same start as the GitHub curses installer: show 2% and "Preparing the disk" at once.
            pct = 2; stage = "Preparing the disk"; detail = ""; etaMin = -1
            send({ op: "start_install", form: formPayload(), disk: d.path, disk_bytes: d.size })
            step = 4
        }
    }

    function back() {
        message = ""
        messageIsError = false
        if (step > 0 && step < 4) { step -= 1; focusRow = 0 }
    }

    // ---- window -----------------------------------------------------------------------------------
    PanelWindow {
        id: window
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; left: true; right: true; bottom: true }
        exclusionMode: ExclusionMode.Ignore
        color: root.background
        WlrLayershell.namespace: "axiom-installer"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrLayershell.Exclusive

        Item {
            id: page
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (root.step === 4) return
                var rs = root.rows()
                if (root.step === 5) { event.accepted = true; return }
                var r = rs[root.focusRow]
                if (event.key === Qt.Key_Escape) { root.back(); event.accepted = true; return }
                if (event.key === Qt.Key_Down) { root.focusRow = Math.min(root.focusRow + 1, rs.length - 1); event.accepted = true; return }
                if (event.key === Qt.Key_Up) { root.focusRow = Math.max(root.focusRow - 1, 0); event.accepted = true; return }
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (r && r.kind === "action") root.next()
                    else root.focusRow = Math.min(root.focusRow + 1, rs.length - 1)
                    event.accepted = true
                    return
                }
                if (!r) return
                var dir = event.key === Qt.Key_Left ? -1 : (event.key === Qt.Key_Right ? 1 : 0)
                if (r.kind === "choice" && dir !== 0) { root.setChoice(r, dir); event.accepted = true }
                else if (r.kind === "disk" && dir !== 0) {
                    root.diskIndex = (root.diskIndex + dir + root.disks.length) % Math.max(root.disks.length, 1)
                    event.accepted = true
                } else if (r.kind === "text") {
                    if (event.key === Qt.Key_Backspace) {
                        root.setText(r.key, root.textOf(r.key).slice(0, -1)); event.accepted = true
                    } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32
                               && root.textOf(r.key).length < 64) {
                        root.setText(r.key, root.textOf(r.key) + event.text); event.accepted = true
                    }
                }
            }

            // Header: the proper Axiom wordmark (not letter-spaced pixel text).
            Image {
                id: wordmark
                anchors.horizontalCenter: parent.horizontalCenter
                y: 22
                height: 44
                fillMode: Image.PreserveAspectFit
                source: Qt.resolvedUrl("assets/axiom-wordmark.png")
                smooth: true
            }

            // Step bar: six segments, the current one lit.
            Row {
                id: stepBar
                anchors.horizontalCenter: parent.horizontalCenter
                y: 88
                spacing: 6
                Repeater {
                    model: 6
                    delegate: Rectangle {
                        required property int index
                        width: 80; height: 8; radius: 2
                        color: index <= root.step ? root.cyan : root.rowBg
                    }
                }
            }
            Text {
                id: stepLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: stepBar.bottom
                anchors.topMargin: 6
                visible: root.step < 5
                text: "Step " + (root.step + 1) + " of 6"
                color: root.textSecondary
                font.pixelSize: 13
            }

            // Penguin on the progress and done screens: grey logo, filled from the bottom in cyan.
            Item {
                id: penguinBox
                visible: root.step >= 4
                anchors.horizontalCenter: parent.horizontalCenter
                y: root.step >= 4 ? Math.max(40, parent.height / 2 - 190) : 140
                width: 220; height: 220
                Image {
                    anchors.fill: parent
                    source: Qt.resolvedUrl("assets/axiom-penguin-512.png")
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: 0.12
                }
                Item {
                    id: fill
                    width: parent.width
                    height: parent.height * (root.step === 5 ? 1 : root.pct / 100)
                    anchors.bottom: parent.bottom
                    clip: true
                    Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    Image {
                        width: penguinBox.width
                        height: penguinBox.height
                        anchors.bottom: parent.bottom
                        source: Qt.resolvedUrl("assets/axiom-penguin-512.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }
            }

            Text {
                id: pctLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: penguinBox.bottom
                anchors.topMargin: 10
                visible: root.step === 4
                text: root.pct + "%" + (root.etaMin >= 0 ? "   ·   about " + root.etaMin + " min left" : "")
                color: root.textPrimary
                font.pixelSize: 26
                font.bold: true
            }

            // Title, intro and rows (the reference layout).
            Column {
                id: body
                x: 80
                y: 150
                width: 1120
                spacing: 0
                visible: root.step < 4

                Text {
                    text: root.step < 4 ? root.stepNames[root.step] : (root.step === 4 ? "Installing" : "Done")
                    color: root.cyan
                    font.pixelSize: 20
                    font.bold: true
                }
                Item { width: 1; height: 14 }
                Text {
                    width: 900
                    wrapMode: Text.WordWrap
                    text: root.stepIntros[root.step]
                    color: root.textPrimary
                    font.pixelSize: 15
                }
                Item { width: 1; height: 26 }

                Repeater {
                    model: root.step < 4 ? root.rows() : []
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: body.width
                        height: modelData.kind === "action" ? 56 : 46

                        Text {
                            visible: modelData.kind !== "action"
                            x: 0
                            anchors.verticalCenter: parent.verticalCenter
                            width: 300
                            text: modelData.label
                            color: index === root.focusRow ? root.textPrimary : root.textSecondary
                            font.pixelSize: 16
                            font.bold: index === root.focusRow
                        }
                        Rectangle {
                            visible: modelData.kind !== "action"
                            x: 340
                            anchors.verticalCenter: parent.verticalCenter
                            width: body.width - 340
                            height: 36
                            color: index === root.focusRow ? root.cyan : root.rowBg
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                color: index === root.focusRow ? root.background : root.textPrimary
                                font.pixelSize: 16
                                text: {
                                    if (modelData.kind === "choice") return "<  " + root.values[modelData.key] + "  >"
                                    if (modelData.kind === "disk") {
                                        if (root.disks.length === 0) return "(no disk found)"
                                        var d = root.disks[root.diskIndex]
                                        return "<  " + d.path + "   " + Math.round(d.size / 1073741824) + " GB  " + d.model + "  >"
                                    }
                                    if (modelData.secret) return "*".repeat(root.textOf(modelData.key).length)
                                    return root.textOf(modelData.key)
                                }
                            }
                        }
                        Rectangle {
                            visible: modelData.kind === "action"
                            anchors.left: parent.left
                            anchors.leftMargin: 340
                            anchors.verticalCenter: parent.verticalCenter
                            width: 200
                            height: 40
                            radius: 6
                            color: index === root.focusRow ? root.cyan : "transparent"
                            border.color: root.cyan
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: index === root.focusRow ? root.background : root.cyan
                                font.pixelSize: 18
                                font.bold: index === root.focusRow
                            }
                        }
                    }
                }

                Item { width: 1; height: 16 }
                Text {
                    width: 1120
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                    text: root.message !== "" ? root.message : (root.step < 4 ? root.stepHints[root.step] : "")
                    color: root.messageIsError ? root.orangeBright : root.textSecondary
                    font.pixelSize: 14
                }
            }

            // Progress and done: centered, near the bottom (same wording as the curses installer).
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 80
                spacing: 10
                visible: root.step >= 4
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.step === 5 ? "Axiom is installed." : "Installing Axiom. Please keep the computer on."
                    color: root.textPrimary
                    font.pixelSize: 17
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.step === 4
                    text: root.stage + (root.detail !== "" ? "  ·  " + root.detail : "")
                    color: root.textSecondary
                    font.pixelSize: 14
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.step === 4 && root.message !== ""
                    width: 700
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: root.message
                    color: root.messageIsError ? root.orangeBright : root.textSecondary
                    font.pixelSize: 15
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.step === 5
                    text: "Remove the install medium and restart."
                    color: root.textSecondary
                    font.pixelSize: 14
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 26
                visible: root.step < 4
                text: "Up/Down  move      Left/Right  change      Enter  continue      Esc  go back"
                color: root.textSecondary
                font.pixelSize: 13
            }
        }

        Component.onCompleted: send({ op: "list_disks" })
    }
}
