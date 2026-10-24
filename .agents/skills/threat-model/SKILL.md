---
name: threat-model
description: "Model trust boundaries and misuse before sensitive implementation."
---

# threat-model

## When to use

Use for new privilege, external integration or sensitive data flow. Do not use for cosmetic edits without a changed security boundary.

## Required inputs

Feature diagram, assets, actors, entry points and intended authority.

## Procedure

1. Identify assets, authorized users, hostile actors, untrusted content and trust boundaries.
2. Trace data/control paths including model output, MCP servers, D-Bus, Polkit, file handles and network egress.
3. Write concrete misuse scenarios for injection, exfiltration, confused deputy, race/replay and supply-chain compromise.
4. Compare mitigations with enforceable Linux mechanisms and identify residual risks/assumptions.
5. Define adversarial tests, owners and release blockers with evidence that would falsify the design.

## Validation

A reviewer can map each serious scenario to enforcement, a test and residual risk; unknowns are explicit.

## Failure handling

Block the sensitive path when authority cannot be bounded; propose a smaller experiment instead of asserting safety.

## Project references

- [security/THREAT_MODEL.md](../../../docs/security/THREAT_MODEL.md)
- [security/SECURITY.md](../../../docs/security/SECURITY.md)
