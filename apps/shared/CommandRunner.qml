import QtQuick
import Quickshell.Io

// Run commands as argv arrays (never shell strings) and get the result:
//   runner.run(["pacman", "-Qi"], function (r) { r.code, r.out, r.err })
// Output is collected whole; use it for bounded output, not for streams.
Item {
    id: runner

    property int running: 0

    Component {
        id: procComponent
        Process {
            id: proc
            property var callback: null
            property string out: ""
            property string err: ""
            property bool outDone: false
            property bool errDone: false
            property bool exited: false
            property int code: -1
            stdout: StdioCollector { onStreamFinished: { proc.out = text; proc.outDone = true; proc.check() } }
            stderr: StdioCollector { onStreamFinished: { proc.err = text; proc.errDone = true; proc.check() } }
            onExited: function (exitCode) { code = exitCode; exited = true; check() }
            function check() {
                if (!(outDone && errDone && exited)) return
                runner.running--
                var cb = callback
                var r = { code: code, out: out, err: err }
                destroy()
                if (cb) cb(r)
            }
        }
    }

    function run(argv, callback) {
        running++
        var p = procComponent.createObject(runner, { command: argv, callback: callback })
        p.running = true
    }

    // Convenience: the same command with a C locale, so parsers see stable text.
    function runC(argv, callback) { run(["env", "LC_ALL=C"].concat(argv), callback) }
}
