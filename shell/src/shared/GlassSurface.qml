import QtQuick
import qs.src.shared

// Glass card (ADR-029): translucent fill with a 1 px cyan-to-amber gradient
// edge. Blur comes from the compositor, not from here, so on a compositor
// without blur this is a tinted card. Children go inside as usual.
Rectangle {
    id: glass

    property bool strong: false

    radius: Theme.radiusWindow
    color: strong ? Theme.glassFillStrong : Theme.glassFill

    // A Rectangle border cannot take a gradient, and the fill is translucent so
    // an inset rectangle cannot hide a gradient backing. Stroke it once instead.
    Canvas {
        id: edge
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const g = ctx.createLinearGradient(0, 0, width, height)
            g.addColorStop(0, Theme.glassEdgeStart)
            g.addColorStop(1, Theme.glassEdgeEnd)
            ctx.strokeStyle = g
            ctx.lineWidth = 1
            const r = Math.min(glass.radius, width / 2, height / 2)
            ctx.beginPath()
            ctx.roundedRect(0.5, 0.5, width - 1, height - 1, r, r)
            ctx.stroke()
        }
    }
}
