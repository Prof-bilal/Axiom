# Axiom desktop design

Status: implemented for the Phase 3 Axiom Shell MVP (2026-11-01; top bar, dock,
terminal and compositor revised 2026-11-02, [ADR-016](decisions/016-labwc-compositor-harness.md)). This is the
visual and behavioral contract for the Axiom desktop identity. Token values are
canonical in [`branding/theme/axiom/colors.toml`](../branding/theme/axiom/colors.toml)
and consumed by [`shell/src/shared/Theme.qml`](../shell/src/shared/Theme.qml),
the compositor harness config and the terminal config. The general token
families remain in [desktop/DESIGN_SYSTEM.md](desktop/DESIGN_SYSTEM.md).

## Goal

Someone who boots Axiom should recognise Axiom OS immediately — not "Linux
that looks cool". The desktop combines Linux/tiling efficiency with refined,
restrained visual detail: dark graphite surfaces, one cyan accent, a warm
orange used sparingly, strong type, and minimal chrome.

## Principles

1. **Everything visible is real.** Every indicator, menu row and dock icon maps
   to a real service, application or compositor state. Absent backends are
   hidden or labelled unavailable; nothing is drawn for screenshots.
2. **Applications first.** Shell chrome is thin and dark; the wallpaper stays
   visible but secondary; windows get breathing room.
3. **One state language.** Hover, selected, active, focus, urgent and disabled
   look the same on every surface (see [states](#ui-states)).
4. **Colour has meaning.** Cyan means focus/selection/activity. Orange means
   urgency, destruction or attention. Neither is decoration.
5. **Proportional, not positional.** Sizes are fractions of the work area or
   fixed small UI metrics; no coordinates assume a particular resolution.

## Component ownership (audit)

The desktop is assembled from these real components. Nothing else draws it.

| Visual element | Owner | File(s) |
| --- | --- | --- |
| Compositor, placement, keybindings | labwc 0.20 (temporary harness, [ADR-016](decisions/016-labwc-compositor-harness.md)) | `iso/phase3/airootfs/etc/axiom/labwc/{rc.xml,autostart,menu.xml}` |
| Window title bars, buttons, corners, edge glow | labwc theme "Axiom" | `iso/phase3/airootfs/usr/local/share/themes/Axiom/labwc/themerc` |
| Top panel, workspaces, clock, status icons | Axiom Shell (Quickshell/QML) | `shell/src/panel/*` |
| Axiom menu ("Axiom OS ▾") | Axiom Shell | `shell/src/menu/AxiomMenu.qml` |
| Activities overview | Axiom Shell | `shell/src/activities/ActivitiesOverview.qml` |
| Status menu, session menu | Axiom Shell | `shell/src/status/ControlCenter.qml`, `shell/src/session/SessionMenu.qml` |
| Dock | Axiom Shell | `shell/src/dock/*` |
| Launcher | Axiom Shell | `shell/src/launcher/Launcher.qml` |
| Wallpaper | Axiom Shell (background layer; no wallpaper daemon) | `shell/src/desktop/Wallpaper.qml`, `shell/assets/wallpaper.png` |
| Tokens, icons, menu primitives | Axiom Shell | `shell/src/shared/*` |
| Terminal colours, font (title bar from labwc) | foot 1.28 | `iso/phase3/airootfs/etc/xdg/foot/foot.ini` |
| Terminal launch size | Axiom script + shell IPC | `iso/phase3/airootfs/usr/local/bin/axiom-terminal` |
| Terminal greeting and prompt | Axiom scripts + sixel logo | `iso/phase3/airootfs/usr/local/bin/axiom-greeting`, `iso/phase3/airootfs/usr/local/share/axiom/terminal/axiom-logo.six` (from `scripts/render-terminal-logo.sh`), `iso/phase3/airootfs/etc/axiom/zshrc` |
| Axiom app icons (Terminal, Files, Trash) and entries | XDG icons + desktop entries | `iso/phase3/airootfs/usr/local/share/icons/hicolor/scalable/apps/axiom-*.svg`, `iso/phase3/airootfs/usr/local/share/applications/*.desktop` |
| GTK app appearance | GTK settings | `iso/phase3/airootfs/etc/xdg/gtk-{3,4}.0/settings.ini` |
| Application icons | XDG icon theme (Adwaita → AdwaitaLegacy → hicolor) | resolved by `shell/services/ApplicationService.qml` |
| OS identity | os-release | `iso/phase3/airootfs/etc/axiom/os-release` (installed by `customize_airootfs.sh`) |

There is no Hyprland, Waybar, Rofi or other desktop-project config in Axiom.

## Root causes fixed in this revision

| Symptom | Actual cause | Fix |
| --- | --- | --- |
| Terminal fills the screen, gray rectangle | Sway tiled every window; foot ran with no config (default `#242424` opaque background) | Stacking compositor (labwc) with centred, cascaded placement; terminal opens at 70%×68%; Axiom foot config |
| "Dark overlay" hiding the wallpaper | Not an opacity rule, blur or dim: the opaque tiled terminal covered ~97% of the output | Same as above; wallpaper now visible around windows |
| Tofu boxes in the right panel | Font Awesome code points rendered with Noto Sans; no icon font installed | Axiom-drawn monochrome icon set (`AxiomIcon.qml`) |
| Magenta/black block in the dock | `pcmanfm` uses `Icon=system-file-manager`, which Adwaita 51 no longer ships; Qt drew its missing-image texture | Icon resolution with existence check + aliases; Axiom fallback glyph instead of a broken image |
| Editor missing from dock | Pinned id `mousepad` vs desktop id `org.xfce.mousepad` | Pinned the real id; reverse-DNS app-id matching |
| Dock overlapping windows / arbitrary position | Dock anchored to bottom-left corner with a computed left margin; corner-anchored layer surfaces get no exclusive zone | Anchored to bottom edge only: compositor centres it and reserves its space |
| Super+D/C/Shift+E did nothing | `qs ipc call` without a config path looks for a "default" config | Bindings use `qs ipc -p /usr/local/share/axiom/shell`; session exports `QS_CONFIG_PATH` |
| Tiny prompt, plain bash-style prompt | foot defaults (monospace 8pt) and grml prompt | JetBrains Mono 11.5pt, 17px line height, Axiom prompt |
| Second window hid the first | All new floating windows were centred identically | labwc `cascade` placement (32 px offsets) |
| Light GTK apps on a dark desktop | No GTK preference set | System `gtk-application-prefer-dark-theme=1` |

## Colour tokens

Budget: roughly **80% neutral, 15% cyan, 5% orange**.

| Role | Token | Value |
| --- | --- | --- |
| Background | `background` | `#070B0D` |
| Surface | `surface` | `#0C1215` |
| Elevated surface | `surfaceElevated` | `#11191D` |
| Hover surface | `surfaceHover` | `#162126` |
| Border | `border` | `#233238` |
| Primary text | `textPrimary` | `#EDF5F5` |
| Secondary text | `textSecondary` | `#8EA2A5` |
| Disabled text | `textDisabled` | `#4E5E62` |
| Cyan primary / bright / muted | `cyan`, `cyanBright`, `cyanMuted` | `#20D6D2`, `#37F0EA`, `#126E70` |
| Orange primary / bright / muted | `orange`, `orangeBright`, `orangeMuted` | `#FF9418`, `#FFB348`, `#804713` |
| Panel | `panelBackground` / `panelBorder` | `rgba(5,12,15,.88)` / `rgba(68,230,220,.10)` |
| Dock | `dockBackground` / `dockBorder` | `rgba(7,12,15,.82)` / `rgba(80,235,220,.15)` |
| Menus | `overlayBackground` / `overlayBorder` | `rgba(12,18,21,.97)` / `rgba(80,235,220,.14)` |
| Terminal background | foot `alpha` + `background` | `#0A0D0F` at 94% |

## UI states

| State | Treatment | Token |
| --- | --- | --- |
| Hover | slightly lighter surface (white 6%) | `stateHover` |
| Pressed | white 10% | `statePressed` |
| Selected (menu open, current workspace, selected result) | cyan wash + cyan hairline | `stateSelected`, `stateSelectedBorder` |
| Active (enabled toggle, focused app, hovered icon) | cyan icon/text | `cyanBright` |
| Focus (focused window) | cyan border | `cyanMuted` border in compositor |
| Urgent / destructive | orange text, border or dot | `stateUrgent`, `stateUrgentWash` |
| Disabled / unavailable | muted grey | `stateDisabled` |

## Typography

| Use | Family | Size |
| --- | --- | --- |
| Shell UI | Inter (OFL, Arch `inter-font`) | 12 caption · 13 body · 14 label · 16 title · 20 display (px) |
| Code, terminal, About values | JetBrains Mono (OFL, Arch `ttf-jetbrains-mono`) | terminal 11.5 pt, 17 px line height |
| Window title bars (labwc) | Inter Bold 10 pt | — |
| Terminal logo | Inter 600/400, rendered to sixel | 48 px (three terminal rows) |

Fontconfig falls back to Noto if either font is absent. Numbers that change
(clock, percentages, workspace numbers) use tabular figures. No proprietary
fonts are bundled.

## Spacing, radius, metrics

4 px grid (`2, 4, 8, 12, 16, 24`). Radii: 6 controls, 10 surfaces/dock items,
12 menus and windows, 16 dock container. Panel 40 px high, 17 px status
icons, 26 px penguin, 30×26 px workspace tiles, 28 px navigation buttons.
Dock items 48 px with 36 px icons, 7 px padding, 12 px gap from the screen
edge. Compositor gap 10 px.

## Top panel

`[penguin Axiom OS ▾] Activities  Apps  [folder] Files  [>_] Terminal ····· [1] 2 3 4 ····· search bell [tray] net bt vol bat  Sat, Nov 1  10:24 PM  power`

- Full width, 40 px, `panelBackground` with a 1 px `panelBorder` hairline.
- **Left:** the Axiom penguin with "Axiom OS ▾" opens the Axiom menu.
  *Activities* opens the Activities overview, *Apps* the application grid,
  *Files* and *Terminal* launch those apps (hidden if not installed). Text
  buttons get a cyan wash and cyan text while their surface is open.
- **Centre:** workspace tiles from the compositor (ext-workspace), centred on
  the output. Active: solid Axiom cyan with a dark numeral; others: graphite
  tiles; urgent: orange. Click or scroll to switch.
- **Right:** search (opens the launcher's search list), notifications (tiny
  orange dot when there are notifications), tray items, network
  (wired/wireless/offline), Bluetooth (only with a BlueZ adapter), volume
  (scroll to change), battery with percentage (only on battery hardware),
  date and time `ddd, MMM d  h:mm AP`, and the session menu. Icons are light
  grey, cyan on hover or while their menu is open.
- Panel controls act on press, like desktop menu bars.

## Menus

Compact dark cards under the panel (`MenuSurface`), radius 12, 1 px tinted
border. Outside click or Escape closes; keyboard focus is exclusive while
open. Rows (`MenuItem`) share the state language.

- **Axiom menu ("Axiom OS ▾", Super+A):** header with the Axiom penguin and
  *Axiom OS / AI-native Linux*;
  search (filters real desktop entries, Enter launches the top hit);
  Applications (opens the launcher), Files, Terminal; Recent (applications
  launched this session, memory only); About Axiom (OS, kernel, host and
  uptime read from os-release and /proc); Log Out, Restart, Shut Down.
- **Activities (panel "Activities", Super+S):** full-screen overview of every
  open window (live preview where the compositor allows capture, app icon
  otherwise), with workspace tiles. Click a window to focus it; its × sends a
  normal close request.
- **Apps (panel "Apps", dock Axiom mark):** grid of installed applications;
  type to filter, arrows to move, Enter to launch. The search icon and Super+D
  open the same results as a list.
- **Status menu (network/volume/battery, Super+C):** network state and Wi-Fi
  toggle, Bluetooth toggle when an adapter exists, output level slider and
  mute, power source.
- **Session menu (power, Super+Shift+E):** Log Out, Restart, Shut Down.
- **Destructive actions are two-step.** The first click arms the row (orange,
  "Click again to shut down"); a second click within four seconds runs it via
  `PowerService` (logind/systemd, authorised by polkit). There is no Lock row
  until Axiom ships a screen locker, and no Settings row until a Settings app
  exists (Phase 4).

## Dock

- Centred, floating 12 px above the bottom edge, anchored to the bottom edge
  so the compositor centres it at any resolution and windows never slide under
  it. Only the dock body takes input and reserves space.
- Graphite glass body (radius 16) with a 1 px edge gradient — Axiom cyan
  leading, warm orange trailing — and a soft glow of the same gradient.
- Order: Axiom A-mark (opens Apps) → pinned Terminal, Files, Firefox, Code
  (VS Code OSS), Trash (each omitted if not installed) → separator → other
  running apps. Trash opens the real `trash:///` in Files (GVfs).
- Terminal, Files and Trash use the Axiom icon set; other apps use their own
  XDG icons; an Axiom fallback glyph replaces any missing icon. Hover scales
  to 1.08.
- Indicators: none when not running; 4 px dim cyan dot when running; 12×3 px
  bright cyan pill plus a faint cyan wash when focused. Left click focuses the
  app (restoring it if minimized, cycling its windows when already focused) or
  launches it; middle click opens a new instance.

## Terminal (Axiom Terminal)

- foot with the system config in `/etc/xdg/foot/foot.ini` (user overrides in
  `~/.config/foot/foot.ini`); listed as *Terminal* with the Axiom terminal
  icon. Launched through `axiom-terminal`, which opens it at 70% × 68% of the
  usable area (asked from the shell, because labwc resizes only in pixels).
- Title bar (labwc, Axiom theme): terminal icon, *Axiom Terminal*, and working
  minimize, maximize and close; close is orange. 12 px corners; focused window
  has a cyan-muted border and a soft cyan glow.
- Background `#0A0D0F` at 94% opacity; JetBrains Mono 11.5 pt, 17 px line
  height; Axiom ANSI palette (red stays red; yellow is Axiom amber).
- Greeting (`axiom-greeting`), left to right: a dashed cyan penguin with
  orange eyes, beak and feet; a divider; the Axiom OS logo (sixel image, text
  heading in terminals without sixel); *AI-native Linux for Developers*; and
  OS (with architecture), kernel, shell, terminal, theme and uptime with
  icons, all read from the running system. Shown once per login session by
  default; `greeting=always|session|off` in `~/.config/axiom/terminal.conf`,
  or `axiom-greeting --disable/--enable`.
- Prompt: `axiom@host` in cyan, path in white, `❯` in orange (coral after a
  failed command).

## Window rules

| Rule | Implementation (labwc) |
| --- | --- |
| New windows centred; later ones offset so none hides another | `<placement><policy>cascade</policy>`, 32 px offsets |
| Focused window: cyan border and soft cyan glow | theme `window.active.border.color`, cyan-tinted `window.active.shadow.*` |
| Inactive window: neutral border, dimmer title, normal opacity | theme `window.inactive.*`; no inactive dimming |
| Title bar: icon, left-aligned title, minimize / maximize / close | `<titlebar><layout>icon:iconify,max,close`; Axiom themerc |
| Maximize / minimize / fullscreen | title-bar buttons, double-click title, Super+M / Super+H / Super+F |
| Snap halves | Super+arrows |
| Window switcher | Alt+Tab (labwc, Axiom-themed) |
| Gap around maximized/snapped windows | `<core><gap>10</gap>` |

## Wallpaper

The cinematic Axiom wallpaper (`shell/assets/wallpaper.png`, eclipse and
penguin) is drawn by the shell on the background layer with
`PreserveAspectCrop`, so it fills any aspect ratio without distortion. It is not
overlaid or dimmed; it stays secondary because windows are opaque-enough
graphite and the image itself is low-key. The launcher alone adds a transient
45% scrim while open.

## Icons and identity marks

| Asset | Role | Canonical file |
| --- | --- | --- |
| Axiom penguin | **OS / session identity**: top-panel "Axiom OS" button, Axiom menu header, terminal greeting art | `branding/identity/axiom-penguin.png` (512 px) → `shell/assets/axiom-penguin.png` (96 px) |
| Axiom A-mark | **Product identity**: dock launcher, terminal logo |
| Axiom app icons | Terminal, Files, Trash | `iso/phase3/airootfs/usr/local/share/icons/hicolor/scalable/apps/axiom-{terminal,files,trash}.svg` | `branding/identity/axiom-mark.svg` → `shell/assets/axiom-mark.svg` |
| Axiom wordmark | Documents, boot/installer branding | `branding/identity/axiom-wordmark.svg` |
| System icons | Panel/menu glyphs | `shell/src/shared/AxiomIcon.qml` (original 24-unit paths) |

Competing assets found during the audit: a hand-drawn cyan-outlined penguin SVG
(`branding/theme/axiom/icons/axiom-penguin*.{svg,png}`, previously in the
panel) and the new reviewed penguin (`branding/theme/walllpaper/toppanel.png`).
The reviewed penguin is canonical; the old SVG is retained only as history and
is no longer shipped in the shell. The penguin sits next to "Axiom OS" in the
top panel (product owner, 2026-11-02) and in the Axiom menu header; the A-mark
is the product mark in the dock and terminal logo. The penguin is never an app
icon.

## Responsive rules

- Panel and dock use fixed small metrics and edge anchoring; the compositor
  positions them on any output size.
- The terminal's size is a percentage of the usable area, computed by the
  shell from the real output; other windows use their own default size and
  are centred by the compositor.
- Menus cap their height to the output and clamp their width.
- Verified at 1366×768, 1920×1080 and 2560×1440 (see
  [evidence](research/phase3/evidence.md)). Fractional output scaling and
  multi-monitor layouts are not yet verified.

## Known open bug

Under Sway, after a keyboard-grabbing overlay closed while an app was focused,
the first press on a panel button was lost. Whether it persists under labwc is
recorded in [evidence](research/phase3/evidence.md).

## Harness limitations (not design decisions)

labwc cannot draw gradient window borders or blur; the focused-window glow is
a cyan-tinted drop shadow. Firefox draws its own title bar. The terminal logo
is a 48 px sixel image sized for a scale-1 output with the Axiom line height;
on fractional or 2× scaling it is not resized yet.
