import QtQuick
import qs.src.shared
import qs.apps.shared
import "installfile.js" as IF

// Axiom App Installer. Layout: a path bar (paste a path or drop a file, Browse),
// a card with the file's facts, then one progress row with a bar and Cancel.
// Nothing installs until the user presses Install.
AppWindow {
    id: root

    title: "App Installer"
    implicitWidth: 640
    implicitHeight: 560
    minimumSize: Qt.size(560, 480)

    InstallFile { id: installer }

    property var info: null
    property var found: []
    property bool browsing: false
    property string status: ""
    property bool statusIsError: false
    property bool busy: false
    property int step: 0
    property int total: 3
    property string stepText: ""

    readonly property int percent: busy ? Math.min(95, Math.round(100 * Math.max(0, step - 0.5) / Math.max(1, total)))
                                        : (info && status.indexOf("Installed") === 0 ? 100 : 0)

    function pick(path) {
        status = "Reading file…"; statusIsError = false; browsing = false
        installer.inspect(path, function (i) {
            if (!i) { info = null; status = "That file can't be read or isn't a supported package."; statusIsError = true; return }
            i.path = path
            info = i
            status = ""
        })
    }

    function install() {
        busy = true; step = 1; total = 3; stepText = "Starting…"
        status = ""; statusIsError = false
        installer.install(info.path, function (r) {
            busy = false
            statusIsError = !r.ok
            status = r.message
        }, function (s, t, text) { step = s; total = t; stepText = text })
    }

    Component.onCompleted: installer.candidates(function (list) {
        found = list
        if (list.length === 0) status = "No AppImage, Flatpak or package files in Downloads yet."
    })

    component FieldRow: Row {
        property string label: ""
        property string value: ""
        property bool mono: false
        spacing: Theme.spacingLg
        Text {
            width: 96
            text: parent.label
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
        Text {
            width: root.width - 96 - Theme.spacingXl * 4
            wrapMode: Text.WrapAnywhere
            text: parent.value
            color: parent.mono ? Theme.textSecondary : Theme.textPrimary
            font.family: parent.mono ? Theme.fontFamilyMono : Theme.fontFamily
            font.pixelSize: parent.mono ? Theme.fontCaption : Theme.fontBody
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingLg

        // ---- path bar ----
        Row {
            width: parent.width
            spacing: Theme.spacingSm

            Rectangle {
                id: pathBox
                width: parent.width - browseButton.width - Theme.spacingSm
                height: 40
                radius: 20
                color: Theme.surfaceElevated
                border.width: 1
                border.color: pathInput.activeFocus ? Theme.stateFocus : Theme.border

                Text {
                    id: glyph
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: "⌕"
                    color: Theme.textSecondary
                    font.pixelSize: 16
                }
                TextInput {
                    id: pathInput
                    anchors.left: glyph.right
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    selectByMouse: true
                    clip: true
                    onAccepted: root.pick(text.trim())
                }
                Text {
                    visible: pathInput.text.length === 0
                    anchors.left: glyph.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Paste path, URL, or drop a file…"
                    color: Theme.textDisabled
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
            }

            AppButton {
                id: browseButton
                height: 40
                text: "Browse"
                onClicked: root.browsing = !root.browsing
            }
        }

        // Files in Downloads, shown when Browse is open.
        Rectangle {
            visible: root.browsing
            width: parent.width
            height: Math.min(root.found.length, 5) * 32 + 12
            radius: 12
            color: Theme.surfaceElevated
            border.width: 1
            border.color: Theme.border
            Column {
                anchors.fill: parent
                anchors.margins: 6
                Repeater {
                    model: root.found
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 32
                        radius: Theme.radiusControl
                        color: pick.containsMouse ? Theme.stateHover : "transparent"
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            text: modelData.name
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontBody
                        }
                        MouseArea {
                            id: pick
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.pick(modelData.path)
                        }
                    }
                }
            }
        }

        // ---- file card ----
        Rectangle {
            width: parent.width
            height: facts.implicitHeight + Theme.spacingXl * 2
            radius: 14
            color: Theme.surface
            border.width: 1
            border.color: Theme.borderSubtle

            Column {
                id: facts
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingLg

                FieldRow { label: "Name"; value: root.info ? root.info.name : "—" }
                FieldRow { label: "Type"; value: root.info ? root.info.label : "—" }
                FieldRow { label: "Size"; value: root.info ? IF.formatSize(root.info.size) : "—" }
                FieldRow { label: "SHA-256"; value: root.info ? root.info.sha256 : "—"; mono: true }
                Text {
                    visible: !root.info
                    text: "Choose a file to see what it installs."
                    color: Theme.textDisabled
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }
            }
        }

        // ---- progress row: step text, percent, Cancel ----
        Column {
            width: parent.width
            spacing: Theme.spacingSm
            visible: root.busy || (root.status.length > 0 && root.info !== null && root.statusIsError === false)

            Row {
                width: parent.width
                spacing: Theme.spacingSm
                Text {
                    width: parent.width - pctText.width - cancelButton.width - Theme.spacingSm * 2
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    text: root.busy ? (root.stepText.length > 0 ? root.stepText : "Installing…") : root.status
                    color: root.statusIsError ? Theme.orangeBright : Theme.cyanBright
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
                Text {
                    id: pctText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.percent + "%"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: Theme.fontCaption
                }
                AppButton {
                    id: cancelButton
                    visible: root.busy
                    enabled: false
                    text: "Cancel"
                }
            }
            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: Theme.surfaceElevated
                clip: true
                Rectangle {
                    height: parent.height
                    radius: 3
                    color: Theme.cyan
                    width: Math.max(parent.height, parent.width * root.percent / 100)
                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
            }
        }

        // Errors and messages that are not progress.
        Text {
            visible: !root.busy && root.status.length > 0 && (root.statusIsError || root.info === null)
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.status
            color: root.statusIsError ? Theme.orangeBright : Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }

        Item { width: 1; height: Theme.spacingSm }

        // ---- actions ----
        Row {
            anchors.right: parent.right
            spacing: Theme.spacingSm
            AppButton { text: "Close"; onClicked: Qt.quit() }
            AppButton {
                text: root.busy ? "Installing…" : "Install"
                primary: true
                enabled: root.info !== null && !root.busy
                onClicked: root.install()
            }
        }
    }
}
