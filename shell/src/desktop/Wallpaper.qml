import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared

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
    WlrLayershell.keyboardFocus: WlrLayershell.None

    Image {
        anchors.fill: parent
        source: Quickshell.shellPath("assets/wallpaper.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
}
