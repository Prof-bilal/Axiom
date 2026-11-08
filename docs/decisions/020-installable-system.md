# ADR-020: Installable system (Phase 6)

**Date:** 2026-11-07
**Status:** Accepted (Phase 6 verified in QEMU 2026-11-08; evidence in `iso/out-phase6/evidence/`).

## Context

Axiom only runs as a live archiso image with tty1 autologin
(`iso/phase3/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf`),
so Settings and all user state vanish on reboot. Phase 6 exit: a blank QEMU disk
installs, reboots, logs in and keeps Settings. First hardware contract is
x86-64 UEFI, GPT, fresh disposable disk ([INSTALLER](../engineering/INSTALLER.md)).

## Decision (recommended)

| Area | Choice | Reason / alternative |
| --- | --- | --- |
| Installer engine | `archinstall`, driven by a generated JSON config | Already in the ISO package list; scriptable; no Qt stack. Calamares is heavier and needs a Qt/branding module. |
| Installer UI | Axiom QML app on Quickshell, calling the engine with an argv-only config file | Axiom owns UX and plan display; engine stays replaceable. |
| Disk layout | GPT: 1 GiB ESP (FAT32), root btrfs (`@`, `@home`, `@snapshots` subvolumes), optional LUKS2 on root | btrfs is needed for Phase 7 snapshots ([ADR-005](../DECISIONS.md)). |
| Bootloader | systemd-boot; GRUB only if LUKS+btrfs testing shows it is required | ADR-002 re-opened the systemd-boot half; test both in QEMU/OVMF. A fallback kernel entry is mandatory. |
| Login manager | `greetd` with an Axiom QML greeter (Quickshell, `labwc` session) | Small; reuses the shell stack. SDDM is the fallback. |
| Lock screen | Quickshell `WlSessionLock` (`ext-session-lock-v1`) + PAM | Built into the shell runtime; no new daemon. |
| User creation | `useradd`/`chpasswd` with the password on stdin; never argv, env or logs | [INSTALLER](../engineering/INSTALLER.md) secret rule. |
| First run | One-shot systemd unit + QML wizard (locale, timezone, keyboard, Wi-Fi); developer-profile choice is recorded only | [INSTALL_CHECKLIST](../engineering/INSTALL_CHECKLIST.md). |
| Autologin | Removed on installed systems; kept only on the live ISO | Required by Phase 6. |

No new Axiom daemon is added: greetd, systemd, PAM and archinstall are upstream.

## Safety rules

Show target identity, capacity and the full destructive plan, then require
explicit confirmation. Re-validate the target immediately before writing; refuse
the running medium and mounted disks. Disk/user inputs are data, never shell
strings. Cancel means no write.

## Verification (disposable QEMU + OVMF only)

Blank qcow2 install, reboot without media, login, Settings value persists;
LUKS unlock; fallback boot entry; cancel, wrong-target, low-space, user-creation
failure and interrupted install each leave a defined state. Retain serial,
journal and screenshot evidence.

## Consequences / rollback

Rollback is discarding the installer app and returning to the live ISO; no host
disk is touched outside tests. Unverified until tested: LUKS+systemd-boot
initrd path, greeter under labwc, archinstall offline behaviour. Real hardware,
Secure Boot, TPM and dual boot are out of scope (Phase 10 and later).
