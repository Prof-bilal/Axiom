# ADR 035: Install from the live desktop (native QML installer)

Status: Proposed. Implementation done; QEMU verification pending. Supersedes the privilege mechanism of
[ADR-026](026-installer-privilege.md); the text installer ([ADR-021](021-installer-and-developer-hub.md))
stays as a hidden fallback.

## Context
The installer ran at boot as a console UI. A user with no network found out only after answering every
question and waiting through most of the install (pacman aborted a stalled download at 85%). The boot menu
also offered "Install Axiom" before the user could try the system. Users expect what Linux Mint does:
boot a live desktop first, then run an installer from the desktop.

## Decision
1. **Live desktop first.** The boot menu shows only the Axiom live desktop (UEFI and BIOS). Install Axiom
   is an icon on the live desktop (`shell/src/desktop/InstallTile.qml`, shown only when `/run/archiso`
   exists) and an entry in `/usr/share/applications`, which the installer does not copy to the target.
2. **Native QML app** `apps/liveinstaller/` (`axiom-app installer`, AppId `org.axiom.Installer`), steps:
   Welcome, Network, Locale, Partitioning, Identity, Installation, Finish. Fixed-size window, no compositor
   frame (labwc `windowRule`), the app draws its own title strip. It reuses the backend and does not copy its rules.
3. **Network inside the flow.** The Network step joins Wi-Fi through `Quickshell.Networking` (as Settings
   does; polkit already allows it for the live user). Confirm checks that the mirror pacman needs is reachable
   (`curl` to `geo.mirror.pkgbuild.com`) before the disk is erased. Skipping is allowed; installing offline is not.
4. **Privilege: one-shot pkexec helper, no daemon.** `system/installer/axiom-install-run` runs as root through
   `pkexec` after polkit approves `org.axiom.installer.system-install`. It takes no arguments, reads one JSON
   line on stdin, refuses unless `/run/archiso` exists, then runs `installer/axiom_install.py`, which validates
   every field and re-checks the target disk before writing. Validation and the disk list need no root and run
   as the live user (`axiom_install.py --validate`, `--list-disks`).
   Rule `52-axiom-live-installer.rules` grants that one action to the live user `axiom`, local and active. It is
   not in the installer's overlay list, so it never reaches an installed system.
5. **Offline package source is not decided here.** Installing from a local repository or the live squashfs
   needs its own ADR; this one keeps pacstrap over the network.

## Why not ADR-026's daemon
`axiom-installd` adds a long-running root service with a socket protocol for operations (`validate`,
`list_disks`) that need no privilege. The one privileged step is the install itself, and a one-shot helper
behind polkit matches `axiom-pkgd` and adds nothing to the always-running attack surface (AGENTS.md: every
daemon needs justification). What the helper cannot do is cancel a running install cleanly: Cancel is
disabled while the disk is being written, and killing the helper leaves recovery to the backend's cleanup.

## Consequences
- The text installer remains for recovery and the QEMU tests (`axiom.installer=1` on the kernel command
  line); it is just not on the boot menu.
- The installer app and its QML files are copied to installed systems with the other apps (`/usr/local/share/axiom`);
  without the helper and the live marker they cannot install anything.
- Language and keyboard lists exist in the text installer and in `installer.js`; a later cleanup can share them.

## Verification
- Unit: `tests/apps/installer-logic.test.mjs`, `tests/apps/install-run.test.mjs` (refuses off the live medium,
  as non-root, with arguments), `tests/installer/test_query.py`.
- Host: the app runs against `tests/installer/fake_backend.py` (`AXIOM_INSTALL_HELPER`) with no QML errors.
- QEMU (pending): boot the live desktop, double-click Install Axiom, install to a blank disk, boot the
  installed system; evidence kept under `iso/out-*/evidence/`.
