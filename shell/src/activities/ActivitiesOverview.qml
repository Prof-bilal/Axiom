import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.services

// Activities overview (panel "Activities", Super+S): every open window from
// the compositor's toplevel list, with a live preview where the compositor
// supports toplevel capture (app icon otherwise), plus the workspace switcher.
// Click a window to focus it; the x closes it (a normal close request the
// application may decline, e.g. to save work).
PanelWindow {
    id: overview

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Qt.rgba(2 / 255, 5 / 255, 7 / 255, 0.72)
    visible: UiState.activitiesOpen
    WlrLayershell.namespace: "axiom-activities"
    WlrLayershell.layer: WlrLayershell.Overlay
    // No `focusable:` here: it makes Quickshell request on-demand keyboard
    // interactivity and overrides the explicit Exclusive mode below, so the
    // compositor hands the keyboard straight back to the app and Escape never
    // reaches this overlay.
    WlrLayershell.keyboardFocus: UiState.activitiesOpen ? WlrLayershell.Exclusive : WlrLayershell.None

    readonly property var windows: WindowService.list()

    onVisibleChanged: if (visible) keys.forceActiveFocus()

    MouseArea { anchors.fill: parent; onClicked: UiState.closeAllOverlays() }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: UiState.closeAllOverlays()
    }

    Column {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.panelHeight + Theme.spacingXl
        width: Math.min(parent.width - 96, 1400)
        spacing: Theme.spacingXl

        // --- workspaces ---
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingMd

            Repeater {
                model: WorkspaceService.list
                delegate: Rectangle {
                    required property var modelData
                    width: 132
                    height: 78
                    radius: Theme.radiusSurface
                    color: modelData.active ? Theme.stateSelected : (wsMouse.containsMouse ? Theme.surfaceHover : Theme.surface)
                    border.width: 1
                    border.color: modelData.active ? Theme.cyan : Theme.border

                    Text {
                        anchors.centerIn: parent
                        text: modelData.name
                        color: modelData.active ? Theme.cyanBright : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontDisplay
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        id: wsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WorkspaceService.activate(modelData)
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: overview.windows.length === 0 ? "No open windows"
                : overview.windows.length + (overview.windows.length === 1 ? " window" : " windows")
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }

        // --- windows ---
        Flow {
            id: grid
            width: parent.width
            spacing: Theme.spacingLg
            readonly property int cardWidth: 300
            // Centre the cards: n cards on the first row, at most what fits.
            readonly property int perRow: Math.max(1, Math.floor((width + spacing) / (cardWidth + spacing)))
            readonly property int firstRow: Math.max(1, Math.min(perRow, overview.windows.length))
            leftPadding: Math.max(0, (width - (firstRow * (cardWidth + spacing) - spacing)) / 2)

            Repeater {
                model: overview.windows
                delegate: Rectangle {
                    id: card
                    required property var modelData
                    readonly property var entry: ApplicationService.entryForAppId(modelData.appId)
                    width: grid.cardWidth
                    height: 214
                    radius: Theme.radiusOverlay
                    color: Theme.surface
                    border.width: 1
                    border.color: modelData.activated ? Theme.cyan
                                : cardMouse.containsMouse ? Theme.stateSelectedBorder : Theme.border

                    // Preview area
                    Rectangle {
                        id: preview
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                        height: 150
                        radius: Theme.radiusSurface
                        color: Theme.background
                        clip: true

                        ScreencopyView {
                            id: shot
                            anchors.fill: parent
                            captureSource: overview.visible ? card.modelData : null
                            live: false
                            visible: hasContent
                        }

                        AppIcon {
                            anchors.centerIn: parent
                            visible: !shot.hasContent
                            size: 64
                            source: card.entry ? ApplicationService.iconFor(card.entry)
                                               : ApplicationService.resolveIcon(card.modelData.appId)
                        }
                    }

                    Row {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
                        spacing: Theme.spacingSm
                        AppIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            size: 20
                            source: card.entry ? ApplicationService.iconFor(card.entry)
                                               : ApplicationService.resolveIcon(card.modelData.appId)
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 60
                            text: card.modelData.title || (card.entry ? card.entry.name : card.modelData.appId)
                            elide: Text.ElideRight
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.Medium
                        }
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            UiState.closeAllOverlays()
                            WindowService.activate(card.modelData)
                        }
                    }

                    // Close request
                    Rectangle {
                        anchors { right: parent.right; top: parent.top; margins: 14 }
                        width: 26; height: 26; radius: 13
                        visible: cardMouse.containsMouse || closeMouse.containsMouse
                        color: closeMouse.containsMouse ? Theme.orangeMuted : Qt.rgba(0, 0, 0, 0.6)
                        AxiomIcon {
                            anchors.centerIn: parent
                            width: 14; height: 14
                            name: "close"
                            color: closeMouse.containsMouse ? Theme.orangeBright : Theme.textPrimary
                        }
                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: WindowService.close(card.modelData)
                        }
                    }
                }
            }
        }
    }
}
