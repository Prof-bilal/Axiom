import Quickshell
import Quickshell.Io
import "services"

// Surface-free integration probe for real window actions. It is intentionally
// separate from the visible control panel so tests can target owned windows.
ShellRoot {
    WindowActions { id: actions }

    IpcHandler {
        target: "axiomWindowControlsProbe"

        function summary(): string {
            return JSON.stringify(actions.windowState.summary());
        }

        function windows(): string {
            return JSON.stringify(actions.windowState.windows.map(window => {
                const description = actions.windowState.describe(window);
                if (description) description.minimized = actions.isMinimized(window);
                return description;
            }));
        }

        function action(address: string, operation: string): string {
            return JSON.stringify({queued: actions.request(address, operation)});
        }

        function lastResult(): string { return actions.lastResultJson; }
    }
}
