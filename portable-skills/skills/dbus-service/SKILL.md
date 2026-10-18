---
name: dbus-service
description: "Design and test versioned D-Bus service contracts and authorization."
---

# dbus-service

## When to use

Use for D-Bus interfaces, methods, signals or policy changes. Do not use for introducing a generic RPC layer without a use case.

## Required inputs

Bus choice, interface name/version, methods/signals, callers and privilege policy.

## Procedure

1. Choose session versus system bus deliberately; use owned well-known/interface/object names with documented major-version strategy.
2. Specify typed method inputs/results, stable namespaced errors, signal ordering, bounds and cancellation semantics.
3. Authenticate the actual D-Bus sender through bus credentials; never trust a caller-supplied UID or agent label.
4. Authorize each operation and bind asynchronous Polkit decisions to the original caller and exact request.
5. Test introspection compatibility, unauthorized senders, disconnect during authorization, malformed input and signal/data leakage.

## Validation

Contract tests cover success, denial, error and reconnect; bus policy restricts exposure without pretending bus reachability grants operation authority.

## Failure handling

Return documented errors and invalidate stale authorization; avoid broad allow-all bus policy as a workaround.

## Project references

- [ai/SYSTEM_AGENT_API.md](../../../docs/ai/SYSTEM_AGENT_API.md)
- [security/PERMISSIONS.md](../../../docs/security/PERMISSIONS.md)
