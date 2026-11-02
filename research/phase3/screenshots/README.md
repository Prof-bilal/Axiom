# Screenshots

Real captured display evidence of the running Axiom Shell, produced by the QEMU
monitor `screendump` (guest framebuffer, not a mock).

## Committed

- `desktop-phase3-live.png` — a live Phase 3 session in QEMU/KVM: top panel
  (Axiom mark, workspace chip "1", centered clock, status + power), bottom dock
  (running terminal highlighted, editor, browser), aurora wallpaper, and three
  tiled `foot` windows. Captured 2026-11-01; see
  [evidence](../../../docs/research/phase3/evidence.md) for the environment and
  checksum.

## Expected on the automated run

`tests/qemu-session.sh` writes to its evidence directory (gitignored):
`01-desktop`, `02-launcher`, `03-terminal`, `04-workspace-2`,
`05-control-center`. Accepted images should be copied here once a run passes.

No screenshot-only component is accepted as a phase gate: each image must
correspond to real session state in the same run.
