---
name: btrfs-transaction
description: "Design snapshot, change, verification and bounded rollback workflows."
---

# btrfs-transaction

## When to use

Use for filesystem or package recovery transactions. Do not use for claiming external effects or every file is reversible.

## Required inputs

Subvolume layout, snapshot scope, boot layout, mutation plan, verification and recovery console.

## Procedure

1. Inventory root/home/var/boot/ESP and nested subvolumes; identify what snapshots exclude.
2. Plan snapshot/change/verify/commit and explicit recovery; serialize conflicting changes and authorize bounded snapshot preparation before any privileged preparation writes.
3. Take and identify a recoverable snapshot before effects; record package versions and boot artifacts separately. Then obtain final mutation authorization bound to the exact plan, state and recovery coverage; revalidate immediately before execution.
4. Apply the bounded change, verify postconditions, and test rollback from the actual boot/recovery path.
5. Inject partial update, crash, disk-full and failed verification; protect audit history from silent rollback.

## Validation

Guest tests prove recoverability and package/kernel/initramfs/ESP consistency; distinguish read-only snapshot from a bootable restored root.

## Failure handling

Stop mutations on snapshot/verification failure; preserve audit/recovery evidence and never promise reversal of network sends or excluded user data.

## Project references

- [system/BTRFS_ROLLBACK.md](../../../docs/system/BTRFS_ROLLBACK.md)
- [engineering/TESTING.md](../../../docs/engineering/TESTING.md)
