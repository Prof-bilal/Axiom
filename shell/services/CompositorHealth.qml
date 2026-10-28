import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Read-only, bounded health checks for the two compositor IPC channels. The
// pinned native model exposes neither request results nor connection health.
Scope {
    id: root
    readonly property bool available: events.connected && requestHealthy
    readonly property bool eventConnected: events.connected
    property bool requestHealthy: false
    property bool checking: false
    property string response: ""
    signal checked(bool reachable)

    function check(): void {
        if (checking) return;
        if (!events.connected || request.path.length === 0) {
            requestHealthy = false;
            checked(false);
            return;
        }
        response = "";
        checking = true;
        deadline.start();
        request.connected = true;
    }

    function finish(reachable): void {
        if (!checking) return;
        checking = false;
        requestHealthy = reachable && events.connected;
        deadline.stop();
        request.connected = false;
        response = "";
        checked(requestHealthy);
    }

    function receive(data): void {
        if (!checking) return;
        if (response.length + data.length > 4096) {
            finish(false);
            return;
        }
        response += data;
        let status;
        try { status = JSON.parse(response); } catch (_) { return; }
        finish(status !== null && typeof status === "object"
               && (status.configProvider === "lua" || status.configProvider === "hyprlang"));
    }

    Timer {
        id: scheduled
        interval: 100
        repeat: false
        onTriggered: root.check()
    }
    Timer {
        id: deadline
        interval: 1000
        repeat: false
        onTriggered: root.finish(false)
    }
    Socket {
        id: events
        path: Hyprland.eventSocketPath
        connected: path.length > 0
        onConnectionStateChanged: {
            if (connected) root.check();
            else {
                root.requestHealthy = false;
                root.finish(false);
            }
        }
        // Drain chunks without retaining titles or growing a line buffer.
        // Activity coalesces checks to at most ten a second; idle has no timer.
        parser: SplitParser {
            splitMarker: ""
            onRead: scheduled.start()
        }
    }
    Socket {
        id: request
        path: Hyprland.requestSocketPath
        connected: false
        onConnectionStateChanged: {
            if (connected && root.checking) {
                write("j/status");
                flush();
            }
        }
        onError: { if (root.checking) root.finish(false); }
        parser: SplitParser {
            splitMarker: ""
            onRead: data => root.receive(data)
        }
    }
}
