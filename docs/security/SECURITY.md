# Axiom security architecture

Status: Phase 0 design contract; enforcement implementation is not authorized
until Phase 6. Security applies to the base, compositor/session, shell, apps,
services and AI even when the feature is not yet implemented.

## Invariants

1. AI never receives unrestricted root, sudo or arbitrary shell passthrough.
2. UI and shell code run as the user; privileged code exposes narrow APIs.
3. Every privileged request independently authenticates caller, operation and
   target; missing, expired or invalid authority denies.
4. Secrets stay out of repository files, prompts, telemetry and routine text.
5. Wayland and portal consent are preserved; no hidden input/capture fallback.
6. Core desktop operation works without cloud AI or network access.
7. Every mutation verifies its result and states recovery limits honestly.
8. Models, MCP output, files, web pages and downloaded artifacts are untrusted
   data and cannot grant authority.

## Boundaries

The base system uses standard kernel/systemd/udev/device/network/audio/graphics
interfaces. The compositor/session owns display and input policy, but does not
authorize agent actions. The shell presents trusted controls as unprivileged
code. Apps and platform services receive least-privilege filesystem, network,
secret and subprocess scopes. A future system broker uses versioned D-Bus
interfaces and existing Polkit/service authorization where possible.

The AI runtime may propose a typed capability request. A deterministic policy
layer binds it to caller, target, scope, expiry and audit ID. A Warden adapter
may enforce the approved request after its own Linux bypass matrix passes; it is
never the authority and is not yet a dependency.

## Data and audit

User metadata may use per-user SQLite/FTS5. System mutation audit belongs at the
privileged boundary and records actor/session, capability version, normalized
request digest, authorization, affected resources, verification and recovery
reference. Redact secrets, file contents, full environments and provider
payloads. Interrupted mutations are reconciled, never silently replayed. Local
root can tamper with local logs; do not claim tamper-proof history.

## Required future review

Review app permissions, agent filesystem/network scopes, secret handling,
subprocesses, portals, lock-screen behavior, sandbox ABI, audit failure,
symlink/TOCTOU/path traversal, caller races, denial/replay and recovery before
enabling mutation. See [permissions](PERMISSIONS.md), [threat model](THREAT_MODEL.md),
[sandboxing](SANDBOXING.md) and [Warden integration](WARDEN_INTEGRATION.md).
