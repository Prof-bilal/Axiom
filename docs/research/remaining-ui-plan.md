# Axiom remaining UI plan

Status: plan, not started. Source: glass UI handoff (memory `glass-ui-migration-handoff`) and the
reference images in `/home/abullah/Documents/axiomassets` (23 images, read 2026-11-16).
Nothing here is committed. Verify each item in QEMU before calling it done (see Gates).

## A. Verify in VM (no new code)
1. Title-bar buttons (close, min, max) and drag.
2. Alt+Tab keys and commit on Alt release.
3. Dock restore of a minimized window.
4. Firefox and VS Code native titlebar defaults.
5. Airplane and media cards (act on real radios: test in VM only).

Input: keyboard works in QEMU; mouse from tools does not. Use VNC (`-vnc 127.0.0.1:1`) for mouse checks.

## B. Performance: blur (currently lags in QEMU, software GL)
1. Reduce blur passes and radius in the Hyprland config (`shell/hypr/hyprland.lua`, verify path).
2. Adaptive blur: a `reduceEffects` token in `shell/src/shared/Theme.qml`, read by `GlassSurface.qml`.
   Auto-off on software GL.
3. "Reduce transparency" setting: one bool in the Personalization page.
4. Measure CPU and frame feel before and after. No performance claim without numbers.

## C. Desktop and file interactions (new, from reference)
1. Desktop right-click menu: New Folder, New Document, Sort By, Paste, Change Wallpaper, Settings.
2. File right-click menu: Open, Open With, Cut, Copy, Paste, Rename, Delete, Properties.
3. Confirm dialogs: delete ("cannot be undone" wording), with Cancel and a red destructive action.
4. Open File picker (sidebar Home, Desktop, Documents, Downloads, Projects, Trash; tags).

## D. Capture tools (new)
1. Screenshot bar: region, window, screen modes; settings; the grid and size label overlay.
2. Video recording mode in the same bar; mic toggle. Video capture backend (PipeWire/wf-recorder)
   to be chosen with an ADR before implementation.

## E. Shell overlays (new)
1. Snap layouts: drag a window to an edge, show the "Snap to Right/Left" zone.
2. OSD cards: brightness, volume, Caps Lock (center-bottom glass cards, auto-hide).
3. Polkit "Authentication Required" dialog in glass style (admin user, password, Cancel, Authenticate).

## F. Remaining screens (from earlier list)
1. Lock screen: `shell/src/session/LockScreen.qml`, match the reference card and bottom power row.
2. Power menu: `shell/src/session/SessionMenu.qml` with Shut Down, Restart, Sleep, Log Out, Cancel.
3. Greeter: `greeter/axiom-greeter-graphical`.
4. Installer: `installer/axiom-installer`, per `docs/research/installer-ui-plan.md`.
5. Boot splash: Plymouth plan in `docs/research/boot-ui-plan.md`; reference `branding/reference/glass/boot-splash.webp`.
6. Personalization settings page: Dark/Light, wallpaper picker, glass toggle, accent colors.

## G. Icons and cursors
1. Application icon suite (Files, Terminal, Browser, Settings, Code Editor, System Monitor,
   Media Player, Calculator, Calendar, Document Viewer, Trash).
2. Pointer package (Normal, Link, Busy, Working, Help, Text, Blocked, Move, Diagonal resize).

## Order
A, then B (lag blocks testing the rest), then C, E, F, D, G. Each item lands with its own screenshot.

## Gates
- Each screen: ISO rebuild (about 30 minutes; one build per work dir), QEMU boot, retained screenshot.
- `python3 scripts/validate-repo.py` and shell tests pass.
- Do not commit unless asked. Check ContextGit ownership before editing shared files (AGENTS.md).
- Never `pkill` by name on the host (see memory `glass-ui-migration-handoff`).

## Open decisions
- Video capture backend (needs an ADR).
- Whether reference images in `axiomassets` are licensed for shipping; icons and pointers are
  design references, not yet vetted assets.

## Section A results (2026-11-16, scripted QMP run on iso/out-phase3 ISO, not manual)

- A1 title bar drag: NOT VERIFIED. An Axiom menu was open at the start and the terminal did not move. Retest by hand.
- A2 Alt+Tab: switcher opened, but it stayed open after Alt release (A2b). Not committed. Suspected bug; confirm by hand before fixing (the injected Alt release may not have been delivered).
- A3 minimize (Super+H) and restore from dock: NOT VERIFIED. The switcher was still open and grabbing input, so the minimize did not run.
- A4 Firefox and VS Code from dock: NOT VERIFIED. Tooltips appeared, but no window opened within 8 s. Titlebar defaults untested.
- A5 control centre: NOT VERIFIED. Super+C did not open it.
- Boot: the first two attempts stalled in firmware (known QEMU flake). The third attempt reached the desktop.

## Section B status (2026-11-16)

Adaptive blur implemented in source, NOT yet measured in the VM or on real hardware:
`iso/phase3/airootfs/usr/local/bin/axiom-blur-tier` (off | light | full from VM flag, RAM, CPUs, and
`~/.config/axiom/blur` override), exported as `AXIOM_BLUR` by `axiom-session`, read by `hyprland.lua`
(blur and shadow) and `shell/src/shared/Theme.qml` (dark tint when off). Tests: `tests/test_blur_tier.py`.
Still to do: Settings toggle, ISO rebuild, before/after CPU measurement.

### Section B measurement (2026-11-16, QEMU, guest CPU busy during launcher toggles)

- Old ISO (`iso/out-phase3`, blur always on): 85.8, 85.1, 86.7, 74.1. Median ~85.5%.
- New ISO (`iso/out-phase3-blur`, tier off): 61.2, 65.8, 61.4. Median 61.4%.
- One run of the new ISO stalled in firmware on all three tries and gave no reading.
- Only the blur-off tier was measured. `light` and `full` on the new ISO are not measured.
- VM numbers say nothing about real GPU hardware.

### Tier measurement, stopped early (2026-11-16)

Measured on the new ISO (`iso/out-phase3-blur`). Blur was set live with `hyprctl keyword`; the guest serial
showed `SETQ=0` (keyword command ran), but the applied values were not captured.

- Off (config tier off): 61.2, 65.8, 61.4 (median 61.4%)
- Light (size 4, 1 pass): 61.7, 62.7, 59.8 (median 61.7%)
- Full (size 8, 3 passes): 63.6 (one run stalled in firmware; third run stopped, not measured)
- Old ISO (blur always on, from config): 85.8, 85.1, 86.7, 74.1 (median ~85.5%)

Open questions:
- Does live `hyprctl keyword` really change the blur, or did light and off both skip it? Check
  `hyprctl getoption decoration:blur:passes` in the guest before trusting light/full numbers.
- The old-vs-new gap may come from config-level blur and shadow, not from blur passes alone.
- VM numbers do not predict real GPU hardware.

## Implementation status (2026-11-16)

Verified in a QEMU dev VM (shell synced over 9p onto the 2026-11-15 ISO; screenshots in the session scratchpad, not yet retained under `docs/`):

| Item | State |
|---|---|
| Compositor | **Migrated back to labwc (ADR-016 amendment, 2026-11-16); not yet booted.** Hyprland is opt-in. labwc draws the themed title bar; shell bars removed. Status rows below that mention Hyprland describe the earlier session and need re-verification on labwc. |
| Window buttons | Back on request (2026-11-16): macOS-style circles (red close, yellow minimize, green maximize) drawn by labwc from svg theme files, on every window. Keyboard still works: Super+Q/W close, Super+H minimize, Super+Shift+H show minimized, Alt+Tab restores. |
| Alt+Tab | Fixed. The compositor release bind did not fire; the overlay now holds the keyboard and commits on Alt release. Verified. |
| Title-bar drag (Axiom apps) | Verified (Files moved). Terminal/Firefox bars still cannot drag (shell overlay). |
| Dock restore of a minimized window | Verified. |
| Desktop icons, right-click menus, rename, new folder, trash confirm | Done and verified (`shell/src/desktop/DesktopLayer.qml`, reuses the Files backend). Paste and Properties not exercised. |
| OSD (volume, brightness, Caps Lock) | Brightness visual verified through IPC. Volume path shares code; Caps Lock needs a keyboard LED (none in QEMU), so unverified. Media-key binds are in `hyprland.lua` but the dev VM used the old config. |
| Snap zones | Done for the snap keys (Super+Left/Right) with a dashed zone and label; verified. No live preview while dragging (no drag events from Hyprland). |
| Polkit dialog | Done and verified (wrong then right password). The shell is the session agent; polkit-gnome starts only as a fallback. |
| Capture bar (screenshot, video) | UI verified (modes, region drag, button). `grim`, `wf-recorder` and `wl-clipboard` are new ISO packages (ADR-030); capture itself is unverified until the new ISO. |
| Power dialog | Done and verified (arm on first click). Session test coordinates updated. |
| Lock screen | Done and verified (card, unlock with PAM, power row). |
| Greeter | Restyled; rendered in the VM with a fake user list. Real greetd login not re-verified. |
| Settings: Glass blur (Auto, Off, Light, Full) | Done and verified (writes `~/.config/axiom/blur`). Applies at next login. |
| Adaptive blur | Source done earlier; VM CPU numbers in the measurement sections above. |
| Icon suite (15 icons) | Generated by `scripts/gen-icons.py`; contact sheet reviewed. Not yet seen in the dock on a rebuilt ISO. |
| Cursor theme | Generated by `scripts/gen-cursors.py` (Xcursor written directly); shapes reviewed, file format tested. `XCURSOR_THEME` set in `axiom-session`. Not yet seen in a session. |
| Plymouth splash | Script, wordmark and ring updated. Not rendered: Plymouth is not run in the live ISO. |
| Installer | Not changed. It is a framebuffer text renderer; a glass card needs pixel-level layers in `tui/fbdraw.py`, which would touch every TUI screen and its tests. |
| Open File picker | Not built. |
| Firefox/VS Code titlebar | Firefox shows the shell overlay bar, but a large window can sit under the panel. Not fixed. |

### Blur removed (2026-11-16)

Per the user, blur and glass are gone. The adaptive tier (`axiom-blur-tier`, the Settings "Glass blur"
card, the `AXIOM_BLUR` export and its test) was deleted, and the surfaces are solid. The measurement
numbers above describe the old tier design and are kept only as history.
