import QtQuick
import qs.src.shared

// The three window buttons (close, minimize, maximize) in the Axiom look. The
// symbols appear while the group is hovered. Used by the in-window title bar of
// Axiom apps and by the shell's bar for other windows, so both look the same.
Row {
    id: lights

    signal closeClicked()
    signal minimizeClicked()
    signal maximizeClicked()

    spacing: 8

    HoverHandler { id: groupHover }

    Repeater {
        model: [
            { color: "#FF5F57", glyph: "×", action: "close" },
            { color: "#FFB348", glyph: "−", action: "minimize" },
            { color: "#20D6D2", glyph: "+", action: "maximize" }
        ]
        delegate: Rectangle {
            required property var modelData
            width: 14; height: 14; radius: 7
            color: modelData.color

            Text {
                anchors.centerIn: parent
                visible: groupHover.hovered
                text: modelData.glyph
                color: "#3a2a00"
                font.pixelSize: 11
                font.bold: true
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -2
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.action === "close") lights.closeClicked()
                    else if (modelData.action === "minimize") lights.minimizeClicked()
                    else lights.maximizeClicked()
                }
            }
        }
    }
}
