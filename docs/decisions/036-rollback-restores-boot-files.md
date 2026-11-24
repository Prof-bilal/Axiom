# ADR 036: A rollback also restores the kernels on /boot

Status: Proposed. Follows the pre-Phase-8 audit (`reports/phase-8/01-repository-audit.md`, finding H5). Amends ADR-033.

## Context
The installed system keeps `/boot` on the FAT ESP (systemd-boot) and the rest on btrfs. A snapper snapshot covers the
root, including `/usr/lib/modules/<ver>/` (modules, `vmlinuz`, `pkgbase`), but not the ESP. After a kernel update and a
rollback the restored root has the old modules while `/boot` still holds the newer kernel and initramfs: the kernel cannot
load modules and the system boots broken or degraded. ADR-033 did not cover this.

## Options considered
1. **ESP at `/efi`, kernels on btrfs `/boot`**: not possible with systemd-boot, which reads only FAT (ESP/XBOOTLDR), not btrfs.
2. **Switch to GRUB + grub-btrfs**: reads btrfs and adds a snapshot boot menu, but replaces the boot chain; too large and
   untestable for this change. Revisit in Phase 10 with a hardware matrix.
3. **Chosen: keep the layout, resync the ESP from the snapshot.** The kernel image and modules in the snapshot are authoritative.

## Decision
`axiom-pkgd rollback` runs `system/pkgd/axiom-boot-sync <n>` after `snapper rollback` succeeds. For every kernel under
`/.snapshots/<n>/snapshot/usr/lib/modules/*/` it copies `vmlinuz` to `/boot/vmlinuz-<pkgbase>` and rebuilds
`/boot/initramfs-<pkgbase>.img` with `mkinitcpio -r <snapshot> -k <ver> -g`. Files are written next to the target and renamed,
so a failed build leaves the old, bootable files. If the sync fails the helper exits 4 and says not to reboot.
Normal updates are unchanged: the kernel package hooks keep `/boot` consistent with the new root.

## Consequences and limits
- No partition or bootloader change, so installed systems keep their layout.
- The initramfs is built with the running system's `mkinitcpio.conf` and hooks, not the snapshot's. Fine for a single
  rollback; a snapshot taken before a hook change can differ.
- Restoring a snapshot by any other route (booting a snapshot by hand) is not covered.
- The ESP is still not snapshotted: a power loss between `snapper rollback` and the sync leaves the old mismatch until
  `axiom-boot-sync <n>` is run again.
- **Not yet verified end to end.** Unit tests (`tests/apps/pkgd.test.mjs`) use fake `mkinitcpio` and temp directories.
  Required before this ADR is Accepted: a QEMU test that bumps the kernel, snapshots, rolls back, reboots, and loads a module
  (extend `tests/phase7-update-rollback.py`).
