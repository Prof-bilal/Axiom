# ISO build and QEMU workflow

Status: **LEGACY Phase 1 evidence.** The reviewed profile in [`iso/profile/`](../../iso/profile/README.md), build wrapper `scripts/build-iso.sh` and QEMU harness `tests/qemu-boot.sh` produced the Phase 1 exit evidence ([PHASE1_EVIDENCE](PHASE1_EVIDENCE.md)) and are retained as a historical reproducible-Arch baseline. After [ADR-013](../DECISIONS.md) the Phase 2 image base is the pinned Omarchy-derived ISO flow (`omacom/omarchy-iso`), not this archiso profile; use [PHASE2_BUILD](PHASE2_BUILD.md) for that path and [PHASE2_EVIDENCE](PHASE2_EVIDENCE.md) for its exit record. The Plasma packages added later to `iso/profile/packages.x86_64` are legacy and are not the migration base. Last researched: 2026-10-18; first executed 2026-10-25; legacy status recorded 2026-10-27.

Use a disposable fully updated Arch x86_64 build VM, reviewed archiso package and enough RAM/disk for its root tree and artifacts. Install archiso, qemu-desktop and edk2-ovmf there using an authorized administrator; record exact installed package versions and repository databases. Current upstream mkarchiso supports unprivileged execution when user namespaces/unshare are available; validate the chosen builder rather than assuming root is always mandatory. Prefer isolation over running builds on a personal host.

The first experiment uses the installed upstream releng profile, copied to a writable directory. Future commands inside that disposable builder (not commands executed during foundation work):

```sh
cp -a /usr/share/archiso/configs/releng ./axiom-profile
mkarchiso -h
mkarchiso -v -w ./archiso-work -o ./archiso-out ./axiom-profile
```

A later reviewed repository profile belongs in `iso/`; its `profiledef.sh`, package list, pacman configuration and airootfs must be versioned. Pin the selected archiso/profile revision, Arch package inputs, timestamps and builder environment before claiming repeatable artifacts. Rebuild independently and compare hashes; explain any difference. Do not claim upstream rolling mirrors alone are reproducible inputs.

After an image exists, inspect `run_archiso -h` for the installed version; the upstream helper supports QEMU boot. Explicit example with prerequisites KVM access and matching OVMF pflash image pair:

```sh
cp /usr/share/edk2/x64/OVMF_VARS.4m.fd ./vm-vars.fd
qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -m 8192 -smp 4   \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd   \
  -drive if=pflash,format=raw,file=./vm-vars.fd   \
  -cdrom ./archiso-out/axiom.iso -boot d -nic none -serial file:./serial.log
```

`axiom.iso` is an example path: substitute the actual produced filename and verify firmware paths against installed edk2-ovmf files. This command provides a display for manual checks, no guest disk and no network; later installation tests attach a disposable qcow2 disk. Serial output requires guest console configuration and is not a substitute for guest journals. No host shared directories or physical disks.

Collect journal/boot errors, session type, compositor state and package manifest from guest; pass UEFI boot and clean shutdown before branding. On failed builds inspect mounts with `findmnt` before cleanup: blindly deleting mounted work trees can destroy unrelated data. Do not suppress failure logs. Legacy BIOS is not an initial installed-system requirement, even if upstream releng has additional live boot modes.

Sources: [archiso upstream](https://github.com/archlinux/archiso), [profile specification](https://github.com/archlinux/archiso/blob/master/docs/README.profile.rst), [mkarchiso manual](https://github.com/archlinux/archiso/blob/master/man/mkarchiso.1.rst), [QEMU](https://www.qemu.org/docs/master/system/introduction.html), [current Arch OVMF file list](https://archlinux.org/packages/extra/any/edk2-ovmf/files/). See [testing](TESTING.md).
