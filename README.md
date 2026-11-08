# Axiom

Axiom is an experimental AI-native Linux desktop focused on developer workflows,
privacy, secure system agents, recovery and a desktop experience designed from
first principles.

**Status: Phases 0 to 6 are complete (Phase 6, the installable system, on
2026-11-08). Phase 7, package management and updates, is next.** Axiom is
pre-alpha: it is verified in QEMU only, there is no public release, and the AI
layer is designed but not built. Nothing here is a hardware or release promise.

Axiom uses standard Linux infrastructure. The compositor/session boundary, shell,
core applications and product services are developed specifically for Axiom. The
previous upstream-derived desktop direction has been removed and is not a
dependency.

Start with [the product brief](docs/PRODUCT.md), [architecture](docs/ARCHITECTURE.md),
[phase gates](docs/PHASES.md), [design](docs/DESIGN.md) and
[development workflow](docs/DEVELOPMENT.md). No browser mock or themed upstream
desktop counts as an Axiom result: every milestone must boot the real system in a
disposable QEMU guest with retained evidence.

## What works today

| Area | State | Evidence |
| --- | --- | --- |
| Boot and graphical session (Phases 1 to 2) | Done | Folded into the Phase 3 QEMU run |
| Axiom Shell: panel, dock, launcher, workspaces, tray, notifications, session controls (Phase 3) | Done | 21 automated checks, boot to shutdown through the UI |
| Core apps: Files, Settings, Terminal integration, read-only Software Center (Phase 4) | Done | 58 automated checks, hostile file names, 10,000-entry folders |
| System experience: Wi-Fi, Bluetooth, sound, display, power, keyboard, date, users (Phase 5) | Done | 76 automated checks |
| Installable system: terminal installer, optional disk encryption, greetd login, lock screen, Developer Hub first-boot job (Phase 6) | Done | `tests/phase6-install.py` with real key events in QEMU, plus installer unit tests ([ADR-020](docs/decisions/020-installable-system.md), [ADR-021](docs/decisions/021-installer-and-developer-hub.md)) |

Known limits: verified in QEMU only (real hardware is Phase 10), the Software Center
is read-only, Wi-Fi and Bluetooth were simulated or absent in the VM, and all timings
are software-rendered baselines, not hardware figures. The full list is in
[PHASES](docs/PHASES.md) and on the project site's Progress page.

## What Axiom reuses and owns

Linux, systemd, udev, device drivers, networking, PipeWire, Mesa, Wayland protocols,
libc, package management and boot technologies remain upstream infrastructure. Axiom
owns the visible desktop workflow: compositor/session contracts, shell surfaces, core
apps, platform services, AI boundaries and security UX. Axiom does not rewrite mature
infrastructure without a measured, product-specific reason.

## Non-negotiable rules

- AI never gets unrestricted root, sudo or an arbitrary shell. The UI never runs as root.
- Privileged APIs are narrow and independently authorize caller, operation and target.
- The core desktop works without cloud AI.
- Secrets stay out of the repository and logs.
- Performance claims need measurements. Recovery is tested, and universal undo is never promised.

These are stated in full in [AGENTS.md](AGENTS.md) and [SECURITY](docs/SECURITY.md).

## Repository map

| Path | Contents |
| --- | --- |
| `docs/` | Product, architecture, contracts, ADRs, research, phases and evidence. |
| `shell/` | The Axiom Shell and core app windows (Quickshell/QML). |
| `apps/` | Files, Settings and Software Center logic. |
| `installer/` | The terminal installer (`axiom_install.py` backend and the curses UI). |
| `greeter/` | The greetd login screen. |
| `provision/`, `catalog/` | The Developer Hub first-boot job and its catalog. |
| `iso/` | archiso profiles: `profile/` (Phase 1 legacy) and `phase3/` (graphical image). |
| `tests/` | QEMU acceptance tests and installer unit tests. |
| `scripts/` | Repository validation, ISO builders and the VM launcher. |
| `branding/` | Reviewed Axiom identity and palette assets. |
| `portable-skills/`, `research/` | Agent skills and research notes. |

The marketing site is a separate Next.js project in `landing-page/` on the `frontend`
branch. See its README for how to run and edit it.

## Try it

You need an Arch-based host with `archiso`, QEMU with OVMF and KVM, and Python 3. A full
ISO build takes about 30 minutes and downloads packages from the official Arch
repositories. Do not run any of this on a machine whose disks you cannot lose: the
acceptance tests only touch disposable QEMU disks, but the ISO build needs root.

```sh
# 1. Validate the repository (no root, fast)
python3 scripts/validate-repo.py
python3 scripts/test-concepts.py
python3 scripts/check-iso-profile.py

# 2. Build the graphical ISO (needs mkarchiso)
sudo pacman -S --needed archiso
scripts/build-phase3-iso.sh
#   AXIOM_PHASE3_WORK=... AXIOM_PHASE3_OUT=... override the work and output directories

# 3. Boot it by hand (shown over VNC on 127.0.0.1:5901)
scripts/run-vm.sh path/to/axiom-*.iso
```

## Tests

```sh
# Installer unit tests (no VM)
python3 -m unittest discover -s tests/installer

# Phase 6: install onto a blank QEMU disk through the real installer, boot, log in
tests/phase6-install.py ISO OUTDIR --stage install|installed|provision|all [--luks]

# Earlier phases, on the same ISO
tests/phase3-acceptance.py ...   tests/phase4-apps.py ...   tests/phase5-system.py ...
```

Keep evidence directories short: Unix socket paths are limited to 108 characters. Tests
retain serial output, transcripts and screenshots as evidence. See
[TESTING](docs/TESTING.md) for each test's arguments and what it proves.

## Phases

| Phase | Goal | Status |
| --- | --- | --- |
| 0 | Architecture reset | Done |
| 1 to 2 | Bootable base, graphical session | Done |
| 3 | Axiom Shell MVP | Done |
| 4 | Core apps | Done |
| 5 | System experience | Done |
| 6 | Installable system | Done |
| 7 | Package management and updates | Next |
| 8 | Daily-driver completeness | Planned |
| 9 | Developer edition | Planned |
| 10 | Hardware and stability | Planned |
| 11 | Security layer | Planned |
| 12 | AI-native layer | Planned |
| 13 | Distribution | Planned |

The order changed on 2026-11-06: a complete, installable core distribution comes before
the security and AI layers. Each phase needs retained evidence, and code on a branch is
not an exit criterion. Details and exit criteria: [PHASES](docs/PHASES.md).

## The AI layer is designed, not built

The AI design lives in [docs/ai/](docs/ai/AI_ARCHITECTURE.md): a model only proposes typed
steps, policy re-checks each one, a narrow privileged executor runs one capability with a
one-use grant, and every action is audited and, where possible, recoverable. No AI runtime
exists yet (`AI_ARCHITECTURE.md`: "V1 design, no runtime exists"). Do not describe any of
it as shipped.

## Documentation map

| Area | Entry point |
| --- | --- |
| Product and design | [PRODUCT](docs/PRODUCT.md), [DESIGN](docs/DESIGN.md), [VISION](docs/VISION.md) |
| Architecture and decisions | [ARCHITECTURE](docs/ARCHITECTURE.md), [DECISIONS](docs/DECISIONS.md), [reset impact report](docs/engineering/ARCHITECTURE_RESET_IMPACT.md) |
| Roadmap and scope | [PHASES](docs/PHASES.md), [ROADMAP](docs/ROADMAP.md), [MVP](docs/MVP.md) |
| Development and build | [DEVELOPMENT](docs/DEVELOPMENT.md), [BUILD](docs/BUILD.md), [TESTING](docs/TESTING.md) |
| Desktop contracts | [desktop UX](docs/desktop/DESKTOP_UX.md), [tokens](docs/desktop/DESIGN_SYSTEM.md), [Wayland](docs/desktop/WAYLAND.md) |
| Installer and login | [ADR-020](docs/decisions/020-installable-system.md), [ADR-021](docs/decisions/021-installer-and-developer-hub.md) |
| AI and security | [AI architecture](docs/ai/AI_ARCHITECTURE.md), [security](docs/SECURITY.md), [threat model](docs/security/THREAT_MODEL.md) |
| Evidence | [Phase 1 ISO](docs/engineering/ISO_BUILD.md) |

## Contributing and licence

Read [AGENTS.md](AGENTS.md) and the current phase in [PHASES](docs/PHASES.md) before
changing anything. Define acceptance criteria, make the smallest coherent change, run the
targeted tests, update the canonical docs when behaviour changes, and add an ADR before any
major technology change. There is no public release, and redistribution is not authorized
(see [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md)).
