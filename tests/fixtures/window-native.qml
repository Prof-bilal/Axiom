import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io

// Unmodified native API baseline for the observation-adapter cost experiment.
// No surfaces or processes; startup initializes the same native model families.
ShellRoot {
    IpcHandler {
        target: "axiomWindowProbe"
        function summary(): string {
            return JSON.stringify({
                status: Hyprland.monitors.values.length > 0 ? "observing" : "unavailable",
                windowCount: Hyprland.toplevels.values.length,
                workspaceCount: Hyprland.workspaces.values.length,
                monitorCount: Hyprland.monitors.values.length,
                activeWindowKnown: !!ToplevelManager.activeToplevel
            });
        }
    }
}
