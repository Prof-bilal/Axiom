import QtQuick
import Quickshell
import "hubstyle.js" as S

// Left navigation: logo, four sections, and the OS tag at the bottom.
Rectangle {
    id: bar

    property var hub: null
    readonly property var items: [
        { page: "discover", label: "Discover", glyph: "◇" },
        { page: "installed", label: "Installed", glyph: "↓" },
        { page: "updates", label: "Updates", glyph: "⟳" },
        { page: "local", label: "Local Install", glyph: "▤" }
    ]

    width: 190
    color: S.panel

    Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: S.border }

    Column {
        anchors.top: parent.top
        anchors.topMargin: 22
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6
        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 52; height: 52
            source: Quickshell.shellPath("assets/axiom-penguin.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "AXIOM HUB"
            color: S.text
            font.family: S.font
            font.pixelSize: 12
            font.weight: Font.DemiBold
            font.letterSpacing: 1.5
        }
    }

    Column {
        anchors.top: parent.top
        anchors.topMargin: 120
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 4

        Repeater {
            model: bar.items
            delegate: Rectangle {
                required property var modelData
                readonly property bool active: bar.hub.navPage === modelData.page
                width: parent.width
                height: 36
                radius: 6
                color: active ? "#2A1B12" : (m.containsMouse ? S.cardHover : "transparent")

                Rectangle {
                    visible: parent.active
                    width: 3; height: 18; radius: 1.5
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: S.accent
                }
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Text { text: modelData.glyph; color: parent.parent.active ? S.accent : S.muted; font.pixelSize: 14 }
                    Text {
                        text: modelData.label
                        color: parent.parent.active ? S.text : S.muted
                        font.family: S.font
                        font.pixelSize: 13
                        font.weight: parent.parent.active ? Font.Medium : Font.Normal
                    }
                    Rectangle {
                        visible: modelData.page === "updates" && bar.hub.be.updates.length > 0
                        width: badge.implicitWidth + 12; height: 18; radius: 9
                        color: S.accent
                        anchors.verticalCenter: parent.verticalCenter
                        Text { id: badge; anchors.centerIn: parent; text: bar.hub.be.updates.length; color: "#FFFFFF"; font.family: S.font; font.pixelSize: 10; font.weight: Font.Medium }
                    }
                }
                MouseArea {
                    id: m
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bar.hub.open(modelData.page)
                }
                Accessible.role: Accessible.Button
                Accessible.name: modelData.label
            }
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16
        text: "Axiom OS"
        color: S.muted
        font.family: S.font
        font.pixelSize: 11
    }
}
