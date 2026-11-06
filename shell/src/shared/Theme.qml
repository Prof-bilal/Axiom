pragma Singleton

// Axiom design tokens. UI components read these instead of literals so the
// shell toolkit can be replaced without rewriting product behavior.
//
// Canonical source: branding/theme/axiom/colors.toml and
// docs/DESKTOP_DESIGN.md. Keep the three in step.
//
// Colour budget: ~80% neutral graphite, ~15% cyan, ~5% orange. Cyan means
// "focus / selected / active"; orange means "urgent / destructive / attention"
// and is never used as decoration.

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: theme

    // --- base neutrals ---
    readonly property color background: "#070B0D"
    readonly property color surface: "#0C1215"
    readonly property color surfaceElevated: "#11191D"
    readonly property color surfaceHover: "#162126"
    readonly property color border: "#233238"
    readonly property color borderSubtle: "#182328"
    readonly property color textPrimary: "#EDF5F5"
    readonly property color textSecondary: "#8EA2A5"
    readonly property color textDisabled: "#4E5E62"

    // --- Axiom cyan (primary accent) ---
    readonly property color cyan: "#20D6D2"
    readonly property color cyanBright: "#37F0EA"
    readonly property color cyanMuted: "#126E70"

    // --- Axiom orange (secondary accent; urgent/destructive only) ---
    readonly property color orange: "#FF9418"
    readonly property color orangeBright: "#FFB348"
    readonly property color orangeMuted: "#804713"

    // --- translucent surfaces (alpha over the wallpaper) ---
    readonly property color panelBackground: Qt.rgba(5 / 255, 12 / 255, 15 / 255, 0.88)
    readonly property color panelBorder: Qt.rgba(68 / 255, 230 / 255, 220 / 255, 0.10)
    readonly property color dockBackground: Qt.rgba(1, 1, 1, 0.9)
    readonly property color dockBorder: Qt.rgba(0, 0, 0, 0.1)
    readonly property color overlayBackground: Qt.rgba(12 / 255, 18 / 255, 21 / 255, 0.97)
    readonly property color overlayBorder: Qt.rgba(80 / 255, 235 / 255, 220 / 255, 0.14)
    readonly property color scrim: Qt.rgba(2 / 255, 5 / 255, 7 / 255, 0.45)

    // --- interaction states (one visual language for every component) ---
    // hover    -> slightly lighter surface
    // selected -> subtle cyan wash
    // active   -> cyan text/icon
    // focus    -> cyan border
    // urgent   -> orange
    // disabled -> muted grey
    readonly property color stateHover: Qt.rgba(1, 1, 1, 0.06)
    readonly property color statePressed: Qt.rgba(1, 1, 1, 0.10)
    readonly property color stateSelected: Qt.rgba(32 / 255, 214 / 255, 210 / 255, 0.14)
    readonly property color stateSelectedBorder: Qt.rgba(32 / 255, 214 / 255, 210 / 255, 0.45)
    readonly property color stateActive: cyan
    readonly property color stateFocus: cyan
    readonly property color stateUrgent: orange
    readonly property color stateUrgentWash: Qt.rgba(1, 148 / 255, 24 / 255, 0.14)
    readonly property color stateDisabled: textDisabled

    // --- legacy role aliases (keep existing surfaces readable) ---
    readonly property color foreground: textPrimary
    readonly property color muted: textSecondary
    readonly property color accent: cyan
    readonly property color accentDeep: cyanMuted
    readonly property color surfaceHigh: surfaceElevated
    readonly property color danger: orange
    readonly property color warning: orangeBright

    // --- spacing (4 px grid) ---
    readonly property int spacingXxs: 2
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 24

    // --- radius ---
    readonly property int radiusSmall: 6
    readonly property int radiusControl: 6
    readonly property int radiusSurface: 10
    readonly property int radiusOverlay: 12
    readonly property int radiusDock: 22

    // --- surfaces ---
    readonly property int panelHeight: 40
    readonly property int panelIconSize: 17
    readonly property int panelMarkSize: 26
    readonly property int panelButtonSize: 30
    readonly property int panelNavHeight: 28
    readonly property int workspaceButtonWidth: 30
    readonly property int workspaceButtonHeight: 26
    readonly property int dockIconSize: 54
    readonly property int dockItemSize: 66
    readonly property int dockPadding: 7
    readonly property int dockEdgeGap: 12
    readonly property real dockHoverScale: 1.12
    readonly property int menuWidth: 280

    // --- type ---
    // Inter (OFL) for UI, JetBrains Mono (OFL) for code; both from Arch
    // `extra`. Fontconfig falls back to Noto if either is missing.
    readonly property string fontFamily: "Inter"
    readonly property string fontFamilyMono: "JetBrains Mono"
    // Text sizes follow the user's text-size setting (Settings > Appearance);
    // layout sizes (panel, dock, row heights) do not scale.
    readonly property real textScale: SettingsService.textScale
    readonly property int fontCaption: Math.round(12 * textScale)
    readonly property int fontBody: Math.round(13 * textScale)
    readonly property int fontLabel: Math.round(14 * textScale)
    readonly property int fontTitle: Math.round(16 * textScale)
    readonly property int fontDisplay: Math.round(20 * textScale)

    // --- motion ---
    readonly property int motionFeedback: 110
    readonly property int motionStandard: 180
}
