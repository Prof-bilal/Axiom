# Architecture

Status: design baseline, not implemented. V1 is a prototype scope label; LATER is intentionally deferred; RESEARCH means no dependency may assume support. See [ADRs](DECISIONS.md), [API contract](ai/SYSTEM_AGENT_API.md) and [security](security/SECURITY.md).

## Platform responsibilities

Axiom comprises Desktop, AI Runtime, Shield (protect machine/user), Sentinel (test developer-built applications) and Flow (resource orchestration/responsiveness). These are separate subsystems, not one daemon. Shield/Sentinel have no dedicated specifications in this checkout; their labels below express conceptual boundaries only. Flow does not authorize agent actions or run tests. [FLOW.md](system/FLOW.md) owns its detailed design; [PERFORMANCE.md](system/PERFORMANCE.md) retains the single profile/target system.

```mermaid
flowchart LR
  AX[Axiom] --> D[Desktop — V1]
  AX --> AI[AI Runtime — V1]
  AX --> SH[Shield — conceptual security boundary]
  AX --> SE[Sentinel — future test integration]
  AX --> FL[Flow — V1 proof / service RESEARCH]
  SE -. explicit worker budgets .-> FL
  AI -. explicit agent budgets .-> FL
  D --> FL
  SH -. authority constraints .-> FL
  FL --> PR[PSI / cgroups / systemd]
  FL -. integration experiments .-> RR[zram / scheduler controls / oomd]
```

## Process architecture

```mermaid
flowchart TD
  User[User] --> UI[Plasma / QML agent UI — V1 user session]
  UI --> A[assistantd — V1 unprivileged]
  A --> R[Provider router — V1 library]
  R --> P[One cloud + Ollama — V1 adapters]
  A --> C[Typed capability request — V1]
  C --> E[Policy engine — V1]
  E --> U[User-session executor — V1]
  E --> B[system-agentd broker — V1 narrow system D-Bus]
  B --> K[Polkit / Linux enforcement — V1]
  K --> S[Existing system services — V1]
  E -. integration decision .-> W[Warden — RESEARCH]
  B --> T[Snapshot coordinator — V1 job/module]
  T --> BS[Btrfs / Snapper — V1]
  E --> AU[Audit events — V1]
  B --> AU
  U --> AU
  A -.-> RT[Deterministic routine engine — LATER module]
  UI -.-> CD[Cross-device layer — LATER]
  UI -.-> MM[Structured activity memory — LATER]
  UI --> FT[Flow telemetry and manual policy — V1]
  FT --> FM[systemd user manager / app cgroups — V1 proof]
  FM --> FK[Kernel resource controllers / PSI]
  FW[Enrolled agents / future Sentinel workers] --> FM
  FT --> FH[Bounded intervention history]
  FH --> UI
  FT -. SHOULD experiment .-> FO[systemd-oomd / freeze compatibility]
```

## Processes and privilege boundaries

Plasma/KWin provides the compositor and existing desktop integration. Shell customizations and QML apps run as the logged-in user. Never move UI into a root process to bypass permissions. The overlay is a client, not the policy authority.

`assistantd` is a proposed per-user process for cancellation, request lifecycle and adapter IO. It has no system privilege; justify its idle cost before making it persistent. Router, planner and routine engine are modules, not separate daemons. Models return proposals; a non-model validator produces bounded typed requests. No plan itself conveys authority.

`system-agentd` is a proposed minimal system broker, preferably activatable, for operations existing services cannot safely expose directly to the caller. Split user actions from privileged handlers; do not make every capability transit a root executor. Every privileged handler authenticates D-Bus sender identity, validates target and authorizes independently of the assistant's claims. Reuse existing service APIs/Polkit when they already provide the required scope. Determine per-handler process isolation in a threat review, rather than requiring the entire broker to be root permanently.

The policy engine performs deterministic classification and request-bound authorization. A trusted confirmation UI shows canonical target, side effects and recovery limitations, separate from model-authored text. Warden remains an evaluated enforcement adapter only: identify repository, revision, Linux behavior and gaps before integration. Linux mechanisms supply defense in depth, not a competing orchestration architecture.

Flow telemetry, deterministic resource policy and Resource Guard form one subsystem outside the AI runtime. Begin on demand; `flowd` persistence is conditional on event/recovery needs and measured overhead. Existing systemd user scopes/services own app lifecycle; do not rewrite their cgroup tree. Session resource presets stay within enrolled same-user groups, effective parent ceilings and [permission classifications](security/PERMISSIONS.md). System swap/oomd policy and rootful containers require separately authorized narrow system integration. Soft weights precede hard boundaries; Flow never runs a normal app-kill loop. Freeze is not memory release. Shield constrains authority and Sentinel declares budgets; neither merges into Flow. No production resource thresholds have been chosen.

## IPC and contracts

Session D-Bus connects user UI and session services. System D-Bus carries the narrow privileged API and upstream service calls. Version interface names and explicit error/result schemas; prohibit arbitrary bus destination/method forwarding. Proposed names are design identifiers pending a project-controlled reverse-DNS namespace. Do not ship fabricated `org.axiom` ownership assumptions.

Unix sockets require a demonstrated need (for example bounded local streaming); document filesystem permissions, peer credentials, framing, limits, cancellation and authorization parity. Do not introduce general RPC infrastructure by default. Model streaming stays in the session process and cannot bypass the capability contract.

## State and audit

Use per-user SQLite for application metadata; FTS5 only for user-visible search requirements. System audit persistence belongs to the privileged boundary with append-only behavior from unprivileged callers. An audit database is not tamper-proof against root. Each action has correlation ID, actor/session, normalized request digest, policy/version, authorization scope/expiry, timestamps, affected resources, execution status, verification and recovery reference. Redact secrets/content and bound retention; record pre-execution intent before mutation and report crash reconciliation states. Audit history remains distinct from future opt-in personal activity memory.

Package/config changes use serialized jobs with preflight, authorization, eligible snapshots, execution, verification and explicit commit/recovery. No claim of atomic rollback across Btrfs, ESP, pacman hooks, firmware, cloud or another device. [Recovery](system/BTRFS_ROLLBACK.md) owns layout and consistency requirements. Audit evidence must survive recovery or explicitly expose a recovery gap.

## Future components and directory boundaries

| Path / component | Status | Responsibility |
| --- | --- | --- |
| `apps/{control-center,launcher,settings,welcome,agent-ui}` | V1 incrementally | Session UI; shared design tokens |
| `shell/{panel,dock,notifications,workspace}` | V1 incrementally | Plasma extensions; KWin remains compositor |
| `services/{assistantd,system-agentd}` | V1 | Session orchestration and narrow privileged execution |
| `services/flowd` | RESEARCH service; V1 on-demand proof | One candidate per-user Rust Flow controller; replaces speculative performanced, no parallel duplicate |
| `services/{connectd,memoryd}` | LATER, process need unproven | Device / activity modules first |
| `security/{policies,warden}` | V1 policies / RESEARCH Warden | Reviewed enforcement configuration |
| `packages`, `iso`, `installer`, `branding`, `tests` | V1 as phases authorize | Packaging, image, installation, identity and evidence |
| Workspace continuation | LATER | Serializable intent, not process/checkpoint migration |

These paths are intended architecture, not empty directories to create now. Dependency direction is UI → session runtime → typed contract → authorized executor → upstream service. No provider-specific type in the capability or policy layer. Desktop and system operations remain usable without AI or network.

**First-party components.** Axiom integrates five sibling projects behind versioned adapters
(ADR-012): Warden (execution enforcement, Phase 7), RepoSpine (bounded code context),
ContextGit (per-child runtime context branches), ModelCheck (model promotion gate) and Morphix
(reversible desktop customization). None is a required dependency of the core desktop. The
single orchestrator spawns bounded child agents; the catalogue, contract and user-authored
children are defined in [agent system](ai/AGENT_SYSTEM.md), and the product-to-subsystem
mapping in [ecosystem](ai/ECOSYSTEM.md).

## Experiments before commitment

Prove UEFI boot + Btrfs recovery including ESP mismatch; Plasma extension packaging/upgrade; per-user/system bus authorization and sender races; request-bound interactive approval; cloud/local adapter conformance; audit crash/recovery; sandbox ABI behavior; and clean-run reproducibility. See [research register](RESEARCH.md). Phase 6 mutation stays disabled until Phase 7 security gates pass, even though API implementation starts earlier.
