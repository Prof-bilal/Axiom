# Axiom

Axiom is an experimental AI-native Linux desktop focused on developer
workflows, privacy, secure system agents, recovery and a desktop experience
designed from first principles.

**Status: Phase 3 Axiom Shell MVP (2026-11-01).** Axiom uses standard Linux
infrastructure, but the compositor/session boundary, shell, core applications
and product services are being developed specifically for Axiom. The previous
upstream-derived desktop direction has been removed and is not an active
dependency.

Start with [the product brief](docs/PRODUCT.md), [architecture](docs/ARCHITECTURE.md),
[phase gates](docs/PHASES.md), [design](docs/DESIGN.md) and [development workflow](docs/DEVELOPMENT.md).
The first implementation target is a bootable minimal Axiom graphical session
inside QEMU; no browser mock or themed upstream desktop counts as that result.

## What Axiom reuses and owns

Linux, systemd, udev, device drivers, networking, PipeWire, Mesa, Wayland
protocols, libc, package management and boot technologies remain upstream
infrastructure. Axiom owns the visible desktop workflow: compositor/session
contracts, shell surfaces, core apps, platform services, AI boundaries and
security UX. Axiom does not rewrite mature infrastructure without a measured,
product-specific reason.

## Documentation map

| Area | Entry point |
| --- | --- |
| Product and design | [PRODUCT](docs/PRODUCT.md), [DESIGN](docs/DESIGN.md), [VISION](docs/VISION.md) |
| Architecture and decisions | [ARCHITECTURE](docs/ARCHITECTURE.md), [DECISIONS](docs/DECISIONS.md), [reset impact report](docs/engineering/ARCHITECTURE_RESET_IMPACT.md) |
| Roadmap and scope | [PHASES](docs/PHASES.md), [ROADMAP](docs/ROADMAP.md), [MVP](docs/MVP.md) |
| Development and build | [DEVELOPMENT](docs/DEVELOPMENT.md), [BUILD](docs/BUILD.md), [testing](docs/TESTING.md) |
| Desktop contracts | [desktop UX](docs/desktop/DESKTOP_UX.md), [tokens](docs/desktop/DESIGN_SYSTEM.md), [Wayland](docs/desktop/WAYLAND.md) |
| AI and security | [AI architecture](docs/ai/AI_ARCHITECTURE.md), [security](docs/SECURITY.md), [threat model](docs/security/THREAT_MODEL.md) |
| Evidence | [Phase 1 ISO](docs/engineering/ISO_BUILD.md) |

## Validation

```sh
python3 scripts/validate-repo.py
python3 scripts/test-concepts.py
python3 scripts/check-iso-profile.py
```

The retained `scripts/build-iso.sh` and `tests/qemu-boot.sh` support historical
Phase 1 evidence. A new base-image builder will be added only after Phase 0
contracts and inputs are reviewed. Do not publish a release, alter host disks,
or run privileged operations based on documentation alone.
