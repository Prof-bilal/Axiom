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
        "lock": {
            stroke: "M6 11h12v9H6z M8.5 11V8a3.5 3.5 0 0 1 7 0v3"
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
        "settings": {
            stroke: "M4 7h9 M17 7h3 M4 12h3 M11 12h9 M4 17h11 M19 17h1 M15 4.5v5 M9 9.5v5 M17 14.5v5"
        },
        "arrow-left": {
            stroke: "M19 12H5 M11 6l-6 6 6 6"
        },
        "arrow-right": {
            stroke: "M5 12h14 M13 6l6 6-6 6"
        },
        "arrow-up": {
            stroke: "M12 19V5 M6 11l6-6 6 6"
        },
        "refresh": {
            stroke: "M19.5 12a7.5 7.5 0 1 1-2.2-5.3 M19.5 4.5v4h-4"
        },
        "eye": {
            stroke: "M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z M12 9.2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6z"
        },
        "plus": {
            stroke: "M12 5v14 M5 12h14"
        },
        "sort": {
            stroke: "M8 5v14 M4.5 15.5L8 19l3.5-3.5 M16 19V5 M12.5 8.5L16 5l3.5 3.5"
        },
        "home": {
            stroke: "M3.5 11.5L12 4l8.5 7.5 M6 10v10h12V10 M10 20v-6h4v6"
        },
        "download": {
            stroke: "M12 4v11 M7 10.5l5 5 5-5 M5 20h14"
        },
        "disk": {
            stroke: "M4 14h16v6H4z M4 14l2-9h12l2 9 M16.5 17h.01"
        },
        "file": {
            stroke: "M7 3h7l5 5v12a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1z M14 3v5h5"
        },
        "document": {
            stroke: "M7 3h7l5 5v12a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1z M14 3v5h5 M9.5 13h6 M9.5 17h6"
        },
        "image": {
            stroke: "M4 5h16a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z M3 16l5-5 4 4 3-3 6 6",
            dots: [[15.5, 9.5, 1.3]]
        },
        "audio": {
            stroke: "M9 17.5V6l10-2v11.5 M9 17.5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z M19 15.5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z"
        },
        "video": {
            stroke: "M3.5 6h11.5v12H3.5z M15 10.5l5.5-3.5v10L15 13.5"
        },
        "archive": {
            stroke: "M4.5 4h15v4h-15z M5.5 8v12h13V8 M10 12h4"
        },
        "code": {
            stroke: "M9 7.5L4 12l5 4.5 M15 7.5l5 4.5-5 4.5"
        },
        "broken-link": {
            stroke: "M10.5 13.5L8 16a3 3 0 0 1-4.2-4.2L6.5 9 M13.5 10.5L16 8a3 3 0 0 1 4.2 4.2L17.5 15 M4 4l16 16"
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
