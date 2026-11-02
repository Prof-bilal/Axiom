# Phase 3 current state (pre-implementation scan)

Recorded: 2026-11-01, before any Phase 3 shell code was written. This is the
repository audit required by the Phase 3 brief ("inspect existing Axiom
repository"): what works, what is incomplete, what was removed, what is
reusable, and what blocked the shell.

## Repository shape

Tracked tree (post reset): `docs/`, `iso/` + `scripts/` + `tests/` (Phase 1
archiso/QEMU evidence), `branding/` (Axiom identity), `.agents/skills` +
`portable-skills/` (agent workflows). There was **no active `shell/`,
`compositor/`, `services/`, `apps/` or `packages/` implementation tree.**

## What already worked

| Area | State |
| --- | --- |
| Base image | A reviewed archiso profile (`iso/profile/`) builds twin ISOs and boots to a login prompt in QEMU/KVM with retained serial evidence (Phase 1 exit, 2026-10-25). Reproducible *inputs*, not bit-identical artifacts. |
| Boot harness | `tests/qemu-boot.sh` verifies the ISO checksum, boots UEFI, checks for a login prompt, requests a clean poweroff and reports failed units. |
| QEMU tooling | Host has `qemu-system-x86_64 11.1.2`, `mkarchiso 91`, `/dev/kvm`, OVMF firmware. |
| Validation | `scripts/validate-repo.py`, `test-concepts.py`, `check-iso-profile.py` all pass (0 errors). |
| Identity assets | `branding/identity/*` and `branding/theme/axiom/*` (palette, aurora wallpaper, penguin mark) are original Axiom assets. |
| Contracts | Architecture, design-token, Wayland-boundary, security and phase documents define the owned boundaries. |

## What was incomplete

1. **No graphical session.** The image reached a login prompt only. No Wayland
   compositor, no session command, no shell process.
2. **No compositor decision implemented.** `docs/ARCHITECTURE.md` selected
   "shell/session contract first with a temporary compositor harness" but no
   harness was chosen, configured or measured.
3. **No shell.** No panel, dock, launcher, workspace UI, notifications, status
   or session controls existed as code.
4. **Package list drift.** `iso/profile/packages.x86_64` ended with a
   "Historical desktop experiment" block (`plasma-meta`, `konsole`, `dolphin`,
   `kate`, `xorg-xwayland`) that was never the Axiom base and was never built
   into the Phase 1 evidence ISO.
5. **No Phase 3 test path.** The QEMU harness checked for a login prompt, not a
   running desktop session, and captured no display evidence.

## What was removed during this phase

The prior upstream-derived ("Omarchy") desktop foundation was removed
completely, per the project's own decision record and an explicit instruction:

- `archive/legacy/omarchy-foundation/` and `archive/legacy/omarchy-theme/`
  (build wrapper, migration report, theme adapters, workflow skills);
- the local `omarchy` and `migration/omarchy-foundation` git branches;
- local mirrors under `workspace/upstream/` (incl. a 4.4 GB VM image);
- Omarchy naming from all forward-facing docs; `docs/decisions/001-remove-omarchy.md`
  remains as the record of the removal.

## What is reusable

- Phase 1 archiso profile (as a build base) and the QEMU harness pattern.
- `branding/` palette and assets, consumed by shell design tokens.
- The Wayland, design-token, security and phase contracts.
- The host toolchain: Quickshell 0.3.2, `qs`/`quickshell`, Qt 6.12, sway,
  `grim`, `mkarchiso`, QEMU.

## Blockers to starting the shell (and how they were resolved)

| Blocker | Resolution |
| --- | --- |
| No compositor decision | Written up as [ADR-015](../../decisions/phase3-shell-architecture.md); sway (MIT) selected as a temporary harness. |
| No shell toolkit decision | Quickshell/QML (LGPL-3.0-only) selected as a replaceable implementation dependency. |
| Running the shell as non-root in a live ISO | ISO overlay creates unprivileged user `axiom`, autologin on tty1, session script runs the compositor + shell as that user. |
| No local graphical test loop (no sudo to install sway on the host) | QEMU is the acceptance gate; the shell was also parse-validated through `qs -p`. |
| Software rendering on virtual GPUs | Session exports `WLR_RENDERER=pixman` and `LIBGL_ALWAYS_SOFTWARE=1`. |

## Immediate Phase 3 target

Boot → graphical session → Axiom desktop → panel/dock/launcher/workspaces/
notifications/status/session controls, all consuming real session state and
verified in QEMU. See [PHASES](../../PHASES.md) and the feature research under
`docs/research/phase3/features/`.
