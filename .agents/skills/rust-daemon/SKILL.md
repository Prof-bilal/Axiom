---
name: rust-daemon
description: "Create bounded Rust services with explicit lifecycle and privilege boundaries."
---

# rust-daemon

## When to use

Use for new daemon or substantial daemon lifecycle changes. Do not use for small CLI work that does not justify a persistent process.

## Required inputs

Service purpose, bus scope, data ownership, concurrency budget and failure policy.

## Procedure

1. Justify persistence; prefer an existing service or activation over another always-running daemon.
2. Separate protocol/domain logic from privileged integration; define typed configuration and error types.
3. Use structured tracing with redaction, cancellation, bounded queues/timeouts and explicit shutdown/signals.
4. Minimize privileges and filesystem/network scope; use systemd credentials or the chosen secret store instead of repository secrets.
5. Test restart, malformed configuration, dependency absence, cancellation, concurrent requests and resource exhaustion.

## Validation

Run fmt/check/clippy and relevant unit/integration tests once a Rust workspace exists; measure idle and loaded resources.

## Failure handling

Fail closed on invalid security configuration; preserve redacted diagnostics and prevent restart storms.

## Project references

- [system/SYSTEMD.md](../../../docs/system/SYSTEMD.md)
- [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
