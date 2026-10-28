# Open-source desktop and distro license map

Status: **RESEARCH/DOCUMENTATION ONLY**. This is a planning inventory, not a
license grant and not a substitute for checking the exact pinned files before
redistribution.

## First principle: a distro does not have one license

An operating-system distribution is an aggregation of independently licensed
kernel, compositor, shell, services, packages, fonts, icons, wallpapers,
documentation and trademarks. “Open source” and “MIT” are not interchangeable.
The repository, package, file and asset that Axiom copies or links must be
tracked separately. The existing [third-party inventory](../../THIRD_PARTY_NOTICES.md)
remains the release-gate record.

## Primary-source matrix

| Project / role | License reported by the upstream source | Relevance to Axiom | Reuse rule |
| --- | --- | --- | --- |
| [Omarchy](https://github.com/omacom/omarchy/blob/main/LICENSE) | MIT | Upstream foundation reference and shell/session conventions | Pin a revision; preserve notice; remove Omarchy product identity from Axiom surfaces; do not copy unlicensed artwork or manual prose |
| [Omarchy packages](https://github.com/omacom/omarchy-pkgs) | Repository metadata currently reports MIT; verify each package | Packaging/reference material | Treat package recipes and bundled assets as separate provenance records |
| [Hyprland](https://github.com/hyprwm/Hyprland/blob/main/LICENSE) | BSD 3-Clause | Compositor, workspaces, window/focus authority | Preserve notice and do not treat IPC or Lua helpers as an authority bypass |
| [Quickshell](https://github.com/quickshell-mirror/quickshell/blob/master/LICENSE) | LGPL-3.0 | Qt/QML shell toolkit and Wayland integration | Keep the library replaceable/relinkable as required by LGPL; Axiom QML remains its own work; verify the exact build/package license |
| [Waybar](https://github.com/Alexays/Waybar/blob/master/LICENSE) | MIT | Open-source bar architecture and module UX reference | Study module boundaries and tests; do not copy branding or assume its compositor semantics are ours |
| [wlroots](https://github.com/swaywm/wlroots/blob/master/LICENSE) | MIT | Wayland compositor library reference | Reference only unless ADR-013 changes; copied code still needs notices and API compatibility review |
| [PipeWire](https://github.com/PipeWire/pipewire/blob/master/LICENSE) | MIT for most source; upstream records LGPL/GPL exceptions | Audio/video graph service | Track the exact library/plugin; do not flatten the exceptions into “MIT” |
| [systemd](https://github.com/systemd/systemd/blob/main/LICENSES/README.md) | LGPL-2.1-or-later by default, with file/program exceptions | Service lifecycle and user-session primitives | Use the system package; if copying code, preserve per-file SPDX and exceptions |
| [Flatpak](https://github.com/flatpak/flatpak) | LGPL-2.1 | Optional application sandbox/distribution integration | Reuse through the system package/API; retain LGPL notices for any redistributed component |
| [xdg-desktop-portal](https://github.com/flatpak/xdg-desktop-portal) | LGPL-2.1-or-later in upstream source files | Consent and desktop integration boundary | Prefer the portal contract over direct privileged/device access |

The table records upstream declarations, not legal advice. A dependency's
README, repository license and individual source-file SPDX tags can disagree
for a particular subdirectory; the exact file and pinned revision win.

## Practical compatibility rules

1. **MIT/BSD code can usually be reused with notice retention**, but that does
   not transfer trademarks, artwork, documentation rights or project identity.
2. **LGPL components are usable by Axiom**, but redistribution and relinking
   obligations must be preserved. Do not statically copy or modify a library
   without following the applicable LGPL terms.
3. **GPL/LGPL exceptions are file-specific.** systemd and PipeWire explicitly
   document exceptions; inspect the exact component instead of classifying the
   whole project from its name.
4. **Runtime dependency is not source copying.** Depending on a distribution's
   installed Hyprland, Quickshell or PipeWire package is different from
   embedding its source or binaries in an Axiom image; both cases still need
   package and notice records at build time.
5. **Assets are code-adjacent but not automatically code-licensed.** Fonts,
   icons, wallpapers, sounds, screenshots, manuals and vendor marks require
   their own provenance and redistribution decision.
6. **Axiom has no root license grant yet.** Do not imply that this repository,
   its original branding or its documentation is MIT merely because Omarchy is
   MIT. The release inventory remains incomplete.

## Required provenance record for copied material

Before importing any upstream file, add a row to the third-party inventory with
the repository URL, immutable commit/tag, file path, copyright notice,
SPDX/license, whether it is copied/linked/generated, and the validation that
the delivered artifact contains the required notices. If the source is an
inspiration only, record it as a reference and do not copy it.

## Direction for Axiom

Use MIT/BSD/LGPL projects as **referenceable infrastructure**, not as a reason
to merge their codebases into a monolith. Keep Axiom Shell, Axiom branding,
services and future AI runtime in Axiom-owned boundaries. Reuse mature Linux
primitives through stable packages and documented APIs; fork or copy only after
an ADR, license review, maintenance plan and rollback path.
