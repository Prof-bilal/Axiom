import QtQuick
import qs.src.shared
import "files.js" as Files

// Large folder and file icons for the Files grid (ADR-029 look): a coloured
// folder with a tab, or a page with a folded corner and a type mark. Drawn with
// Canvas so no image assets are needed. Folder colour comes from the name, so
// the same folder always gets the same colour.
Item {
    id: glyph
    property var entry
    property real size: 84

    width: size
    height: size

    readonly property bool isFolder: entry ? entry.isDir === true : false
    readonly property string kind: entry ? Files.category(entry) : "file"
    // Amber or cyan folders, like the reference.
    readonly property color folderColor: {
        var n = entry ? entry.name : ""
        var h = 0
        for (var i = 0; i < n.length; i++) h = (h * 31 + n.charCodeAt(i)) % 7
        return h % 2 === 0 ? "#F5B73B" : "#4FD6D6"
    }
    readonly property color markColor: kind === "code" ? "#FFB348"
        : kind === "image" ? "#4FD6D6" : kind === "document" ? "#EF5350" : "#8EA2A5"

    onFolderColorChanged: canvas.requestPaint()
    onKindChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width, h = height, r = w * 0.09
            if (glyph.isFolder) {
                var col = glyph.folderColor
                // back plate with the tab
                ctx.fillStyle = Qt.darker(col, 1.25)
                ctx.beginPath()
                ctx.moveTo(r, h * 0.22)
                ctx.lineTo(w * 0.38, h * 0.22)
                ctx.lineTo(w * 0.46, h * 0.32)
                ctx.lineTo(w - r, h * 0.32)
                ctx.arcTo(w, h * 0.32, w, h * 0.32 + r, r)
                ctx.lineTo(w, h - r)
                ctx.arcTo(w, h, w - r, h, r)
                ctx.lineTo(r, h)
                ctx.arcTo(0, h, 0, h - r, r)
                ctx.lineTo(0, h * 0.22 + r)
                ctx.arcTo(0, h * 0.22, r, h * 0.22, r)
                ctx.fill()
                // front panel
                ctx.fillStyle = col
                ctx.beginPath()
                ctx.moveTo(0, h * 0.40)
                ctx.lineTo(w, h * 0.40)
                ctx.lineTo(w, h - r)
                ctx.arcTo(w, h, w - r, h, r)
                ctx.lineTo(r, h)
                ctx.arcTo(0, h, 0, h - r, r)
                ctx.lineTo(0, h * 0.40)
                ctx.fill()
            } else {
                // page with a folded top-right corner
                var fold = w * 0.26
                ctx.fillStyle = "#E9EEF0"
                ctx.beginPath()
                ctx.moveTo(w * 0.12, 0)
                ctx.lineTo(w - fold, 0)
                ctx.lineTo(w, fold)
                ctx.lineTo(w, h)
                ctx.lineTo(w * 0.12, h)
                ctx.closePath()
                ctx.fill()
                ctx.fillStyle = "#B8C4C7"
                ctx.beginPath()
                ctx.moveTo(w - fold, 0)
                ctx.lineTo(w - fold, fold)
                ctx.lineTo(w, fold)
                ctx.closePath()
                ctx.fill()
                // type mark: a bar for code, a box for images, a line for others
                ctx.fillStyle = glyph.markColor
                if (glyph.kind === "image") {
                    ctx.fillRect(w * 0.26, h * 0.46, w * 0.48, h * 0.30)
                } else {
                    ctx.fillRect(w * 0.26, h * 0.50, w * 0.48, h * 0.07)
                    ctx.fillRect(w * 0.26, h * 0.62, w * 0.36, h * 0.07)
                }
            }
        }
    }
}
