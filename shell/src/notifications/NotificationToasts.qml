import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.src.notifications
import qs.services

// Transient notification toasts (top-right), hidden while the centre is open.
PanelWindow {
    id: toasts

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { top: true; right: true }
    margins.top: Theme.panelHeight + Theme.spacingSm
    margins.right: Theme.spacingSm
    implicitWidth: 340
    implicitHeight: toastColumn.childrenRect.height
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: toasts.items.length > 0 && !UiState.notificationCenterOpen
    WlrLayershell.namespace: "axiom-notifications-toast"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrLayershell.None

    readonly property var items: NotificationService.tracked
        ? NotificationService.tracked.values.slice(-4).reverse() : []

    Column {
        id: toastColumn
        width: parent.width
        spacing: Theme.spacingSm

        Repeater {
            model: toasts.items
            delegate: NotificationCard { width: toastColumn.width; notification: modelData; toast: true }
        }
    }
}
