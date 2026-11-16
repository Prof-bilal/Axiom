import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.services

// Axiom desktop background. Drawn by the shell on the Background layer so the
// session does not depend on an external wallpaper daemon.
PanelWindow {
    id: wallpaper
    property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true; bottom: true }
    color: Theme.background
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "axiom-wallpaper"
    WlrLayershell.layer: WlrLayershell.Background
    // On-demand keyboard so the desktop can take a name or Delete/F2 when clicked.
    WlrLayershell.keyboardFocus: WlrLayershell.OnDemand

    // The Axiom default stays underneath, so a missing or unreadable custom
    // image falls back to it instead of leaving a blank desktop.
    Image {
        anchors.fill: parent
        source: Quickshell.shellPath("assets/wallpaper.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Image {
        anchors.fill: parent
        visible: status === Image.Ready
        source: SettingsService.wallpaper.length > 0 ? "file://" + SettingsService.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        // Large photos are scaled once to the output, not kept at full size.
        sourceSize.width: wallpaper.width
        sourceSize.height: wallpaper.height
    }

    // Desktop icons and menus on the primary output only.
    Loader {
        anchors.fill: parent
        active: wallpaper.screen !== null && Quickshell.screens.length > 0
                && wallpaper.screen.name === Quickshell.screens[0].name
        source: "DesktopLayer.qml"
    }
}
