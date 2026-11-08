import QtQuick
import Quickshell
import qs.src.shared
import qs.services

// Axiom session menu (panel power button) — real log out / restart / shut
// down via PowerService (systemd + logind). Each action needs a confirming
// second click so a stray click cannot end the session. Lock is immediate.
MenuSurface {
    id: menu

    open: UiState.sessionMenuOpen
    alignRight: true
    layerNamespace: "axiom-session-menu"
    cardWidth: 230

    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 88
        height: 88
        source: Quickshell.shellPath("assets/mascots/shutdown.png")
        sourceSize.width: 176
        sourceSize.height: 176
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
    }

    MenuSeparator { caption: "Session" }

    MenuItem {
        text: "Lock Screen"
        icon: "lock"
        onTriggered: { UiState.closeAllOverlays(); UiState.lockRequested() }
    }

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
