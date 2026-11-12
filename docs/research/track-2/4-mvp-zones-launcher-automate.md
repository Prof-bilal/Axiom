# Track 2, Agent 4 (MVP designer): Zones, Launcher, Automate

Date: 2026-11-09. Input: track2-agent2-verdicts.md (BUILD rows 2, 3, 4, 8), the
repo (read-only): AGENTS.md, ARCHITECTURE, SECURITY, PHASES, TECH_STACK, ADR-016
to 019, `shell/services/*`, `shell/src/launcher/Launcher.qml`,
`iso/phase3/airootfs/etc/axiom/labwc/rc.xml`.

## What the harness can and cannot do (facts every spec depends on)

Checked against labwc-config(5) and labwc-actions(5) (labwc 0.20 is the
ADR-016 harness):

- **labwc has no runtime IPC.** It runs actions only from keybinds, mousebinds,
  menus and window rules in `rc.xml`. It reloads all config (but not
  autostart) on SIGHUP or `labwc --reconfigure`. The shell cannot ask labwc to
  move a window. `wlr-foreign-toplevel` (what `WindowService` uses) can
  activate, close, minimize, maximize and fullscreen a window. It has **no
  set-geometry request**.
- **labwc already has snap regions.** `<regions><region name x y width height>`
  (percent of each output's usable area), `SnapToRegion` and
  `ToggleSnapToRegion` actions, and snapping by **dragging with a modifier
  held**. Regions are one global set applied to every output. There are none
  by default.
- **labwc window rules** match on identifier (app id), title or type, and can
  run actions such as SendToDesktop or SnapToRegion when a window maps.
- **Privileged protocols on labwc are global.** `zwp_virtual_keyboard_manager_v1`,
  `zwlr_virtual_pointer_manager_v1`, `zwp_input_method_manager_v2` and data
  control are on by default for every unsandboxed client. They are off for
  clients sandboxed through security-context-v1, such as Flatpak. A
  `<privilegedInterfaces>` allow-list can turn an interface off for *all*
  unsandboxed clients, but it cannot grant one per client.
- **No portal route on the harness.** xdg-desktop-portal-wlr implements only
  Screenshot and ScreenCast: no GlobalShortcuts, no RemoteDesktop and no libei
  (README checked). One 2026 roadmap source says stock wlroots still has no
  libei/EIS. GNOME's GlobalShortcuts rejects non-Flatpak apps (from the
  verdict). On labwc, a global hotkey therefore means an rc.xml keybind, which
  is how the shell's Super+D/A/S/N/C bindings already work.
- **Existing Axiom code to reuse:** `WindowService` (toplevels, activate,
  maximize), `WorkspaceService` (ext-workspace-v1), `ApplicationService`
  (desktop entries, `search()`, `launch()`), `Launcher.qml` (245 lines,
  list/grid modes, keyboard navigation), `KeyboardService` (validated XKB
  layout written to `~/.config/axiom/keyboard.env`), `SettingsService`
  (ADR-018 watched JSON), `TerminalService`, and `qs ipc` driven by labwc
  keybinds.

**Shared design consequence (applies to all three apps).** On the harness,
anything that moves windows or binds global keys has to become **generated
labwc config plus a reconfigure**. Put this in one place: a new harness adapter
that renders a per-user labwc config directory (system template plus
user-generated `<regions>`, `<keybind>` and `<windowRules>`) into
`$XDG_RUNTIME_DIR/axiom/labwc/` and sends SIGHUP. `axiom-session` starts labwc
with `-C` pointing at that directory. Only this adapter knows labwc syntax,
just as `WindowService` and `WorkspaceService` are today the only files that
name a compositor protocol. The Axiom compositor later replaces it with a real
session API (set geometry, bind key, rule on map). UI and the user's stored
data (`settings.json` keys) stay the same.

## Challenges to the verdict

1. **Zones is a feature, not an app.** It is a Settings page ("Window layouts")
   plus the keybind and drag behavior. No separate binary or window. Keep the
   BUILD verdict; drop the "app" label.
2. **Launcher and Automate share one action catalog.** Both need the same typed
   actions (launch app, focus or move a window, switch workspace, snap to
   zone, insert snippet, open path, run a user script). Build one `ActionService`
   singleton in `shell/services/`. The Launcher is its searchable front end;
   Automate binds actions to keys and rules. Zones registers its "snap to zone
   N" actions there. This is one registry and one validator. Two engines would
   double the security review.
3. **Do not adopt or embed Vicinae as the Axiom launcher** (decided; see the
   Launcher spec). Offer it as a curated BRIDGE package instead.
4. **Cut AutoHotkey parity hard.** Abbreviation-triggered text expansion
   (espanso-style), macro *recording* and arbitrary per-key remapping are
   excluded from the MVP. Each needs one of: system-wide keystroke observation
   (espanso on Wayland needs CAP_DAC_OVERRIDE to read `/dev/input` plus write
   access to `/dev/uinput`, which is a keylogger that Wayland was designed to
   prevent), a root remap daemon (keyd), or an input-method slot that the
   Phase 8 IME (fcitx5) also needs. The right place for these is the Axiom
   compositor, which already sees every key event. The MVP is "Shortcuts,
   snippets and window rules", which is the part users actually miss and the
   part that can be authorized.

---

## 1. Axiom Zones and snap layouts

**Problem / user.** A Windows switcher or developer on a wide or ultrawide
monitor wants editor, terminal and browser placed in repeatable regions
without a tiling WM. Today they get only half-screen `SnapToEdge` (already
bound to Super+arrows).

**MVP (must have)**
- Built-in layout presets: halves, thirds, 2/3+1/3, 1/3+2/3, grid 2x2, and
  "priority" (60 / 20 / 20). One active layout at a time.
- Settings > Window layouts: pick a preset and preview it, or make a custom
  layout by splitting or merging a grid with draggable dividers. Store it in
  `settings.json` as percent rectangles (validated: 0-100, non-zero area, at
  most 12 zones).
- Snap by **Shift-drag** (labwc modifier-drag onto regions; FancyZones uses
  Shift too). Snap by keyboard: Super+Ctrl+1..9 = SnapToRegion N, and
  Super+Ctrl+Left/Right moves the window to the previous/next zone.
- Window rule: "always open app X in zone N / workspace M" (from a window's
  context in the dock or Activities).
- Actions registered in `ActionService`, so the Launcher can run "Snap to zone
  2".

**Later:** per-output and per-workspace layouts. A snap flyout on
maximize-button hover (Windows 11 style). Zone spanning (drag across two
zones). Snap groups (restore a set of windows together). Restoring
window-to-zone placement after logout. A drag overlay drawn by the shell.

**Out of scope:** automatic tiling or a tiling WM mode. A full layout
scripting language.

**Reuse:** labwc regions, SnapToRegion and windowRules. The `SettingsService`
JSON. QML for the editor (same Theme tokens).

**Compositor dependency.** Harness: everything in the MVP, through the labwc
config adapter (regions are global to all outputs; switching layout = rewrite
plus SIGHUP). Needs the Axiom compositor: per-output layouts, the hover
flyout, spanning, a shell-drawn drag overlay, and any "move this window there"
started from shell UI (labwc has no IPC or geometry protocol).

**Privilege and security.** None. User session only, no daemon, no root. The
generated config is written only by the adapter from validated numeric data
(no string passthrough into `rc.xml`; app ids in rules must match
`^[A-Za-z0-9._-]{1,128}$` and are XML-escaped). Invalid settings fall back to
"no regions" and say so.

**Acceptance (QEMU, extend `tests/phase5-system.py` style with real key/pointer events)**
1. Choose "thirds" in Settings. foot and Mousepad snapped with
   Super+Ctrl+1 and Super+Ctrl+3 land within 2 px of the expected rectangles
   at 1366x768 and 1920x1080 (checked from a screenshot plus labwc geometry).
2. Shift-drag of a window to the middle zone snaps it there.
3. A custom 2x2 layout survives a shell restart and a reboot on the installed
   image.
4. A rule "foot -> zone 1" places the next terminal correctly.
5. Adversarial: settings with negative or overflowing values, 1000 zones, or
   an app id containing `"/><keybind` produce no generated config change and
   a visible error. labwc stays running.

**Effort:** 3 weeks (adapter 1, editor UI 1.5, tests 0.5).

**Measure:** time from the snap key to final geometry (target under 100 ms in
QEMU). Reconfigure time when switching layouts. Shell memory delta from the
editor (target under 5 MiB).

**Top risk:** labwc-specific behavior (global regions, no IPC) leaks into UX
promises. Keep the per-output and flyout claims for the compositor milestone.

---

## 2. Axiom Launcher (command palette and instant file search)

**Problem / user.** Developers want one keystroke to reach apps, files,
windows and commands (Raycast, Alfred, PowerToys Run, Everything). The current
launcher searches only desktop entries by substring.

**Decision on Vicinae: do not adopt or embed it; borrow its script-command
format and ship it as an optional package.** Reasons:
- (a) Axiom already has a working launcher in the shell (`Launcher.qml` plus
  `ApplicationService`). Vicinae would be a second Qt UI process with its own
  theme and window, which breaks "no upstream desktop project is the product
  contract" and the design-token rule.
- (b) Vicinae is GPL-3.0 and Axiom is Apache-2.0. Embedding by linking would
  force GPL. Running it as a separate program is allowed but gives up
  integration.
- (c) Raycast-compatible extensions are React/TypeScript run on Node 20+ (the
  Vicinae FAQ). The docs describe no sandbox: store code runs with the user's
  full rights. This is the same class of risk as the 2024 KDE Store theme that
  ran `rm -rf` (Track 1).
- (d) Owning the palette is what makes the shared `ActionService` and the
  Phase 12 natural-language launcher possible.

Cheap compatibility: support **Raycast/Vicinae script commands** (an executable
with `# @raycast.title`-style header comments). That reuses an existing
ecosystem without a JS runtime. Put Vicinae in the Software Center as a
curated BRIDGE for people who want the extension store (it supports
layer-shell, so it runs on labwc).

**MVP (must have)**
- One palette (Super+D, existing). Results are grouped: Apps (existing
  ranking plus fuzzy matching and frecency persisted in `settings.json`),
  Windows (`WindowService.list()`, Enter = activate), Actions (from
  `ActionService`: workspaces, zones, session, Settings pages), Files, and
  Calculator (pure QML expression parser, no `eval`).
- **Files:** a per-user `plocate` database of `$HOME` built by
  `updatedb -l 0 -U $HOME -o $XDG_CACHE_HOME/axiom/home.plocate` with
  developer prune names (`.git node_modules target .cache .venv __pycache__`).
  The database file is mode 0600, because anyone who can read it sees the
  whole file list. Refresh comes from a systemd **user** timer (every 15 min)
  plus "Refresh index" in the palette. There is no permanent daemon. A query
  is one argv `plocate -d … -i -l 50 -- <q>` per debounced keystroke. Enter
  opens the file through the existing Files/xdg-open path. Alt+Enter reveals
  it in Files. Ctrl+Enter opens a terminal there (`TerminalService`).
- Prefix modes: `>` actions, `/` or `~` files only, `=` calculator.
- Script commands from `~/.local/share/axiom/scripts/` run as argv with no
  shell. A script is refused if it or its directory is group- or
  world-writable, or if it is a symlink pointing outside that directory. The
  first run shows the path.

**Later:** clipboard history (Phase 8 owns it; it plugs in as a provider
through `ext_data_control`). Content (full-text) search with SQLite FTS5 over
opted-in folders. inotify freshness for recent files. Emoji and
unicode picker. Snippet search (shared with Automate). Phase 12
natural-language mode.

**Out of scope:** Raycast/Node extension runtime. Web search providers
enabled by default (no network by default). Indexing outside `$HOME`. Tracker
or Baloo.

**Compositor dependency.** None beyond what exists: layer-shell surface plus
foreign-toplevel. All of it works on labwc. The Axiom compositor adds only
nicer window previews.

**Privilege and security.** Unprivileged. Files results come only from the
user's own index. File names are untrusted text, shown as plain text and
never interpolated into a command. Opening is always argv. Script commands
are user code. The launcher only refuses unsafe file modes and never builds
shell strings.

**Acceptance (QEMU)**
1. With a 200k-file fixture in `$HOME`, typing `phase5ev` shows
   `phase5-evidence.md` first in Files results. Enter opens it.
2. "term" puts foot or Terminal first. A second foot window appears under
   Windows, and Enter focuses it.
3. `=2*(3+4)` shows 14. A script command appears and runs. A world-writable
   script is refused with a message.
4. A file created after the last index run is found after "Refresh index".
5. Adversarial: file names with newlines, `$(…)`, RTL override characters and
   4 KiB names render inertly and open the correct file. A missing or corrupt
   database falls back to "index unavailable" and app search still works.

**Effort:** 4 weeks (palette and providers 2, file index and timer 1, script
commands and tests 1).

**Measure:**
- Keypress-to-results p50/p95 for Apps (target p95 under 16 ms) and Files
  (target p95 under 80 ms after debounce at 200k files, and also at 1M).
- Index build time and CPU.
- Index size per 100k files.
- Palette open latency (key to first frame).
- Shell RSS delta.

**Top risk:** index freshness (a 15-minute window). Users expect Everything's
instant NTFS-journal updates. Show "indexed N min ago" and offer refresh; if
complaints follow, add inotify on recent directories.

---

## 3. Axiom Automate (shortcuts, snippets, window rules)

**Problem / user.** Windows switchers and developers lost AutoHotkey-style
hotkeys and snippets on Wayland: AutoKey's Wayland support is unreleased, wtype
only types, and keyd only remaps (and needs root). The user wants "Super+E
opens my project", "Ctrl+Alt+S types my signature" and "Slack always goes to
workspace 3".

**MVP (must have)**
- **Custom shortcuts:** key chord -> one action, or a short **sequence** of
  actions (at most 10 steps, fixed delays at most 2 s) from the `ActionService`
  catalog:
  - launch an app (desktop-entry id),
  - focus an app, launching it if it is not running (`focusOrReport`),
  - switch or send to a workspace,
  - snap to a zone,
  - maximize, close or minimize,
  - open a path or URL,
  - insert a snippet,
  - run a **user script** (argv array plus optional cwd; no shell).
- **Snippets:** a named text library. Insert through a hotkey or a palette
  picker, typed into the focused window with **wtype** (virtual-keyboard
  protocol; unicode handled through a keymap upload). Placeholders are
  limited to `{date}`, `{time}` and `{clipboard}`.
- **Remaps:** a curated XKB options list (Caps->Esc, Caps->Ctrl, swap
  Alt/Super, compose key). This extends the existing validated
  `KeyboardService` env file. Arbitrary per-key remapping is not included.
- **Window rules:** app id -> workspace, zone, maximized, or always-on-top.
- Settings > Shortcuts: list, add, edit, enable or disable, detect conflicts
  with system bindings (system bindings are reserved and cannot be
  overridden), and import/export as a JSON file.

**Later (needs the Axiom compositor):** abbreviation-triggered expansion done
inside the compositor (it sees keys already, so no `/dev/input`). App-scoped
hotkeys. Mouse and gesture triggers. Conditional rules (title regex, display
connected). Phase 12: an agent may *propose* a rule as a typed diff that the
user confirms.

**Out of scope:**
- an AHK-style scripting language,
- macro recording,
- pixel or image matching,
- clicking at coordinates (virtual pointer),
- `/dev/uinput` or `/dev/input` access, a root daemon or keyd,
- any D-Bus or socket API through which other apps or the AI trigger actions
  or inject input.

**Reuse:** labwc keybinds and windowRules (through the config adapter), wtype
(MIT, Arch extra), XKB options, `ApplicationService`, `WindowService`,
`WorkspaceService`, `SettingsService`, and `ActionService` (shared with the
Launcher). A future Axiom compositor could use libei/EIS for the injection
path when portals support it. espanso is rejected (needs CAP_DAC_OVERRIDE plus
uinput).

**Compositor dependency.** Harness: shortcuts become generated
`<keybind key="…"><action name="Execute" command="axiom-automate run <id>"/>`
entries (an id, never a user command string), plus window rules and XKB
options. Snippets use wtype, which needs `zwp_virtual_keyboard_manager_v1`.
That interface is already open to every unsandboxed client on labwc, and
Automate does not widen it. Needs the Axiom compositor: abbreviation
expansion, app-scoped bindings, per-client injection grants, and
reserved-chord enforcement inside the compositor.

**Threat model and authorization**
- **Assets:** keystrokes, the focused window's input, and the user's ability
  to run code.
- **Attackers:**
  - (1) a sandboxed (Flatpak) app trying to inject input or trigger
    actions,
  - (2) an imported shortcut file from the internet (like a malicious
    theme),
  - (3) the Phase 12 agent or model output,
  - (4) an action targeting a sensitive surface: the lock screen,
    greeter, polkit dialog, or Settings > Shortcuts itself.
- **Not defended:** malware already running unsandboxed as the same user. It
  can edit config or use labwc's open virtual-keyboard interface today. State
  this honestly. Phase 11 narrows it with `<privilegedInterfaces>`, sandboxing
  and later per-client grants in the compositor.
- **Caller:** the only callers are (a) a compositor keybind the user created
  in Settings and (b) the user pressing Enter in the palette. There is no
  public IPC. `axiom-automate run` accepts only an id that exists in the
  user's validated store; unknown or disabled ids are denied.
- **Operation:** only catalog action types. Each has a schema; anything else
  is denied. "Run user script" and "insert snippet" are flagged
  *sensitive*: they can be created only in Settings by the user, never by
  import without per-item review showing argv and text, and never by an
  agent.
- **Target:** app ids or desktop ids must exist. Paths are absolute and
  canonicalized. Snippets are refused when the focused toplevel is the lock
  screen, greeter, a polkit/authentication agent, or Axiom Settings > Shortcuts
  (checked through `WindowService.active` app id against a deny list). Locking
  the session cancels running sequences.
- **Deny by default:** a missing, invalid or unknown-version store loads zero
  user bindings (system bindings still work) and shows a banner.
- **Attribution and logs:** every run logs id, trigger (key or palette),
  action types and result to the user journal (`systemd-cat -t
  axiom-automate`). Snippet text and script output are never logged. Imports
  and edits are logged as diffs of ids and types.

**Acceptance (QEMU, real key events)**
1. Super+Alt+T bound to "focus or launch foot": the first press launches it,
   the second focuses the existing window.
2. A snippet containing `héllo ✓ {date}` inserted into Mousepad matches
   exactly.
3. A sequence (workspace 2, launch foot, snap to zone 1) completes in order.
4. Caps->Esc works after re-login.
5. The rule "mousepad -> workspace 3" holds.
6. Journal entries exist for each run and contain no snippet text.

**Adversarial tests**
- a store with an unknown action type, an id like `x"; rm -rf ~`, a script
  path with `..`, or a symlink: each is denied and logged;
- an imported file containing a script action is held for review and not
  enabled;
- binding Super+L or Ctrl+Alt+Del: refused as reserved;
- a snippet hotkey pressed while the lock screen or a polkit prompt is focused
  types nothing;
- a Flatpak test app calling wtype/virtual-keyboard fails (security-context);
- `axiom-automate run` with a non-existent id: denied with a non-zero exit;
- an 11-step sequence or a 10 s delay is refused;
- a fuzz of 1000 random stores leaves labwc running and the generated config
  either valid or unchanged.

**Effort:** 5 weeks (shared `ActionService` 1, generator and runner 1.5,
Settings UI 1, security tests 1.5). It assumes the Zones config adapter exists;
add 1 week if Automate ships first.

**Measure:**
- Hotkey-to-action latency (target p95 under 50 ms to action start).
- Snippet typing throughput (characters per second through wtype) and
  correctness on 3 apps (GTK, Qt, Chromium/Electron).
- Reconfigure time after an edit.
- Zero added resident processes when idle.

**Top risk:** wtype or virtual-keyboard insertion is unreliable in some
toolkits (Electron, XWayland, non-US keymaps). Also, users will compare it to
AHK and call the cut scope "missing features". Ship the clipboard-paste
fallback only behind an explicit setting, and document the compositor-era
roadmap.

---

## Rollup

| App | MVP in one line | Effort | Compositor dependency | Top risk |
|---|---|---|---|---|
| Zones | Preset and custom layouts, Shift-drag and Super+Ctrl+N snapping, app-to-zone rules, via generated labwc regions | 3 wk | All MVP works on labwc; per-output layouts, hover flyout and spanning need the Axiom compositor | labwc limits (global regions, no IPC) shaping UX promises |
| Launcher | One palette: apps, windows, actions, calculator, per-user plocate file index and Raycast-format script commands; Vicinae not embedded, offered as BRIDGE | 4 wk | None; works fully on labwc | Index freshness (15-min timer) compared with Everything |
| Automate | Hotkeys -> typed action sequences, snippet insertion via wtype, curated XKB remaps and window rules; no IPC, no uinput, no recording | 5 wk (+1 if before Zones) | Hotkeys, rules and remaps on labwc; abbreviation expansion and per-client injection grants need the Axiom compositor | Insertion reliability across toolkits, and scope perception vs AHK |

Total about 12 weeks for one developer, sequenced Zones (it builds the labwc
config adapter), then Launcher (it builds `ActionService`), then Automate.

## Sources

- [labwc-config(5)](https://labwc.github.io/labwc-config.5.html) (regions, snapping, privilegedInterfaces, window rules, SIGHUP reconfigure); [labwc-actions(5)](https://manpages.ubuntu.com/manpages/resolute/en/man5/labwc-actions.5.html) (ToggleSnapToRegion; actions only from bindings/menus); [wayctl](https://github.com/ThomasFunk/wayctl) (third-party workaround for labwc's lack of IPC)
- [xdg-desktop-portal-wlr README](https://github.com/emersion/xdg-desktop-portal-wlr) (Screenshot and ScreenCast only); [libei roadmap, 2026](https://perrette.github.io/scribe/roadmap-libei/) (stock wlroots has no libei)
- [Vicinae GitHub](https://github.com/vicinaehq/vicinae) (GPL-3.0, React/TS Raycast-compatible extensions); [Vicinae docs](https://docs.vicinae.com/) and [FAQ](https://docs.vicinae.com/faq) (`vicinae server`, Node 20+ for extensions, deeplinks); [NixOS option: layer shell](https://mynixos.com/home-manager/option/programs.vicinae.useLayerShell)
- [updatedb(8), plocate](https://man.archlinux.org/man/updatedb.8.en) (private database: `-l 0 -o db -U dir`; readable by anyone who can read the file)
- espanso on Wayland: [espanso issue #1955](https://www.github.com/espanso/espanso/issues/1955), [NixOS discourse](https://discourse.nixos.org/t/using-espanso-on-wayland-nixos/55268), [nixpkgs PR 423931](https://github.com/NixOS/nixpkgs/pull/423931) (CAP_DAC_OVERRIDE wrapper); [AutoKey Wayland technical notes](https://autokey-wayland.readthedocs.io/en/latest/technical.html) (uinput access)
