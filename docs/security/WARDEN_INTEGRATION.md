# Warden integration: Axiom's execution-enforcement layer

Status: design spec — **not implemented**. Shapes a first-party project; see
[ecosystem](../ai/ECOSYSTEM.md) and the [sandboxing gate](SANDBOXING.md). Warden was re-verified
on 2026-10-27 against `main` `f7c9793167398c86a61148c746cb4d934be11727`; the earlier `cd5e8bf`
reference is the `axiom/integration` branch tip, not `main` or `v0.1.17`, and is corrected here.
Last updated: 2026-10-27.

Warden today is a CLI that sandboxes one MCP server from a hand-written policy. Axiom needs it
to be **the layer every agent and tool execution passes through**, enforcing a policy derived
from an *approved typed request* rather than from YAML a human wrote. This is the concrete
answer to the user's question "is this AI system actually safe?" — not a claim, but a visible
enforcement path.

## Current Warden shape (verified from the clone)

Go module `warden-starter/warden`:

| Path | Role |
| --- | --- |
| `cmd/warden` | CLI entry (`run`, `trace`, `init`, `doctor`, `logs`, `gateway`, `mcp`) |
| `internal/policy` | `policy.go`, `grants.go`, `starter.go` — YAML policy model, grant sets, and `init`-style starter generation from a trace |
| `internal/sandbox` | `backend.go`, `approval.go`, `run_linux.go`, and `linux/ darwin/ windows/ docker/` backends |
| `internal/audit` | JSONL decision log |
| `internal/approve`, `gateway`, `mcpproxy`, `mcpbridge`, `mcpserver`, `envfilter`, `proxy`, `packs`, `attestation` | Approval prompt, gateway registry, MCP filtering, env filtering, egress proxy, packs, attestation |

Behaviour (from the same source inspection): Linux uses `bubblewrap` namespaces plus
`setpriv --nnp`, a hostname allowlist checked before DNS, deny-by-default bind mounts (`ENOENT`),
env allowlisting, wall-clock/memory limits, `strace`-based auditing (required; launch refuses
without it), and fail-closed refusal when no backend is available. There is **no seccomp filter,
no Landlock use and no typed programmatic interface**. Upstream states it is **not hardened
against a determined local attacker**. The bypass matrix here is **NOT RUN**.

## What must change (the shaping)

1. **A programmatic interface, not just a CLI.** Axiom's executor must invoke Warden as a
   library/package (and optionally a short-lived service) instead of shelling out and parsing
   text. Keep the CLI for humans and CI. Proposed entry point: an `Execute`-style call taking a
   request envelope and returning a structured result (see sketch).
2. **Policy derived from the approved request.** Today policy comes from YAML (`internal/policy`)
   or from `init`/trace starter generation. Axiom needs a **request → policy builder**: the
   validated capability, its resolved targets (filesystem read/write roots, network hosts, env
   names, limits) and the one-use grant hash become the grant set. **The model never supplies
   policy text**; a plan the user approved does.
3. **Audit correlation.** `internal/audit` must accept and emit Axiom's `request_id` and
   `audit_id` so an enforcement decision is attributable to a user-approved request, and must
   expose blocked attempts in machine-readable form for the activity view.
4. **Permission-class mapping.** Axiom's classes ([permissions](PERMISSIONS.md)) map onto grant
   shapes rather than being re-invented:

   | Axiom class | Warden grant shape |
   | --- | --- |
   | OBSERVE | no filesystem write, no network, read-only metadata roots; usually no sandbox needed |
   | NORMAL | exact read/write roots + allowlisted hosts for the enrolled workspace; short-lived |
   | SENSITIVE | as NORMAL plus explicit env allowlist and tighter limits; per-request grant |
   | CRITICAL | *not delegated to Warden as an approval*; the root operation runs through the privileged broker, which may still be sandboxed |

5. **Preserve fail-closed.** If no backend can be applied, the execution is refused. No
   unsandboxed fallback, ever — this is the property the security narrative rests on.
6. **Linux-first for Axiom.** The `linux` (bubblewrap) backend is the Axiom target; the
   `darwin`/`windows`/`docker` backends stay in Warden's product scope but are not an Axiom gate.

## Interface sketch (PROPOSED — not implemented, no code exists)

Language-neutral; a real schema and a Go type must be authored in Warden before use.

```
Envelope  = { request_id, audit_id, capability, class,
              targets: { fs_read[], fs_write[], net_hosts[], env_names[] },
              command[], limits: { wall_s, memory_mb }, grant_hash }
Result    = { status: ok|denied|refused|failed, exit_code,
              audit_ref, blocked[], sandbox_backend, detail }
```

`refused` is the fail-closed outcome (no backend). `denied` is policy refusal. Axiom treats
`ok` as *executed*, never as *authorized* — authorization already happened upstream.

## What must not change

- **No authorization in Warden.** It enforces a decision made by Axiom's policy engine; it must
  not learn to decide. A model can never make Warden allow something policy denied.
- **No ambient host access.** No home, D-Bus, SSH/GPG agent or provider key by default.
- **No arbitrary shell from model output.** Warden runs an already-approved command line.
- **No silent privilege escalation.** The `windows` backend's elevation requirement is not a
  model for Axiom.

## Evidence required before reliance

Per [testing](../engineering/TESTING.md); experiments E05/E22:

1. Bypass matrix on mainline **and** LTS kernels — namespace, seccomp, Landlock, network egress,
   descriptor leak, cancellation. **NOT RUN.**
2. Policy-derivation tests: a model-supplied policy or grant cannot widen an approved request.
3. Audit-correlation test: every execution carries the correct request/audit IDs; blocked
   attempts appear in the activity view.
4. Fail-closed proof: with the backend removed, execution is refused (not run unsandboxed).

Until 1–4 pass, Warden is RESEARCH and the [sandboxing gate](SANDBOXING.md) stands.

## Where it lands

Axiom Phase 7 (permission enforcement and auditing). The parent/child design
([agent system](../ai/AGENT_SYSTEM.md)) routes child tool execution through this layer.
