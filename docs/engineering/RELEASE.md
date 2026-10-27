# Release gates and publication

Status: future workflow; no release artifacts, CI build or signing infrastructure exist. Last researched: 2026-10-18.

A release is a tested package set and installation/recovery contract, not an ISO that boots once. GitHub Actions orchestrates unprivileged checks and isolated builds; signing credentials never enter pull-request jobs. Separate immutable build artifacts from publication rights. Use ephemeral release builders, protected promotion and independent review of security-sensitive changes.

**Upstream inputs (ADR-013, RESEARCH):** the foundation is a pinned Omarchy-derived set (`omacom/omarchy`, `omarchy-iso`, `omarchy-pkgs` plus the Quickshell revision). Freeze the exact upstream revision, package versions, mirror identity and license inventory per build; preserve Omarchy's MIT notices, Quickshell's LGPL-3.0 obligations and every third-party asset license ([notices](../../THIRD_PARTY_NOTICES.md)). Do not publish any bundled wallpaper, font, icon or sound whose provenance is unresolved. The release pipeline is inherited as a mechanism to evaluate, not as an approved Axiom process.

Execution order:

1. Freeze source revision, package versions, repository inputs, licenses and known issues; check every required phase exit criterion.
2. Build packages in clean Arch environments; preserve source/checksums, dependency and build metadata. Test install/upgrade/remove.
3. Build ISO from reviewed profile; archive package manifest, builder identity and logs. Independently rebuild and record whether artifacts match.
4. Test UEFI/live desktop, installer to disposable disk, both kernels, offline desktop, permissions, provider failures, audit integrity and accessibility smoke paths.
5. Test upgrade from previous supported release, interrupted updates, low space and root/ESP-consistent recovery. Reject silent partial success.
6. Run adversarial tests and compare benchmark baselines. Document every accepted unresolved issue and its effect; blockers prevent release.
7. Generate SHA-256 checksums and detached signatures through isolated key custody; verify using a clean consumer environment and documented trusted key distribution.
8. Publish signed repository metadata/artifacts and release notes after authorized promotion. Verify downloads and upgrade path from published endpoints; retain rollback inputs and recovery ISO.

Future artifact command after the actual filename is known: `sha256sum path/to/release.iso`; checksum alone does not authenticate origin. Signing-key bootstrap, offline recovery key, rotation/revocation and compromised mirror behavior need a separate reviewed operational plan before public distribution.

Release notes include supported hardware/firmware, exact build/package manifest, upgrade/reboot instructions, measured performance, recovery limits, privacy/provider defaults and known issues. Do not publish fabricated compatibility, completed security review or benchmark numbers. Retention preserves previous supported packages and at least one tested recovery path; restored snapshots must not re-enable revoked trust.

Source: [Arch package format/build metadata](https://man.archlinux.org/man/PKGBUILD.5.en). See [test matrix](TESTING.md), [benchmark evidence](BENCHMARKS.md), [packaging](../system/PACKAGING.md).
