# ADR 033: System updates and snapshot rollback

Status: Proposed. Phase 7 (package management and updates). Implementation in progress.

## Context
The Software Center can install and remove packages through the root helper
`system/pkgd/axiom-pkgd`, but it cannot update the system and cannot roll back a bad
update. Phase 7 exit requires both.

## Decision
1. **Snapshots with snapper on btrfs.** The installed system uses btrfs by default (user
   decision). `snapper -c root` creates and rolls back snapshots of the root.
2. **Snapshot before every update.** `axiom-pkgd update` takes a snapshot first and runs
   `pacman -Syu` only if the snapshot succeeded. Without snapper (the live ISO on ext4) the
   helper refuses: it never updates without a way back.
3. **Rollback is root-only and narrow.** `axiom-pkgd rollback <number>` accepts a numeric id
   only and logs the request. A rollback needs a reboot; the UI says so.
4. **No shell from the caller.** Every verb takes validated arguments and runs a fixed command.
5. **Separate polkit actions (required before shipping).** Today every verb is one polkit
   action (`org.axiom.installer.install`). `update` and `rollback` must be separate actions
   with their own messages, so approving an install does not approve a rollback.

## Consequences
- The live ISO cannot update or roll back; the Software Center shows that instead of an
  Update button that does nothing.
- Snapshots use disk space; the retention policy is a follow-up.
- `snapper` must be in the installed system's package list.

## Verification
- `tests/apps/pkgd.test.mjs`: update snapshots before pacman, rollback takes a numeric id
  only, snapshot descriptions are checked, and without snapper the verbs refuse and pacman never runs.
- QEMU on an installed btrfs system: update, then a deliberately bad update, then rollback to
  the snapshot; serial and screenshots kept as evidence.

## Amendment (2026-11-24, pre-Phase-8 audit S2)

`axiom-pkgd update` and `rollback` now refuse unless called through `axiom-pkg-update` / `axiom-pkg-rollback`, which set
`AXIOM_PKGD_VIA=wrapper` (pkexec clears the caller's environment). Approving "install a package" can therefore no longer
approve an update or a rollback. `sync` and `remove` snapshot first on installed systems, and `remove` refuses core packages.
