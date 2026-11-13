import QtQuick
import qs.apps.appinstaller
import "hubstyle.js" as S
import "../appinstaller/installfile.js" as IF

// Install from a local file: drop it, browse Downloads, or paste a path. The file is
// read (size, SHA-256) and shown first; nothing installs until the user presses Install.
Item {
    id: page

    property var hub: null
    property var info: null
    property var found: []
    property string message: ""
    property bool messageIsError: false

    InstallFile { id: local }

    onVisibleChanged: if (visible && info === null) pathInput.forceActiveFocus()

    function review(path) {
        message = "Reading file..."
        messageIsError = false
        local.inspect(path, function (i) {
            if (!i) { info = null; message = "That file can't be read or isn't a supported package."; messageIsError = true; return }
            i.path = path
            info = i
            message = ""
        })
    }

    function fromUrl(url) {
        review(decodeURIComponent(url.toString().replace(/^file:\/\//, "")))
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Text { text: "Install from Local File"; color: S.text; font.family: S.font; font.pixelSize: 20; font.weight: Font.DemiBold }
        Text { text: "Drop a package or select a file to install."; color: S.muted; font.family: S.font; font.pixelSize: 12 }

        // drop zone (reference: dashed panel, cloud icon, Browse Files)
        Rectangle {
            visible: page.info === null
            width: parent.width
            height: 200
            radius: 12
            color: drop.containsDrag ? "#2A1B12" : S.card

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.setLineDash([6, 5])
                    ctx.lineWidth = 1.2
                    ctx.strokeStyle = drop.containsDrag ? S.accent : S.border
                    ctx.strokeRect(0.5, 0.5, width - 1, height - 1)
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 8
                Image { anchors.horizontalCenter: parent.horizontalCenter; width: 44; height: 44; source: Qt.resolvedUrl("icons/cat/cloud-upload.svg"); sourceSize.width: 88; sourceSize.height: 88; smooth: true }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Drag and drop your package here"; color: S.text; font.family: S.font; font.pixelSize: 14; font.weight: Font.Medium }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Supports: .AppImage, .deb, .pkg.tar.zst, .Flatpak"; color: S.muted; font.family: S.font; font.pixelSize: 11 }
                HubButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    primary: false
                    text: "Browse Files"
                    onClicked: local.candidates(function (list) {
                        page.found = list
                        page.message = list.length === 0 ? "No installable files in your Downloads folder." : ""
                        page.messageIsError = false
                    })
                }
            }

            DropArea {
                id: drop
                anchors.fill: parent
                onDropped: function (d) { if (d.hasUrls && d.urls.length > 0) page.fromUrl(d.urls[0]) }
            }
        }

        // "or" and format chips (reference)
        Text { visible: page.info === null; anchors.horizontalCenter: parent.horizontalCenter; text: "or"; color: S.muted; font.family: S.font; font.pixelSize: 11 }
        Row {
            visible: page.info === null
            spacing: 8
            Text { anchors.verticalCenter: parent.verticalCenter; text: "Supported Formats:"; color: S.muted; font.family: S.font; font.pixelSize: 11 }
            Repeater {
                model: ["AppImage", ".deb", ".pkg.tar.zst", "Flatpak"]
                delegate: Rectangle {
                    required property string modelData
                    width: fl.implicitWidth + 16; height: 22; radius: 5
                    color: "transparent"; border.width: 1; border.color: S.border
                    Text { id: fl; anchors.centerIn: parent; text: modelData; color: S.text; font.family: S.font; font.pixelSize: 10 }
                }
            }
        }

        // files found in Downloads
        Column {
            visible: page.info === null && page.found.length > 0
            width: parent.width
            spacing: 2
            Repeater {
                model: page.found
                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 30
                    radius: 6
                    color: m.containsMouse ? S.cardHover : "transparent"
                    Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 10; text: modelData.name; color: S.text; font.family: S.font; font.pixelSize: 12 }
                    MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: page.review(modelData.path) }
                }
            }
        }

        // path box
        Row {
            visible: page.info === null
            width: parent.width
            spacing: 8
            Rectangle {
                width: parent.width - go.width - 8
                height: 34
                radius: 6
                color: S.card
                border.width: 1
                border.color: pathInput.activeFocus ? S.accent : S.border
                TextInput {
                    id: pathInput
                    anchors.fill: parent
                    anchors.margins: 9
                    verticalAlignment: TextInput.AlignVCenter
                    color: S.text
                    font.family: S.font
                    font.pixelSize: 12
                    selectByMouse: true
                    onAccepted: if (text.trim().length > 0) page.review(text.trim())
                    Text { visible: parent.text.length === 0; anchors.verticalCenter: parent.verticalCenter; text: "or paste a full path, then press Enter"; color: S.muted; font.family: S.font; font.pixelSize: 12 }
                }
            }
            HubButton { id: go; primary: false; text: "Open"; enabled: pathInput.text.trim().length > 0; onClicked: page.review(pathInput.text.trim()) }
        }

        // review
        Rectangle {
            visible: page.info !== null
            width: parent.width
            height: rev.implicitHeight + 28
            radius: 12
            color: S.card
            border.width: 1
            border.color: S.border
            Column {
                id: rev
                anchors.fill: parent
                anchors.margins: 14
                spacing: 6
                Text { text: page.info ? page.info.name : ""; color: S.text; font.family: S.font; font.pixelSize: 15; font.weight: Font.DemiBold }
                Text { text: page.info ? page.info.label + " · " + IF.formatSize(page.info.size) : ""; color: S.muted; font.family: S.font; font.pixelSize: 12 }
                Text { width: parent.width; wrapMode: Text.WrapAnywhere; text: "SHA-256  " + (page.info ? page.info.sha256 : ""); color: S.muted; font.family: S.fontMono; font.pixelSize: 11 }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: page.info && page.info.root ? "System package: the system will ask for your admin password. Nothing is stored." : "Installs for your user only. No password needed."
                    color: S.muted; font.family: S.font; font.pixelSize: 12
                }
                Row {
                    spacing: 8
                    topPadding: 6
                    HubButton { primary: false; text: "Back"; onClicked: page.info = null }
                    HubButton { text: "Install"; onClicked: { var i = page.info; page.info = null; hub.startLocal(i) } }
                }
            }
        }

        // trust note / messages
        Rectangle {
            width: parent.width
            height: note.implicitHeight + 20
            radius: 8
            color: S.card
            border.width: 1
            border.color: S.border
            Text {
                id: note
                anchors.fill: parent
                anchors.margins: 10
                wrapMode: Text.WordWrap
                text: page.message.length > 0 ? page.message : "ⓘ  Make sure the package is from a trusted source. AppImages run with your permissions."
                color: page.messageIsError ? S.bad : S.muted
                font.family: S.font
                font.pixelSize: 12
            }
        }
    }
}
