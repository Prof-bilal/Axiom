# Phase 4 evidence log

Records what was observed, not what was planned. Companion to
[PHASES](../../PHASES.md), [ADR-017](../../decisions/017-core-app-runtime.md)
and [ADR-018](../../decisions/018-axiom-settings-store.md).

## Final acceptance run (2026-11-03)

`tests/phase4-apps.py iso/out-phase3/axiom-2026.11.03-x86_64.iso` at 1920x1080:
**58 checks, 0 failures**, guest powered off cleanly. Environment: QEMU 11.1.2
with KVM, UEFI (OVMF), 2 GiB RAM / 2 vCPU, VGA with EDID, USB tablet, `-nic
none`, no host shares, software rendering (pixman); labwc 0.20.2, Quickshell
0.3.2, Qt 6.12.0, foot 1.28.0. One firmware-stage boot stall (exit 3, the known
host/QEMU flake) was retried automatically. Every result below is checked on
disk or in process state over the serial console; screenshots are retained
beside it in `iso/out-phase3/evidence/phase4/1920x1080/` (not committed) with a
full command `transcript.txt` and each app's startup log. After that run the
Settings section was repeated (`1920x1080-settings-rerun/`, 12 checks, all
passing) with the two text-size assertions tightened: the first version of the
"back to Default" check matched `1.25` as well as `1`, so it could not fail.

| Area | Checks that passed |
| --- | --- |
| Image | Axiom Files is the default for folders; Files, Software, Settings and Trash entries installed; `pcmanfm` gone; `axiom-app` rejects unknown names |
| Dock | clicking Files launches it with no stray `%U`; the Trash pin opens Files at `trash:///` |
| Files | startup path argument; Ctrl+Shift+N and F2; copy/paste of all 18 entries of a hostile folder (spaces, quotes, a newline, a leading dash, `$(...)`, `;rm -rf x`, `*`, a directory link, a broken link) is byte-exact on names and content; Delete trashes (0 to 18 Trash entries); Ctrl+R restores; plain Enter does not permanently delete, Ctrl+Enter does; rename onto an existing name is refused and nothing is lost; Enter opens the file in the default application; restoring onto an existing name is refused and both files survive; F4 opens a terminal in the viewed folder; an unreadable folder is handled; 10,000 entries listed; last folder saved and restored; no QML errors |
| Software | the app lists exactly the 681 packages `pacman -Q` reports; no QML errors. Search, filters, details, files and Show in terminal were checked on screen (screenshots retained) and in earlier manual runs; the driver asserts the package count only |
| Settings | Text size, wallpaper, dock pin removal and reset are written to `settings.json`; the text editor default changes to Vim and back through the system MIME database; the shell, a different process, applies the new wallpaper live; no QML errors |
| Notifications | a notification renders on screen (objective brightness change of the toast region) |
| Recovery | the supervised shell restarts after being killed and the chosen wallpaper is still applied |
| Memory | per-app PSS below the amended 256 MiB figure with all apps open; whole guest 1.22 GiB of 2 GiB |

Phase 3 regression on the same image: `tests/phase3-desktop.py` at 1920x1080,
full path through the confirmed shutdown: pass.

## Measurements

| Measurement | Result |
| --- | --- |
| Files, 10,000 entries (`find` parse + sort/apply + selection) | 79 + 159 + 22 ms (earlier runs 263 to 568 ms total; the host was under different load) |
| Files PSS: small folder (all apps open) / 10,000 entries | 185 MiB / 284 MiB (the 10,000-entry case is above the 256 MiB per-app figure and is reported, not gated; see ADR-017) |
| Software PSS / Settings PSS (all open) | 158 MiB / 131 MiB |
| Quickshell shell PSS | 395 MiB |
| Guest memory in use, shell + all three apps | 1,251 MiB of 2,048 MiB |

All from a software-rendered KVM guest on a developer host; they are baselines,
not hardware claims. The per-app gate was amended from a guess to measured
values in ADR-017.

## Defects found by this work and fixed

| Defect | Cause | Fix |
| --- | --- | --- |
| Notification toasts and history never rendered (a Phase 3 gap) | nothing set `notification.tracked`, so Quickshell discarded them | `onNotification: tracked = true`; a rendered-toast check is part of the driver |
| `FolderListModel` missed new files after a burst of changes | the change stream alone is not reliable | Files lists with `find`, reacts to `gio monitor` with a debounced full rescan, and rescans after every operation |
| 10,000-entry folder blocked the UI for 1.6 to 2.6 s | Qt converted every JS object when the array was a `ListView` model | integer model with per-row lookup: 116 ms; rule recorded in ADR-017 |
| Files ignored Ctrl+C/V/Delete after a click | a hidden `TextInput` regained focus when the scope was re-focused | a dedicated key-target item owns focus |
| Dialogs opened from the context menu never took typing | the action handler re-focused the key target after the dialog grabbed focus | only re-focus when no dialog is open |
| Properties dialog never appeared | stale variable name left by a rename | fixed; covered by manual and driver runs |
| Settings written before the file existed were never noticed by the shell | file watching needs an existing file | 1.5 s retry only while the file is missing (ADR-018) |
| **Trash view stays empty on a fresh account** after the first trashed item | the GVfs trash daemon started (or a `gio monitor trash:///` ran) while `~/.local/share/Trash` did not exist and never noticed items trashed later; reproduced in QEMU | the Trash directories are created (0700) at session start and again by Files before it first lists or monitors |
| Desktop-entry field code `%U` could reach the app | `axiom-app` forwarded any argument | empty and `%`-prefixed arguments are ignored |

Test-harness defects fixed along the way (so the evidence can be trusted): the
UART drops bytes in long bursts (writes are paced); shell prompts and `$?`
leaked into captured output and produced false results (commands now return
output between explicit begin/end markers, with the prompt disabled); a shell
arithmetic expansion typo in a comparison; the scratch directory path was too
long for a UNIX socket (limit 108 bytes).

## Looked at, not asserted

- Text size at 125% (`settings-02b-text-larger.png`): the panel text, the
  Settings rows and the buttons all scale together with no clipping. The driver
  asserts the saved value; the look was checked on the screenshot.
- Software search and details (`software-02-search.png`): filtering to Firefox
  shows one application, with the offline notice and the 681/162/519 package
  counts.

## What this does not cover

- **Persistence across a reboot.** The live image resets its writable layer on
  reboot, so "settings survive a reboot" cannot be demonstrated here. Persistence
  across a shell restart (killed and restarted by its supervisor) and Files
  reopening its saved folder are tested. A reboot test needs a persistent disk
  and belongs with the installer phase.
- **Software Center is read-only** by design: no install, remove or update
  (they need the permission layer) and no repository search (the live image has
  no sync databases and no network).
- **Settings** covers About, Appearance, Dock, Default apps and Displays
  (read-only). Wi-Fi, Bluetooth, sound, power and users belong to Phase 5.
- **Files** has no drag and drop, thumbnails or device mounting, and no undo
  beyond restoring from the Trash.
- Only the 1920x1080 resolution was run for Phase 4; the Phase 3 driver covers
  the shell at 1366x768 and 2560x1440.
- Emoji glyphs in file names render as a placeholder (no colour emoji font in
  the image).
- Logout and restart through the UI were not exercised by an automated check.

## Reproduce

```sh
python3 scripts/validate-repo.py
node --test tests/apps/*.test.mjs
scripts/build-phase3-iso.sh             # unprivileged (user namespaces); needs network for the package download
tests/phase4-apps.py iso/out-phase3/axiom-2026.11.03-x86_64.iso
tests/phase3-desktop.py iso/out-phase3/axiom-2026.11.03-x86_64.iso iso/out-phase3/evidence/desktop --res 1920x1080
```
