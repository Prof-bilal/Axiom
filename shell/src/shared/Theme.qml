pragma Singleton

// Axiom design tokens. UI components read these instead of literals so the
// shell toolkit can be replaced without rewriting product behavior.
//
// Canonical source: branding/theme/axiom/colors.toml and
// docs/DESKTOP_DESIGN.md. Keep the three in step.
//
// Colour budget: ~80% neutral graphite, ~15% orange, ~5% red. Orange means
// "focus / selected / active"; red means "urgent / destructive / error"
// and is never used as decoration.

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: theme

    // Light mode is opt-in (AXIOM_THEME=light) until the shell has a mode switch.
    readonly property bool light: Quickshell.env("AXIOM_THEME") === "light"

    // --- base neutrals ---
    // Dark charcoal, sampled from the reference screenshot; light mockup otherwise.
    readonly property color background: light ? "#F4F6F7" : "#2A2B2E"
    readonly property color surface: light ? "#FFFFFF" : "#38393B"
    readonly property color surfaceElevated: light ? "#FFFFFF" : "#38393B"
    readonly property color surfaceHover: light ? "#EEF2F4" : "#4A4C50"
    readonly property color border: light ? "#C9D3D8" : "#2E2F32"
    readonly property color borderSubtle: light ? "#D8DEE2" : "#2E2F32"
    readonly property color textPrimary: light ? "#14181B" : "#E6E6E8"
    readonly property color textSecondary: light ? "#5F6F74" : "#9A9CA0"
    readonly property color textDisabled: light ? "#9AA6AA" : "#6B6E73"

    // --- Axiom orange (primary accent) ---
    readonly property color accent: "#FF9418"
    readonly property color accentBright: "#FFB348"
    readonly property color accentMuted: "#804713"

    // --- danger (destructive actions, errors, urgent state) ---
    // Red, so it never looks like the orange accent.
    readonly property color danger: "#FF5A4F"
    readonly property color dangerBright: "#FF8A80"
    readonly property color dangerMuted: "#7A2A24"

    // Solid surfaces only: flat graphite like a native desktop, no blur or transparency.
    readonly property color panelBackground: light ? "#FFFFFF" : "#222325"
    readonly property color dockBackground: "transparent"
    readonly property color overlayBackground: light ? "#F4F6F7" : "#2A2B2E"
    readonly property color panelBorder: Qt.rgba(255 / 255, 148 / 255, 24 / 255, 0.10)
    readonly property color dockBorder: Qt.rgba(255 / 255, 148 / 255, 24 / 255, 0.10)
    // Dim behind modal dialogs and the power menu.
    readonly property color scrim: Qt.rgba(2 / 255, 5 / 255, 7 / 255, 0.55)

    // --- card fills and their hairline edge (all solid) ---
    readonly property color cardFill: light ? "#EEF2F4" : "#38393B"
    readonly property color cardFillStrong: light ? "#FFFFFF" : "#2A2B2E"
    readonly property color cardEdge: light ? "#C9D3D8" : "#4A4C50"

    // --- menus: solid card, light text, dark row on hover ---
    readonly property color menuSurface: light ? "#FFFFFF" : "#38393B"
    readonly property color menuBorder: light ? "#C9D3D8" : "#4A4C50"
    readonly property color menuHover: light ? "#EEF2F4" : "#4A4C50"
    readonly property color menuText: light ? "#14181B" : "#E6E6E8"
    readonly property color menuTextDisabled: light ? "#9AA6AA" : "#6B6E73"

    // --- interaction states (one visual language for every component) ---
    // hover    -> slightly lighter surface
    // selected -> subtle orange wash
    // active   -> orange text/icon
    // focus    -> orange border
    // urgent   -> red
    // disabled -> muted grey
    readonly property color stateHover: Qt.rgba(1, 1, 1, 0.06)
    readonly property color statePressed: Qt.rgba(1, 1, 1, 0.10)
    readonly property color stateSelected: Qt.rgba(255 / 255, 148 / 255, 24 / 255, 0.14)
    readonly property color stateSelectedBorder: Qt.rgba(255 / 255, 148 / 255, 24 / 255, 0.45)
    readonly property color stateActive: accent
    readonly property color stateFocus: accent
    readonly property color stateUrgent: danger
    readonly property color stateUrgentWash: Qt.rgba(255 / 255, 90 / 255, 79 / 255, 0.14)
    readonly property color stateDisabled: textDisabled

    // --- legacy role aliases (keep existing surfaces readable) ---
    readonly property color foreground: textPrimary
    readonly property color muted: textSecondary
    readonly property color accentDeep: accentMuted
    readonly property color surfaceHigh: surfaceElevated
    readonly property color warning: "#FFCB52"

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
    readonly property int radiusWindow: 16

    // --- surfaces ---
    readonly property int panelHeight: 26
    // The panel floats (ADR-029): gap above it, and everything that opens
    // below it starts at panelBottom.
    readonly property int panelGap: 0
    readonly property int panelSideGap: 0
    readonly property int panelBottom: panelHeight + panelGap
    readonly property int panelIconSize: 14
    readonly property int panelMarkSize: 18
    readonly property int panelButtonSize: 24
    readonly property int panelNavHeight: 22
    readonly property int workspaceButtonWidth: 30
    readonly property int workspaceButtonHeight: 26
    readonly property int dockIconSize: 60
    readonly property int dockItemSize: 76
    readonly property int dockPadding: 7
    readonly property int dockEdgeGap: 12
    // Dock magnification (macOS style): peak scale of the icon under the pointer, how far the effect reaches
    // along the dock (pixels, about 2.6 slots), and how far that icon also rises (pixels).
    readonly property real dockMagnifyPeak: 1.65
    readonly property int dockMagnifyReach: 208
    readonly property int dockLift: 6
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
