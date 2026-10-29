# Axiom: shared agent instructions

Build an original AI-native Linux desktop for developers with safe structured
automation, privacy, recovery and measured performance. The repository is
project memory; no tool or chat is authoritative over maintained contracts.

**Current development: Phase 0 architecture reset (authorized 2026-10-29).**
The previous Omarchy-derived Phase 2/3 desktop direction is superseded and
archived. The next implementation gate is Phase 1: bootable minimal Axiom base
and graphical-session prerequisites in QEMU. Read [PHASES](docs/PHASES.md), the
[reset impact report](docs/engineering/ARCHITECTURE_RESET_IMPACT.md) and
[architecture](docs/ARCHITECTURE.md) before changing direction.

## Architecture and map

Axiom reuses the Linux kernel, libc, systemd, udev, drivers, networking, audio,
Mesa/graphics, Wayland protocols, package management and proven boot tools.
Axiom owns the compositor/session boundary, shell, core apps, platform
services, AI boundary and security UX. A temporary compositor may be used for
bring-up, but no upstream desktop project is the product contract. See
[ARCHITECTURE](docs/ARCHITECTURE.md), [DESIGN](docs/DESIGN.md),
[DECISIONS](docs/DECISIONS.md) and [ROADMAP](docs/ROADMAP.md).

- `docs/`: product, architecture, contracts, research, phases and evidence.
- `archive/legacy/`: superseded Omarchy foundation and theme material; never an
  active input.
- `iso/` and `tests/`: retained Phase 1 archiso/QEMU evidence and harness.
- `branding/`: reviewed Axiom identity and palette assets, not an upstream
  desktop theme install.
- `scripts/`: deterministic repository validation and legacy evidence helpers.
- Future `system/`, `compositor/`, `shell/`, `apps/`, `services/`, `security/`,
  `ai/`, `packages/` and `vm/` appear only when their phase authorizes real
  implementation; do not create empty scaffolds.

## Non-negotiable rules

AI never gets unrestricted root, sudo or arbitrary shell passthrough. UI never
runs as root. Privileged APIs are narrow and independently authorize caller,
operation and target. Deny missing/invalid authority. Keep secrets out of the
repository and logs. Preserve Wayland and portal boundaries. Attribute actions,
verify changes and test recovery where practical; never promise universal undo.
Core desktop works without cloud AI. Deterministic routines avoid unnecessary
model calls. Every daemon and new privileged component requires justification.
Reuse mature Linux primitives. Performance claims require measurements.

No fake browser UI, hardcoded desktop state or screenshot-only component can
pass a graphical phase. Every major milestone boots the real system in
disposable QEMU with retained serial/journal/display evidence.

## Work and completion

Read this file, the current phase, relevant docs and the relevant portable skill.
Define acceptance criteria and ownership, implement the smallest coherent
change, run targeted tests plus adversarial checks for security changes and
benchmarks for performance claims. Update canonical docs when architecture or
behavior changes. Do not replace core technologies opportunistically: research,
record compatibility/security/performance/rollback impact and add an ADR before
major changes.

Done means implementation complete, targeted tests and integration pass,
failure/security behavior addressed, reproducible evidence retained, no known
regression and documentation updated. Foundation changes use
`python3 scripts/validate-repo.py`; Phase 1 legacy evidence additionally uses
`python3 scripts/check-iso-profile.py`, `sudo scripts/build-iso.sh` and
`tests/qemu-boot.sh`. New base/VM commands require their own reviewed phase
contract.
