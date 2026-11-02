import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared

// Compact floating menu surface shared by the Axiom, status and session
// menus: dark graphite card under the panel, subtle cyan-tinted border, a
// click anywhere outside or Escape closes it. Content goes in the card column.
PanelWindow {
    id: surface

    property bool open: false
    property bool alignRight: false
    property int cardWidth: Theme.menuWidth
    property string layerNamespace: "axiom-menu"
    default property alias content: column.data
    readonly property alias card: card

    signal opened()

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: open
    WlrLayershell.namespace: layerNamespace
    WlrLayershell.layer: WlrLayershell.Overlay
    // No `focusable:` here: it makes Quickshell request on-demand keyboard
    // interactivity and overrides the explicit Exclusive mode below, so the
    // compositor hands the keyboard straight back to the app and Escape never
    // reaches this overlay.
    WlrLayershell.keyboardFocus: open ? WlrLayershell.Exclusive : WlrLayershell.None

    onOpenChanged: if (open) { keys.forceActiveFocus(); surface.opened() }

    // Outside click closes.
    MouseArea {
        anchors.fill: parent
        onClicked: UiState.closeAllOverlays()
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: UiState.closeAllOverlays()
    }

    Rectangle {
        id: card
        x: surface.alignRight ? parent.width - width - Theme.spacingSm : Theme.spacingSm
        y: Theme.panelHeight + Theme.spacingXs
        width: Math.min(surface.cardWidth, parent.width - Theme.spacingSm * 2)
        height: Math.min(column.implicitHeight + Theme.spacingSm * 2,
                         parent.height - y - Theme.spacingSm)
        radius: Theme.radiusOverlay
        color: Theme.overlayBackground
        border.width: 1
        border.color: Theme.overlayBorder
        clip: true

        // Swallow clicks inside the card.
        MouseArea { anchors.fill: parent }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingSm
            spacing: Theme.spacingXxs
        }
    }
}
