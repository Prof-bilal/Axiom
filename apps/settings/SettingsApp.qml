import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared

// Axiom Settings. System pages (Network, Bluetooth, Sound, Displays, Power,
// Notifications, Keyboard, Date & time, Users) drive real services and say
// plainly when a service or adapter is missing; Appearance and Dock write the
// shared settings store that the shell watches; Default apps use the system
// MIME defaults.
AppWindow {
    id: root

    title: "Settings"
    implicitWidth: 1020
    implicitHeight: 660

    // `axiom-app settings <page>` opens that page; anything unknown opens About.
    property string page: components.hasOwnProperty(Quickshell.env("AXIOM_APP_ARG") || "") ? Quickshell.env("AXIOM_APP_ARG") : "about"
    property var menuCallback: null

    readonly property var pages: [
        { key: "about", label: "About", icon: "info" },
        { key: "appearance", label: "Appearance", icon: "image" },
        { key: "dock", label: "Dock", icon: "application" },
        { key: "apps", label: "Default apps", icon: "grid" },
        { key: "displays", label: "Displays", icon: "window" },
        { key: "network", label: "Network", icon: "network-wireless" },
        { key: "bluetooth", label: "Bluetooth", icon: "bluetooth" },
        { key: "sound", label: "Sound", icon: "volume-high" },
        { key: "power", label: "Power", icon: "battery" },
        { key: "notifications", label: "Notifications", icon: "bell" },
        { key: "keyboard", label: "Keyboard", icon: "terminal" },
        { key: "datetime", label: "Date & time", icon: "refresh" },
        { key: "users", label: "Users", icon: "home" }
    ]
    readonly property var components: ({
        network: networkPage, bluetooth: bluetoothPage, sound: soundPage, displays: displaysPage,
        power: powerPage, notifications: notificationsPage, keyboard: keyboardPage,
        datetime: dateTimePage, users: usersPage, appearance: appearancePage,
        dock: dockPage, apps: appsPage, about: aboutPage
    })

    function showMenu(x, y, items, callback) {
        menuCallback = callback
        menu.show(x, y, items)
    }

    FocusScope {
        id: main
        anchors.fill: parent
        focus: true

        Item { id: keyTarget; focus: true }

        Keys.onPressed: function (event) {
            event.accepted = true
            var idx = -1
            for (var i = 0; i < root.pages.length; i++) if (root.pages[i].key === root.page) idx = i
            if (menu.open && event.key === Qt.Key_Escape) menu.open = false
            else if (event.key === Qt.Key_Down && (event.modifiers & Qt.ControlModifier)) root.page = root.pages[Math.min(root.pages.length - 1, idx + 1)].key
            else if (event.key === Qt.Key_Up && (event.modifiers & Qt.ControlModifier)) root.page = root.pages[Math.max(0, idx - 1)].key
            else event.accepted = false
        }

        Rectangle {
            id: sidebar
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 220
            color: Theme.surface

            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.borderSubtle }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingSm
                anchors.topMargin: Theme.spacingLg
                spacing: 2

                Repeater {
                    model: root.pages
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool active: root.page === modelData.key
                        width: parent.width
                        height: 36
                        radius: Theme.radiusControl
                        color: active ? Theme.stateSelected : (hit.containsMouse ? Theme.stateHover : "transparent")
                        border.width: active ? 1 : 0
                        border.color: Theme.stateSelectedBorder

                        Accessible.role: Accessible.PageTab
                        Accessible.name: modelData.label

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingMd
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingMd
                            AxiomIcon {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 18
                                height: 18
                                name: modelData.icon
                                color: parent.parent.active ? Theme.cyanBright : Theme.textSecondary
                                strokeWidth: 1.5
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontBody
                                font.weight: parent.parent.active ? Font.Medium : Font.Normal
                            }
                        }
                        MouseArea {
                            id: hit
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { root.page = modelData.key; keyTarget.forceActiveFocus() }
                        }
                    }
                }
            }
        }

        Loader {
            id: loader
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: sidebar.right
            anchors.right: parent.right
            sourceComponent: root.components[root.page]
        }

        Component { id: aboutPage; AboutPage {} }
        Component { id: appearancePage; AppearancePage {} }
        Component { id: dockPage; DockPage {} }
        Component { id: appsPage; DefaultAppsPage {} }
        Component { id: displaysPage; DisplaysPage {} }
        Component { id: networkPage; NetworkPage {} }
        Component { id: bluetoothPage; BluetoothPage {} }
        Component { id: soundPage; SoundPage {} }
        Component { id: powerPage; PowerPage {} }
        Component { id: notificationsPage; NotificationsPage {} }
        Component { id: keyboardPage; KeyboardPage {} }
        Component { id: dateTimePage; DateTimePage {} }
        Component { id: usersPage; UsersPage {} }

        Connections {
            target: loader.item
            ignoreUnknownSignals: true
            function onPickApplication(x, y, items, onPick) { root.showMenu(x, y, items, onPick) }
        }

        ContextMenu {
            id: menu
            onTriggered: function (action) { if (root.menuCallback) root.menuCallback(action) }
            onOpenChanged: if (!open) keyTarget.forceActiveFocus()
        }
    }
}
