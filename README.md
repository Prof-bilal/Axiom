# Axiom

The Linux desktop built for the AI-agent era: a cohesive, privacy-conscious environment for developers, with structured automation, visible permissions and practical recovery.

**Status: Phase 2 foundation POC and the Phase 3 Axiom Shell implementation are in progress. The Omarchy-derived VM boots with Hyprland/Quickshell and an Axiom theme; the first Axiom shell surfaces run in the test VM ([Phase 2 evidence](docs/engineering/PHASE2_EVIDENCE.md), [Phase 3 evidence](docs/engineering/PHASE3_EVIDENCE.md)). No installer, release or full Phase 2/3 exit is claimed yet.**

Start with [AGENTS.md](AGENTS.md), [vision](docs/VISION.md), [MVP](docs/MVP.md), [architecture](docs/ARCHITECTURE.md) and [phase gates](docs/PHASES.md). Durable knowledge belongs in this repository; coding tools are replaceable.

## Working here

1. Read the current phase and relevant contracts before changing files.
2. Use [specialist roles](docs/SUBAGENTS.md), [agent workflow](docs/AGENT_WORKFLOW.md) and the relevant portable skill.
3. Define acceptance criteria, make one coherent change, validate failures as well as success, and record evidence.
4. Propose major architectural changes through [ADRs](docs/DECISIONS.md).

Omarchy is the proposed upstream infrastructure, not the product: Axiom owns identity, shell UX, AI runtime, Shield, Sentinel, Flow, system APIs and recovery. Upstream revisions are pinned; changes are classified and ported deliberately, never auto-merged.

## Documentation map

| Area | Entry points |
| --- | --- |
| Migration | [Omarchy migration report](docs/engineering/OMARCHY_MIGRATION.md), [third-party notices](THIRD_PARTY_NOTICES.md) |
| Product | [PRD](docs/PRD.md), [scope](docs/MVP.md), [roadmap](docs/ROADMAP.md) |
| Engineering | [stack](docs/TECH_STACK.md), [research](docs/RESEARCH.md), [testing](docs/engineering/TESTING.md), [benchmarks](docs/engineering/BENCHMARKS.md), [dev environments](docs/engineering/DEV_ENVIRONMENTS.md), [ecosystem plan](docs/engineering/ECOSYSTEM_PLAN.md) |
| Desktop | [UX](docs/desktop/DESKTOP_UX.md), [tokens](docs/desktop/DESIGN_SYSTEM.md), [Wayland](docs/desktop/WAYLAND.md), [Axiom Shell](shell/README.md) |
| AI | [runtime](docs/ai/AI_ARCHITECTURE.md), [agent system](docs/ai/AGENT_SYSTEM.md), [capability contract](docs/ai/SYSTEM_AGENT_API.md), [routing](docs/ai/MODEL_ROUTER.md), [ecosystem](docs/ai/ECOSYSTEM.md) |
| Security | [invariants](docs/security/SECURITY.md), [threat model](docs/security/THREAT_MODEL.md), [permissions](docs/security/PERMISSIONS.md), [sandboxing](docs/security/SANDBOXING.md), [Warden integration](docs/security/WARDEN_INTEGRATION.md) |
| System | [packaging](docs/system/PACKAGING.md), [recovery](docs/system/BTRFS_ROLLBACK.md), [services](docs/system/SYSTEMD.md), [performance](docs/system/PERFORMANCE.md), [Flow](docs/system/FLOW.md) |
| Delivery | [ISO](docs/engineering/ISO_BUILD.md), [installer](docs/engineering/INSTALLER.md), [install checklist](docs/engineering/INSTALL_CHECKLIST.md), [release](docs/engineering/RELEASE.md) |
| Future | [connectivity](docs/connect/CONNECT.md), [routines](docs/ai/ROUTINES.md), [MCP](docs/ai/MCP.md) |

## Validation

Run the foundation checks with Python 3:

```sh
python3 scripts/validate-repo.py
python3 scripts/check-iso-profile.py
python3 scripts/test-concepts.py
```

Phase 1 also produced `sudo scripts/build-iso.sh` and `tests/qemu-boot.sh`; both target the legacy archiso profile. Migration work adds no privileged runner.

Do not create implementation directories until there is reviewed implementation work for them. Contributions do not authorize publishing a release, changing a machine's disks, or executing privileged operations. Project licensing and redistribution/trademark review must be resolved before distribution; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). No license grant is inferred from this documentation.
