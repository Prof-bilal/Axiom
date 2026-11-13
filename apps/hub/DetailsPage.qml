import QtQuick
import "hubstyle.js" as S
import "rules.js" as R
import "details.js" as D

// App details: header with the action, tabs, how it fits this machine, similar apps.
Flickable {
    id: page

    property var hub: null
    property string tab: "Overview"
    readonly property var app: hub.selected
    readonly property bool installed: app ? hub.isInstalled(app.id) : false
    readonly property var fit: app ? R.fit(app, hub.be.sys) : null
    readonly property var lighter: app ? R.lighterOption(hub.be.catalog, app, hub.be.sys) : null
    readonly property var info: app && D.DETAILS[app.id] ? D.DETAILS[app.id] : { overview: "", shots: [], commands: [], commandsStatus: "" }
    readonly property var similar: app ? R.byCategory(hub.be.catalog, app.category).filter(function (a) { return a.id !== app.id }).slice(0, 3) : []
    readonly property color fitColor: !fit ? S.muted : fit.level === "fits" ? S.ok : fit.level === "unknown" ? S.muted : fit.level === "tight" ? S.warn : S.bad

    contentWidth: width
    contentHeight: col.height + 32
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    // smooth wheel scrolling: animate contentY only when the user is not dragging or flicking
    Behavior on contentY { enabled: !moving && !flicking; SmoothedAnimation { velocity: 2400; easing.type: Easing.OutCubic } }
    onAppChanged: tab = "Overview"

    Column {
        id: col
        x: 20
        y: 16
        width: page.width - 40
        spacing: 16
        visible: page.app !== null

        // header
        Row {
            spacing: 14
            width: parent.width
            AppTile { id: tile; app: page.app; size: 64 }
            Column {
                width: parent.width - 64 - 14 - actions.width - 14
                anchors.verticalCenter: tile.verticalCenter
                spacing: 3
                Text { text: page.app ? page.app.name : ""; color: S.text; font.family: S.font; font.pixelSize: 22; font.weight: Font.DemiBold }
                Text { text: page.app ? page.app.summary : ""; color: S.muted; font.family: S.font; font.pixelSize: 12; width: parent.width; elide: Text.ElideRight }
                Text { text: page.app ? R.metaLine(page.app) + " · " + page.app.weight : ""; color: S.muted; font.family: S.font; font.pixelSize: 11 }
            }
            Row {
                id: actions
                anchors.verticalCenter: tile.verticalCenter
                spacing: 8
                HubButton { visible: page.installed && page.app && hub.be.hasUpdate(page.app.id); text: "Update"; onClicked: hub.startInstall(page.app, "update") }
                HubButton { visible: page.installed; primary: false; text: "Remove"; onClicked: hub.startInstall(page.app, "remove") }
                HubButton { visible: !page.installed; text: "Install  ⤓"; onClicked: hub.startInstall(page.app, "install") }
            }
        }

        // tabs
        Row {
            spacing: 22
            Repeater {
                model: ["Overview", "Details", "Requirements", "Commands"]
                delegate: Item {
                    required property string modelData
                    readonly property bool on: page.tab === modelData
                    width: t.implicitWidth
                    height: 28
                    Text { id: t; text: modelData; color: parent.on ? S.text : S.muted; font.family: S.font; font.pixelSize: 13; font.weight: parent.on ? Font.Medium : Font.Normal }
                    Rectangle { visible: parent.on; anchors.bottom: parent.bottom; width: parent.width; height: 2; color: S.accent }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: page.tab = modelData }
                }
            }
        }
        Rectangle { width: parent.width; height: 1; color: S.border }

        // overview
        Column {
            visible: page.tab === "Overview"
            width: parent.width
            spacing: 12
            Text { width: parent.width; wrapMode: Text.WordWrap; text: page.app ? page.app.summary : ""; color: S.text; font.family: S.font; font.pixelSize: 13 }
            Text { width: parent.width; wrapMode: Text.WordWrap; visible: text !== ""; text: page.info.overview; color: S.muted; font.family: S.font; font.pixelSize: 12 }
            Repeater {
                model: [["When to use", page.info.when], ["How it works", page.info.how], ["Not for", page.info.notFor]]
                delegate: Column {
                    required property var modelData
                    width: col.width
                    spacing: 4
                    visible: modelData[1] !== ""
                    Text { text: modelData[0]; color: S.text; font.family: S.font; font.pixelSize: 13; font.weight: Font.Medium }
                    Text { width: parent.width; wrapMode: Text.WordWrap; text: modelData[1]; color: S.muted; font.family: S.font; font.pixelSize: 12 }
                }
            }
            Text { visible: page.info.shots.length === 0; text: "No screenshots yet."; color: S.muted; font.family: S.font; font.pixelSize: 12 }
            Flow {
                width: parent.width
                spacing: 10
                Repeater {
                    model: page.info.shots
                    delegate: Image {
                        required property var modelData
                        source: modelData.url.indexOf("http") === 0 ? modelData.url : Qt.resolvedUrl(modelData.url)
                        width: 240
                        height: 150
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: fitText.implicitHeight + 24
                radius: 10
                color: S.card
                border.width: 1
                border.color: page.fitColor
                Column {
                    id: fitText
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 3
                    Text { text: "On this machine: " + (page.fit ? page.fit.level : ""); color: page.fitColor; font.family: S.font; font.pixelSize: 13; font.weight: Font.DemiBold }
                    Text { width: parent.width; wrapMode: Text.WordWrap; text: page.fit ? page.fit.reason : ""; color: S.muted; font.family: S.font; font.pixelSize: 12 }
                }
            }
            Rectangle {
                visible: page.lighter !== null
                width: parent.width
                height: 64
                radius: 10
                color: S.card
                border.width: 1
                border.color: S.border
                AppTile { id: lt; app: page.lighter; size: 38; anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.left: lt.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: page.lighter ? "Lighter option: " + page.lighter.name : ""; color: S.text; font.family: S.font; font.pixelSize: 13; font.weight: Font.Medium }
                    Text { text: page.lighter ? page.lighter.summary : ""; color: S.muted; font.family: S.font; font.pixelSize: 11 }
                }
                HubButton { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; small: true; primary: false; text: "View"; onClicked: hub.showApp(page.lighter) }
            }
        }

        // details
        Column {
            visible: page.tab === "Details"
            width: parent.width
            spacing: 8
            Repeater {
                model: page.app ? [
                    ["Publisher", page.app.publisher], ["Licence", page.app.license], ["Category", page.app.category],
                    ["Source", page.app.sources.map(function (s) { return s.type + ": " + s.ref }).join("   ")],
                    ["Weight", page.app.weight], ["Size", R.formatSize(page.app.size_mb) || "not verified"]
                ] : []
                delegate: Row {
                    required property var modelData
                    spacing: 12
                    Text { width: 110; text: modelData[0]; color: S.muted; font.family: S.font; font.pixelSize: 12 }
                    Text { text: modelData[1]; color: S.text; font.family: S.font; font.pixelSize: 12 }
                }
            }
        }

        // requirements
        Column {
            visible: page.tab === "Requirements"
            width: parent.width
            spacing: 8
            Repeater {
                model: page.app ? [
                    ["Memory (about)", page.app.min_ram_gb ? page.app.min_ram_gb + " GB" : "not verified"],
                    ["Download / disk", R.formatSize(page.app.size_mb) || "not verified"],
                    ["This machine: RAM", hub.be.sys.ramGb + " GB"],
                    ["This machine: free disk", hub.be.sys.freeDiskGb + " GB"]
                ] : []
                delegate: Row {
                    required property var modelData
                    spacing: 12
                    Text { width: 160; text: modelData[0]; color: S.muted; font.family: S.font; font.pixelSize: 12 }
                    Text { text: modelData[1]; color: S.text; font.family: S.font; font.pixelSize: 12 }
                }
            }
        }

        // commands
        Column {
            visible: page.tab === "Commands"
            width: parent.width
            spacing: 12
            Text { width: parent.width; wrapMode: Text.WordWrap; text: page.info.commandsStatus; color: S.muted; font.family: S.font; font.pixelSize: 12 }
            Text { visible: page.info.commands.length === 0; text: "No install commands yet."; color: S.muted; font.family: S.font; font.pixelSize: 12 }
            TextEdit { id: clipboard; visible: false }
            Repeater {
                model: page.info.commands
                delegate: Column {
                    required property var modelData
                    property bool copied: false
                    width: parent.width
                    spacing: 4
                    Timer { id: resetTimer; interval: 1500; onTriggered: copied = false }
                    Text { text: modelData.method + (modelData.root === "yes" ? "  (needs root)" : ""); color: S.text; font.family: S.font; font.pixelSize: 13; font.weight: Font.Medium }
                    Rectangle {
                        width: parent.width
                        height: cmdText.implicitHeight + 16
                        radius: 8
                        color: S.card
                        border.width: 1
                        border.color: S.border
                        Text { id: cmdText; anchors.fill: parent; anchors.margins: 8; anchors.rightMargin: 34; wrapMode: Text.WrapAnywhere; text: modelData.command; color: S.text; font.family: S.fontMono; font.pixelSize: 12 }
                        Text { visible: copied; anchors.right: copyIcon.left; anchors.rightMargin: 8; anchors.verticalCenter: copyIcon.verticalCenter; text: "Copied"; color: S.ok; font.family: S.font; font.pixelSize: 11 }
                        Item {
                            id: copyIcon
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 8
                            width: 16; height: 16
                            Rectangle { x: 5; y: 0; width: 11; height: 11; radius: 2; color: "transparent"; border.width: 1; border.color: S.muted }
                            Rectangle { x: 0; y: 5; width: 11; height: 11; radius: 2; color: S.card; border.width: 1; border.color: S.text }
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { clipboard.text = modelData.command; clipboard.selectAll(); clipboard.copy(); copied = true; resetTimer.restart() }
                            }
                        }
                    }
                    Text { visible: modelData.source !== ""; width: parent.width; wrapMode: Text.WordWrap; text: "Source: " + modelData.source; color: S.muted; font.family: S.font; font.pixelSize: 10 }
                }
            }
        }

        // similar
        Row {
            width: parent.width
            Text { text: "Similar Apps"; color: S.text; font.family: S.font; font.pixelSize: 14; font.weight: Font.Medium }
        }
        Flow {
            width: parent.width
            spacing: 12
            Repeater {
                model: page.similar
                delegate: AppCard { required property var modelData; app: modelData; hub: page.hub; width: (col.width - 24) / 3 }
            }
        }
    }
}
