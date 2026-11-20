import QtQuick
import "installer.js" as Ins
import "worldmap.js" as WM

// World map from real country outlines (Natural Earth, simplified by scripts/gen-worldmap.py), drawn
// equirectangular so a city's latitude and longitude land exactly where the outline puts it.
// `pin` is { lat, lon } (or null); `highlight` is the ISO country code to fill; `label` is the pin's text,
// for example "Karachi, Pakistan". The pin glides to the new place; the country fill changes at once.
Item {
    id: root

    property var pin: null
    property string highlight: ""
    property string label: ""
    // Zoom into the pin (so a country is easy to see); the chip in the corner switches to the whole world.
    property bool zoomed: true
    readonly property real zoomFactor: 3.6

    // 360 degrees across, LAT_TOP to LAT_BOTTOM down: the same scale on both axes.
    height: width * (WM.LAT_TOP - WM.LAT_BOTTOM) / 360
    clip: true

    // Pin position on the unzoomed map, in pixels.
    readonly property real baseX: pin ? (pin.lon + 180) / 360 * width : width / 2
    readonly property real baseY: pin ? (WM.LAT_TOP - pin.lat) / (WM.LAT_TOP - WM.LAT_BOTTOM) * height : height / 2
    readonly property real wantZoom: pin && zoomed ? zoomFactor : 1
    // Top-left of the visible window on the unzoomed map, kept inside the map.
    readonly property real wantX: Math.max(0, Math.min(baseX - width / wantZoom / 2, width - width / wantZoom))
    readonly property real wantY: Math.max(0, Math.min(baseY - height / wantZoom / 2, height - height / wantZoom))
    property real zoomNow: wantZoom
    property real viewX: wantX
    property real viewY: wantY
    Behavior on zoomNow { NumberAnimation { duration: 600; easing.type: Easing.InOutCubic } }
    Behavior on viewX { NumberAnimation { duration: 600; easing.type: Easing.InOutCubic } }
    Behavior on viewY { NumberAnimation { duration: 600; easing.type: Easing.InOutCubic } }
    readonly property real pinX: (baseX - viewX) * zoomNow
    readonly property real pinY: (baseY - viewY) * zoomNow

    onWidthChanged: canvas.requestPaint()
    onHighlightChanged: canvas.requestPaint()
    onZoomNowChanged: canvas.requestPaint()
    onViewXChanged: canvas.requestPaint()
    onViewYChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var kb = root.width / (360 * WM.Q)                      // base pixels per stored unit
            var z = root.zoomNow
            var x0 = 180 * WM.Q
            var y0 = WM.LAT_TOP * WM.Q
            var vx = root.viewX
            var vy = root.viewY
            function trace(ring) {
                ctx.beginPath()
                ctx.moveTo(((ring[0] + x0) * kb - vx) * z, ((y0 - ring[1]) * kb - vy) * z)
                for (var i = 2; i < ring.length; i += 2)
                    ctx.lineTo(((ring[i] + x0) * kb - vx) * z, ((y0 - ring[i + 1]) * kb - vy) * z)
                ctx.closePath()
            }
            ctx.lineJoin = "round"
            ctx.lineWidth = 0.6
            ctx.fillStyle = "#3a4047"
            ctx.strokeStyle = "#181b1f"
            var chosen = null
            for (var s = 0; s < WM.SHAPES.length; s++) {
                var rings = WM.SHAPES[s][1]
                if (WM.SHAPES[s][0] === root.highlight) { chosen = rings; continue }
                for (var r = 0; r < rings.length; r++) { trace(rings[r]); ctx.fill(); ctx.stroke() }
            }
            if (chosen) {
                ctx.fillStyle = Qt.rgba(1, 0.58, 0.09, 0.62)
                ctx.strokeStyle = "#ff9418"
                ctx.lineWidth = 1.4
                for (var c = 0; c < chosen.length; c++) { trace(chosen[c]); ctx.fill(); ctx.stroke() }
            }
        }
    }

    Item {
        id: marker
        visible: root.pin !== null
        x: root.pinX
        y: root.pinY

        Rectangle {
            id: ring
            anchors.centerIn: parent
            width: 12; height: 12; radius: 6
            color: "transparent"
            border.width: 2
            border.color: Ins.C.orange
            SequentialAnimation {
                running: marker.visible
                loops: Animation.Infinite
                ParallelAnimation {
                    NumberAnimation { target: ring; property: "scale"; from: 1; to: 3.2; duration: 1300; easing.type: Easing.OutQuad }
                    NumberAnimation { target: ring; property: "opacity"; from: 0.9; to: 0; duration: 1300 }
                }
                PauseAnimation { duration: 300 }
            }
        }
        Rectangle { anchors.centerIn: parent; width: 9; height: 9; radius: 4.5; color: "#ffffff"; border.width: 2; border.color: Ins.C.orange }
    }

    Rectangle {
        id: tag
        visible: root.pin !== null && root.label.length > 0
        width: tagText.implicitWidth + 20
        height: 26
        radius: 13
        color: "#14171a"
        border.width: 1
        border.color: Ins.C.orange
        x: Math.max(2, Math.min(root.pinX - width / 2, root.width - width - 2))
        y: root.pinY - 14 - height < 2 ? root.pinY + 14 : root.pinY - 14 - height
        IText { id: tagText; anchors.centerIn: parent; text: root.label; font.pixelSize: 12; font.weight: Font.Medium; wrapMode: Text.NoWrap; color: "#ffffff" }
    }

    Rectangle {
        visible: root.pin !== null
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
        width: chipText.implicitWidth + 18
        height: 24
        radius: 12
        color: chipHit.containsMouse ? "#343a41" : "#23282d"
        border.width: 1
        border.color: "#3a4048"
        IText { id: chipText; anchors.centerIn: parent; text: root.zoomed ? "Show world" : "Zoom in"; font.pixelSize: 12; wrapMode: Text.NoWrap }
        MouseArea { id: chipHit; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.zoomed = !root.zoomed }
    }
}
