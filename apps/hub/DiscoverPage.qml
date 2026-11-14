import QtQuick
import Quickshell
import "hubstyle.js" as S
import "rules.js" as R

// Discover, as in the reference: big hero, outlined chips, featured app, then a 4-column grid.
Flickable {
    id: page

    property var hub: null
    property string chip: "All"
    readonly property var chips: ["All", "Development", "Productivity", "Graphics", "Internet", "System"]
    readonly property var featured: R.find(hub.be.catalog, "vscode")
    readonly property var shown: R.search(hub.be.catalog, hub.query).filter(function (a) { return page.chip === "All" || a.category === page.chip })

    contentWidth: width
    contentHeight: col.height + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    // smooth wheel scrolling: animate contentY only when the user is not dragging or flicking
    Behavior on contentY { enabled: !moving && !flicking; SmoothedAnimation { velocity: 2400; easing.type: Easing.OutCubic } }

    Column {
        id: col
        x: 24
        y: 20
        width: page.width - 48
        spacing: 18

        // hero
        Rectangle {
            width: parent.width
            height: 176
            radius: 12
            color: S.card
            border.width: 1
            border.color: S.border
            clip: true

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var c = getContext("2d")
                    c.clearRect(0, 0, width, height)
                    c.fillStyle = "#1E1E1E"
                    c.beginPath(); c.moveTo(0, height); c.lineTo(width * 0.55, height * 0.35); c.lineTo(width * 0.7, height * 0.6); c.lineTo(width * 0.85, height * 0.25); c.lineTo(width, height * 0.5); c.lineTo(width, height); c.closePath(); c.fill()
                    c.lineWidth = 6; c.lineCap = "round"; c.strokeStyle = S.accent
                    c.beginPath(); c.arc(width * 0.8, height * 0.62, 84, Math.PI * 1.05, Math.PI * 1.9); c.stroke()
                }
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 28
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Text { text: "Your system. Your tools."; color: S.text; font.family: S.fontMono; font.pixelSize: 30; font.weight: Font.Bold }
                Text { text: "Find and install software for your Axiom workspace."; color: S.muted; font.family: S.font; font.pixelSize: 13 }
            }

            Image {
                anchors.right: parent.right
                anchors.rightMargin: 60
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                width: 110; height: 130
                source: Quickshell.shellPath("assets/axiom-penguin.png")
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }

        // chips
        Row {
            spacing: 10
            Repeater {
                model: page.chips
                delegate: Rectangle {
                    required property string modelData
                    readonly property bool on: page.chip === modelData
                    width: lbl.implicitWidth + 30
                    height: 30
                    radius: 6
                    color: "transparent"
                    border.width: 1
                    border.color: on ? S.accent : S.border
                    Text { id: lbl; anchors.centerIn: parent; text: modelData; color: parent.on ? S.accent : S.muted; font.family: S.font; font.pixelSize: 12 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: page.chip = modelData }
                }
            }
        }

        // featured
        Text {
            visible: page.featured !== null && page.chip === "All" && hub.query === ""
            text: "★ Featured"; color: S.warn; font.family: S.font; font.pixelSize: 13; font.weight: Font.Medium
        }
        Rectangle {
            visible: page.featured !== null && page.chip === "All" && hub.query === ""
            width: parent.width
            height: 96
            radius: 10
            color: S.card
            border.width: 1
            border.color: S.border

            AppTile { id: ft; app: page.featured; size: 56; anchors.left: parent.left; anchors.leftMargin: 20; anchors.verticalCenter: parent.verticalCenter }
            Column {
                anchors.left: ft.right
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text { text: page.featured ? page.featured.name : ""; color: S.text; font.family: S.fontMono; font.pixelSize: 16; font.weight: Font.Medium }
                Text { text: page.featured ? page.featured.summary : ""; color: S.muted; font.family: S.font; font.pixelSize: 12 }
                Text { text: page.featured ? "Flatpak  |  " + (page.featured.size_mb ? R.formatSize(page.featured.size_mb) : "size not verified") + "  |  " + page.featured.weight : ""; color: S.muted; font.family: S.font; font.pixelSize: 11 }
            }
            Rectangle { id: sep; width: 1; height: 56; color: S.border; anchors.right: fbtn.left; anchors.rightMargin: 22; anchors.verticalCenter: parent.verticalCenter }
            HubButton {
                id: fbtn
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: page.featured && hub.isInstalled(page.featured.id) ? "Installed" : "Install  →"
                onClicked: hub.showApp(page.featured)
            }
        }

        // grid
        Flow {
            width: parent.width
            spacing: 14
            Repeater {
                model: page.shown
                delegate: AppCard { required property var modelData; app: modelData; hub: page.hub; width: (col.width - 42) / 4 }
            }
        }
        Text { visible: page.shown.length === 0; text: "No apps match."; color: S.muted; font.family: S.font; font.pixelSize: 13 }
    }
}
