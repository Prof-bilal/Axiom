import QtQuick
import Quickshell
import qs.src.shared
import qs.apps.shared
import "installfile.js" as IF

// Click-to-install: a small progress window for one downloaded file. Opened by
// the desktop's file handler (axiom-app quickinstall <file>), so the user never
// opens an installer app. It installs at once, shows the step it is on, and
// closes itself shortly after success. Errors stay on screen until closed.
AppWindow {
    id: root

    title: "Installing"
    implicitWidth: 420
    implicitHeight: 200
    minimumSize: Qt.size(420, 200)
    maximumSize: Qt.size(420, 200)

    property string path: ""
    property string fileName: ""
    property string kindLabel: ""
    property string phase: "working"   // working | done | error
    property int step: 0
    property int total: 1
    property string stepText: "Starting…"
    property string message: ""

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
        path = toPath(Quickshell.env("AXIOM_APP_ARG"))
        if (path.length === 0) {
            phase = "error"; message = "No file to install."; return
        }
        fileName = path.split("/").pop()
        var c = IF.classify(fileName)
        if (!c) {
            phase = "error"; message = "That file type can't be installed."; return
        }
        kindLabel = c.label
        installer.install(path, function (r) {
            phase = r.ok ? "done" : "error"
            message = r.message
            if (r.ok) { step = total; autoClose.start() }
        }, function (s, t, text) { step = s; total = t; stepText = text })
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingMd

        Text {
            width: parent.width
            elide: Text.ElideMiddle
            text: root.phase === "done" ? "Installed" : root.phase === "error" ? "Could not install" : "Installing " + root.fileName
            color: root.phase === "error" ? Theme.orangeBright : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontTitle
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            elide: Text.ElideMiddle
            text: root.kindLabel
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
        }

        // Step progress: the bar fills as each stage of the install completes.
        Rectangle {
            width: parent.width
            height: 8
            radius: 4
            color: Theme.surfaceElevated
            visible: root.phase !== "error"
            Rectangle {
                height: parent.height
                radius: 4
                color: Theme.cyan
                width: parent.width * (root.phase === "done" ? 1 : Math.max(0.08, (root.step - 0.5) / Math.max(1, root.total)))
                Behavior on width { NumberAnimation { duration: 250 } }
            }
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            text: root.phase === "working" ? root.stepText : root.message
            color: root.phase === "error" ? Theme.orangeBright : Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }

        Item { width: 1; height: Theme.spacingSm }

        Row {
            anchors.right: parent.right
            spacing: Theme.spacingSm
            AppButton {
                text: root.phase === "working" ? "Hide" : "Close"
                onClicked: Qt.quit()
            }
        }
    }
}
