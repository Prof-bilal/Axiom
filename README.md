# Axiom

The Linux desktop built for the AI-agent era: a cohesive, privacy-conscious environment for developers, with structured automation, visible permissions and practical recovery.

**Status: repository foundation / Phase 1. The reviewed archiso profile, build script and QEMU boot harness exist; no desktop, installer or daemon is implemented yet.** Architecture choices are project decisions, not compatibility or performance claims. No release is available.

Start with [AGENTS.md](AGENTS.md), [vision](docs/VISION.md), [MVP](docs/MVP.md), [architecture](docs/ARCHITECTURE.md) and [phase gates](docs/PHASES.md). Durable knowledge belongs in this repository; coding tools are replaceable.

## Working here

1. Read the current phase and relevant contracts before changing files.
2. Use [specialist roles](docs/SUBAGENTS.md), [agent workflow](docs/AGENT_WORKFLOW.md) and the relevant portable skill.
3. Define acceptance criteria, make one coherent change, validate failures as well as success, and record evidence.
4. Propose major architectural changes through [ADRs](docs/DECISIONS.md).

See the [validation record](docs/engineering/FOUNDATION_VALIDATION.md) for completed checks and environment limitations. Run the foundation checks with Python 3:

```sh
python3 scripts/validate-repo.py
```

Phase 1 adds `python3 scripts/check-iso-profile.py` (static profile checks), `sudo scripts/build-iso.sh` (reproducible archiso build with evidence capture) and `tests/qemu-boot.sh` (UEFI boot harness).

Skills target `.agents/skills/`. This session's environment mounts `.agents` read-only, so authored skills are durably staged in `portable-skills/`. After that restriction is removed, run `python3 scripts/install-skills.py` and validate again. The staging directory is not claimed to be automatically discovered by any tool.

## Documentation map

| Area | Entry points |
| --- | --- |
| Product | [PRD](docs/PRD.md), [scope](docs/MVP.md), [roadmap](docs/ROADMAP.md) |
| Engineering | [stack](docs/TECH_STACK.md), [research](docs/RESEARCH.md), [testing](docs/engineering/TESTING.md), [benchmarks](docs/engineering/BENCHMARKS.md), [dev environments](docs/engineering/DEV_ENVIRONMENTS.md), [ecosystem plan](docs/engineering/ECOSYSTEM_PLAN.md) |
| Desktop | [UX](docs/desktop/DESKTOP_UX.md), [tokens](docs/desktop/DESIGN_SYSTEM.md), [Wayland](docs/desktop/WAYLAND.md) |
| AI | [runtime](docs/ai/AI_ARCHITECTURE.md), [agent system](docs/ai/AGENT_SYSTEM.md), [capability contract](docs/ai/SYSTEM_AGENT_API.md), [routing](docs/ai/MODEL_ROUTER.md), [ecosystem](docs/ai/ECOSYSTEM.md) |
| Security | [invariants](docs/security/SECURITY.md), [threat model](docs/security/THREAT_MODEL.md), [permissions](docs/security/PERMISSIONS.md), [sandboxing](docs/security/SANDBOXING.md), [Warden integration](docs/security/WARDEN_INTEGRATION.md) |
| System | [packaging](docs/system/PACKAGING.md), [recovery](docs/system/BTRFS_ROLLBACK.md), [services](docs/system/SYSTEMD.md), [performance](docs/system/PERFORMANCE.md), [Flow](docs/system/FLOW.md) |
| Delivery | [ISO](docs/engineering/ISO_BUILD.md), [installer](docs/engineering/INSTALLER.md), [release](docs/engineering/RELEASE.md) |
| Future | [connectivity](docs/connect/CONNECT.md), [routines](docs/ai/ROUTINES.md), [MCP](docs/ai/MCP.md) |

Do not create implementation directories until there is reviewed implementation work for them. Contributions do not authorize publishing a release, changing a machine's disks, or executing privileged operations. Project licensing and redistribution/trademark review must be resolved before distribution; no license grant is inferred from this documentation.
