# Btrfs transactions and recovery

Status: V1 experiment required; no working recovery mechanism exists. Last researched: 2026-10-18.

Use Btrfs and Snapper initially. Proposed layout: root (including /usr, /etc and /var/lib/pacman) is one recovery domain; /home, /var/log, package cache, VM images and audit persistence are separate explicitly enumerated subvolumes. Avoid separating all of /var: restoring package files without their package database creates inconsistent state. Confirm installer support before accepting this layout.

Snapshots share filesystem storage; they are neither independent backups nor recursive snapshots of child subvolumes. ESP/kernel/initramfs artifacts, firmware state, external disks, remote actions, sent messages and provider requests need separate recovery or compensation. Root snapshot restoration does not undo them. Retained audit records must identify restored transaction lineage without logging secret contents.

## Transaction contract

1. Validate scope and serialize conflicting operations; reserve free space and identify recovery domains.
2. Authorize bounded snapshot preparation before privileged writes; record intent, create pre-snapshot and bind a plan digest to the relevant state/version.
3. Show the exact diff, exclusions and recovery limitations; authorize before mutation. Snapshot creation is internal preparation with its own policy, never permission to execute the plan.
4. Revalidate authorization and preconditions; execute bounded typed operations.
5. Verify package database/files, services and boot artifacts as applicable; record post-state.
6. Commit a successful result. On failure stop dependent work and restore only the covered domains through a reviewed recovery path. Verify recovery; report partial or failed rollback explicitly.

Do not auto-reboot after an unverified restoration. A running root cannot safely be treated as a fully reverted process state: reboot/restart requirements belong in the plan. Security-policy/key revocation must not be silently undone by an older root snapshot.

## Required experiment

In disposable UEFI VMs, prove bootloader entries select the intended root
generation. The boot chain remains a Phase 1/9 experiment against signed boot,
fallback kernels, encryption and recovery. A fixed `subvol=` boot parameter can
defeat default-subvolume changes; plain `snapper rollback` is not a boot
integration design. Compare explicit boot-generation entries against
default-subvolume switching before recording an ADR. `/home` and external
effects remain excluded unless separately proven.

Inject ENOSPC, package-script failure, interruption, power loss, mismatched ESP, missing snapshot, corrupt metadata, concurrent updates and expired authorization. Recover from the ISO when root cannot boot. Prove audit survives and user data remains untouched. Retention must preserve a tested known-good boot generation and enforce capacity limits.

Sources: [Btrfs subvolumes](https://btrfs.readthedocs.io/en/latest/btrfs-subvolume.html), [Snapper upstream](https://github.com/openSUSE/snapper), [systemd-boot](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html). See [installer](../engineering/INSTALLER.md), [security](../security/SECURITY.md).
