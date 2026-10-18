# Deterministic routines

Status: LATER, after typed API, authorization, audit and recovery gates.

Natural language may generate a routine draft once. Execution uses a versioned declarative graph of approved capabilities, bounded arguments, dependencies, deadlines and failure policy. No embedded shell, arbitrary JavaScript, dynamic tool name or model-generated approval. A work-start routine can open a saved workspace and application; container orchestration waits for a reviewed capability rather than shell escape hatches.

Required record: routine ID/version, owner, readable description, trigger, graph, capability versions, resource scopes, expected external destinations, permission requirements, concurrency policy and audit retention. Editing/importing invalidates grants and requires review. Imports are untrusted even when shared by a paired device. Secrets are references to approved secret-store entries and never exported routine data.

Login, startup, battery, charging, Wi-Fi, time, app/workspace and device triggers remain future candidates. Debounce events, limit frequency and duration, serialize incompatible resource changes and reject recursion. Wi-Fi names and device identifiers are data, not proof of trust. A background trigger cannot answer a sensitive prompt; pause pending user authorization or fail. CRITICAL steps always require fresh confirmation. OBSERVE and NORMAL grants may be scoped and revocable.

On failure, stop dependent steps, record partial completion and offer only supported compensating actions. Never describe remote sends or arbitrary app state as reversible. Reconcile interrupted executions without replaying uncertain actions. LLM reasoning is an explicit optional step with upload consent and budget, not part of every trigger.

Acceptance tests: malicious imported graphs, hidden external actions, cycles, trigger storms, revoked/expired grants, capability upgrades, session lock, partial failure, daemon restart and cancellation. Display each step and outcome in the same [activity architecture](AI_ARCHITECTURE.md). See [permissions](../security/PERMISSIONS.md) and [threat model](../security/THREAT_MODEL.md).
