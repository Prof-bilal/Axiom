pragma Singleton

// TerminalService — the Axiom boundary for "open in terminal". Apps and shell
// surfaces call open(); the service runs `axiom-terminal` with an argv array
// (never a shell string), so a path or command from the UI cannot inject
// anything. The terminal itself (foot today) is replaceable behind this API.

import Quickshell

Singleton {
    id: terminal

    readonly property string backend: "axiom-terminal"

    // Open a terminal. All arguments are optional.
    //   cwd     absolute directory path to start in
    //   title   window title
    //   command argv array to run instead of the login shell (e.g.
    //           ["pacman", "-Qi", "firefox"]); the window stays open after it
    //           exits so the output can be read
    function open(cwd, title, command) {
        var argv = ["axiom-terminal"]
        if (cwd && cwd.length > 0) argv.push("--cwd", cwd)
        if (title && title.length > 0) argv.push("--title", title)
        if (command && command.length > 0) {
            argv.push("--hold", "--exec")
            for (var i = 0; i < command.length; i++) argv.push(String(command[i]))
        }
        Quickshell.execDetached(argv)
    }
}
