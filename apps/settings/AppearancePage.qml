import QtQuick
import Quickshell
import Quickshell.Io
import qs.src.shared
import qs.services
import qs.apps.shared
import "settings.js" as St

PageFrame {
    id: page
    title: "Appearance"

    readonly property string pictures: Quickshell.env("HOME") + "/Pictures"
    property var images: []
    property bool scanned: false

    CommandRunner { id: runner }

    function scan() {
        var argv = ["find", "-H", pictures, "-maxdepth", "2", "-type", "f", "("]
        St.IMAGE_EXT.forEach(function (e, i) { if (i > 0) argv.push("-o"); argv.push("-iname", "*." + e) })
        argv.push(")", "-print")
        runner.run(argv, function (r) { page.images = St.parseImagePaths(r.out); page.scanned = true })
    }

    Component.onCompleted: scan()

    // Light or dark for the whole desktop. The session reads this file at login
    // (see axiom-session), so a change applies at the next sign-in.
    property string themeMode: "dark"
    readonly property string themeDir: Quickshell.env("HOME") + "/.config/axiom"

    FileView {
        id: themeFile
        path: page.themeDir + "/theme"
        printErrors: false
        onLoaded: {
            var m = text().trim()
            page.themeMode = (m === "light" || m === "dark") ? m : "dark"
        }
        onLoadFailed: page.themeMode = "dark"
    }

    function setThemeMode(m) {
        runner.run(["mkdir", "-p", page.themeDir], function () {
            themeFile.setText(m + "\n")
            page.themeMode = m
        })
    }

    // Brand mark at the top of the Appearance page.
    Row {
        spacing: Theme.spacingMd
        Image {
            width: 44
            height: 44
            source: Quickshell.shellPath("assets/axiom-penguin.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
            sourceSize: Qt.size(88, 88)
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "Appearance"
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody + 2
                font.weight: Font.DemiBold
            }
            Text {
                text: "Light or dark, text size and wallpaper"
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }
        }
    }

    SettingsCard {
        title: "Appearance"

        SettingRow {
            first: true
            label: "Light or dark"
            description: "Applies the next time you sign in."

            SegmentControl {
                options: [{ name: "Dark", value: "dark" }, { name: "Light", value: "light" }]
                current: page.themeMode
                onPicked: function (v) { page.setThemeMode(v) }
            }
        }
    }

    SettingsCard {
        title: "Text size"

        SettingRow {
            first: true
            label: "Size of text in the desktop and apps"
            description: "The terminal keeps its own font size."

            SegmentControl {
                options: [{ name: "Default", value: 1.0 }, { name: "Large", value: 1.125 }, { name: "Larger", value: 1.25 }]
                current: Math.round(SettingsService.textScale * 1000) / 1000
                onPicked: function (v) { SettingsService.setTextScale(v) }
            }
        }
    }

    SettingsCard {
        title: "Wallpaper"

        Item {
            width: parent.width
            height: grid.height + Theme.spacingLg * 2

            Flow {
                id: grid
                x: Theme.spacingLg
                y: Theme.spacingLg
                width: parent.width - Theme.spacingLg * 2
                spacing: Theme.spacingMd

                component Choice: Rectangle {
                    id: choice
                    property string name: ""
                    property string source: ""
                    property string path: ""      // value stored in settings ("" = Axiom default)
                    readonly property bool active: SettingsService.wallpaper === path
                    width: 190
                    height: 132
                    radius: Theme.radiusSurface
                    color: Theme.background
                    border.width: active ? 2 : 1
                    border.color: active ? Theme.stateFocus : (hit.containsMouse ? Theme.cyanMuted : Theme.border)

                    Accessible.role: Accessible.RadioButton
                    Accessible.name: name
                    Accessible.checked: active

                    Image {
                        anchors.fill: parent
                        anchors.margins: 3
                        source: choice.source
                        sourceSize.width: 380
                        sourceSize.height: 264
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 3
                        height: 24
                        radius: Theme.radiusSmall
                        color: "#0A1215"
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingSm
                            anchors.rightMargin: Theme.spacingSm
                            verticalAlignment: Text.AlignVCenter
                            text: choice.name
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontCaption
                            elide: Text.ElideRight
                        }
                    }
                    MouseArea {
                        id: hit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SettingsService.setWallpaper(choice.path)
                    }
                }

                Choice { name: "Axiom"; source: Quickshell.shellPath("assets/wallpaper.png"); path: "" }

                Repeater {
                    model: page.images
                    delegate: Choice {
                        required property string modelData
                        name: St.label(modelData)
                        source: "file://" + modelData
                        path: modelData
                    }
                }
            }
        }
    }

    Text {
        width: parent.width
        wrapMode: Text.Wrap
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        text: !page.scanned ? "Looking for images…"
              : page.images.length === 0 ? "Put PNG, JPEG or WebP images in " + page.pictures + " to choose them here."
              : page.images.length + (page.images.length === 1 ? " image" : " images") + " found in " + page.pictures + "."
    }

    Text {
        width: parent.width
        visible: SettingsService.loadError.length > 0
        wrapMode: Text.Wrap
        color: Theme.orangeBright
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        text: SettingsService.loadError
    }
}
