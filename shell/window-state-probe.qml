import Quickshell
import Quickshell.Io
import "services"

// Diagnostic only: no surfaces, capture, input, dispatch or window mutations.
ShellRoot {
    WindowState { id: state }
    IpcHandler {
        target: "axiomWindowProbe"
        function summary(): string { return JSON.stringify(state.summary()); }
        function revalidate(): string { state.revalidate(); return JSON.stringify({requested: true}); }
        function windowPlacement(address: string): string {
            const window = state.windowByAddress(address);
            const description = state.describe(window || null);
            if (!description) return JSON.stringify({known: false});
            return JSON.stringify({
                known: true,
                workspaceId: description.workspaceId,
                monitorName: description.monitorName,
                monitorScale: description.monitorScale,
                active: description.active
            });
        }
        function applicationSummary(appId: string): string {
            const windows = state.windows.filter(window => window.wayland && window.wayland.appId === appId);
            const addresses = windows.map(window => window.address);
            return JSON.stringify({
                windowCount: windows.length,
                activeWindowCount: windows.filter(window => window === state.activeWindow).length,
                uniqueAddressCount: addresses.filter((address, index) => addresses.indexOf(address) === index).length
            });
        }
    }
}
