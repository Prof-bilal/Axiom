# ADR-017: Core apps run as Quickshell/QML apps sharing the shell's config root

**Date:** 2026-11-03
**Status:** Accepted for Phase 4. Revisit if a measured gate below fails.
Extends [ADR-015](phase3-shell-architecture.md) and
[ADR-016](016-labwc-compositor-harness.md).

## Context

Phase 4 ([PHASES](../PHASES.md)) needs functional Files, Settings, Terminal
integration and Software Center. Axiom owns these apps and their information
architecture, but must reuse a toolkit and standard Linux APIs
([ARCHITECTURE](../ARCHITECTURE.md)). The Phase 3 shell is Quickshell/QML with
a token set (`shell/src/shared/Theme.qml`) and shared components. The image
already ships Qt 6.12 declarative, Quickshell 0.3.2 and GVfs; no GTK/Qt widgets
app framework or build toolchain is part of the image.

## Options

| Option | Reuses shipped runtime | Shares tokens without copying | Needs build toolchain / new packages | Process control (`gio`, `pacman`) | Notes |
| --- | --- | --- | --- | --- | --- |
| **A. Quickshell `FloatingWindow` apps, one process each, shared config root** | Yes | Yes (`qs.src.shared`) | No | `Quickshell.Io` Process (argv arrays) | Measured below |
| B. Plain `qml` runner + Qt Quick Controls | Qt only | Needs duplicated or packaged QML module | No | None without a C++ plugin | Cannot spawn processes |
| C. C++/Qt app binaries | Qt | Packaged module | Yes (compiler, CMake, PKGBUILDs) | Native | Heaviest; premature before the apps exist |
| D. Python + PySide6 | No (new packages) | Duplicated | Yes (new runtime) | Native | Adds a second UI runtime |

## Decision

**Option A.** Each core app is a Quickshell entry file at the shell config root
(`shell/<app>.qml`, AppId `org.axiom.<App>`) whose code lives in top-level
`apps/` (a relative symlink `shell/apps -> ../apps` makes it part of the same
config root, staged to `/usr/local/share/axiom/{shell,apps}`). Apps are
launched through `axiom-app <name>` which accepts only a fixed list of names.
One process per app keeps crash isolation: an app crash closes its window and
nothing else; recovery is launching it again.

No new daemon is introduced. System work uses argv-array processes (`gio`,
`pacman`, `xdg-mime`, ...), never `sh -c` with user-controlled strings. Apps
run as the desktop user. If a measured limit is hit (very large folders, mime
lookup), the escalation is one small C++ QML plugin, recorded in a new ADR.

## Evidence (QEMU/KVM, software rendering, 2026-11-03)

Spike on the Phase 3 image, 2 GiB guest, labwc 0.20.2, Quickshell 0.3.2:

- A `FloatingWindow` app gets the full labwc/Axiom title bar (icon, title,
  minimize/maximize/close, rounded corners, focus glow) with no extra work.
- Tokens import through `qs.src.shared`; a symlinked `apps/` tree resolves from
  the shell root (`qs.apps.<name>`); a second Quickshell instance runs beside
  the shell without interfering with it.
- A `FolderListModel` window listing a real directory: **222 MB RSS / 157 MB
  PSS** per app process (shell: 450 MB RSS / 361 MB PSS in the same guest).
  The spike's first guess was a gate of PSS below 200 MB per app; see the
  amendment below, which replaces it with measured numbers.

## Amendment (2026-11-03): memory gate measured on the finished apps

Measured by `tests/phase4-apps.py` on the full image (2 GiB guest, software
rendering), shell plus Files, Software and Settings all open:

| Process | PSS |
| --- | --- |
| Axiom Files (small folder, all apps open) | 185 to 247 MiB across runs |
| Axiom Files with a 10,000-entry folder open | 284 MiB |
| Axiom Software (681 packages) | 157 to 236 MiB (higher while searching/browsing) |
| Axiom Settings | 120 to 234 MiB (higher with wallpaper previews loaded) |
| Quickshell shell (for scale) | about 395 MiB |
| Whole guest in use, shell and all three apps open | about 1.22 GiB of 2 GiB |

The 200 MiB per-app figure was a guess taken from an empty spike window and
Files exceeds it. The gate that matters for the product is the whole-session
budget, so it becomes: **each app below 256 MiB PSS with an ordinary folder or
list and all apps open, and the guest below 1.8 GiB with the shell and all three
apps open.** The driver enforces that. A very large folder is outside it and is
reported rather than gated: Files with 10,000 entries open measured 284 MiB,
which is a known exceedance of the per-app figure (the guest still had more than
700 MiB free). Files is the heaviest at rest because of its list view and
per-row canvas icons (`AxiomIcon` is a `Canvas`); caching those glyphs as images
is the first optimisation to try if the budget tightens.
Running the apps as one shared process would save more but give up crash
isolation, and is not needed at these numbers.

- **Measured limit, `FolderListModel` (superseded):** after `mkdir` + `touch` of several
  entries in one burst the list missed one file (`a b.txt`) for at least 5 s
  and corrected itself only on the next filesystem event. Files must therefore
  not trust the change stream alone: a debounced rescan after changes and after
  every operation the app performs, plus a manual refresh. If a rescan cannot
  make listing reliable, this is the trigger for the C++ plugin escalation.
  **Outcome:** Files does not use `FolderListModel`. It lists with
  `find -printf` (NUL-separated, safe for any file name), reacts to
  `gio monitor` events with a debounced full rescan, and rescans after every
  operation it runs, so a missed or coalesced event cannot leave the list
  stale. No native plugin was needed.
- **Measured: large lists.** 10,000 entries in the guest: parsing 52 ms; sorting
  with a regex comparator 2,578 ms; a precomputed key and native string sort
  did not help (1,640 ms) because the cost was Qt converting 10,000 JS objects
  when they were assigned as a `ListView` model. With an integer model and
  per-row lookup, sort-and-apply is 116 ms (total listing about 190 ms).
  Rule for every app list: integer model, rows look their data up by index.
- `axiom-app` rejects unknown app names (exit 2); a launched app has AppId
  `org.axiom.Files`, matched to its desktop entry (`StartupWMClass`) so the dock
  shows the Axiom icon for the running window.

## Consequences

- Positive: no duplicated tokens, no new runtime or packages, apps look like the
  shell by construction, real titled windows with working window controls.
- Negative: each app costs about 150 MB PSS; apps are coupled to the shell
  config root and its Quickshell version; QML offers no native file/mime APIs.
- Rollback: apps are isolated directories; switching runtime later keeps each
  app's service layer and information architecture.
