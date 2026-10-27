# Packaging and updates

Status: V1 contract; package definitions and repository do not exist. Last researched: 2026-10-18.

pacman owns system packages; PKGBUILD defines Axiom packages. Flatpak is optional for user applications; it does not replace OS updates. Snap and automatic AUR installation are outside default scope. Upstream Arch rolling repositories require full upgrades: do not design a UI around partial upgrades or claim that a snapshot makes live package mutation atomic.

**Omarchy-derived upstream (ADR-013, RESEARCH):** the proposed foundation consumes a pinned set of `omacom/omarchy`, `omacom/omarchy-pkgs` and the Omarchy Arch mirror. Axiom must record the exact package versions, mirror identity and upstream revision per build; it must not use the Omarchy package repository as an unreviewed trust root, and it must not let upstream package updates overwrite Axiom-owned files. The update path, migration mechanism and channel behavior are upstream inputs to evaluate, not inherited policy. Calamares/archiso remain legacy research only.

Every package must declare name/version/release, architecture, license, upstream URL, source provenance/checksums, runtime/build/test dependencies and packaging functions. Pin reviewed source revisions, verify upstream signatures when available, and avoid network downloads inside build functions. Separate build-only dependencies and executable install hooks; hooks are privileged code requiring review. No provider keys or machine identifiers in artifacts.

Future workflow on a disposable Arch builder with base-devel, devtools and namcap installed, from a reviewed package directory:

```sh
makepkg --verifysource
makepkg --printsrcinfo
pkgctl build
namcap PKGBUILD
```

Inspect the resulting archive and run namcap on its explicit filename; install, upgrade from the previous release, remove and reinstall inside a VM. Verify permissions, unit lifecycle, schema migrations and configuration preservation. Running an untrusted PKGBUILD executes code; review before any makepkg invocation. Build as an unprivileged account in clean environments.

A package manifest must accompany each ISO: exact versions, source revision, repository database identities, builder versions and artifact hashes. A pinned package set plus recorded inputs is the reproducibility objective; bit-for-bit reproducibility needs independent rebuild evidence.

Signed repository publication, key custody/rotation, revocation, promotion and frozen release inputs are Phase 10 gates. Public Arch signing keys do not authenticate Axiom artifacts. Update capabilities resolve exact packages against trusted configured repositories and show scope/size/reboot/recovery limitations; serialize pacman operations and never bypass its lock.

Flatpak permission review rejects unnecessary home/session-bus/device exposure; portals are preferred. Sources: [PKGBUILD manual](https://man.archlinux.org/man/PKGBUILD.5.en), [Arch devtools](https://github.com/archlinux/devtools), [pkgctl build manual](https://man.archlinux.org/man/pkgctl-build.1.en), [Flatpak sandbox permissions](https://docs.flatpak.org/en/latest/sandbox-permissions.html). See [release](../engineering/RELEASE.md).
