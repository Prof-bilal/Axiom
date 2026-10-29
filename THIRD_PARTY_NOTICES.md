# Third-party notices and license inventory

Status: **incomplete — redistribution is not authorized.** This file begins the inventory
required by the [release gate](docs/engineering/RELEASE.md). Axiom has no root `LICENSE`, and
project licensing/trademark review is unresolved (see [README](README.md)). Nothing here grants
a license, and listing a component here does not complete the release inventory.

Recorded 2026-10-27 from repository and release metadata. Verify every item against the actual
installed artifact before any distribution.

## Upstream infrastructure (research / not a current product dependency)

The old Omarchy foundation experiment is archived. These entries are retained
for provenance only; no current Axiom image is authorized to ship them as a
product/runtime dependency. Current reuse decisions are made per component
under [ARCHITECTURE](docs/ARCHITECTURE.md) and [decision 001](docs/decisions/001-remove-omarchy.md).

| Component | Pinned input | License | Obligation / note |
| --- | --- | --- | --- |
| Omarchy | `omacom/omarchy` tag `v4.0.6` `237f1b40` (archived experiment) | MIT | Historical notice only; not an active Axiom input |
| Omarchy ISO tooling | `omacom/omarchy-iso` `main` `3c36557f` (archived experiment) | MIT | Historical notice only; not an active Axiom input |
| Omarchy packages | `omacom/omarchy-pkgs` (archived experiment) | MIT (repository metadata) | Verify only if a future decision reopens a component |
| Hyprland | `hyprwm/Hyprland` (historical evaluation) | BSD-3-Clause | Not an Axiom product dependency; retain notice if a temporary harness uses it |
| Quickshell | `quickshell-mirror/quickshell` (historical evaluation) | **LGPL-3.0-only** | Not an Axiom product dependency; LGPL obligations apply only if deliberately shipped |
| SDDM (greeter) | Arch package (pin at build) | GPL-2.0-or-later (verify) | Preserve notice; distribution obligations |
| Plymouth | Arch package (pin at build) | GPL-2.0-or-later (verify) | Preserve notice |
| Btrfs / Snapper | Arch/SUSE packages | GPL-2.0 | Preserve notices |

## First-party sibling projects (not bundled by default)

| Component | Repository | Revision verified 2026-10-27 | License |
| --- | --- | --- | --- |
| Warden | `Prof-bilal/Warden` | `main` `f7c97931` | MIT |
| RepoSpine | `Prof-bilal/RepoSpine` | `main` `9ea06ec3` | MIT |
| ContextGit | `Prof-bilal/ContextGit` | `main` `8acd4e7d` | Apache-2.0 |
| ModelCheck | `Prof-bilal/ModelChecker` | `main` `eddcf746` | **No LICENSE file**; `cli/package.json` declares MIT — must be fixed before shipping |
| Morphix | `Prof-bilal/Morphix` | `main` `1ee76d11` | MIT OR Apache-2.0 |

## Unresolved asset provenance (RESEARCH)

Omarchy bundles artwork and fonts whose upstream license status is incomplete:

- Theme wallpapers under `themes/*/backgrounds/` have **no in-tree attribution or license file**.
- The custom icon font partially documents glyph provenance (simpleicons/lobehub/vendor
  favicons); the remainder is untraced.
- Vendor brand icons (Basecamp, Discord, Google, Zoom, etc.) are third-party trademarks.
- Sounds were not located in the inspected tree; their existence and licensing are unverified.
- Theme palettes re-implement known open palettes (Catppuccin, Gruvbox, Nord, Rosé Pine,
  Tokyo Night, Everforest, Kanagawa, Flexoki); upstream licenses still apply.
- One ALSA UCM directory ships an HP license file; other hardware data may differ.

No archived Omarchy bundled asset may ship in an Axiom artifact. Axiom's own
branding must be original or openly licensed with the license text and
attribution retained.

## Project-level status

- No root `LICENSE` exists; no license grant is inferred from documentation.
- Redistribution, trademark and asset review remain release blockers.
- This file must be updated with exact versions and hashes when a pinned image is built.
