---
name: agent-system-api
description: "Add a narrow typed agent capability with authorization and audit contracts."
---

# agent-system-api

## When to use

Use for capability addition or behavior change. Do not use for arbitrary shell passthrough or an API without a user use case.

## Required inputs

Use case, schema, permission class, executor and verification/rollback requirements.

## Procedure

1. Use the smallest existing namespace and define bounded parameters, return/error types and concrete examples.
2. Document validation, privilege, execution path, side effects, audit fields, rollback limits and postcondition verification in the canonical API.
3. Authenticate principal and bind grants to arguments, targets, expiry and request ID; revalidate at execution.
4. Separate untrusted planning from authorized execution; prohibit arbitrary shell and unrestricted sudo.
5. Test malicious model output, permission denial, replay, symlink/path races, partial failure and audit completeness.

## Validation

Contract, policy and adversarial tests pass; verification detects failed effects and rollback availability is truthful.

## Failure handling

Deny unknown schema/capability or expired grants; return explicit partial outcome and recovery instructions rather than silently retry mutation.

## Project references

- [ai/SYSTEM_AGENT_API.md](../../../docs/ai/SYSTEM_AGENT_API.md)
- [security/PERMISSIONS.md](../../../docs/security/PERMISSIONS.md)
- [security/THREAT_MODEL.md](../../../docs/security/THREAT_MODEL.md)
