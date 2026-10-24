---
name: systemd-service
description: "Create and validate systemd units with tested sandbox restrictions."
---

# systemd-service

## When to use

Use for unit creation or hardening. Do not use for replacing systemd or hiding failures with repeated restarts.

## Required inputs

Service lifecycle, required paths/devices/network, dependencies and secret sources.

## Procedure

1. Choose user/system scope, activation and Type based on actual lifecycle and readiness; order dependencies only when needed.
2. Define restart limits, timeout, shutdown and resource budgets; avoid unnecessary network-online dependencies.
3. Use a dedicated user or DynamicUser when compatible and explicitly scoped state/runtime directories.
4. Apply NoNewPrivileges, capabilities reduction, filesystem restrictions, address-family limits and compatible syscall restrictions; test each requirement.
5. Supply secrets through credentials with documented rotation; collect redacted journal diagnostics.

## Validation

Use systemd-analyze verify and security as diagnostics; test actual startup, failure, stop and restart inside target guest. A security score is not proof.

## Failure handling

Identify the denied resource and narrow the exception; do not remove sandboxing wholesale or copy secrets into Environment.

## Project references

- [system/SYSTEMD.md](../../../docs/system/SYSTEMD.md)
- [security/SANDBOXING.md](../../../docs/security/SANDBOXING.md)
