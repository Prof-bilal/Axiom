import QtQuick
import qs.src.shared
import qs.apps.shared
import "installfile.js" as IF

// Axiom App Installer. Sections like the reference: Source, File, Install
// options; status and actions sit at the bottom. Nothing installs until the
// user presses Install.
AppWindow {
    id: root

    title: "App Installer"
    implicitWidth: 620
    implicitHeight: 560

    InstallFile { id: installer }

    property var info: null
    property var found: []
    property string status: ""
    property bool statusIsError: false
    property bool busy: false

    function pick(path) {
        status = "Reading file…"
        statusIsError = false
        installer.inspect(path, function (i) {
            if (!i) {
                info = null
                status = "That file can't be read or isn't a supported package."
                statusIsError = true
                return
            }
            i.path = path
            info = i
            status = ""
        })
    }

    function install() {
        busy = true
        status = "Installing " + info.name + "…"
        statusIsError = false
        installer.install(info.path, function (r) {
            busy = false
            statusIsError = !r.ok
            status = r.message
        })
    }

    Component.onCompleted: installer.candidates(function (list) {
        found = list
        if (list.length === 0) status = "No AppImage, Flatpak or package files in Downloads. Paste a path."
    })

    component Section: Text {
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        font.weight: Font.DemiBold
        font.letterSpacing: 1
    }

    component FieldRow: Row {
        property string label: ""
        property string value: ""
        property bool mono: false
        spacing: Theme.spacingMd
        Text {
            width: 110
            text: parent.label
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
        Text {
            width: root.width - 110 - Theme.spacingXl * 3
            wrapMode: Text.WrapAnywhere
            text: parent.value
            color: Theme.textPrimary
            font.family: parent.mono ? Theme.fontFamilyMono : Theme.fontFamily
            font.pixelSize: parent.mono ? Theme.fontCaption : Theme.fontBody
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingLg

        Text {
            text: "App Installer"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontDisplay
            font.weight: Font.DemiBold
        }

        // ---- source ----
        Section { text: "SOURCE" }

        Row {
            width: parent.width
            spacing: Theme.spacingSm

            Rectangle {
                width: parent.width - openButton.width - Theme.spacingSm
                height: 36
                radius: Theme.radiusControl
                color: Theme.surfaceElevated
                border.width: 1
                border.color: pathInput.activeFocus ? Theme.stateFocus : Theme.border

                TextInput {
                    id: pathInput
                    anchors.fill: parent
                    anchors.margins: Theme.spacingSm
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    selectByMouse: true
                    onAccepted: root.pick(text.trim())
                }
            }

            AppButton {
                id: openButton
                text: "Open"
                enabled: pathInput.text.trim().length > 0
                onClicked: root.pick(pathInput.text.trim())
            }
        }

        Column {
            width: parent.width
            spacing: 2
            visible: root.found.length > 0
            Repeater {
                model: root.found
                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 30
                    radius: Theme.radiusControl
                    color: pick.containsMouse ? Theme.stateHover : "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingSm
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

        // ---- file ----
        Section { text: "FILE" }

        FieldRow { label: "Name"; value: root.info ? root.info.name : "—" }
        FieldRow { label: "Type"; value: root.info ? root.info.label : "—" }
        FieldRow { label: "Size"; value: root.info ? IF.formatSize(root.info.size) : "—" }
        FieldRow { label: "SHA-256"; value: root.info ? root.info.sha256 : "—"; mono: true }

        // ---- install ----
        Section { text: "INSTALL" }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: !root.info ? "Choose a file to see how it installs."
                  : root.info.root ? "System package: the system will ask for your admin password. Nothing is stored."
                  : "Installs for your user only. No password needed."
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }

        // ---- status and actions ----
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.borderSubtle
        }

        Row {
            width: parent.width
            spacing: Theme.spacingSm

            Text {
                width: parent.width - closeButton.width - installButton.width - Theme.spacingSm * 2
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.WordWrap
                text: root.status
                color: root.statusIsError ? Theme.orangeBright : Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }

            AppButton {
                id: closeButton
                text: "Close"
                onClicked: Qt.quit()
            }

            AppButton {
                id: installButton
                text: root.busy ? "Installing…" : "Install"
                primary: true
                enabled: root.info !== null && !root.busy
                onClicked: root.install()
            }
        }
    }
}
