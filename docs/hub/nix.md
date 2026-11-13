# Nix

- Id: `nix` · Category: System · Weight: light · Licence (catalog): LGPL-2.1
- Catalog sources: pacman `nix`
- Install verified: no · Screenshots: 0 of 3 · Logo: yes

## Overview
Package manager for reproducible installs (multi-user daemon).

## Facts
Not researched yet.

## Logo
Bundled icon: `apps/hub/icons/nix.png`.

## Screenshots
Not found.

## Install (verified against a source)
Not verified yet. Use the draft below only after checking it.

## Install options (research draft; Verified for the install commands (nixos.org download page and Nix 2.31 manual); no command was run on a machine here, and the fix for the macOS error is only a pointer to an issue.)
| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Multi-user (daemon, recommended) | `curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install \| sh -s -- --daemon` | Script invokes sudo as needed; can run as a normal user with sudo | Verified: https://nixos.org/download/ |
| Multi-user (alternate form) | `bash <(curl -L https://nixos.org/nix/install) --daemon` | Same as above | Verified: https://nix.dev/manual/nix/2.31/installation/installing-binary.html |
| Single-user | `curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install \| sh -s -- --no-daemon` | Script invokes sudo only to create `/nix`; run as normal user, not root | Verified: https://nixos.org/download/ |
| Single-user (alternate form) | `bash <(curl -L https://nixos.org/nix/install) --no-daemon` | Same as above | Verified: https://nix.dev/manual/nix/2.31/installation/installing-binary.html |

Notes: the multi-user install needs systemd with SELinux disabled. Uninstall and `nix --version` checks are not on the official pages, so they are not listed.

## Possible errors and fixes (draft)
**Error: `error: the user '_nixbld1' in the group 'nixbld' does not exist`**
- Cause: stated on the official page under "Updating to macOS 15 Sequoia" (macOS, not Linux).
- Fix: the official page gives no inline fix; it points to NixOS/nix issue #10892 for repairing the installation without reinstalling. Treat the issue as the reference, not a verified fix here.
- Source: https://nix.dev/manual/nix/2.31/installation/installing-binary.html

**Error: `could not connect to daemon`, `/nix/var` permission errors, WSL errors**
- Cause: Not found on official pages.
- Fix: Not found.

## Sources
