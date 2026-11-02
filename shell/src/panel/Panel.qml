import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.src.panel
import qs.services

// Axiom top panel.
//   left:   Axiom penguin + "Axiom OS" (Axiom menu), Activities, Apps, Files,
//           Terminal
//   centre: workspace switcher, centred on the output
//   right:  search, tray, notifications, network, Bluetooth, volume,
//           battery, date and time, session
// Every control opens a real surface or launches a real application.
PanelWindow {
    id: panel
    property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.panelHeight
    color: Theme.panelBackground
    exclusiveZone: Theme.panelHeight
    WlrLayershell.namespace: "axiom-panel"
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.keyboardFocus: WlrLayershell.None

    // Hairline separating the panel from the desktop.
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: Theme.panelBorder
    }

    // --- left ---
    Row {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXs

        // Axiom penguin + "Axiom OS" -> Axiom menu
        Item {
            id: brand
            anchors.verticalCenter: parent.verticalCenter
            width: brandRow.implicitWidth + Theme.spacingSm * 2
            height: Theme.panelNavHeight + 2
            Accessible.role: Accessible.Button
            Accessible.name: "Axiom menu"

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusControl + 2
                color: UiState.axiomMenuOpen ? Theme.stateSelected
                     : brandMouse.containsMouse ? Theme.stateHover : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.motionFeedback } }
            }

            Row {
                id: brandRow
                anchors.centerIn: parent
                spacing: Theme.spacingSm

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.panelMarkSize
                    height: Theme.panelMarkSize
                    // Axiom penguin: OS / session identity.
                    source: Quickshell.shellPath("assets/axiom-penguin.png")
                    sourceSize.width: Theme.panelMarkSize * 2
                    sourceSize.height: Theme.panelMarkSize * 2
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Axiom OS"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontLabel
                    font.weight: Font.Bold
                }

                AxiomIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 11
                    height: 11
                    name: "chevron-down"
                    strokeWidth: 2.2
                    color: UiState.axiomMenuOpen ? Theme.cyanBright : Theme.textSecondary
                }
            }

            MouseArea {
                id: brandMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.toggleAxiomMenu()
            }
        }

        Item { width: Theme.spacingSm; height: 1 }

        NavButton {
            anchors.verticalCenter: parent.verticalCenter
            text: "Activities"
            selected: UiState.activitiesOpen
            onActivated: UiState.toggleActivities()
        }

        NavButton {
            anchors.verticalCenter: parent.verticalCenter
            text: "Apps"
            selected: UiState.launcherOpen && UiState.launcherMode === "grid"
            onActivated: UiState.toggleLauncher("grid")
        }

        NavButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: ApplicationService.entryForAppId("pcmanfm") !== null
            text: "Files"
            icon: "folder"
            onActivated: {
                UiState.closeAllOverlays()
                ApplicationService.launchId("pcmanfm")
            }
        }

        NavButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: ApplicationService.entryForAppId("foot") !== null
            text: "Terminal"
            icon: "terminal"
            onActivated: {
                UiState.closeAllOverlays()
                ApplicationService.launchId("foot")
            }
        }
    }

    // --- centre ---
    WorkspaceIndicator {
        anchors.centerIn: parent
    }

    // --- right ---
    Row {
        id: right
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXxs

        PanelButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "search"
            accessibleName: "Search applications"
            selected: UiState.launcherOpen && UiState.launcherMode === "search"
            onClicked: UiState.toggleLauncher("search")
        }

        PanelButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "bell"
            accessibleName: "Notifications"
            selected: UiState.notificationCenterOpen
            badge: NotificationService.count > 0
            badgeUrgent: true
            onClicked: UiState.toggleNotificationCenter()
        }

        Tray {
            id: tray
            anchors.verticalCenter: parent.verticalCenter
        }

        StatusIndicators {
            anchors.verticalCenter: parent.verticalCenter
        }

        Clock {
            anchors.verticalCenter: parent.verticalCenter
        }

        PanelButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "power"
            accessibleName: "Session"
            selected: UiState.sessionMenuOpen
            onClicked: UiState.toggleSessionMenu()
        }
    }
}
