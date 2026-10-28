pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "theme"

// Integrated Phase 3 shell surface. Every displayed state comes from a
// Quickshell/Hyprland model; unavailable services remain explicitly unknown.
// Mutating operations are limited to the native toplevel activate/close APIs
// and DesktopEntry.execute(), both scoped to this user's session.
ShellRoot {
    id: root
    property var theme: AxiomTheme {}
    property bool launcherOpen: false
    property bool notificationsOpen: false
    property string launcherQuery: ""
    property var launcherEntries: []

    function entriesFor(query) {
        const needle = String(query || "").trim().toLowerCase();
        const values = DesktopEntries.applications.values || [];
        return values.filter(entry => !entry.noDisplay
            && (!needle || String(entry.name || "").toLowerCase().indexOf(needle) >= 0
                || String(entry.genericName || "").toLowerCase().indexOf(needle) >= 0))
            .slice(0, 12);
    }

    function refreshLauncher() { launcherEntries = entriesFor(launcherQuery); }

    function activateOrLaunch(entry) {
        if (!entry) return;
        const id = String(entry.id || "").toLowerCase();
        const startup = String(entry.startupClass || "").toLowerCase();
        const target = (ToplevelManager.toplevels.values || []).find(window => {
            const appId = String(window.appId || "").toLowerCase();
            return appId === id || appId === startup || appId === id.replace(/\.desktop$/, "");
        });
        if (target) target.activate();
        else entry.execute();
    }

    function activeAppLabel() {
        const active = Hyprland.activeToplevel;
        if (!active) return "Desktop";
        const app = active.wayland ? active.wayland.appId : "";
        return app || active.title || "Active window";
    }

    SystemClock {
        id: clock
        enabled: true
        precision: SystemClock.Minutes
    }

    NotificationServer {
        id: notifications
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        actionsSupported: true
    }

    Variants {
        model: Quickshell.screens
        // qmllint disable uncreatable-type
        PanelWindow {
            id: topBar
            required property var modelData
            screen: modelData
            implicitHeight: 38
            anchors { top: true; left: true; right: true }
            exclusiveZone: implicitHeight
            color: "transparent"
            WlrLayershell.namespace: "axiom-top-bar"
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                anchors.fill: parent
                color: root.theme.background
                border.color: Qt.rgba(0.39, 0.85, 0.77, 0.20)
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: root.theme.spacingMedium
                    anchors.rightMargin: root.theme.spacingMedium
                    spacing: root.theme.spacingSmall

                    Text {
                        width: 48
                        anchors.verticalCenter: parent.verticalCenter
                        text: "AXIOM"
                        color: root.theme.accent
                        font.bold: true
                        font.pixelSize: 12
                        Accessible.name: "Axiom menu"
                    }

                    Button {
                        width: 30
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        text: "⌕"
                        focusPolicy: Qt.NoFocus
                        Accessible.name: "Open launcher"
                        onClicked: {
                            root.launcherOpen = true;
                            root.refreshLauncher();
                            launcherInput.forceActiveFocus();
                        }
                        background: Rectangle { color: "transparent" }
                        contentItem: Text {
                            text: parent.text
                            color: root.theme.accent
                            font.pixelSize: 19
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Repeater {
                        model: Hyprland.workspaces.values || []
                        delegate: Button {
                            required property var modelData
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                            text: String(modelData.name || modelData.id)
                            focusPolicy: Qt.NoFocus
                            Accessible.name: "Workspace " + text
                            onClicked: modelData.activate()
                            background: Rectangle {
                                radius: root.theme.radiusControl
                                color: modelData.active ? root.theme.accent : "transparent"
                                border.width: modelData.focused ? 1 : 0
                                border.color: root.theme.accent
                            }
                            contentItem: Text {
                                text: parent.text
                                color: modelData.active ? root.theme.accentText : root.theme.muted
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 11
                            }
                        }
                    }

                    Item { width: 1 }

                    Text {
                        width: 220
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.activeAppLabel()
                        elide: Text.ElideRight
                        color: root.theme.foreground
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignRight
                        Accessible.name: "Active application: " + text
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Pipewire.ready ? "◉" : "◌"
                        color: Pipewire.ready ? root.theme.accent : root.theme.muted
                        font.pixelSize: 14
                        Accessible.name: Pipewire.ready ? "Audio service ready" : "Audio service unavailable"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: UPower.devices && UPower.devices.values && UPower.devices.values.length > 0
                              ? Math.round(UPower.devices.values[0].percentage) + "%" : "—"
                        color: root.theme.muted
                        font.pixelSize: 11
                        Accessible.name: "Battery " + text
                    }

                    Button {
                        id: notificationButton
                        width: 30
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        focusPolicy: Qt.NoFocus
                        text: notifications.trackedNotifications.values.length > 0
                              ? "●" : "○"
                        Accessible.name: "Notifications (" + notifications.trackedNotifications.values.length + ")"
                        onClicked: root.notificationsOpen = !root.notificationsOpen
                        background: Rectangle { color: "transparent" }
                        contentItem: Text {
                            text: notificationButton.text
                            color: notificationButton.text === "●" ? root.theme.accent : root.theme.muted
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatTime(clock.date, "HH:mm")
                        color: root.theme.foreground
                        font.pixelSize: 12
                        Accessible.name: "Current time " + text
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens
        // qmllint disable uncreatable-type
        PanelWindow {
            id: dockPanel
            required property var modelData
            screen: modelData
            implicitWidth: 560
            implicitHeight: 62
            anchors { bottom: true; left: true; right: true }
            // qmllint disable unresolved-type
            // qmllint disable unqualified
            margins { bottom: root.theme.spacingMedium; left: 120; right: 120 }
            // qmllint enable unresolved-type
            // qmllint enable unqualified
            exclusiveZone: 0
            color: "transparent"
            WlrLayershell.namespace: "axiom-dock"
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                anchors.fill: parent
                radius: root.theme.radiusSurface
                color: Qt.rgba(0.08, 0.10, 0.12, 0.96)
                border.width: 1
                border.color: Qt.rgba(0.39, 0.85, 0.77, 0.34)
                Row {
                    anchors.centerIn: parent
                    spacing: root.theme.spacingSmall
                    Repeater {
                        model: (DesktopEntries.applications.values || []).filter(entry => !entry.noDisplay).slice(0, 8)
                        delegate: Button {
                            required property var modelData
                            width: 44
                            height: 44
                            focusPolicy: Qt.NoFocus
                            text: String(modelData.name || "?").charAt(0).toUpperCase()
                            Accessible.name: "Launch or focus " + String(modelData.name || "application")
                            onClicked: root.activateOrLaunch(modelData)
                            background: Rectangle {
                                radius: root.theme.radiusControl
                                color: parent.down ? root.theme.accent : root.theme.surfaceRaised
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.down ? root.theme.accentText : root.theme.foreground
                                font.bold: true
                                font.pixelSize: 15
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // qmllint disable uncreatable-type
    PanelWindow {
        id: launcherPanel
        visible: root.launcherOpen
        implicitWidth: 560
        implicitHeight: 410
        anchors { top: true; left: true; right: true; bottom: true }
        // qmllint disable unresolved-type
        // qmllint disable unqualified
        margins { top: 72; left: 160; right: 160; bottom: 120 }
        // qmllint enable unresolved-type
        // qmllint enable unqualified
        color: "transparent"
        focusable: true
        WlrLayershell.namespace: "axiom-launcher"
        WlrLayershell.layer: WlrLayer.Overlay

        Rectangle {
            anchors.fill: parent
            radius: root.theme.radiusSurface
            color: Qt.rgba(0.08, 0.10, 0.12, 0.98)
            border.width: 1
            border.color: root.theme.accent

            Column {
                anchors.fill: parent
                anchors.margins: root.theme.spacingMedium
                spacing: root.theme.spacingSmall

                TextInput {
                    id: launcherInput
                    width: parent.width
                    height: 42
                    focus: root.launcherOpen
                    color: root.theme.foreground
                    selectionColor: root.theme.accent
                    font.pixelSize: 20
                    clip: true
                    text: root.launcherQuery
                    Accessible.name: "Search applications"
                    onTextChanged: {
                        root.launcherQuery = text;
                        root.refreshLauncher();
                    }
                    Keys.onEscapePressed: root.launcherOpen = false
                    Keys.onReturnPressed: if (root.launcherEntries.length > 0) {
                        root.activateOrLaunch(root.launcherEntries[0]);
                        root.launcherOpen = false;
                    }
                }

                ListView {
                    id: launcherList
                    width: parent.width
                    height: parent.height - launcherInput.height - 8
                    model: root.launcherEntries
                    clip: true
                    delegate: Button {
                        required property var modelData
                        width: launcherList.width
                        height: 42
                        text: String(modelData.name || modelData.id || "Application")
                        Accessible.name: "Launch " + text
                        onClicked: {
                            root.activateOrLaunch(modelData);
                            root.launcherOpen = false;
                        }
                        background: Rectangle {
                            radius: root.theme.radiusControl
                            color: parent.down ? root.theme.accent : "transparent"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.down ? root.theme.accentText : root.theme.foreground
                            leftPadding: root.theme.spacingSmall
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }

    // qmllint disable uncreatable-type
    PanelWindow {
        id: notificationPanel
        visible: root.notificationsOpen
        implicitWidth: 420
        implicitHeight: 360
        anchors { top: true; right: true }
        // qmllint disable unresolved-type
        // qmllint disable unqualified
        margins { top: 50; right: root.theme.spacingMedium }
        // qmllint enable unresolved-type
        // qmllint enable unqualified
        color: "transparent"
        focusable: true
        WlrLayershell.namespace: "axiom-notifications"
        WlrLayershell.layer: WlrLayer.Overlay

        Rectangle {
            anchors.fill: parent
            radius: root.theme.radiusSurface
            color: Qt.rgba(0.08, 0.10, 0.12, 0.98)
            border.width: 1
            border.color: Qt.rgba(0.39, 0.85, 0.77, 0.34)
            Column {
                anchors.fill: parent
                anchors.margins: root.theme.spacingMedium
                spacing: root.theme.spacingSmall
                Text {
                    text: "Notifications"
                    color: root.theme.foreground
                    font.bold: true
                    font.pixelSize: 16
                }
                ListView {
                    width: parent.width
                    height: parent.height - 30
                    clip: true
                    model: notifications.trackedNotifications
                    delegate: Rectangle {
                        required property var modelData
                        width: parent ? parent.width : 0
                        height: 68
                        radius: root.theme.radiusControl
                        color: root.theme.surface
                        Column {
                            anchors.fill: parent
                            anchors.margins: root.theme.spacingSmall
                            Text { text: modelData.appName + ": " + modelData.summary; color: root.theme.foreground; elide: Text.ElideRight; width: parent.width }
                            Text { text: modelData.body; color: root.theme.muted; elide: Text.ElideRight; width: parent.width; font.pixelSize: 11 }
                        }
                        TapHandler { onTapped: modelData.dismiss() }
                    }
                }
            }
        }
    }
}
