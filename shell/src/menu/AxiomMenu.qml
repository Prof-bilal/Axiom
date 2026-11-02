import QtQuick
import Quickshell
import qs.src.shared
import qs.services

// Axiom menu — opened from the penguin at the top-left. The recognisable
// Axiom entry point: search, core places, recent applications, About, and
// session actions. Every row performs a real action; rows for applications
// that are not installed are omitted (there is no Settings app until Phase 4,
// and no screen locker yet, so neither is offered).
MenuSurface {
    id: menu

    open: UiState.axiomMenuOpen
    layerNamespace: "axiom-menu"
    cardWidth: Theme.menuWidth + 20

    property string query: ""
    property bool aboutOpen: false
    readonly property var results: query.length > 0 ? ApplicationService.search(query).slice(0, 6) : []
    readonly property var recent: open ? ApplicationService.recentEntries() : []
    readonly property var filesEntry: ApplicationService.entryForAppId("pcmanfm")
    readonly property var terminalEntry: ApplicationService.entryForAppId("foot")

    onOpened: {
        query = ""
        search.text = ""
        aboutOpen = false
        HostService.refresh()
        search.forceActiveFocus()
    }

    function launch(entry) {
        UiState.closeAllOverlays()
        ApplicationService.launch(entry)
    }

    // --- header: OS identity ---
    Item {
        width: parent.width
        height: 56

        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingMd

            Image {
                anchors.verticalCenter: parent.verticalCenter
                width: 34
                height: 34
                source: Quickshell.shellPath("assets/axiom-penguin.png")
                sourceSize.width: 68
                sourceSize.height: 68
                smooth: true
                mipmap: true
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                Text {
                    text: "Axiom OS"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTitle
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "AI-native Linux"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }
            }
        }
    }

    // --- search ---
    Rectangle {
        width: parent.width
        height: 34
        radius: Theme.radiusControl
        color: Theme.surface
        border.width: 1
        border.color: search.activeFocus ? Theme.stateSelectedBorder : Theme.border

        AxiomIcon {
            id: searchIcon
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingSm + 2
            anchors.verticalCenter: parent.verticalCenter
            name: "search"
            width: 15
            height: 15
            color: Theme.textSecondary
        }

        TextInput {
            id: search
            anchors.left: searchIcon.right
            anchors.leftMargin: Theme.spacingSm
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textPrimary
            selectionColor: Theme.cyanMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            clip: true
            onTextChanged: menu.query = text
            onAccepted: if (menu.results.length > 0) menu.launch(menu.results[0])
            Keys.onEscapePressed: UiState.closeAllOverlays()

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: search.text.length === 0
                text: "Search applications"
                color: Theme.textDisabled
                font: search.font
            }
        }
    }

    Item { width: 1; height: Theme.spacingXs }

    // --- search results ---
    Repeater {
        model: menu.results
        delegate: MenuItem {
            required property var modelData
            required property int index
            text: modelData.name
            useAppIcon: true
            iconSource: ApplicationService.iconFor(modelData)
            selected: index === 0
            hint: index === 0 ? "Enter" : ""
            onTriggered: menu.launch(modelData)
        }
    }

    MenuItem {
        visible: menu.query.length > 0 && menu.results.length === 0
        text: "No matching applications"
        icon: "search"
        enabled: false
    }

    // --- places (hidden while searching) ---
    Column {
        width: parent.width
        spacing: Theme.spacingXxs
        visible: menu.query.length === 0

        MenuItem {
            text: "Applications"
            icon: "grid"
            hint: "Super+D"
            onTriggered: {
                UiState.closeAllOverlays()
                UiState.toggleLauncher("grid")
            }
        }
        MenuItem {
            visible: menu.filesEntry !== null
            text: "Files"
            icon: "folder"
            onTriggered: menu.launch(menu.filesEntry)
        }
        MenuItem {
            visible: menu.terminalEntry !== null
            text: "Terminal"
            icon: "terminal"
            hint: "Super+Enter"
            onTriggered: menu.launch(menu.terminalEntry)
        }

        MenuSeparator { visible: menu.recent.length > 0; caption: "Recent" }

        Repeater {
            model: menu.recent
            delegate: MenuItem {
                required property var modelData
                text: modelData.name
                useAppIcon: true
                iconSource: ApplicationService.iconFor(modelData)
                onTriggered: menu.launch(modelData)
            }
        }

        MenuSeparator {}

        MenuItem {
            text: "About Axiom"
            icon: "info"
            selected: menu.aboutOpen
            onTriggered: menu.aboutOpen = !menu.aboutOpen
        }

        // Real system identity, read from os-release and /proc.
        Column {
            visible: menu.aboutOpen
            width: parent.width
            topPadding: Theme.spacingXs
            bottomPadding: Theme.spacingXs
            spacing: 3

            Repeater {
                model: [
                    ["OS", HostService.osName],
                    ["Kernel", HostService.kernel],
                    ["Host", HostService.hostname],
                    ["Uptime", HostService.uptime]
                ]
                delegate: Row {
                    required property var modelData
                    x: Theme.spacingSm + 28
                    spacing: Theme.spacingSm
                    visible: modelData[1].length > 0
                    Text {
                        width: 52
                        text: modelData[0]
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                    }
                    Text {
                        text: modelData[1]
                        color: Theme.textPrimary
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: Theme.fontCaption
                    }
                }
            }
        }

        MenuSeparator {}

        MenuItem {
            text: "Log Out"
            icon: "logout"
            confirm: true
            confirmText: "Click again to log out"
            onTriggered: { UiState.closeAllOverlays(); PowerService.logout() }
        }
        MenuItem {
            text: "Restart"
            icon: "restart"
            confirm: true
            confirmText: "Click again to restart"
            onTriggered: { UiState.closeAllOverlays(); PowerService.reboot() }
        }
        MenuItem {
            text: "Shut Down"
            icon: "power"
            destructive: true
            confirm: true
            confirmText: "Click again to shut down"
            onTriggered: { UiState.closeAllOverlays(); PowerService.powerOff() }
        }
    }
}
