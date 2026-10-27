---
name: release-check
description: "Evaluate a distro release against evidence-backed shipping gates."
---

# release-check

## When to use

Use for release candidate readiness review. Do not use for publishing a release without an explicit release task.

## Required inputs

Candidate revision, package/ISO manifests, checksums, test matrix, known issues and signing policy.

## Procedure

1. Verify clean package provenance, pinned builder inputs, dependency licenses and reproducibility claims.
2. Check ISO UEFI boot, Hyprland/Quickshell session, installer storage choices, mainline/LTS boot and offline operation.
3. Require update/upgrade, rollback and recovery evidence plus adversarial permission/audit tests.
4. Compare benchmark distributions with declared thresholds; publish limitations and hardware support matrix.
5. Verify checksums/signatures, documentation, known issues, migration notes and rollback path; keep publishing separately authorized.

## Validation

Every release gate has a traceable artifact and owner; security blockers or missing recovery evidence prevent a release-ready result.

## Failure handling

Return blocked with exact failed gate and recovery task; never fabricate a passing check or upload artifacts as part of a readiness review.

## Project references

- [engineering/RELEASE.md](../../../docs/engineering/RELEASE.md)
- [engineering/TESTING.md](../../../docs/engineering/TESTING.md)
- [engineering/BENCHMARKS.md](../../../docs/engineering/BENCHMARKS.md)
