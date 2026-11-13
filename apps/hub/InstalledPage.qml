import QtQuick
import "hubstyle.js" as S
import "rules.js" as R

// Installed apps from the catalog, with Update (when one exists) and Remove.
Flickable {
    id: page

    property var hub: null
    property bool updatesOnly: false
    readonly property var rows: hub.be.catalog.filter(function (a) { return hub.isInstalled(a.id) && (!updatesOnly || hub.be.hasUpdate(a.id)) })

    contentWidth: width
    contentHeight: col.height + 32
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    // smooth wheel scrolling: animate contentY only when the user is not dragging or flicking
    Behavior on contentY { enabled: !moving && !flicking; SmoothedAnimation { velocity: 2400; easing.type: Easing.OutCubic } }

    Column {
        id: col
        x: 20
        y: 16
        width: page.width - 40
        spacing: 12

        Item {
            width: parent.width
            height: 44
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text { text: "Your Applications"; color: S.text; font.family: S.font; font.pixelSize: 20; font.weight: Font.DemiBold }
                Text { text: page.updatesOnly ? hub.be.updates.length + " update(s) available." : "Manage your installed software."; color: S.muted; font.family: S.font; font.pixelSize: 12 }
            }
            HubButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                primary: false
                text: "⟳  Check for Updates"
                onClicked: hub.be.checkUpdates()
            }
        }

        Repeater {
            model: page.rows
            delegate: Rectangle {
                required property var modelData
                width: col.width
                height: 62
                radius: 10
                color: S.card
                border.width: 1
                border.color: S.border
                AppTile { id: t; app: modelData; size: 38; anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.left: t.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: modelData.name; color: S.text; font.family: S.font; font.pixelSize: 13; font.weight: Font.Medium }
                    Text { text: R.metaLine(modelData); color: S.muted; font.family: S.font; font.pixelSize: 11 }
                }
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    HubButton { visible: hub.be.hasUpdate(modelData.id); small: true; text: "Update"; onClicked: hub.startInstall(modelData, "update") }
                    HubButton { small: true; primary: false; text: "Details"; onClicked: hub.showApp(modelData) }
                    HubButton { small: true; primary: false; text: "Remove"; onClicked: hub.startInstall(modelData, "remove") }
                }
            }
        }

        // empty state (shown only when nothing from the Hub is installed)
        Column {
            visible: page.rows.length === 0
            width: parent.width
            topPadding: 70
            spacing: 10

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 68; height: 68; radius: 16
                color: S.card
                border.width: 1
                border.color: S.border
                Image { anchors.centerIn: parent; width: 32; height: 32; source: Qt.resolvedUrl("icons/cat/empty.svg"); sourceSize.width: 64; sourceSize.height: 64; smooth: true }
            }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: page.updatesOnly ? "Everything is up to date" : "Container not found"; color: S.text; font.family: S.fontMono; font.pixelSize: 16; font.weight: Font.Medium }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width, 420)
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: page.updatesOnly ? "None of the apps installed from the Hub has a newer version." : "Nothing from the Hub is installed yet. Find software in Discover, or install a file you already downloaded."
                color: S.muted; font.family: S.font; font.pixelSize: 12
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                topPadding: 6
                HubButton { visible: !page.updatesOnly; text: "Discover apps"; onClicked: hub.open("discover") }
                HubButton { visible: !page.updatesOnly; primary: false; text: "Install from file"; onClicked: hub.open("local") }
                HubButton { visible: page.updatesOnly; primary: false; text: "⟳  Check for Updates"; onClicked: hub.be.checkUpdates() }
            }
        }
    }
}
