# Track 1: Profiles (customizer plus distro-style navigator)

Date: 2026-11-09. Rounds: 3. Sources: Google/web, GitHub (Omarchy, Konsave,
Stylix, Hyprland), project docs and release notes, Hacker News, YouTube/ricing
guides (indirect), and the Axiom code. Reddit is not reachable by the research
tools. Builds on [track-0-positioning.md](track-0-positioning.md).

## Question

How do we let a user make the whole desktop their own (built-in styles plus
their own layout) in a GUI, safely, without the breakage other systems have?

## Round 1: How others do it

| System | How it works | Weak point |
|---|---|---|
| **Omarchy themes** | Folder with a mandatory `colors.toml` plus assets; `omarchy-theme-install <git-url>`; switching re-generates app configs (terminal, editor, bar) from templates | Theme = git repo with files, installed by script; CLI/TUI only |
| **KDE Plasma** | Global Themes from the KDE Store; very deep settings | No built-in "save my current layout"; people use Konsave (CLI) or copy `plasma-org.kde.plasma.desktop-appletsrc` |
| **GNOME** | Extensions change the shell's UI | Major updates disable extensions by design; repeated "all extensions broken after update" reports (Zorin, July 2026; Ubuntu 25.10) |
| **Hyprland/Quickshell rices** | Hand-written dotfiles; pywal/matugen generate colors from the wallpaper | Setup "takes days"; Hyprland renames options often (0.53.2: one user had 200+ config errors; 0.55 moves to Lua) |
| **NixOS + Stylix** | One declarative config themes the whole system | Needs Nix knowledge; Home Manager vs NixOS inheritance pitfalls |

**Pattern:** the good ideas are (a) **a small set of color tokens** that
generate every app's config (Omarchy, Stylix) and (b) **one declarative file**
(Stylix). The bad parts are CLI-only flows, configs that break on update, and
user edits that get mixed with system files.

## Round 2: What breaks and what's dangerous

- **Shared themes can run code. This is the biggest lesson.** In March 2024 a
  KDE Store global theme ("Grey Layout", ~4,000 downloads) ran `rm -rf` and
  wiped a user's files. KDE admitted the store had no checks for malicious
  behavior and that it lacks the people to review everything.
- **Updates break customization:** GNOME disables extensions on purpose at
  each major version. Hyprland renames config keys every few releases.
  Omarchy issue #4327: theme or bar broke after `omarchy update`. Omarchy's
  own guidance says edits under `~/.local/share/omarchy/` are lost on update.
- **Beginners:** tutorials "jump right into complex topics"; "you may lose
  hours tweaking configs instead of working". No well-known beginner GUI
  customizer was found (wpgtk and GNOME Tweaks only cover pieces).

## Round 3: Rollback, and what Axiom already has

- **Rollback options:** Snapper/btrfs (can snapshot `/home` separately),
  rpm-ostree and NixOS generations (system only; user data is not rolled
  back without extra hooks). **The system and the user's desktop setup are
  separate problems.** A desktop profile that is a small file needs no
  filesystem snapshots: keeping copies of the file is the rollback.
- **The Axiom code already has the foundation:**
  - `shell/services/SettingsService.qml` (ADR-018): one per-user
    `~/.config/axiom/settings.json`, watched by the shell and every app, with
    defaults for missing keys and a fallback for an invalid file. It already
    covers wallpaper, dock pins and text scale.
  - `branding/theme/axiom/colors.toml`: a token palette, the same idea as
    Omarchy's `colors.toml`.
  - **Gap:** `shell/src/shared/Theme.qml` **hardcodes** the colors, and
    the foot/labwc/sway configs are separate copies kept in step by hand. Today
    you can't switch theme at runtime.
  - **Gap:** panel and dock layout are fixed in QML; there is no layout model
    yet.

## Design conclusions

1. **A profile is data, never code.** It's one versioned file (JSON, matching
   `settings.json`): no scripts, no hooks, no executable widgets. Widgets come
   only from Axiom's built-in, reviewed set. This makes the KDE incident
   impossible by design and is a selling point: *"Install any profile. It
   can't run code."*
2. **Four layers you can mix and match:**
   - **Look:** color tokens, fonts, wallpaper, icons, corner radius.
     Optionally generated from the wallpaper (matugen-style).
   - **Layout:** panel position, which built-in widgets go where, dock.
   - **Behavior:** keybind set, floating vs tiling, focus rules.
   - **Apps:** a list of app IDs. They are *suggested*, and installed only
     through the Software Center with a visible confirmation, never silently.
3. **Axiom owns the schema and never breaks it.** The schema is versioned,
   migrations run automatically, and unknown keys are ignored, never fatal.
   That turns GNOME/Hyprland's biggest pain into a promise: *"Updates never
   break your profile."*
4. **System files and user files stay separate.** Built-in profiles are
   read-only system files; the user's edits are always a copy in
   `~/.config/axiom/` (avoiding Omarchy's "your edits are lost on update").
5. **Rollback = file history.** Each apply keeps the previous file, so undo is
   one click. App installs from a profile go through the package manager and
   its own snapshots. That's separate, and we say so honestly.
6. **One set of tokens generates every app's config:** the shell, terminal,
   window borders and GTK preference are all generated from the active
   profile's look (Omarchy and Stylix both do this). This replaces the
   hand-synced copies we have today.
7. **The navigator is the onboarding.** Built-in profiles are presented as
   styles ("Keyboard-first tiling", "Windows-like", "Mac-like", "Minimal dev",
   "Security lab"). Original visuals; no cloned branding.
8. **Sharing = one file.** Import shows a preview, a diff against your
   current setup, and the list of apps it suggests, all before anything
   applies.

## Smallest first version (when we build)

1. `Theme.qml` reads color tokens from the active profile instead of
   hardcoded values (runtime theme switching).
2. A profile file with the **look** layer only, plus 3 built-in looks, one
   click to undo, and switching from Settings.
3. Only then add the **layout** layer (panel and dock positions plus the
   built-in widget set), then behavior, then apps, then import/export.

Measure: theme switch time (target under 1s, no restart), with evidence
retained in QEMU, as the project rules require.

## Challenges

- **"Customize everything" vs "never breaks":** each customizable option is
  a schema promise you must keep forever. Start small and add options only
  when you actually miss them.
- **Tiling vs floating behavior** depends on the compositor. Axiom still runs
  on the temporary labwc harness (ADR-016). Leave the behavior layer until the
  compositor decision is made.
- **Third-party apps** (Firefox, VS Code) won't fully follow the theme. GTK/Qt
  dark mode and accent colors are achievable; full app theming is not. Say so
  in the UI.

## Sources

- Omarchy theming: https://instagit.com/omacom/omarchy/omarchy-theme-activation-flow-description/ , https://github.com/Wheel-Smith/awesome-omarchy
- Omarchy update issues: https://github.com/basecamp/omarchy/issues/4327 , https://github.com/basecamp/omarchy/issues/743
- Konsave: https://github.com/Anon-Artist/konsave
- KDE save-layout discussion: https://discuss.kde.org/t/how-do-i-save-the-current-kde-plasma-configuration-as-a-theme/5303
- KDE theme data loss: https://www.bleepingcomputer.com/news/linux/kde-advises-extreme-caution-after-theme-wipes-linux-users-files/ , https://blog.davidedmundson.co.uk/blog/2024/03/
- GNOME extensions breaking: https://forum.zorin.com/t/all-system-extensions-broken-after-gnome-shell-update-on-2026-07-01/65996 , https://discourse.gnome.org/t/why-do-gnome-extensions-break-on-every-new-os-release/18788
- Hyprland breaking changes: https://hypr.land/news/update55/ , https://linuxiac.com/hyprland-0-53-lands-with-window-rule-rewrite-and-dozens-of-fixes/ , https://github.com/caelestia-dots/caelestia/issues/471
- Stylix: https://github.com/nix-community/stylix
- Pywal/matugen setups: https://github.com/bigsparsh/hypr-config , https://hyprland-community.github.io/pyprland/wallpapers_templates.html
- Rollback: https://sol.sbc.org.br/index.php/sscad_estendido/article/view/37925 , https://discourse.nixos.org/t/rolling-back-data-as-well-not-only-nix-config/63169
- Beginner ricing: https://github.com/filesdot/resources , https://yomotherboard.com/question/how-to-get-started-with-customizing-linux-ricing/
- Axiom code: `shell/services/SettingsService.qml`, `shell/src/shared/Theme.qml`, `branding/theme/axiom/colors.toml`, `docs/DESKTOP_DESIGN.md`
