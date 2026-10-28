pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Trusted, user-session observation only. Native objects retain their identity.
Scope {
    id: root

    readonly property bool available: health.available && Hyprland.monitors.values.length > 0
    readonly property string status: available ? "observing" : "unavailable"
    readonly property bool eventConnected: health.eventConnected
    readonly property bool validating: health.checking
    signal validated(bool reachable)
    readonly property var windows: available ? Hyprland.toplevels.values : []
    readonly property var workspaces: available ? Hyprland.workspaces.values : []
    readonly property var monitors: available ? Hyprland.monitors.values : []
    // The pinned IPC module learns activeToplevel only after a focus event.
    // Wayland supplies initial activation; resolve it to the same native object.
    readonly property var activeWindow: available && ToplevelManager.activeToplevel
        ? windows.find(window => window.wayland === ToplevelManager.activeToplevel) || null
        : null
    readonly property var activeWorkspace: available ? Hyprland.focusedWorkspace : null
    readonly property var activeMonitor: available ? Hyprland.focusedMonitor : null

    // Observe both channels without processes or an idle polling loop.
    CompositorHealth {
        id: health
        onChecked: reachable => root.validated(reachable)
    }

    function revalidate(): void { health.check(); }

    // Runtime hl.monitor() changes need not emit configreloaded. Qt's actual
    // Wayland output geometry/DPI notifications cover that gap in the pinned
    // IPC model. Coalesce notifications; never poll monitor state.
    Timer {
        id: monitorRefresh
        interval: 0
        repeat: false
        onTriggered: { if (root.available) Hyprland.refreshMonitors(); }
    }
    Timer {
        id: monitorPostEventRefresh
        interval: 250
        repeat: false
        // Hyprland emits monitor-added before a subsequent Lua monitor
        // configuration settles. One bounded follow-up refresh captures the
        // final scale without turning this into a polling loop.
        onTriggered: { if (root.available) Hyprland.refreshMonitors(); }
    }

    function scheduleMonitorRefresh(): void {
        monitorRefresh.start();
        monitorPostEventRefresh.start();
    }
    Variants {
        model: Quickshell.screens
        Scope {
            id: screenWatch
            required property var modelData
            Connections {
                target: screenWatch.modelData
                function onGeometryChanged() { root.scheduleMonitorRefresh(); }
                function onPhysicalPixelDensityChanged() { root.scheduleMonitorRefresh(); }
                function onLogicalPixelDensityChanged() { root.scheduleMonitorRefresh(); }
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event && typeof event.name === "string"
                    && (event.name.indexOf("monitoradded") === 0
                        || event.name.indexOf("monitorremoved") === 0))
                root.scheduleMonitorRefresh();
        }
    }

    function contains(window): bool {
        return available && window !== null && windows.indexOf(window) !== -1;
    }

    function windowByAddress(address): var {
        if (!available || typeof address !== "string" || !/^0x[0-9a-f]+$/.test(address)) return null;
        // Quickshell exposes bare hex; Hyprland's JSON uses a 0x prefix.
        return windows.find(window => "0x" + window.address === address) || null;
    }

    function describe(window): var {
        if (!contains(window)) return null;
        const wayland = window.wayland;
        return {
            address: "0x" + window.address,
            appId: wayland ? wayland.appId : null,
            title: window.title,
            active: window === root.activeWindow,
            workspaceId: window.workspace ? window.workspace.id : null,
            monitorName: window.monitor ? window.monitor.name : null,
            monitorScale: window.monitor ? window.monitor.scale : null,
            // Foreign-toplevel exposes the compositor's asynchronous minimize
            // state. Keep it distinct from Hyprland's event-only IPC request.
            minimized: wayland ? wayland.minimized : null,
            maximized: wayland ? wayland.maximized : null,
            fullscreen: wayland ? wayland.fullscreen : null
        };
    }

    // Privacy-preserving diagnostic: no titles, addresses or app identifiers.
    function summary(): var {
        return {
            status: status,
            eventConnected: eventConnected,
            windowCount: windows.length,
            mappedWindowCount: windows.filter(window => !!window.wayland).length,
            workspaceCount: workspaces.length,
            monitorCount: monitors.length,
            activeWorkspaceId: activeWorkspace ? activeWorkspace.id : null,
            activeWindowKnown: activeWindow !== null && contains(activeWindow),
            nativeActivePresent: !!Hyprland.activeToplevel,
            waylandActivePresent: !!ToplevelManager.activeToplevel
        };
    }
}
