import QtQuick

// Frosted card: translucent fill plus the Axiom teal->amber gradient stroke.
// Set `accentStroke: false` for a plain hairline, `danger: true` for red glow.
// Background blur is the compositor's job (labwc has none yet), so the fill
// alpha alone keeps text readable over any wallpaper.
Item {
    id: glass
    property real radius: Theme.radiusOverlay
    property color fill: Theme.overlayBackground
    property bool accentStroke: true
    property bool danger: false
    default property alias content: inner.data

    Rectangle {
        id: stroke
        anchors.fill: parent
        radius: glass.radius
        visible: glass.accentStroke || glass.danger
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: glass.danger ? Theme.danger : Theme.strokeStart }
            GradientStop { position: 1; color: glass.danger ? Theme.orange : Theme.strokeEnd }
        }
        opacity: Theme.dark ? 0.85 : 0.65
    }

    Rectangle {
        id: body
        anchors.fill: parent
        anchors.margins: glass.accentStroke || glass.danger ? 1 : 0
        radius: glass.radius - (glass.accentStroke || glass.danger ? 1 : 0)
        color: glass.fill
        border.width: glass.accentStroke || glass.danger ? 0 : 1
        border.color: Theme.overlayBorder
        clip: true

        Item { id: inner; anchors.fill: parent }
    }
}
