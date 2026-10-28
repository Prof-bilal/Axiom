pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Narrow, same-user requests against one live native toplevel. This component
// never falls back to focus, title text, app IDs or a shell command.
Scope {
    id: root

    readonly property var windowState: state
    readonly property bool available: state.available && !busy
    property bool busy: false
    property string pendingAddress: ""
    property string pendingOperation: ""
    property int pendingRestoreWorkspace: 0
    property bool desiredValue: false
    property var parkedWorkspaces: ({})
    property string lastResultJson: JSON.stringify({status: "idle"})
    property var lastResult: ({status: "idle"})
    signal result(var outcome)

    readonly property string parkedWorkspaceName: "special:axiom-minimized"

    WindowState { id: state }

    function publish(status, reason, address, operation): void {
        const outcome = {
            status: status,
            reason: reason,
            address: address || "",
            operation: operation || ""
        };
        lastResult = outcome;
        lastResultJson = JSON.stringify(outcome);
        result(outcome);
    }

    function finish(status, reason): void {
        const finishedAddress = pendingAddress;
        const finishedOperation = pendingOperation;
        if (status === "verified" && finishedOperation === "minimize") {
            const next = Object.assign({}, parkedWorkspaces);
            next[finishedAddress] = pendingRestoreWorkspace;
            parkedWorkspaces = next;
        } else if (status === "verified" && finishedOperation === "restore-minimize") {
            const restored = Object.assign({}, parkedWorkspaces);
            delete restored[finishedAddress];
            parkedWorkspaces = restored;
        }
        verifyTimer.stop();
        deadline.stop();
        busy = false;
        pendingAddress = "";
        pendingOperation = "";
        pendingRestoreWorkspace = 0;
        publish(status, reason, finishedAddress, finishedOperation);
    }

    function targetProperty(operation): string {
        if (operation === "minimize" || operation === "restore-minimize") return "parked";
        if (operation === "maximize" || operation === "restore-maximize" || operation === "toggle-maximize") return "maximized";
        if (operation === "fullscreen" || operation === "exit-fullscreen" || operation === "toggle-fullscreen") return "fullscreen";
        return "";
    }

    function requestedValue(operation, target): var {
        if (operation === "maximize" || operation === "fullscreen") return true;
        if (operation === "restore-minimize" || operation === "restore-maximize" || operation === "exit-fullscreen") return false;
        if (operation === "toggle-maximize") return !target.wayland.maximized;
        if (operation === "toggle-fullscreen") return !target.wayland.fullscreen;
        return null;
    }

    function isMinimized(window): bool {
        if (!window || !window.wayland) return false;
        const address = "0x" + window.address;
        return !!window.wayland.minimized || Object.prototype.hasOwnProperty.call(parkedWorkspaces, address);
    }

    function dispatchMove(address, workspaceIdOrName, follow): void {
        Hyprland.dispatch("hl.dsp.window.move({window=\"address:" + address
                           + "\",workspace=\"" + workspaceIdOrName
                           + "\",follow=" + (follow ? "true" : "false") + "})");
    }

    function dispatchFullscreen(address, mode, action): void {
        // The address is validated before this function is called. The
        // request contains only fixed dispatcher fields; it is not a shell
        // command and never includes a title, app ID or user text.
        Hyprland.dispatch("hl.dsp.window.fullscreen({mode=\"" + mode
                           + "\",action=\"" + action
                           + "\",window=\"address:" + address + "\"})");
    }

    function request(address, operation): bool {
        if (busy) {
            publish("busy", "another action is being verified", address, operation);
            return false;
        }
        if (!state.available) {
            publish("unavailable", "compositor model is unavailable", address, operation);
            return false;
        }
        if (typeof address !== "string" || !/^0x[0-9a-f]+$/.test(address)) {
            publish("invalid", "canonical address required", address, operation);
            return false;
        }
        const target = state.windowByAddress(address);
        if (!target || !target.wayland) {
            publish("target-changed", "target is no longer live", address, operation);
            return false;
        }

        const property = targetProperty(operation);
        if (operation !== "close" && property === "") {
            publish("invalid", "unsupported operation", address, operation);
            return false;
        }

        if (operation === "restore-minimize") {
            if (!Object.prototype.hasOwnProperty.call(parkedWorkspaces, address)) {
                publish("unsupported", "no recorded workspace for minimized target", address, operation);
                return false;
            }
            pendingRestoreWorkspace = parkedWorkspaces[address];
        } else if (operation === "minimize") {
            if (!target.workspace || target.workspace.name === parkedWorkspaceName) {
                publish("unsupported", "target has no restorable workspace", address, operation);
                return false;
            }
            pendingRestoreWorkspace = target.workspace.id;
        }

        pendingAddress = address;
        pendingOperation = operation;
        desiredValue = operation === "close" ? false : requestedValue(operation, target);
        busy = true;
        deadline.start();
        verifyTimer.start();
        try {
            if (operation === "close") target.wayland.close();
            else if (operation === "minimize") dispatchMove(address, parkedWorkspaceName, false);
            else if (operation === "restore-minimize") dispatchMove(address, String(pendingRestoreWorkspace), false);
            else if (property === "maximized") dispatchFullscreen(address, "maximized", desiredValue ? "set" : "unset");
            else if (property === "fullscreen") dispatchFullscreen(address, "fullscreen", desiredValue ? "set" : "unset");
        } catch (error) {
            finish("failed", "native request threw");
            return false;
        }
        publish("pending", "request sent; waiting for native confirmation", address, operation);
        return true;
    }

    function verifyPending(): void {
        if (!busy) return;
        const target = state.windowByAddress(pendingAddress);
        if (pendingOperation === "close") {
            if (!target) finish("verified", "target disappeared after close request");
            return;
        }
        if (!target || !target.wayland) {
            finish("failed", "target disappeared before state confirmation");
            return;
        }
        if (pendingOperation === "minimize") {
            if (target.workspace && target.workspace.name === parkedWorkspaceName)
                finish("verified", "target parked on the private workspace");
            return;
        }
        if (pendingOperation === "restore-minimize") {
            if (target.workspace && target.workspace.id === pendingRestoreWorkspace)
                finish("verified", "target restored to its recorded workspace");
            return;
        }
        const property = targetProperty(pendingOperation);
        const actual = property === "maximized" ? target.wayland.maximized
            : target.wayland.fullscreen;
        if (actual === desiredValue) finish("verified", "native state confirmed");
    }

    Timer {
        id: verifyTimer
        interval: 50
        repeat: true
        onTriggered: root.verifyPending()
    }

    Timer {
        id: deadline
        interval: 1200
        repeat: false
        onTriggered: root.finish("timeout", "native state was not confirmed before deadline")
    }
}
