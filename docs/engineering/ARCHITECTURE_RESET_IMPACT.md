# Axiom architecture reset impact report

Status: **pre-reset inventory and post-reset audit**, recorded 2026-10-29. This report captures the
repository state before the Omarchy-based product architecture is removed. It is
not an implementation plan by itself; the reset is complete only when the active
architecture, build path and phase gates point at Axiom-owned product layers.

## Executive finding

The repository is structurally small (212 tracked files) and has no active
`apps/`, `shell/`, `services/`, `compositor/`, `kernel/`, `packages/` or
`installer/` implementation trees. The dependency is nevertheless architectural:

```text
active Phase 2 build script
  -> ignored workspace/upstream/omarchy-v4.0.6
  -> ignored workspace/upstream/omarchy-iso-main
  -> Omarchy package/profile/config conventions
  -> Hyprland + Quickshell + SDDM session
  -> Axiom identity applied as a theme/label layer
```

The result is a foundation migration experiment, not an Axiom desktop. The
previous Phase 3 shell code is not present in the current tree, but its intended
technology and ownership assumptions remain in documentation, portable skills,
the theme assets and the Phase 2 build contract.

## Inventory and classification

| Area | Current evidence | Classification | Reset action |
| --- | --- | --- | --- |
| Linux base contracts | Arch, systemd, udev/device assumptions, pacman, Btrfs/Snapper, PipeWire, NetworkManager, BlueZ, Mesa/Wayland research | **KEEP** | Retain as upstream infrastructure; make the ownership boundary explicit. |
| Phase 1 archiso profile and `tests/qemu-boot.sh` | `iso/profile/`, `scripts/build-iso.sh`, QEMU boot harness, retained evidence | **KEEP / ARCHIVE** | Keep as historical boot evidence; do not present it as the new desktop base. |
| `scripts/build-phase2-foundation.sh` | Clones/stages pinned Omarchy and `omarchy-iso`, filters Omarchy package lists, invokes an Omarchy builder | **ARCHIVE / REPLACE** | Preserve the script and evidence under a legacy archive; replace the active entry point with an Axiom base build contract. |
| `workspace/upstream/*` | Ignored Omarchy and omarchy-iso worktrees used by the Phase 2 wrapper | **REMOVE FROM ACTIVE ARCHITECTURE** | Do not vendor or depend on these trees; retain only reproducibility notes and upstream license notices. |
| `archive/legacy/omarchy-foundation/docs/OMARCHY_MIGRATION.md` | Former Phase 2 migration report, ADR-013 references, Omarchy component matrix | **ARCHIVE** | Keep as historical decision/evidence with an explicit superseded banner and link to the reset ADR. |
| `AGENTS.md`, `README.md`, `ARCHITECTURE.md`, `PHASES.md`, `ROADMAP.md` | Describe Omarchy as the current foundation and Phase 3 as Quickshell on Hyprland | **REFACTOR / REPLACE** | Rewrite around Axiom-owned shell/compositor/session layers and Phase 0–9 reset gates. |
| Desktop docs and portable skills | `docs/desktop/*`, `portable-skills/skills/quickshell-ui`, `wayland-integration`, `omarchy-upstream` | **REFACTOR / ARCHIVE** | Preserve Wayland/security guidance; remove Omarchy-specific workflow claims and make compositor APIs replaceable. |
| Axiom identity assets | `branding/identity/*`, original aurora wallpaper and penguin assets | **KEEP** | Preserve provenance and make them product assets, not an Omarchy theme install. |
| `branding/theme/axiom/*` | TOML files and README that install an Omarchy user theme and contain Hyprland-specific keys | **REFACTOR / ARCHIVE** | Preserve original palette/wallpaper; archive Omarchy shell/Hyprland adapters until an Axiom token system owns them. |
| Hyprland/Quickshell package assumptions | Phase 2 package filters, Wayland session labels, Quickshell skill and desktop docs | **REPLACE / RESEARCH** | Evaluate a temporary compositor bring-up path separately from the Axiom compositor strategy. Do not make Hyprland the product contract. |
| AI, security, Flow, recovery and system contracts | `docs/ai/*`, `docs/security/*`, `docs/system/*`, typed-authority rules | **KEEP / REFACTOR** | These are desktop-neutral foundations; update only references that assume an Omarchy shell. No AI implementation in this reset. |
| Installer, release and hardware docs | `docs/engineering/INSTALLER.md`, release and hardware matrices | **RESEARCH / REFACTOR** | Keep deferred gates; remove language that assumes Omarchy owns the installer/update product. |
| UI prototype remnants | No active shell source tree; historical Phase 3 implementation was removed before this scan | **ARCHIVE / REMOVE** | Keep no fake desktop active. Any recovered design concepts go into DESIGN/architecture docs, not screenshot-only code. |

## Active Omarchy dependency map

Direct product/runtime coupling currently appears in:

1. `scripts/build-phase2-foundation.sh` (source checkouts, package names,
   builder image, paths, environment variables and Omarchy revision checks).
2. `archive/legacy/omarchy-foundation/docs/PHASE2_BUILD.md`,
   `archive/legacy/omarchy-foundation/docs/PHASE2_EVIDENCE.md`,
   `archive/legacy/omarchy-foundation/docs/OMARCHY_MIGRATION.md`, `iso/profile/README.md` and
   `docs/security/SECURITY.md` (architecture and security claims).
3. `README.md`, `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/PHASES.md`,
   `docs/ROADMAP.md`, `docs/TECH_STACK.md`, `docs/MVP.md`, `docs/PRD.md`,
   `docs/VISION.md`, desktop docs and ecosystem/testing docs (product framing).
4. `branding/theme/axiom/README.md` and the shell/lock/color configuration
   files (user-theme installation and Hyprland/Omarchy configuration keys).
5. the former `portable-skills/skills/omarchy-upstream/SKILL.md` and
   `portable-skills/skills/quickshell-ui/SKILL.md` (workflow assumed the
   Omarchy-derived session).
6. `THIRD_PARTY_NOTICES.md` (Omarchy and Omarchy-ISO are currently described as
   required image inputs rather than historical/proposed upstream options).

The ignored upstream worktrees are not tracked product code, but the build
wrapper makes them a runtime/build dependency. They must not remain required for
the post-reset base or QEMU milestone.

## What is reusable

- Original Axiom identity assets, product language, design-token research and
  interaction principles, after removing Omarchy installation instructions.
- Arch/systemd/pacman/Btrfs/Wayland/pipewire/networking research and the
  security, recovery, audit, Flow and typed-capability contracts.
- Phase 1 ISO/QEMU harness and validation scripts as evidence and test tooling,
  with the new QEMU-first workflow layered above them.
- Repository validation, concept tests, license inventory and upstream-review
  practices.

## Reset constraints

- Zero Omarchy product/runtime dependencies in the active Axiom architecture.
- Mature Linux infrastructure remains upstream; “from the kernel” does not mean
  rewriting libc, drivers, systemd, networking, audio or graphics plumbing.
- Axiom owns the visible desktop: compositor/session boundary, shell, core apps,
  platform services, AI boundary and security UX.
- No active fake UI, hardcoded desktop state, screenshot-only component or browser
  mock may satisfy a graphical milestone.
- QEMU remains the reproducible acceptance target for each boot/session gate.

## Reset implementation order

1. Add the reset ADR and mark ADR-013/Omarchy migration material historical.
2. Rewrite the architecture, product, design, development, build, testing,
   security, phases and roadmap contracts.
3. Archive or replace the Omarchy build/theme/workflow files without deleting
   useful Axiom assets or Phase 1 evidence.
4. Establish the minimal Axiom base/compositor/session boundary and QEMU-first
   development commands as the next implementation target.

## Post-reset audit

The active tree no longer contains an Omarchy build wrapper, Omarchy migration
document, Omarchy-specific theme adapters or Omarchy/Quickshell workflow skill.
Those artifacts are retained under `archive/legacy/`; the ignored local
`workspace/upstream/` checkouts are not read by any active script. Static
validation, concept tests and skill installation pass after the reset. The
remaining Omarchy/Hyprland/Quickshell references in active docs are explicitly
historical license, decision or impact-report records, not product/runtime
dependencies.
