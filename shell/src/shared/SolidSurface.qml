import QtQuick
import qs.src.shared

// Card surface: a flat solid panel from the mockups (charcoal in dark mode, white
// in light mode) with a 1 px hairline edge. No gradient, blur or transparency.
Rectangle {
    id: card

    property bool strong: false

    radius: Theme.radiusWindow
    border.width: 1
    border.color: Theme.border
    color: Theme.light ? Theme.surface : Theme.cardFill
}
