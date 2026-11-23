.pragma library

// Dock magnification, macOS style: pure layout maths, no QML and no I/O. Unit-tested on the host with
// tests/shell/dock-magnify.test.mjs.
//
// The dock is a row of slots. Each slot grows by a cosine falloff of its distance to the pointer, measured from
// its REST centre, so the result depends only on the pointer and never on the current layout (no feedback loop).
// The row is then placed so the point of the rest layout that is under the pointer maps to the same screen x
// after widening: the icon under the cursor never slides away from it.

function falloff(d, reach) {
    return d >= reach ? 0 : 0.5 * (1 + Math.cos(Math.PI * d / reach))
}

// rest:     [{ w, grow }] slot widths at rest; grow is false for a separator
// gap:      space between slots
// left:     x of the first slot's left edge at rest
// px:       pointer x, in the same coordinates as left
// strength: 0..1, eases the whole effect in and out
// p:        { peak, reach } peak scale of the slot under the pointer; reach is the falloff distance in pixels
// returns   { scales, widths, xs, origin, total, restTotal }
function layout(rest, gap, left, px, strength, p) {
    var n = rest.length
    var restLeft = [], centers = [], x = left
    for (var i = 0; i < n; i++) {
        restLeft.push(x)
        centers.push(x + rest[i].w / 2)
        x += rest[i].w + gap
    }
    var scales = [], widths = [], acc = [], run = 0
    for (i = 0; i < n; i++) {
        var s = rest[i].grow ? 1 + strength * (p.peak - 1) * falloff(Math.abs(px - centers[i]), p.reach) : 1
        scales.push(s)
        widths.push(rest[i].w * s)
        acc.push(run)
        run += widths[i] + gap
    }

    // Where the rest point under the pointer lands once the slots have grown.
    var m = px - left
    if (px > left) {
        for (i = 0; i < n; i++) {
            var end = restLeft[i] + rest[i].w
            if (px <= end) { m = acc[i] + (px - restLeft[i]) * scales[i]; break }
            var next = i + 1 < n ? restLeft[i + 1] : Infinity
            if (px < next) { m = acc[i] + widths[i] + (px - end); break }
        }
    }
    var origin = px - m
    var xs = acc.map(function (a) { return origin + a })
    return {
        scales: scales, widths: widths, xs: xs, origin: origin,
        total: n ? run - gap : 0,
        restTotal: n ? x - gap - left : 0
    }
}

// How far past the rest row the widened row can reach on each side, over every pointer position.
// The dock window is sized from this once, so it never resizes while the pointer moves.
function bounds(rest, gap, p) {
    var restTotal = layout(rest, gap, 0, 0, 0, p).restTotal
    var before = 0, after = 0
    for (var px = -p.reach; px <= restTotal + p.reach; px += 2) {
        var l = layout(rest, gap, 0, px, 1, p)
        if (rest.length === 0) break
        before = Math.max(before, -l.xs[0])
        after = Math.max(after, l.xs[rest.length - 1] + l.widths[rest.length - 1] - restTotal)
    }
    return { before: Math.ceil(before), after: Math.ceil(after) }
}
