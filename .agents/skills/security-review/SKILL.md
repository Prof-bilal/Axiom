---
name: security-review
description: "Adversarially review sensitive changes for exploitable trust-boundary failures."
---

# security-review

## When to use

Use for independent security review. Do not use for automatically approving a design or ordinary formatting review.

## Required inputs

Diff, threat model, contracts, deployment policy and test evidence.

## Procedure

1. Trace attacker-controlled bytes and caller identity to privileged effects and secret/network sinks.
2. Check shell injection, path traversal, symlinks, TOCTOU, temporary files, file descriptor lifetime and capability leakage.
3. Review D-Bus exposure, Polkit subject binding, authorization bypass/replay, confused deputy and sandbox escape.
4. Check logging, provider/MCP payloads, network exfiltration, routine grants, rollback bypass and dependency provenance.
5. Attempt bounded reproductions in disposable environments; report severity, exploit preconditions, file references and focused fixes.

## Validation

Findings distinguish verified exploit, plausible risk and missing evidence; retest remediation and denial paths independently.

## Failure handling

Do not approve based on compilation or sandbox branding; explicitly mark unreviewed paths and unresolved release blockers.

## Project references

- [security/THREAT_MODEL.md](../../../docs/security/THREAT_MODEL.md)
- [security/PERMISSIONS.md](../../../docs/security/PERMISSIONS.md)
- [security/SANDBOXING.md](../../../docs/security/SANDBOXING.md)
