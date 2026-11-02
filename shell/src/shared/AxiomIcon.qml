import QtQuick

// AxiomIcon — the shell's monochrome system icon set.
//
// Original Axiom geometry on a 24-unit grid, stroked at a single weight and
// tinted by state tokens (white/grey normally, cyan when active, orange when
// urgent). Drawing paths directly avoids depending on an icon font: the
// previous panel used Font Awesome code points with no such font installed,
// which rendered as empty boxes.
//
// Application icons are NOT drawn here; they come from the XDG icon theme via
// ApplicationService.
Canvas {
    id: icon

    property string name: ""
    property color color: Theme.textPrimary
    property real strokeWidth: 1.8
    // 0..1 fill level, used by "battery".
    property real level: 0

    implicitWidth: Theme.panelIconSize
    implicitHeight: Theme.panelIconSize
    renderTarget: Canvas.Image
    antialiasing: true

    // stroke: SVG path data; fill: filled SVG path data; dots: [x, y, r]
    readonly property var glyphs: ({
        "network-wired": {
            stroke: "M9 3h6v5H9z M12 8v4 M5 12h14 M5 12v4 M19 12v4 M2 16h6v5H2z M16 16h6v5h-6z"
        },
        "network-wireless": {
            stroke: "M2.5 9.2a14 14 0 0 1 19 0 M5.8 12.6a9.2 9.2 0 0 1 12.4 0 M9.1 16a4.5 4.5 0 0 1 5.8 0",
            dots: [[12, 19.4, 1.4]]
        },
        "network-offline": {
            stroke: "M2.5 9.2a14 14 0 0 1 19 0 M5.8 12.6a9.2 9.2 0 0 1 12.4 0 M9.1 16a4.5 4.5 0 0 1 5.8 0 M4 3l16 18"
        },
        "bluetooth": {
            stroke: "M7 7.5l10 9-5 4.5V3l5 4.5-10 9"
        },
        "volume-high": {
            stroke: "M4 9.5h3.5L12 5.5v13l-4.5-4H4z M15.5 9a4.2 4.2 0 0 1 0 6 M18.2 6.3a8 8 0 0 1 0 11.4"
        },
        "volume-low": {
            stroke: "M4 9.5h3.5L12 5.5v13l-4.5-4H4z M15.5 9a4.2 4.2 0 0 1 0 6"
        },
        "volume-muted": {
            stroke: "M4 9.5h3.5L12 5.5v13l-4.5-4H4z M15.5 9.5l5 5 M20.5 9.5l-5 5"
        },
        "battery": {
            stroke: "M2.5 7.5h16v9h-16z M21 10.5v3"
        },
        "battery-charging": {
            stroke: "M2.5 7.5h16v9h-16z M21 10.5v3 M11 9l-2.5 3.2h3L9 15"
        },
        "bell": {
            stroke: "M6 16.5v-5.5a6 6 0 0 1 12 0v5.5l1.5 1.8h-15z M10 20.6a2.1 2.1 0 0 0 4 0"
        },
        "power": {
            stroke: "M12 3v8.5 M7.2 6.2a8 8 0 1 0 9.6 0"
        },
        "search": {
            stroke: "M10.5 3.8a6.7 6.7 0 1 0 0.01 0z M15.4 15.4l5 5"
        },
        "grid": {
            stroke: "M4 4h6v6H4z M14 4h6v6h-6z M4 14h6v6H4z M14 14h6v6h-6z"
        },
        "folder": {
            stroke: "M3 6.5a1.5 1.5 0 0 1 1.5-1.5h4.8l2 2.2h8.2a1.5 1.5 0 0 1 1.5 1.5v9.8a1.5 1.5 0 0 1-1.5 1.5h-15A1.5 1.5 0 0 1 3 18.5z"
        },
        "terminal": {
            stroke: "M3 5h18v14H3z M7 10l3 2.2L7 14.4 M12.5 15h4.5"
        },
        "info": {
            stroke: "M12 3a9 9 0 1 0 0.01 0z M12 11v5.5",
            dots: [[12, 7.6, 1.2]]
        },
        "logout": {
            stroke: "M14 4h4.5a1.5 1.5 0 0 1 1.5 1.5v13a1.5 1.5 0 0 1-1.5 1.5H14 M10 8l-4 4 4 4 M6 12h10"
        },
        "restart": {
            stroke: "M19.5 12a7.5 7.5 0 1 1-2.2-5.3 M19.8 3.8v4.6h-4.6"
        },
        "close": {
            stroke: "M6.5 6.5l11 11 M17.5 6.5l-11 11"
        },
        "chevron-down": {
            stroke: "M6 9.5l6 6 6-6"
        },
        "trash": {
            stroke: "M4 6.5h16 M9.5 6.5V4.5h5v2 M6 6.5l1 13a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1l1-13 M10 10.5v6.5 M14 10.5v6.5"
        },
        "window": {
            stroke: "M4 5h16a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z M3 9h18"
        },
        "chevron-right": {
            stroke: "M9.5 6l6 6-6 6"
        },
        "application": {
            stroke: "M5 4h14a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1z M4 8.5h16",
            dots: [[6.6, 6.3, 0.8], [9, 6.3, 0.8]]
        }
    })

    onNameChanged: requestPaint()
    onColorChanged: requestPaint()
    onLevelChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var g = glyphs[name] || glyphs["application"]
        var s = Math.min(width, height) / 24
        ctx.save()
        ctx.translate((width - 24 * s) / 2, (height - 24 * s) / 2)
        ctx.scale(s, s)
        ctx.strokeStyle = icon.color
        ctx.fillStyle = icon.color
        ctx.lineWidth = icon.strokeWidth
        ctx.lineCap = "round"
        ctx.lineJoin = "round"

        if (name === "battery" || name === "battery-charging") {
            var lv = Math.max(0, Math.min(1, level))
            if (name === "battery" && lv > 0) {
                ctx.beginPath()
                ctx.rect(4.5, 9.5, 12 * lv, 5)
                ctx.fill()
            }
        }
        if (g.stroke) {
            ctx.beginPath()
            ctx.path = g.stroke
            ctx.stroke()
        }
        if (g.dots) {
            for (var i = 0; i < g.dots.length; i++) {
                ctx.beginPath()
                ctx.arc(g.dots[i][0], g.dots[i][1], g.dots[i][2], 0, Math.PI * 2)
                ctx.fill()
            }
        }
        ctx.restore()
    }
}
