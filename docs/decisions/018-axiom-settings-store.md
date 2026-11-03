# ADR-018: Axiom settings store

**Date:** 2026-11-03
**Status:** Accepted for Phase 4 (implemented in `shell/services/SettingsService.qml`).

## Context

Settings must change shell behaviour live (wallpaper, pinned dock apps, text
size) and persist, without a new daemon and without UI performing privileged
work. The shell and each app are separate Quickshell processes.

## Decision

One JSON file per user, `$XDG_CONFIG_HOME/axiom/settings.json`
(`~/.config/axiom/settings.json`), read and watched by the shell and every app
through `FileView` + `JsonAdapter` (`SettingsService`, imported as
`qs.services`). The Settings app is the only writer; a change written by one
process reaches the others through file watching.

Schema (version 1): `wallpaper` (absolute image path, `""` = Axiom default),
`dockCustom` + `dockPins` (desktop-entry ids; defaults apply while
`dockCustom` is false), `textScale` (0.9 to 1.5, multiplies every font token).

Rules:
- Missing keys use defaults. An unreadable or invalid file falls back to
  defaults, is reported in `SettingsService.loadError` and shown on the
  Appearance page, and is replaced only when the user changes a setting.
- Writes create the directory first (`mkdir -p`) and use `FileView`'s atomic
  write (temporary file and rename).
- File watching only works on an existing file, so while the file is missing
  (fresh account, or deleted) the service retries the load every 1.5 s and stops
  once it loads. This is the only timer the service runs.
- System-wide or privileged settings are out of scope (Phase 5 services,
  Phase 6 permissions). Default applications use the system MIME mechanism
  (`gio mime`, `~/.config/mimeapps.list`), not this file.

App-local view state (Files' last folder, sort order, hidden-files flag) lives
in its own `$XDG_STATE_HOME/axiom/files.json`; it is not a setting.

## Known limits

- `JsonAdapter` rewrites the whole file from its known properties, so unknown
  keys written by a newer version or by hand are dropped on the next save.
- No file lock: two Settings windows would last-writer-win. Acceptable for one
  interactive user.
- Text size scales fonts only; layout metrics (panel, dock, row heights) are
  fixed, so very large sizes would crowd them. The range is capped at 1.5 and
  the Settings app offers 1.0, 1.125 and 1.25.

## Evidence

Cross-process live updates and the missing-file case are recorded in
[Phase 4 evidence](../research/phase4/evidence.md).
