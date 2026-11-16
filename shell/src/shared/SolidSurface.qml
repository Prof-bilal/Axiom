import QtQuick
import qs.src.shared

// Card surface: a glass-like metal gradient (light at the top, darker below, as in
// the reference material) with a 1 px light hairline edge. Flat, no blur and no
// transparency, so it costs nothing at runtime. Children go inside as usual.
Rectangle {
    id: card

    property bool strong: false

    radius: Theme.radiusWindow
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.16)
    gradient: Gradient {
        GradientStop { position: 0.0; color: card.strong ? "#7A767C" : "#8C888D" }
        GradientStop { position: 0.5; color: card.strong ? "#5F5A61" : "#6B666C" }
        GradientStop { position: 1.0; color: card.strong ? "#34313A" : "#3E3A3E" }
    }
}
