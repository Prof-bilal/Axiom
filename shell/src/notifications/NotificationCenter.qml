import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.src.notifications
import qs.services

// Notification centre: real freedesktop notification history from
// NotificationService, with per-item dismiss and clear-all.
PanelWindow {
    id: center

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { top: true; right: true }
    margins.top: Theme.panelHeight + Theme.spacingSm
    margins.right: Theme.spacingSm
    implicitWidth: 380
    implicitHeight: Math.min(520, content.implicitHeight + Theme.spacingMd * 2)
    color: Theme.overlayBackground
    visible: UiState.notificationCenterOpen
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "axiom-notification-center"
    WlrLayershell.layer: WlrLayershell.Overlay
    // No `focusable:` here: it makes Quickshell request on-demand keyboard
    // interactivity and overrides the explicit Exclusive mode below, so the
    // compositor hands the keyboard straight back to the app and Escape never
    // reaches this overlay.
    WlrLayershell.keyboardFocus: UiState.notificationCenterOpen
        ? WlrLayershell.Exclusive : WlrLayershell.None

    // PanelWindow is a window, not an Item, so key handling lives on a
    // focusable child item.
    Item {
        anchors.fill: parent
        z: -1
        focus: true
        Keys.onEscapePressed: UiState.closeAllOverlays()
    }

    readonly property var items: NotificationService.tracked
        ? NotificationService.tracked.values.slice().reverse() : []

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingSm

        Row {
            width: parent.width
            height: 24

            Text {
                text: "Notifications"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
            }

            Item {
                width: Math.max(0, parent.width - clearLabel.implicitWidth - 80)
                height: 1
            }

            Text {
                id: clearLabel
                text: "Clear all"
                color: clearHover.hovered ? Theme.accent : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                HoverHandler { id: clearHover }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -Theme.spacingXs
                    onClicked: NotificationService.dismissAll()
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        Text {
            width: parent.width
            visible: center.items.length === 0
            text: "No notifications"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
        }

        Column {
            id: history
            width: parent.width
            spacing: Theme.spacingSm

            Repeater {
                model: center.items
                delegate: NotificationCard { width: history.width; notification: modelData }
            }
        }
    }
}
