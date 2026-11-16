import QtQuick

// A crescent moon for "Sleep", drawn so it takes any colour and size.
Canvas {
    id: moon
    property color color: "white"
    width: 20
    height: 20
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var w = width, h = height
        ctx.fillStyle = moon.color
        ctx.beginPath()
        ctx.arc(w * 0.5, h * 0.5, w * 0.42, 0, Math.PI * 2)
        ctx.fill()
        // Cut a second circle out to leave the crescent.
        ctx.globalCompositeOperation = "destination-out"
        ctx.beginPath()
        ctx.arc(w * 0.68, h * 0.38, w * 0.36, 0, Math.PI * 2)
        ctx.fill()
    }
}
