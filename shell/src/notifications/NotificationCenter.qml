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
    margins.top: Theme.panelBottom + Theme.spacingSm
    margins.right: Theme.spacingSm
    implicitWidth: 380
    implicitHeight: Math.min(520, content.implicitHeight + Theme.spacingMd * 2)
    color: "transparent"
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

    SolidSurface {
        anchors.fill: parent
        z: -2
        strong: true
    }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Header: title and a "Clear All" pill, as in the reference.
        Row {
            width: parent.width
            height: 32

            Text {
                id: headerTitle
                anchors.verticalCenter: parent.verticalCenter
                text: "Notifications"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontTitle
                font.weight: Font.DemiBold
            }

            Item {
                width: Math.max(0, parent.width - headerTitle.implicitWidth - clearPill.width)
                height: 1
            }

            Rectangle {
                id: clearPill
                anchors.verticalCenter: parent.verticalCenter
                width: clearLabel.implicitWidth + Theme.spacingLg * 2
                height: 28
                radius: height / 2
                color: clearHover.hovered ? Theme.stateHover : Theme.cardFill
                border.width: 1
                border.color: Theme.borderSubtle
                HoverHandler { id: clearHover }
                Text {
                    id: clearLabel
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: NotificationService.dismissAll()
                }
            }
        }

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
            spacing: Theme.spacingMd

            Repeater {
                model: center.items
                delegate: NotificationCard { width: history.width; notification: modelData }
            }
        }
    }
}
