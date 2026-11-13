import QtQuick
import "hubstyle.js" as S
import "rules.js" as R

// One app card, as in the reference: icon, name, two lines of summary, and a small outlined Install.
Rectangle {
    id: card

    property var app: null
    property var hub: null
    readonly property bool installed: hub.isInstalled(app.id)

    height: 124
    radius: 10
    color: m.containsMouse ? S.cardHover : S.card
    border.width: 1
    border.color: S.border

    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: hub.showApp(card.app)
    }

    AppTile { id: tile; app: card.app; size: 40; anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 14 }

    Column {
        anchors.left: tile.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 14
        spacing: 3
        Text { width: parent.width; text: card.app.name; elide: Text.ElideRight; color: S.text; font.family: S.fontMono; font.pixelSize: 13; font.weight: Font.Medium }
        Text { width: parent.width; text: card.app.summary; elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.WordWrap; color: S.muted; font.family: S.font; font.pixelSize: 11 }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        text: R.metaLine(card.app)
        color: S.muted
        font.family: S.font
        font.pixelSize: 10
    }

    // small outlined action, orange like the reference
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        width: btnText.implicitWidth + 20
        height: 24
        radius: 5
        color: "transparent"
        border.width: 1
        border.color: installed ? S.border : S.accent
        Text { id: btnText; anchors.centerIn: parent; text: installed ? "Installed" : "Install"; color: installed ? S.muted : S.accent; font.family: S.font; font.pixelSize: 11 }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: installed ? hub.showApp(card.app) : hub.startInstall(card.app, "install")
        }
    }
}
