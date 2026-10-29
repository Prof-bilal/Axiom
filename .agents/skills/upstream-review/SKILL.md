---
name: upstream-review
description: "Review a pinned Linux upstream component before adopting it as replaceable infrastructure."
---

# upstream-review

Use when evaluating Linux infrastructure, compositor engines, protocol
implementations or package sources that Axiom may reuse. This is an evidence
workflow, not permission to import a desktop product or copy its UX.

## Required context

Read [architecture](../../../docs/ARCHITECTURE.md), [decisions](../../../docs/DECISIONS.md),
the relevant phase gate and [third-party notices](../../../THIRD_PARTY_NOTICES.md).
Record the exact repository, revision, license, build inputs, exposed APIs,
security assumptions, maintenance status and rollback path.

## Workflow

1. Inspect source, release notes and primary documentation at the pinned
   revision; distinguish observed behavior from upstream claims.
2. Classify each proposed use as infrastructure reuse, adapter, fork or
   product dependency. Reject hidden UX/product coupling.
3. Define the Axiom-owned boundary, compatibility tests, upgrade procedure and
   removal plan before adding a package or source checkout.
4. Update the decision record and license inventory. Preserve notices and do
   not vendor generated artifacts without provenance.
5. Run the smallest boot, protocol, performance and failure checks that can
   falsify the adoption decision. Keep the component optional until its gate
   passes.

## Safety rules

Never execute unreviewed install scripts, weaken Wayland consent, grant a model
authority, or make a temporary bring-up component the Axiom product contract.
If evidence is missing, label the dependency RESEARCH and return a bounded
unsupported result.
