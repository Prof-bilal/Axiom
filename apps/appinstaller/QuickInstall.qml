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
    implicitHeight: 230
    minimumSize: Qt.size(460, 230)
    maximumSize: Qt.size(460, 230)

    property string path: ""
    property string fileName: ""
    property string kindLabel: ""
    property string phase: "working"   // working | done | error
    property int step: 0
    property int total: 1
    property string stepText: "Starting…"
    property string message: ""

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
            phase = preview === "done" ? "done" : preview === "error" ? "error" : "working"
            step = 2; total = 3; stepText = "Adding it to your app menu…"
            message = preview === "error" ? "The file could not be copied: no space left on device." : "Installed to ~/Applications"
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
                border.color: root.phase === "error" ? Theme.orangeMuted : Theme.stateSelectedBorder

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
                        c.strokeStyle = ok ? "#37F0EA" : "#FFB348"
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
                    color: Theme.cyanBright
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
                    color: root.phase === "error" ? Theme.orangeBright : root.phase === "done" ? Theme.cyanBright : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
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
                    color: Theme.cyan
                    width: Math.max(parent.height, parent.width * root.percent / 100)
                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    // A light sweep while work is in progress, so a long step still looks alive.
                    Rectangle {
                        visible: root.phase === "working"
                        width: 48; height: parent.height
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: "transparent" }
                            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.35) }
                            GradientStop { position: 1; color: "transparent" }
                        }
                        NumberAnimation on x { from: -48; to: fill.width; duration: 1100; loops: Animation.Infinite }
                    }
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

    // Done or Close; hidden while the install is running, because closing would stop it.
    AppButton {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        visible: root.phase !== "working"
        primary: root.phase === "done"
        text: root.phase === "done" ? "Done" : "Close"
        onClicked: Qt.quit()
    }
}
