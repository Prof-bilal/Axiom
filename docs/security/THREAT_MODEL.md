# Threat model

Status: initial design; refresh per feature. Last verified: 2026-10-18.

## Assets, actors and boundaries

Assets: user files and secrets; account/device identity; provider keys; boot integrity; package trust; authorizations; trustworthy audit and recovery data. Actors: legitimate user, remote provider, local model, untrusted MCP server, compromised application, malicious paired device, hostile downloaded content, malicious package/build dependency, and local attacker. Root compromise and hostile firmware exceed agent isolation guarantees; document this limitation rather than claiming containment.

Boundaries: UI→runtime; provider/MCP→planner; planner→policy; session bus→system bus; executor→filesystem/package manager; device→desktop; installed system→recovery environment. Each boundary needs authenticated identity, bounded schema, resource scope, cancellation and audit handling.

| Misuse | Required mitigation | Adversarial evidence |
|---|---|---|
| Prompt injection in file/tool/model output | Data cannot alter policy; tools remain denied without grants | Document instructs exfiltration; no network/send action follows |
| Malicious MCP server or model output | Untrusted schema/results; tool allowlist; sandbox; no ambient credentials | Oversized output, renamed tool and tool-list changes denied |
| Compromised local app / D-Bus abuse | Peer credentials, per-method authorization, narrow interfaces | Invoke executor directly without assistant; denied |
| Polkit abuse / confused deputy | Action-specific check bound to original peer and exact plan | Reuse approval for another UID/resource; denied |
| Shell injection | Typed arguments, fixed executables, no shell evaluation | Semicolons, newlines, option injection never execute commands |
| Path traversal / symlink / TOCTOU | Descriptor-relative traversal, constrained roots, no-follow semantics, identity recheck | Rename/symlink swaps during authorization fail safely |
| Secret or network exfiltration | Local-only scopes, explicit destination permission, redaction, egress restrictions | Read key via tool and upload via provider both blocked |
| Privilege escalation / sandbox escape | Minimal privileged API, no inherited privileged FDs, no unnecessary capabilities | Child process and descriptor escape attempts fail |
| Insecure temporary files | Private runtime directories, atomic exclusive creation, correct owner/mode | Pre-created symlink and concurrent collision cannot redirect writes |
| Supply-chain compromise | Signed packages, reviewed PKGBUILDs, pinned source provenance and clean builds | Invalid signature and substituted source rejected |
| Rollback bypass | Snapshot coverage, root/boot/package consistency checks, independent recovery boot | Power loss and excluded-subvolume writes reported accurately |
| Malicious routine | Versioned deterministic graph, bounded scopes, reauthorization on edit/import | Hidden sends, trigger flood, recursive routine and stale grants rejected |
| Audit loss / disk full | Durable pre-mutation journal; uncertainty reconciliation | Journal write failure prevents mutation; restart does not replay |

## Residual risk and experiments

Valid user approval can still authorize harm; previews must explain irreversible effects. Kernel flaws can defeat sandboxing. Providers can retain intentionally submitted data under their policies. Snapshots share the storage device and are not backups. Permissions cannot undo a remote send. Prototype authorization races, compromised session-bus peers and power-loss rollback before exposing real host mutations. Maintain per-feature evidence in review artifacts and [testing](../engineering/TESTING.md).

Sources: [MCP specification](https://modelcontextprotocol.io/specification/2026-07-28), [Landlock](https://docs.kernel.org/userspace-api/landlock.html), [seccomp](https://docs.kernel.org/userspace-api/seccomp_filter.html).

## Flow-specific trust and availability risks

Assets: unsaved work, essential interactive progress, workload identity/budgets, bounded resource history and user overrides. Entry points: app/focus/activity hints, user-session D-Bus, unit events, stored rules and telemetry. A forged “foreground” label or stale/reused unit must not authorize privileged priority/protection changes. Compromised agents must remain beneath their real parent budget; quotas are resource bounds, not replacements for file/network security.

Misuse tests: cross-user unit requests; scope/parent substitution; cgroup path traversal and symlink races in any delegated reclaim worker; unit disappearance/recreation; forged activity hints; invalid/huge budgets; concurrent rule writers; starvation/lock inversion; repeated reclaim; malicious history flood; frozen controller/recovery UI; log exhaustion and stale freeze ledger after restart. Fail closed on new unsafe interventions, retain manual recovery and only restore owned settings. No broad Docker socket or Polkit access to simplify grouping. Resource history excludes app contents. Runtime resource state is not recovered by a Btrfs snapshot. See [Flow failure contract](../system/FLOW.md) and [Flow tests](../engineering/TESTING.md).
