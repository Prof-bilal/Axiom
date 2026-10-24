---
name: warden-policy
description: "Evaluate and author Warden integration only against verified implementation behavior."
---

# warden-policy

## When to use

Use for Warden policy or enforcement evaluation. Do not use for assuming that an unidentified Warden project provides OS authorization.

## Required inputs

Exact upstream repository, pinned revision/license, platform, enforcement claims and required policy.

## Procedure

1. Resolve which Warden implementation is intended; inspect code, tests, maintenance and supported Linux behavior before selecting it.
2. Build a claim/evidence matrix covering filesystem/network/process scope, identity, enforcement mechanism, bypasses and failure mode.
3. Compare required guarantees with Linux primitives already used; avoid an unrelated second sandbox with conflicting policy.
4. Prototype positive/negative enforcement, unsupported-kernel handling, child process escape and fail-closed behavior in a disposable guest.
5. Document dependencies, residual gaps, integration boundaries and acceptance decision in research/ADR records.

## Validation

No Warden dependency is accepted until identity, license, supported features and adversarial results are recorded.

## Failure handling

Keep Warden RESEARCH and block reliance on it; use reviewed explicit Linux controls for any separately authorized prototype.

## Project references

- [security/SANDBOXING.md](../../../docs/security/SANDBOXING.md)
- [RESEARCH.md](../../../docs/RESEARCH.md)
- [DECISIONS.md](../../../docs/DECISIONS.md)
