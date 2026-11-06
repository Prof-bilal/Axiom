pragma Singleton

// DisplayService — real output control through the compositor's
// wlr-output-management protocol (wlr-randr). Outputs, modes, scale and
// rotation are what the compositor reports; nothing is cached or invented.
// A change is applied immediately and must be confirmed within `revertSeconds`,
// otherwise the previous state is restored (a bad mode must not strand the user).

import QtQuick
import Quickshell
import qs.apps.shared

Singleton {
    id: display

    property var outputs: []          // [{name, make, model, enabled, scale, transform, width, height, refresh, modes:[...]}]
    property string error: ""
    property bool available: true     // false when wlr-randr is missing or the compositor lacks the protocol

    // Pending change awaiting confirmation: {name, previous:{mode?, scale?, transform?}, seconds}
    property var pending: null
    readonly property int revertSeconds: 12

    CommandRunner { id: runner }

    function refresh() {
        runner.runC(["wlr-randr", "--json"], function (r) {
            if (r.code !== 0) {
                display.available = false
                display.error = (r.err || "wlr-randr failed").trim().split("\n")[0]
                display.outputs = []
                return
            }
            try {
                display.outputs = display.parse(JSON.parse(r.out))
                display.available = true
                display.error = ""
            } catch (e) {
                display.available = false
                display.error = "Unreadable output from the compositor"
            }
        })
    }

    function parse(raw) {
        return raw.map(function (o) {
            var modes = (o.modes || []).map(function (m) {
                return { width: m.width, height: m.height, refresh: m.refresh, current: !!m.current, preferred: !!m.preferred }
            })
            var cur = modes.filter(function (m) { return m.current })[0] || { width: 0, height: 0, refresh: 0 }
            return {
                name: o.name, make: o.make || "", model: o.model || "", enabled: !!o.enabled,
                scale: o.scale || 1, transform: o.transform || "normal",
                width: cur.width, height: cur.height, refresh: cur.refresh, modes: modes
            }
        })
    }

    function modeArg(m) { return m.width + "x" + m.height + "@" + m.refresh.toFixed(3) + "Hz" }

    function outputByName(name) {
        for (var i = 0; i < outputs.length; i++) if (outputs[i].name === name) return outputs[i]
        return null
    }

    // change = {mode?: {width,height,refresh}, scale?: number, transform?: string}
    function apply(name, change) {
        var o = outputByName(name)
        if (!o || pending) return
        var argv = ["wlr-randr", "--output", name]
        var previous = {}
        if (change.mode) { argv.push("--mode", modeArg(change.mode)); previous.mode = { width: o.width, height: o.height, refresh: o.refresh } }
        if (change.scale !== undefined) { argv.push("--scale", String(change.scale)); previous.scale = o.scale }
        if (change.transform) { argv.push("--transform", change.transform); previous.transform = o.transform }
        if (argv.length === 3) return
        runner.runC(argv, function (r) {
            if (r.code !== 0) { display.error = (r.err || "The compositor rejected the change").trim().split("\n")[0]; display.refresh(); return }
            display.error = ""
            display.pending = { name: name, previous: previous, seconds: display.revertSeconds }
            display.refresh()
        })
    }

    function confirm() { pending = null }

    function revert() {
        if (!pending) return
        var p = pending
        pending = null
        var argv = ["wlr-randr", "--output", p.name]
        if (p.previous.mode) argv.push("--mode", modeArg(p.previous.mode))
        if (p.previous.scale !== undefined) argv.push("--scale", String(p.previous.scale))
        if (p.previous.transform) argv.push("--transform", p.previous.transform)
        runner.runC(argv, function () { display.refresh() })
    }

    function setPower(name, on) {
        runner.runC(["wlr-randr", "--output", name, on ? "--on" : "--off"], function () { display.refresh() })
    }

    // Used by the idle blanker: every output on or off.
    function setAllPower(on) {
        // Re-read the outputs first: they may all be off, or not read yet.
        console.warn("DisplayService.setAllPower on=" + on)
        runner.runC(["wlr-randr", "--json"], function (r) {
            console.warn("DisplayService.list code=" + r.code + " err=" + r.err)
            if (r.code !== 0) return
            try { display.parse(JSON.parse(r.out)).forEach(function (o) { display.setPower(o.name, on) }) } catch (e) { console.warn("DisplayService.parse " + e) }
        })
    }

    Timer {
        interval: 1000
        repeat: true
        running: display.pending !== null
        onTriggered: {
            var p = display.pending
            if (!p) return
            if (p.seconds <= 1) display.revert()
            else display.pending = { name: p.name, previous: p.previous, seconds: p.seconds - 1 }
        }
    }

}
