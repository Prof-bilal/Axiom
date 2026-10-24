# Foundation validation record

Date: 2026-10-18. Scope: documentation, portable skill authoring, thin adapters and deterministic foundation helpers. No Linux distro implementation or build was performed.

| Check | Result | Limits |
| --- | --- | --- |
| Required documents, local Markdown links, skill inventory/frontmatter, adapter inventory/role references | PASS: `python3 -E scripts/validate-repo.py`, zero errors | Static checks do not establish semantic correctness or runtime discovery |
| Validator negative cases | PASS: detects a broken local link and absence of both skill trees in temporary fixtures | Not a full Markdown/YAML parser |
| Skill installation into an isolated temporary checkout | PASS: all 18 copied; second invocation idempotent | Canonical repository mount remains read-only |
| Conflicting existing skill | PASS: installer rejected it and preserved user edit | Reconcile intentional changes manually |
| Symlink destination | PASS: installer refused destination | Helper is local repository tooling, not a hardened privileged installer |
| Canonical `.agents/skills` installation | BLOCKED: actual invocation returned read-only filesystem | Durable authored contents in `portable-skills/skills`; no active discovery claimed |
| Cross-area consistency review | Reviewed AI/security, phases, tools and recovery contracts; fixed early Plasma gate and explicit snapshot authorization | Independent implementation security/QA still required in later phases |
| Git status/diff | UNAVAILABLE: exposed `.git` contains no usable metadata | No commit created; use a normal checkout for change review |
| Installed Codex/OpenCode/Command Code/Freebuff discovery | NOT RUN | Requires declared client versions and writable canonical skill path |
| ISO/package/boot/installer/update/recovery tests | NOT RUN | No implementation exists; future disposable VM gates |
| Benchmarks/hardware tests | NOT YET MEASURED | Targets and measurement plans are not results |

The authoring environment has inherited invalid PYTHONHOME/PYTHONPATH values. `python3 -E` ignores those variables and was used for successful helper checks; a clean normal Python environment can use the documented plain `python3` commands. No host environment or service settings were changed.

Rerun static validation after edits. In a writable checkout run `python3 scripts/install-skills.py`, verify discovered paths in each installed client, then move canonical maintenance to `.agents/skills` and remove staging only after its content is confirmed. Do not interpret passing this foundation check as completion of Phase 1 or as permission to start distro implementation.

## Revalidation 2026-10-24

Triggered by an explicit request to validate the foundation before building. Environment: writable checkout (the read-only `.agents` mount of 2026-10-18 is absent here), Arch-based host, Python 3.15.1 via `python3 -E`, `/dev/kvm` present.

| Check | Result | Limits |
| --- | --- | --- |
| `python3 scripts/validate-repo.py` | PASS: zero errors | Static only |
| `python3 scripts/test-concepts.py` | PASS: 12/12, 0 skipped | Local primitives; SQLite rollback is not Btrfs/OS rollback and peer credentials are not an authorization engine |
| `python3 scripts/install-skills.py` | PASS: 18 skills installed to canonical `.agents/skills`; second run idempotent | Supersedes the earlier BLOCKED row; the read-only constraint did not apply in this checkout |
| E05 Warden upstream identification | PASS (identification only): [Prof-bilal/Warden](https://github.com/Prof-bilal/Warden), MIT, Go, `main`@`cd5e8bf2717bd0003194aba8beecd01f33704af9`, release v0.1.17; Linux backend inspected statically | Our runtime namespace/seccomp/Landlock/network bypass tests on mainline/LTS are NOT RUN |
| E10 tool discovery smoke | PARTIAL: codex 0.163.0, opencode 2.1.3, commandcode 1.88.0 installed; canonical skills present; adapter counts valid (11 opencode, 6 commandcode) each referencing `docs/SUBAGENTS.md` | freebuff not installed; per-client runtime discovery and permission smoke tests not executed |
| `python3 scripts/readiness-audit.py` | BLOCKED: missing `qemu-system-x86_64`/`qemu-img`/`mkarchiso`; E01–E20 runtime evidence absent | See note below |

`readiness-audit.py` requires `runtime_experiments_E01_E20 == "COMPLETE"`, but E01/E02/E03/E09/E12 require an implementation that Phase 0 does not authorize. The gate therefore cannot pass in Phase 0: it gates progress into Phase 1, not Phase 0 exit, which [PHASES](../PHASES.md) defines. No experiment was recorded complete without a run.
