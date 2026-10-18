---
name: arch-pkgbuild
description: "Create and validate Arch PKGBUILDs through their complete package lifecycle."
---

# arch-pkgbuild

## When to use

Use for package creation or dependency changes. Do not use for installing an ordinary application as an end user.

## Required inputs

Upstream source/version, license, architecture, dependencies, package ownership and disposable test guest.

## Procedure

1. Review source origin, checksums/signatures, license and build/install hooks before running arbitrary upstream build code.
2. Define pkgname/pkgver/pkgrel/pkgdesc/arch/url/license, runtime depends and makedepends/checkdepends accurately; use prepare/build/check/package appropriately.
3. Build as an unprivileged user in a clean Arch chroot; never run makepkg as root. Generate .SRCINFO from the final PKGBUILD.
4. Run namcap and inspect archive paths, modes, licenses, RPATH, hooks and installed units. Reject unreviewed remote downloads during package().
5. In a disposable guest test install, upgrade from previous package, uninstall and configuration retention; record dependency and reverse-dependency effects.

## Validation

Clean-chroot build and package lifecycle pass with sources authenticated and no writes outside packaging directories.

## Failure handling

Quarantine suspicious source artifacts; preserve build logs and report missing dependencies instead of installing speculative host packages.

## Project references

- [system/PACKAGING.md](../../../docs/system/PACKAGING.md)
- [engineering/RELEASE.md](../../../docs/engineering/RELEASE.md)
