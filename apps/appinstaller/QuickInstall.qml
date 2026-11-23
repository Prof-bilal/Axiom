import QtQuick
import Quickshell
import qs.src.shared
import qs.apps.shared
import "installfile.js" as IF

// Click-to-install: a small progress window for one downloaded file. Opened by
// the desktop's file handler (axiom-app quickinstall <file>), so the user never
// opens an installer app. It installs at once, shows what it is doing, and
// closes itself shortly after success. Errors stay on screen until closed.
//
// AXIOM_QUICKINSTALL_PREVIEW=working|done|error shows a state without
// installing anything (screenshots only; off by default).
AppWindow {
    id: root

    title: "Installing"
    implicitWidth: 460
    implicitHeight: 560
    minimumSize: Qt.size(460, 560)
    maximumSize: Qt.size(460, 560)

    property string path: ""
    property string fileName: ""
    property string kindLabel: ""
    property string phase: "working"   // working | done | error
    property int step: 0
    property int total: 1
    property string stepText: "Starting…"
    property string message: ""
    // Facts from the install (ADR-032): signature result and where the app goes.
    property string signature: "checking"   // checking | verified | unsigned | failed | not-checked
    property string auditId: ""
    property string target: ""      // where the app was installed (for Launch app)
    readonly property bool blocked: phase === "error" && signature === "failed"
    readonly property string scope: fileName.toLowerCase().endsWith(".appimage") ? "User sandbox · no root" : "System-wide · admin"

    readonly property string appName: IF.displayName(fileName)
    // Step progress: each finished stage moves the bar. Held below 100 until the install really ends.
    readonly property int percent: phase === "done" ? 100 : phase === "error" ? 0
                                   : Math.min(95, Math.round(100 * Math.max(0, step - 0.5) / Math.max(1, total)))

    // The launcher hands the file over as a path or a file:// URI.
    function toPath(arg) {
        if (!arg) return ""
        return arg.indexOf("file://") === 0 ? decodeURIComponent(arg.slice(7)) : arg
    }

    InstallFile { id: installer }

    Timer {
        id: autoClose
        interval: 2500
        onTriggered: Qt.quit()
    }

    Component.onCompleted: {
        var preview = Quickshell.env("AXIOM_QUICKINSTALL_PREVIEW")
        if (preview) {
            fileName = "Axiom-Demo-App-1.2.3-x86_64.AppImage"; kindLabel = "AppImage"
            phase = preview === "done" ? "done" : (preview === "error" || preview === "blocked") ? "error" : "working"
            if (preview === "done") { auditId = "ax-7f3a91c20b4e-m3k9x2"; target = "/home/user/Applications/Axiom-Demo-App-1.2.3-x86_64.AppImage"; signature = "verified" }
            if (preview === "blocked") signature = "failed"
            step = 2; total = 3; stepText = "Adding it to your app menu…"
            message = preview === "error" ? "The file could not be copied: no space left on device."
                    : preview === "blocked" ? "Signature does not match this file. Install blocked."
                    : "Installed to ~/Applications"
            return
        }
        path = toPath(Quickshell.env("AXIOM_APP_ARG"))
        if (path.length === 0) { phase = "error"; message = "No file to install."; return }
        fileName = path.split("/").pop()
        var c = IF.classify(fileName)
        if (!c) { phase = "error"; message = "That file type can't be installed."; return }
        kindLabel = c.label
        installer.install(path, function (r) {
            phase = r.ok ? "done" : "error"
            message = r.message
            if (r.signature) root.signature = r.signature
            if (r.auditId) root.auditId = r.auditId
            if (r.target) root.target = r.target
            else if (!r.ok && root.signature === "checking") root.signature = "not-checked"
            if (r.ok) { step = total; autoClose.start() }
        }, function (s, t, text) { step = s; total = t; stepText = text })
    }

    Column {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        // ---- who and what ----
        Row {
            width: parent.width
            spacing: 16

            Rectangle {
                id: tile
                width: 56; height: 56; radius: 14
                color: root.phase === "error" ? Theme.stateUrgentWash : Theme.stateSelected
                border.width: 1
                border.color: root.phase === "error" ? Theme.dangerMuted : Theme.stateSelectedBorder

                // Done: a check mark. Error: a cross. Working: the app's first letter.
                Canvas {
                    anchors.centerIn: parent
                    width: 28; height: 28
                    visible: root.phase !== "working"
                    property bool ok: root.phase === "done"
                    onOkChanged: requestPaint()
                    onPaint: {
                        var c = getContext("2d")
                        c.clearRect(0, 0, width, height)
                        c.lineWidth = 3; c.lineCap = "round"; c.lineJoin = "round"
                        c.strokeStyle = ok ? (Theme.light ? "#C26A00" : "#FFB348") : (Theme.light ? "#C62828" : "#FF8A80")
                        c.beginPath()
                        if (ok) { c.moveTo(5, 15); c.lineTo(11, 21); c.lineTo(23, 7) }
                        else { c.moveTo(7, 7); c.lineTo(21, 21); c.moveTo(21, 7); c.lineTo(7, 21) }
                        c.stroke()
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: root.phase === "working"
                    text: root.appName.charAt(0)
                    color: Theme.accentBright
                    font.family: Theme.fontFamily
                    font.pixelSize: 26
                    font.weight: Font.DemiBold
                }
            }

            Column {
                width: parent.width - tile.width - 16
                anchors.verticalCenter: tile.verticalCenter
                spacing: 3
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: root.appName
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: (root.kindLabel.length > 0 ? root.kindLabel + "  ·  " : "")
                          + (root.phase === "done" ? "Installed" : root.phase === "error" ? "Could not install" : "Installing")
                    color: root.phase === "error" ? Theme.dangerBright : root.phase === "done" ? Theme.accentBright : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
            }
        }

        // ---- capability, scope and signature (ADR-032) ----
        Rectangle {
            width: parent.width
            height: facts.implicitHeight + 20
            radius: 10
            color: Theme.surfaceElevated
            border.width: 1
            border.color: Theme.borderSubtle
            Column {
                id: facts
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                spacing: 6
                Repeater {
                    model: [
                        { k: "Capability", v: root.kindLabel.length > 0 ? "Install " + root.kindLabel : "Install a file" },
                        { k: "Scope", v: root.scope },
                        { k: "Signature", v: root.signature === "verified" ? "Verified (minisign)"
                                          : root.signature === "unsigned" ? "Unsigned · needs admin approval"
                                          : root.signature === "failed" ? "Does not match: blocked"
                                          : root.signature === "not-checked" ? "Not checked"
                                          : "Checking…" }
                    ]
                    delegate: Row {
                        required property var modelData
                        width: facts.width
                        Text {
                            width: 90
                            text: modelData.k
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontCaption
                        }
                        Text {
                            width: parent.width - 90
                            elide: Text.ElideRight
                            text: modelData.v
                            color: modelData.k === "Signature" && root.signature === "verified" ? Theme.accentBright
                                 : modelData.k === "Signature" && (root.signature === "failed" || root.signature === "unsigned") ? Theme.dangerBright
                                 : Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontCaption
                        }
                    }
                }
            }
        }

        // ---- format pills (the file's type is highlighted) ----
        Row {
            width: parent.width
            spacing: 6
            visible: root.phase !== "done" && !root.blocked
            Repeater {
                model: ["AppImage · Portable", ".deb", ".pkg.tar.zst"]
                delegate: Rectangle {
                    required property string modelData
                    readonly property bool on: root.kindLabel.indexOf(modelData.split(" ")[0].replace(".", "")) >= 0
                              || (modelData === ".pkg.tar.zst" && root.kindLabel.indexOf("Arch") >= 0)
                              || (modelData === ".deb" && root.kindLabel.indexOf("Debian") >= 0)
                    height: 26
                    width: pillLabel.implicitWidth + 22
                    radius: 13
                    color: on ? Theme.stateSelected : "transparent"
                    border.width: 1
                    border.color: on ? Theme.stateSelectedBorder : Theme.borderSubtle
                    Text {
                        id: pillLabel
                        anchors.centerIn: parent
                        text: modelData
                        color: parent.on ? Theme.accentBright : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                    }
                }
            }
        }

        // ---- policy blocked (signature does not match) ----
        Rectangle {
            visible: root.blocked
            width: parent.width
            height: blockCol.implicitHeight + 20
            radius: 10
            color: Theme.stateUrgentWash
            border.width: 1
            border.color: Theme.dangerMuted
            Column {
                id: blockCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                spacing: 4
                Text {
                    text: "Installation blocked by policy"
                    color: Theme.dangerBright
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "The signature does not match this file. Policy: failed signatures are never installed."
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }
            }
        }

        // ---- progress checklist (each step turns on from the real install step) ----
        Column {
            width: parent.width
            spacing: 6
            visible: root.phase === "working"
            Repeater {
                model: [
                    { t: "SHA-256 verified", on: root.step >= 1 },
                    { t: "Sandbox isolated", on: root.step >= 3 },
                    { t: "Registering desktop entry", on: root.step >= 4 }
                ]
                delegate: Row {
                    required property var modelData
                    spacing: 8
                    Text {
                        text: modelData.on ? "✔" : "○"
                        color: modelData.on ? Theme.accentBright : Theme.textDisabled
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                    }
                    Text {
                        text: modelData.t
                        color: modelData.on ? Theme.textPrimary : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                    }
                }
            }
        }

        // ---- done card: status, audit ID and desktop entry ----
        Rectangle {
            visible: root.phase === "done"
            width: parent.width
            height: doneCol.implicitHeight + 20
            radius: 10
            color: Theme.stateSelected
            border.width: 1
            border.color: Theme.stateSelectedBorder
            Column {
                id: doneCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                spacing: 6
                Repeater {
                    model: [
                        { k: "Status", v: root.signature === "verified" ? "Verified & sandboxed" : "Installed to user sandbox" },
                        { k: "Audit ID", v: root.auditId.length > 0 ? root.auditId : "not recorded" },
                        { k: "Desktop entry", v: root.target.length > 0 ? root.target : "" }
                    ]
                    delegate: Row {
                        required property var modelData
                        width: doneCol.width
                        visible: modelData.v.length > 0
                        Text {
                            width: 100
                            text: modelData.k
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontCaption
                        }
                        Text {
                            width: parent.width - 100
                            elide: Text.ElideMiddle
                            text: modelData.v
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontCaption
                        }
                    }
                }
            }
        }

        // ---- progress ----
        Column {
            width: parent.width
            spacing: 8
            visible: root.phase !== "error"

            Rectangle {
                id: track
                width: parent.width
                height: 6
                radius: 3
                color: Theme.surfaceElevated
                clip: true
                Rectangle {
                    id: fill
                    height: parent.height
                    radius: 3
                    color: Theme.accent
                    width: Math.max(parent.height, parent.width * root.percent / 100)
                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
            }

            Row {
                width: parent.width
                Text {
                    width: parent.width - pct.width
                    elide: Text.ElideRight
                    text: root.phase === "done" ? root.message : root.stepText
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }
                Text {
                    id: pct
                    text: root.percent + "%"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: Theme.fontCaption
                }
            }
        }

        // ---- error detail ----
        Rectangle {
            visible: root.phase === "error"
            width: parent.width
            height: errorText.implicitHeight + 20
            radius: 10
            color: Theme.surfaceElevated
            border.width: 1
            border.color: Theme.borderSubtle
            Text {
                id: errorText
                anchors.fill: parent
                anchors.margins: 10
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                elide: Text.ElideRight
                text: root.message
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }
        }
    }

    // Launch app (sandboxed) and Done; hidden while the install is running, because closing would stop it.
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 8
        visible: root.phase !== "working"
        AppButton {
            visible: root.phase === "done" && root.target.length > 0
            text: "Launch app"
            primary: true
            onClicked: Quickshell.execDetached(IF.sandboxArgv(root.target))
        }
        AppButton {
            text: root.phase === "done" ? "Done" : "Close"
            onClicked: Qt.quit()
        }
    }
}
