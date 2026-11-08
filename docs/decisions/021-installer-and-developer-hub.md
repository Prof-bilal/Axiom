# ADR-021: Installer flow and Developer Hub (Phase 6)

**Date:** 2026-11-07
**Status:** Accepted for Phase 6 with the defaults below (the owner may change
any row in "Open choices" before the milestone that uses it starts).
Extends [ADR-020](020-installable-system.md) and implements the design in
[INSTALL_CHECKLIST](../engineering/INSTALL_CHECKLIST.md).

## Context

Axiom's installer should feel like Omarchy's: a short guided form (account, git
identity, disk) and then a developer app selection, with no hand-written config.
Omarchy's ISO runs a configurator, writes an archinstall `user_configuration.json`
plus `user_credentials.json`, installs from a bundled mirror, creates the user and
runs a per-user setup step ([omarchy-iso](https://github.com/omacom-io/omarchy-iso)).
Weaknesses we must not copy: weak passwords accepted, LUKS passphrase stored in
plaintext config, encrypted installs needing a console prompt without a stated
contract. archinstall has no post-install hook, so provisioning is our own job.

## Decision

### Installer screens

1. Language, keyboard, timezone (preselected from locale/network).
2. Disk: model/size/serial shown, running medium refused, optional LUKS2 with its
   own passphrase and strength check.
3. Account: full name, username, hostname, password twice. Username must match
   `^[a-z_][a-z0-9_-]{0,31}$` and not be reserved; password minimum 10 characters,
   not on a common-password list, not equal to the username.
4. Git identity: name, email, optional ed25519 SSH key (passphrase prompted), optional
   commit signing with that key. GitHub login is **not** collected here.
5. Developer Hub selection (below).
6. Review: destructive disk plan plus resolved app list; explicit confirm.
7. Install, then reboot.

### Developer Hub

- One declarative **catalogue** (`catalog/developer-hub.json`) lists every item:
  id, category, method (`pacman` | `mise` | `podman` | `config`), source,
  [permission class](../security/PERMISSIONS.md), undo note, loopback/port notes.
  The installer and the post-install Hub read the same file; `validate-repo.py`
  validates it.
- **Presets:** Backend, Frontend, Data/ML, Systems, Minimal. They pre-check items
  only; everything stays editable and nothing installs without confirmation.
- **v1 methods only:** official-repo pacman packages; `mise` for per-user language
  runtimes; rootless Podman containers (loopback only) for databases; config
  items (git, shell). No AUR, no `curl | bash`; items needing them are deferred.
- **Reusable:** the Hub also opens from Settings after install to view, edit and
  re-apply the profile.

### Provisioning timing

The installer **records a profile** (`/var/lib/axiom/provision/profile.json`,
copied to the user's `~/.config/axiom/dev-profile.json`, schema-versioned). A
one-time first-boot job (`axiom-provision.service`, runs as the user, root only
through the existing polkit-gated path) shows the resolved plan, applies each item,
verifies it and records applied/skipped/failed per item. Offline first boot **defers**
with a visible banner; the selection is never dropped. Re-applying converges.
A small core set (git, neovim, podman) may be added to the ISO package list later;
the full set is not bundled in v1.

### Secrets

- Password: hashed (`yescrypt`, via `openssl passwd -5/-6` fallback if unavailable)
  and written to a `0600` file on tmpfs, deleted after install. Never in argv, env,
  logs or the profile.
- LUKS passphrase: passed by file descriptor/stdin if archinstall accepts it; otherwise
  a `0600` tmpfs file deleted immediately after `cryptsetup`. To be proven in M7.
- GitHub: after first boot, `gh auth login` (browser device flow) from the Hub; the
  Hub shows the SSH public key. No token is stored in the profile or logs.
- Profiles contain no passwords, keys or tokens (tested).

### Code layout (created only as each milestone needs it)

| Path | Role |
| --- | --- |
| `installer/` | Python (stdlib) backend: form validation, archinstall JSON generation, argv-only execution, JSON-lines progress. |
| `apps/installer/` | QML installer UI on Quickshell; calls the backend through `Process` with argv. |
| `apps/hub/` | QML Developer Hub UI, shared by the installer and Settings. |
| `catalog/` | Catalogue and preset data. |
| `iso/phase3/` | Launcher, first-boot units, package-list changes. |

No new Axiom daemon: provisioning is a one-shot unit; greetd, systemd, PAM,
archinstall, mise and Podman are upstream.

## Amendments (2026-11-07, owner reference screenshots)

- **Installer and login UI are terminal UIs, not QML.** The owner's reference shows an
  "Axiom Boot Installer" (menu: Start setup / Recovery tools / Open shell; What you'll
  set up and Controls boxes) and a TUI login (password box, F1 Help, F2 Switch User,
  F10 Power). So `installer/axiom-installer` is a Python curses app run on tty1 by
  `axiom-installer.service` when the kernel option `axiom.installer=1` is set (UEFI
  entry "Install Axiom"), and `greeter/axiom-greeter` is a curses greetd greeter.
  Reason: works on any console, testable over QEMU serial/`/dev/vcs1`, no extra
  runtime. `apps/installer/` and `apps/hub/` QML apps are therefore not created in
  Phase 6; the Hub post-install is `axiom-provision --status` plus Settings later.
- **Languages and toolchains install from official-repo pacman packages**, not `mise`:
  fewer moving parts, verifiable with `pacman -Qi`, same user-visible result. A
  per-user version manager is a later catalogue method.
- **Narrow privileged path:** `axiom-provision` (root, first boot) installs only
  packages named in the root-owned catalogue; the profile can only select ids.
  Container items run rootless as the user (Quadlet units, loopback ports, generated
  random credentials in `~/.config/axiom/hub/*.env`, mode 0600).
- Items without an official-repo package (Google Cloud CLI, JetBrains Toolbox) and
  Redis (Valkey is the supported equivalent) are listed in the catalogue's
  `not_in_v1`.

## Milestones and acceptance (QEMU + OVMF, disposable disks, retained evidence)

| ID | Milestone | Done when |
| --- | --- | --- |
| M1 | Headless install | Scripted archinstall onto a blank qcow2 boots, logs in, keeps a setting; serial/journal retained. |
| M2 | Backend | Validation and config generation unit-tested (weak password, bad username, wrong/removable target, shell metacharacters in names). |
| M3 | Installer UI | Screens 1-4, 6, 7 drive a real install in QEMU. |
| M4 | Catalogue and Hub | Catalogue validated; profile exports, edits and re-applies (round-trip test). |
| M5 | First-boot provisioning | Per-item results, failure isolation, idempotent re-run, offline defer, all defaults user-scope, no unexpected listeners. |
| M6 | Greeter and lock | greetd greeter and `WlSessionLock` work; no autologin on installed systems. |
| M7 | LUKS | Encrypted install boots with passphrase prompt; passphrase absent from logs/disk. |
| M8 | Failure matrix and docs | Cancel, wrong target, low space, user-creation failure, interrupted install, no-media reboot, fallback boot; docs and PHASES updated. |

M1 is first because it is the riskiest unknown (archinstall with btrfs, LUKS and
the chosen bootloader). Exit for Phase 6 remains ADR-020: blank disk installs,
reboots, logs in and keeps Settings.

## Open choices (defaults chosen; change before the milestone)

| Choice | Default | Needed by |
| --- | --- | --- |
| v1 catalogue | VS Code, Neovim, Zed, Node, Python, Go, Rust, Podman, PostgreSQL, Redis/Valkey, Ollama, AWS/gcloud/Azure CLIs, kubectl, git, zsh | M4 |
| AUR | not allowed in v1 | M4 |
| Network during install | required in v1; offline mirror is a later option | M1 |
| Name | "Developer Hub" | M4 |

## Consequences and rollback

Rollback: delete the installer/Hub apps and units; the live ISO still works. A
failed item never aborts the rest and is reported. Deleting a datastore volume is
data loss and is not covered by any rollback. Unverified until their milestone:
archinstall schema for our layout, LUKS secret handling, mise and Podman rootless
inside the installed image, Ollama size/hardware needs.
