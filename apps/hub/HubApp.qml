import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.apps.shared
import "hubstyle.js" as S
import "rules.js" as R

// Axiom Hub: find, install, update and remove software. Six screens: Discover,
// App details, Installed, Local install and the Installing progress.
AppWindow {
    id: root

    title: "Axiom Hub"
    implicitWidth: 1040
    implicitHeight: 680
    color: S.bg

    property string page: "discover"
    property string navPage: "discover"
    property var selected: null
    property string category: "All"
    property string query: ""
    readonly property alias be: backend
    readonly property var pages: ["discover", "details", "installed", "updates", "local", "installing"]
    readonly property var titles: ({ discover: "Discover", details: "App Details", installed: "Installed Apps", updates: "Updates", local: "Local Install", installing: "Installing Application" })

    HubBackend { id: backend }

    // Test hook: AXIOM_HUB_PAGE=<page> opens that screen (details shows VS Code).
    Component.onCompleted: {
        var p = Quickshell.env("AXIOM_HUB_PAGE")
        if (!p || pages.indexOf(p) < 0) return
        if (p === "details") showApp(R.find(backend.catalog, "vscode")); else open(p)
    }

    function isInstalled(id) { return backend.isInstalled(id) }
    function open(p) { page = p; navPage = p; if (p === "installed") backend.refreshInstalled(); if (p === "updates") backend.checkUpdates() }
    function showApp(app) { selected = app; page = "details" }
    function startInstall(app, action) { backend.run(app, action); page = "installing" }
    function startLocal(info) { backend.runLocal(info); page = "installing" }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar { hub: root; Layout.fillHeight: true; Layout.preferredWidth: 190 }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // top bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                color: S.panel
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: S.border }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.titles[root.page]
                    color: S.text; font.family: S.font; font.pixelSize: 14; font.weight: Font.DemiBold
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    width: 260; height: 30; radius: 15
                    color: S.card
                    border.width: 1
                    border.color: search.activeFocus ? S.accent : S.border
                    Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "⌕"; color: S.muted; font.pixelSize: 14 }
                    TextInput {
                        id: search
                        anchors.fill: parent
                        anchors.leftMargin: 32
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: S.text; font.family: S.font; font.pixelSize: 12
                        selectByMouse: true
                        onTextChanged: { root.query = text; if (text.length > 0 && root.page !== "discover") root.open("discover") }
                        Text { visible: parent.text.length === 0; anchors.verticalCenter: parent.verticalCenter; text: "Search applications"; color: S.muted; font.family: S.font; font.pixelSize: 12 }
                    }
                }
            }

            // pages
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.pages.indexOf(root.page)
                DiscoverPage { hub: root }
                DetailsPage { hub: root }
                InstalledPage { hub: root }
                InstalledPage { hub: root; updatesOnly: true }
                LocalInstallPage { hub: root }
                InstallingPage { hub: root }
            }

            // status bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                color: S.panel
                Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: S.border }
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Rectangle { width: 8; height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter; color: backend.busy ? S.accent : S.ok }
                    Text { text: backend.status; color: S.muted; font.family: S.font; font.pixelSize: 11 }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "Axiom Hub v1.0.0"; color: S.muted; font.family: S.font; font.pixelSize: 11 }
            }
        }
    }
}
