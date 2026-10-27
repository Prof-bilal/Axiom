# Installation design

Status: installer path under research after [ADR-013](../DECISIONS.md); the Omarchy-derived ISO/configurator flow is the preferred candidate over a Calamares-first design, subject to the experiments in the [migration report](OMARCHY_MIGRATION.md). Phase 10 deliverable, with earlier storage experiments only. Last researched: 2026-10-27.

Prefer the proven upstream installer flow and rebrand it rather than rebuilding Calamares modules merely because the old architecture expected them. Proposed first hardware contract: x86_64 UEFI, GPT, Btrfs and a fresh disposable target disk; the boot chain (Omarchy Limine/UKI vs systemd-boot) is decided by E28. Dual boot, legacy BIOS and complex manual partitioning are deferred until independently tested. Disk encryption is part of the upstream flow and needs an explicit Axiom decision; Secure Boot and TPM are currently **disabled** upstream and are Axiom RESEARCH divergences — do not advertise either as supported.

Installer must show target disk identity/capacity, complete destructive plan and explicit confirmation before writes. Never infer the target from device enumeration order. Revalidate device identity before execution; protect the running installation medium and mounted unrelated disks. Partition and user inputs are data, not shell commands.

Required installed state: appropriate ESP, reviewed root/subvolume layout, matching pacman database, linux and linux-lts boot entries, initramfs, Axiom Shell Hyprland/Quickshell session, timezone/locale/user configuration, trusted repository settings and recovery instructions. Secrets must be absent from logs, live-session remnants and generated image defaults. Installed accounts have no shared default password.

**Developer install checklist.** The installer also presents a curated developer selection (AI tools, editors, languages, datastores, containers, cloud CLIs) and stores it as a declarative profile. Provisioning runs on **first boot**, not inside the installer chroot, so a partial failure cannot corrupt the install and user-scope tools do not need root mid-install. Nothing is pre-selected; the checklist itself writes nothing destructive. See [install checklist](INSTALL_CHECKLIST.md).

Omarchy-derived flow, boot-chain support, Btrfs defaults and failure behavior must be inspected against the pinned revision. Direct project documentation access was unavailable during the earlier research pass; the [migration report](OMARCHY_MIGRATION.md) is the current evidence entry point, not proof this configuration works.

Test fresh install, cancelled destructive confirmation, wrong target guard, low space, firmware mismatch, offline requirements, user creation failure, interrupted installation and reboot without ISO; the developer checklist recorded but not applied inside the installer, and first-boot provisioning reporting per-item outcomes. Verify partition/subvolume layout, boot artifacts, fallback kernel, package consistency and snapshot recovery. Keep failure logs available without exposing credentials. Never test against host physical disks.

Sources: [Omarchy ISO](https://github.com/omacom/omarchy-iso), [migration report](OMARCHY_MIGRATION.md), [Calamares upstream wiki](https://github.com/calamares/calamares/wiki) (legacy research), [Btrfs recovery design](../system/BTRFS_ROLLBACK.md). See [release](RELEASE.md).
