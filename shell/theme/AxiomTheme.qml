import QtQuick

// Shared semantic tokens. Surfaces consume this object instead of inventing
// per-feature constants; values follow docs/desktop/DESIGN_SYSTEM.md.
QtObject {
    readonly property color background: "#151A1E"
    readonly property color surface: "#20282E"
    readonly property color surfaceRaised: "#29343B"
    readonly property color foreground: "#ECF2F4"
    readonly property color muted: "#B4C2CA"
    readonly property color accent: "#64D8C5"
    readonly property color accentText: "#102822"
    readonly property color danger: "#FF9C9C"
    readonly property color warning: "#F3D27A"
    readonly property int radiusControl: 8
    readonly property int radiusSurface: 12
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 12
    readonly property int pointerTarget: 32
    readonly property int motionImmediate: 0
    readonly property int motionFeedback: 100
    readonly property int motionStandard: 180
}
