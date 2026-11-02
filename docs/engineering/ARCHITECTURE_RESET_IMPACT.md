# Axiom architecture reset impact report

Status: **completed 2026-11-01.** The architecture reset removed the previous
upstream-derived desktop foundation from the repository. This report records the
final classification; it is a historical record, not an implementation plan.

## Result

The active tree contains no upstream desktop build wrapper, migration document,
theme adapter or workflow skill, and no `omarchy` branches or local mirrors. The
only remaining reference is the removal decision
[001-remove-omarchy](../decisions/001-remove-omarchy.md), retained as the record
of why the change was made.

## Classification of the removed material

| Area | Final disposition |
| --- | --- |
| Linux base contracts (Arch, systemd, udev, pacman, Btrfs, PipeWire, NetworkManager, BlueZ, Mesa) | KEEP as upstream infrastructure, with an explicit ownership boundary |
| Phase 1 archiso profile and `tests/qemu-boot.sh` | KEEP as historical boot evidence and test tooling |
| Upstream desktop build wrapper and pinned mirrors | REMOVED |
| Former migration report, theme adapters and workflow skills | REMOVED |
| Axiom identity assets under `branding/` | KEEP as product assets |
| AI, security, Flow, recovery and system contracts | KEEP as desktop-neutral foundations |

## Constraints that still apply

- Mature Linux infrastructure remains upstream.
- Axiom owns the visible desktop: compositor/session boundary, shell, core apps,
  platform services, AI boundary and security UX.
- No fake UI, hardcoded desktop state or screenshot-only component may satisfy a
  graphical milestone.
- QEMU remains the reproducible acceptance target for each boot/session gate.
