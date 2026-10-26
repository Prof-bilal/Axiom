# Installation design

Status: Calamares selected initially; configuration/boot compatibility remains unproven. Phase 10 deliverable, with earlier storage experiments only. Last researched: 2026-10-18.

Use upstream Calamares modules and branding rather than writing a custom installer. Proposed first hardware contract: x86_64 UEFI, GPT, systemd-boot, Btrfs and a fresh disposable target disk. Dual boot, legacy BIOS and complex manual partitioning are deferred until independently tested. Disk encryption and Secure Boot require explicit architecture decisions; do not advertise either as supported merely because upstream components have mechanisms.

Installer must show target disk identity/capacity, complete destructive plan and explicit confirmation before writes. Never infer the target from device enumeration order. Revalidate device identity before execution; protect the running installation medium and mounted unrelated disks. Partition and user inputs are data, not shell commands.

Required installed state: appropriate ESP, reviewed root/subvolume layout, matching pacman database, linux and linux-lts boot entries, initramfs, user-session Plasma Wayland, timezone/locale/user configuration, trusted repository settings and recovery instructions. Secrets must be absent from logs, live-session remnants and generated image defaults. Installed accounts have no shared default password.

**Developer install checklist.** The installer also presents a curated developer selection (AI tools, editors, languages, datastores, containers, cloud CLIs) and stores it as a declarative profile. Provisioning runs on **first boot**, not inside the installer chroot, so a partial failure cannot corrupt the install and user-scope tools do not need root mid-install. Nothing is pre-selected; the checklist itself writes nothing destructive. See [install checklist](INSTALL_CHECKLIST.md).

Calamares module ordering, systemd-boot support/configuration, Btrfs defaults and failure behavior must be inspected against a pinned release. Direct project documentation access was unavailable during research; upstream wiki is the current evidence entry point, not proof this exact configuration works.

Test fresh install, cancelled destructive confirmation, wrong target guard, low space, firmware mismatch, offline requirements, user creation failure, interrupted installation and reboot without ISO; the developer checklist recorded but not applied inside the installer, and first-boot provisioning reporting per-item outcomes. Verify partition/subvolume layout, boot artifacts, fallback kernel, package consistency and snapshot recovery. Keep failure logs available without exposing credentials. Never test against host physical disks.

Sources: [Calamares upstream wiki](https://github.com/calamares/calamares/wiki), [systemd-boot UEFI manager](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html), [Btrfs recovery design](../system/BTRFS_ROLLBACK.md). See [release](RELEASE.md).
