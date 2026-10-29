---
name: omarchy-upstream
description: "Review and classify pinned Omarchy upstream changes before porting them into Axiom."
---

# omarchy-upstream

## When to use

Use when inspecting Omarchy/Quickshell/Hyprland upstream changes, deciding whether to port them, or updating Axiom's pinned foundation. Do not use for unrelated third-party upgrades or for merging upstream blindly.

## Required inputs

Pinned upstream revisions (`omacom/omarchy`, `omarchy-iso`, `omarchy-pkgs`, Quickshell, Hyprland), the Axiom migration report, the license inventory and the affected Axiom contracts.

## Procedure

1. Confirm the pinned revision and the candidate revision; diff them and list changed files, releases, migrations and package versions.
2. Classify each change: security, feature, configuration, packaging, cosmetic or asset.
3. Reject or defer anything that changes product identity, weakens Axiom's security defaults, adds an untrusted asset, or conflicts with ADR decisions; record why.
4. For accepted changes, check Axiom compatibility (shell, policy, recovery, packaging), required license/notice updates, and required tests.
5. Port on the migration branch as a reviewed, attributable change; never auto-merge and never edit upstream files inside Axiom.

## Validation

Record upstream and Axiom revisions, the classification, license/asset impact, tests run and the explicit port/reject decision. A change with unresolved asset licensing or security divergence is not accepted.

## Failure handling

Preserve the failed comparison and the pinned checkout; do not "fix" an upstream failure by editing Axiom's copy of upstream. Escalate genuine upstream defects as a tracked finding.

## Project references

- [migration report](../../../docs/engineering/OMARCHY_MIGRATION.md)
- [third-party notices](../../../THIRD_PARTY_NOTICES.md)
- [phases](../../../docs/PHASES.md)
