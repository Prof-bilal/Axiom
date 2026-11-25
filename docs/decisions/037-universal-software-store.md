# ADR 037: Axiom Hub 2.0, a universal software store

Status: Proposed (2026-11-25). Not accepted until the open questions in `research/axiom-hub-universal-store.md` are answered and Stage 1 review is done.
Amends ADR-021 (Developer Hub scope: AUR stays out of v1), ADR-034 (Software Center is proposed to merge into the Hub, Q2).
Research: `research/axiom-hub-universal-store.md` and `research/hub-universal/01..07-*.md`.

## Context
The Hub is a static list of 97 curated apps. Search only filters that list, and installs have known problems: cancel can leave root transactions running, progress parsing rarely matches pacman, and a single-package install is a full system upgrade. The product goal is search once across sources, review, one-click install, launch, with no manual downloads or terminal use.

## Decision
1. Build a new frontend that searches the Arch sync database (local, read-only) and the Flathub AppStream index (cached). Keep pacman, Flatpak and polkit as the real backends. Do not fork a GPL store (`research/hub-universal/06-open-source-comparison.md`).
2. Privileged work stays in `axiom-pkgd` behind polkit. Verbs are fixed argv, input is validated, and installed systems snapshot before any change (ADR-033).
3. Flatpak stays user scope. AppImage and vendor packages come later (ADR-032, ADR-028). AUR and GitHub-only apps are out of the MVP.
4. Sources are matched by AppStream id, then distro id and desktop id, then a curated override file. Never by name alone, and never merged across different publishers.
5. Default source is the official repo; Flathub is used only when the repo has no package or its version is old and the publisher is verified.
6. Trust classes (official repo, verified publisher, community, unverified, suspicious) are shown on every card and review page, with plain-language warnings. Signatures and checksums are described as necessary, not sufficient.
7. Install jobs run as systemd transient units. Cancel is allowed only during download. One pacman transaction at a time, and a job key prevents duplicate installs.
8. Installed-app state comes from the system (`pacman -Qq`, `flatpak list`), not from the catalogue.

## Consequences
- The 97-entry catalogue is removed. The verification badges it carried must be re-derived from the trust classes.
- Single-package installs run a full upgrade unless Q3 changes this. This must be shown to the user.
- Search results depend on the local pacman sync database and a Flathub index download. Both can be stale; the UI shows the last sync time.
- Flathub's public search API is not confirmed. The design uses the AppStream index instead.
- New code adds an index, adapters and a job layer. Each needs unit tests and QEMU evidence before the stage is marked done.

## Not decided here
AUR (own ADR, with PKGBUILD review), AI model store, AppImage, vendor packages, featured list (Q1), Software Center merge (Q2), install policy (Q3), process lifetime (Q4), PackageKit licence (Q5).

## Verification
Per stage: unit tests in CI (`tests/apps`, `tests/installer`), QEMU acceptance on a networked guest with retained evidence, and performance measurements before any claim.
