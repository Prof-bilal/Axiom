# Third-party notices and license inventory

Status: **incomplete — redistribution is not authorized.** This file begins the inventory
required by the [release gate](docs/engineering/RELEASE.md). Axiom has no root `LICENSE`, and
project licensing/trademark review is unresolved (see [README](README.md)). Nothing here grants
a license, and listing a component here does not complete the release inventory.

Recorded 2026-10-27 from repository and release metadata. Verify every item against the actual
installed artifact before any distribution.

## Upstream infrastructure (research / not a current product dependency)

The prior upstream-desktop foundation has been removed. Phase 3 research material
(reference compositors and shell toolkits, see
[research/phase3/repos](research/phase3/repos)) is read-only reference; no current
Axiom image is authorized to ship any of it as a product/runtime dependency.
Current reuse decisions are made per component under
[ARCHITECTURE](docs/ARCHITECTURE.md), [decision 001](docs/decisions/001-remove-omarchy.md)
and the Phase 3 [license audit](docs/research/phase3/licenses.md).

| Component | Pinned input | License | Obligation / note |
| --- | --- | --- | --- |
| Quickshell | `quickshell-mirror/quickshell` (Phase 3 shell toolkit candidate) | **LGPL-3.0-only** | Shared-library relink obligation applies if shipped; see license audit |
| Sway | `swaywm/sway` (Phase 3 harness candidate) | MIT | Preserve notice if used as a temporary harness |
| Hyprland | `hyprwm/Hyprland` (research only) | BSD-3-Clause | Not an Axiom dependency; IPC/behavior reference only |
| Wayfire | `WayfireWM/wayfire` (research) | MIT | Reference only unless adopted |
| COSMIC components | `pop-os/cosmic-*` (research) | GPL-3.0-only | Reference only; no code reuse without compliance |
| SDDM (greeter) | Arch package (pin at build) | GPL-2.0-or-later (verify) | Preserve notice; distribution obligations |
| Plymouth | Arch package (pin at build) | GPL-2.0-or-later (verify) | Preserve notice |
| Btrfs / Snapper | Arch/SUSE packages | GPL-2.0 | Preserve notices |

## Phase 3 desktop image: fonts and visual dependencies

Installed from Arch `extra` as unmodified packages (not vendored in this
repository). See [DESKTOP_DESIGN](docs/DESKTOP_DESIGN.md).

| Component | Arch package | License | Use |
| --- | --- | --- | --- |
| Inter | `inter-font` 4.1 | OFL-1.1 (Reserved Font Name) | Shell UI and title-bar font |
| JetBrains Mono | `ttf-jetbrains-mono` 2.304 | OFL-1.1 | Terminal and code font |
| foot | `foot` 1.28 | MIT | Axiom Terminal (configured, not modified) |
| labwc | `labwc` 0.20 | GPL-2.0-only | Phase 3 compositor harness (ADR-016); unmodified separate program, Axiom theme/config only |
| Code - OSS | `code` 1.138 | MIT | Pinned code editor (Arch build of VS Code OSS; no Microsoft branding or marketplace) |
| GVfs | `gvfs` | LGPL-2.0-or-later | `trash:///` backend for the Trash dock item |
| Adwaita icon theme | `adwaita-icon-theme`, `adwaita-icon-theme-legacy` | LGPL-3.0 / CC-BY-SA-3.0 | Application icons via the XDG icon theme |

Axiom's panel/menu glyphs (`shell/src/shared/AxiomIcon.qml`) are original
paths, not copied from an icon font or set. The penguin and A-mark under
`branding/identity/` are Axiom assets; their provenance review is still a
release blocker like all of `branding/`.

## First-party sibling projects (not bundled by default)

| Component | Repository | Revision verified 2026-10-27 | License |
| --- | --- | --- | --- |
| Warden | `Prof-bilal/Warden` | `main` `f7c97931` | MIT |
| RepoSpine | `Prof-bilal/RepoSpine` | `main` `9ea06ec3` | MIT |
| ContextGit | `Prof-bilal/ContextGit` | `main` `8acd4e7d` | Apache-2.0 |
| ModelCheck | `Prof-bilal/ModelChecker` | `main` `eddcf746` | **No LICENSE file**; `cli/package.json` declares MIT — must be fixed before shipping |
| Morphix | `Prof-bilal/Morphix` | `main` `1ee76d11` | MIT OR Apache-2.0 |

## Unresolved asset provenance (RESEARCH)

Any upstream desktop's bundled artwork, fonts, icons, sounds and palettes may
carry incomplete licensing. Nothing of that kind may ship in an Axiom artifact.
Axiom's own branding under `branding/` must be original or openly licensed with
the license text and attribution retained; validate provenance before shipping.

## Project-level status

- No root `LICENSE` exists; no license grant is inferred from documentation.
- Redistribution, trademark and asset review remain release blockers.
- This file must be updated with exact versions and hashes when a pinned image is built.
