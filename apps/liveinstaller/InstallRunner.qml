import QtQuick
import Quickshell.Io

// Runs the root install helper through pkexec and streams its JSON lines. The install form goes to
// stdin as one line (never argv), so it cannot show up in a process list.
Item {
    id: runner

    property var argv: ["pkexec", "/usr/local/bin/axiom-install-run"]
    property string payload: ""
    property string errText: ""
    readonly property bool running: proc.running
    signal line(string text)
    signal finished(int code)

    function start(json) {
        errText = ""
        payload = json
        proc.running = true
    }

    Process {
        id: proc
        command: runner.argv
        stdinEnabled: true
        stdout: SplitParser { onRead: function (data) { runner.line(data) } }
        stderr: StdioCollector { onStreamFinished: runner.errText = text }
        onStarted: { write(runner.payload + "\n"); runner.payload = "" }
        onExited: function (exitCode) { runner.finished(exitCode) }
    }
}
