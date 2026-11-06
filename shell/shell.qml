// Axiom Shell — Phase 3 MVP entry point.
// Hosts every Axiom surface over the Wayland session. Surfaces read system
// state through the service singletons in qs.services and never perform
// privileged operations themselves.
//@ pragma AppId org.axiom.Shell
//@ pragma IconTheme Adwaita

import QtQuick
import Quickshell
import Quickshell.Io
import qs.src.shared
import qs.src.panel
import qs.src.desktop
import qs.src.dock
import qs.src.launcher
import qs.src.notifications
import qs.src.session
import qs.src.status
import qs.src.menu
import qs.src.activities
import qs.services

ShellRoot {
    id: root

    // Background, then panel and dock on every output.
    Variants {
        model: Quickshell.screens
        Wallpaper {
            property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        Panel {
            property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        Dock {
            property var modelData
            screen: modelData
        }
    }

    // Single-instance overlays on the primary output.
    Launcher {}
    AxiomMenu {}
    ActivitiesOverview {}
    NotificationToasts {}
    NotificationCenter {}
    SessionMenu {}
    ControlCenter {}
    IdleBlank {}

    // Surface control for compositor keybindings, plus session actions so the
    // same PowerService path is reachable from a keybinding or a script. The
    // actions still run through the service boundary, never from UI code.
    IpcHandler {
        target: "axiom"
        function toggleLauncher(): void { UiState.toggleLauncher("search") }
        function toggleApps(): void { UiState.toggleLauncher("grid") }
        function toggleActivities(): void { UiState.toggleActivities() }
        function toggleAxiomMenu(): void { UiState.toggleAxiomMenu() }
        function toggleSessionMenu(): void { UiState.toggleSessionMenu() }
        function toggleNotificationCenter(): void { UiState.toggleNotificationCenter() }
        function toggleControlCenter(): void { UiState.toggleControlCenter() }
        function closeOverlays(): void { UiState.closeAllOverlays() }

        // Axiom Terminal default size ("WxH" in pixels): 70% x 68% of the
        // usable area of the primary output. Used by /usr/local/bin/axiom-terminal
        // because the compositor harness only resizes in absolute pixels.
        function terminalGeometry(): string {
            var s = Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
            if (!s) return ""
            var usableH = s.height - Theme.panelHeight - (Theme.dockItemSize + Theme.dockPadding * 2 + Theme.dockEdgeGap)
            // Content size: the compositor adds its ~34 px title bar on top.
            return Math.round(s.width * 0.70) + "x" + Math.max(200, Math.round(usableH * 0.68) - 34)
        }
        function logout(): void { PowerService.logout() }
        function reboot(): void { PowerService.reboot() }
        function powerOff(): void { PowerService.powerOff() }
    }
}
