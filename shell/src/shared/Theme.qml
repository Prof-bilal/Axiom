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

    // --- mode: dark / light / auto (auto: light 07:00-19:00, re-checked every minute) ---
    property int hour: new Date().getHours()
    Timer { interval: 60000; running: SettingsService.themeMode === "auto"; repeat: true; onTriggered: theme.hour = new Date().getHours() }
    readonly property bool dark: SettingsService.themeMode === "dark"
        || (SettingsService.themeMode === "auto" && (hour < 7 || hour >= 19))

    // --- base neutrals ---
    readonly property color background: dark ? "#05080A" : "#F2F7F8"
    readonly property color surface: dark ? "#0B1214" : "#FFFFFF"
    readonly property color surfaceElevated: dark ? "#111B1E" : "#E8F0F2"
    readonly property color surfaceHover: dark ? "#17252A" : "#DCE8EB"
    readonly property color border: dark ? "#233238" : "#C3D3D7"
    readonly property color borderSubtle: dark ? "#182328" : "#DAE5E8"
    readonly property color textPrimary: dark ? "#FFFFFF" : "#0B1A1D"
    readonly property color textSecondary: dark ? "#9DB0B3" : "#475C61"
    readonly property color textDisabled: dark ? "#4E5E62" : "#8A9DA1"

    // --- Axiom teal (primary accent; darker in light mode for AA contrast) ---
    readonly property color cyan: dark ? "#22D3EE" : "#0A8FA6"
    readonly property color cyanBright: dark ? "#2EE6D6" : "#0E9BB0"
    readonly property color cyanMuted: dark ? "#126E70" : "#9ED9E3"

    // --- Axiom amber (secondary accent; urgent/destructive/warm highlights) ---
    readonly property color orange: dark ? "#F5A623" : "#B86F00"
    readonly property color orangeBright: dark ? "#FFC24D" : "#C77D0A"
    readonly property color orangeMuted: dark ? "#805313" : "#F1D3A0"
    readonly property color danger: dark ? "#EF5350" : "#C62828"
    readonly property color success: dark ? "#4CD964" : "#1E8E3E"

    // --- window controls (match the labwc theme) ---
    readonly property color controlClose: "#E8645A"
    readonly property color controlMinimize: "#2FB8C4"
    readonly property color controlMaximize: "#E0A93A"

    // --- glass: translucent fill + gradient stroke (teal -> amber) ---
    readonly property color panelBackground: dark ? Qt.rgba(20 / 255, 32 / 255, 34 / 255, 0.62) : Qt.rgba(1, 1, 1, 0.68)
    readonly property color panelBorder: dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.10)
    readonly property color dockBackground: dark ? Qt.rgba(20 / 255, 32 / 255, 34 / 255, 0.58) : Qt.rgba(1, 1, 1, 0.66)
    readonly property color dockBorder: dark ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.10)
    readonly property color overlayBackground: dark ? Qt.rgba(14 / 255, 24 / 255, 27 / 255, 0.90) : Qt.rgba(1, 1, 1, 0.92)
    readonly property color overlayBorder: dark ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(0, 0, 0, 0.12)
    readonly property color strokeStart: cyanBright
    readonly property color strokeEnd: orange
    readonly property color scrim: dark ? Qt.rgba(2 / 255, 5 / 255, 7 / 255, 0.50) : Qt.rgba(20 / 255, 35 / 255, 40 / 255, 0.30)

    // --- interaction states (one visual language for every component) ---
    // hover    -> slightly lighter surface
    // selected -> subtle cyan wash
    // active   -> cyan text/icon
    // focus    -> cyan border
    // urgent   -> orange
    // disabled -> muted grey
    readonly property color stateHover: dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.05)
    readonly property color statePressed: dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.09)
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
    readonly property int radiusOverlay: 16
    readonly property int radiusDock: 18
    readonly property int radiusWindow: 10
    readonly property int radiusDialog: 20

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
