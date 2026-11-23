# Phase 8 research 03: Lightweight Linux and ISO optimization

Research only. No source, build system or ISO was changed or built. Date 2026-11-23.
Reports 01, 04, 05 did not exist when this was written; cross-references are by topic only.

Legend: **[V]** verified in this checkout or by a command I ran; **[A]** assumption/estimate; **[R]** recommendation; **[Q]** open question.

## 1. Measurement basis (what the numbers come from)

- Profile in use: `iso/phase3/` (197 lines in `packages.x86_64`, built by `scripts/build-phase3-iso.sh`). `iso/profile/` (137 packages) is the retained Phase 1 profile, built by `scripts/build-iso.sh`. [V]
- The only surviving mkarchiso work tree is `/var/tmp/axiom-work/build` (7.9 GiB), from a **2026-11-14** build. It predates Hyprland in the package list (`hyprland` not in its pacman db), so absolute numbers below are about 30-70 MiB low for the current profile (host `pacman -Qi hyprland` = 64 MiB). The built ISOs of 11.14, 11.18 and 11.21 differ by under 5 MiB, so composition is representative. [V]
- Per-package sizes: `pacman -Q --root <airootfs> -i` on that tree (745 packages, 4976 MiB installed). Raw list was kept in the scratchpad only. [V]
- Compression benchmark: `mksquashfs` on a 857 MiB real sample (electron42, python3.14, qt6, man, locale) from that tree, 12 cores, run by me. [V] It is a sample, not the whole image. Scaling to the full image is [A].
- Build timing: mkarchiso sentinel-file mtimes in `/var/tmp/axiom-work/build`. [V]

## 2. Current architecture assessment

| Item | Finding | Evidence |
|---|---|---|
| Base | Fork of Arch releng: all rescue tooling still listed (clonezilla, partimage, fsarchiver, nmap, lynx, irssi, mc, vpn clients, cloud-init, hyperv, VBox/VMware guest tools, brltty/espeakup, memtest, refind, syslinux, edk2-shell) plus the Axiom desktop on top | `iso/phase3/packages.x86_64` [V] |
| Image | squashfs, `xz -Xbcj x86,arm64 -b 1M -Xdict-size 1M` | `iso/phase3/profiledef.sh` [V] |
| Initramfs | mkinitcpio, xz -9e, releng hooks incl. all `archiso_pxe_*`, and `kms` | `iso/phase3/airootfs/etc/mkinitcpio.conf.d/archiso.conf` [V] |
| Boot modes | BIOS syslinux + UEFI systemd-boot (`efiboot.img`) | profiledef [V] |
| Install | archinstall over network, two pacstrap rounds, no offline source (explicit non-decision in ADR-035 item 6) | ADR-020/021/035, `installer/axiom_install.py` [V] |
| Compositors | Both labwc and Hyprland shipped; `/etc/axiom/compositor` selects hyprland | `axiom-session`, `iso/phase3/airootfs/etc/axiom/compositor` [V] |
| Toolkits | Qt6 (Quickshell, apps) and GTK3 (firefox, mousepad, polkit-gnome, portal-gtk) | package list, `pacman -Qi` [V] |
| Build | Full rebuild every time: `_rm_work "$WORK"` wipes the work tree; pacstrap, squashfs and ISO steps all rerun | `build-phase3-iso.sh` [V] |
| Packages source | Remote mirror only (`geo.mirror.pkgbuild.com`), `CacheDir` is the default host cache. No local repo. | `iso/phase3/pacman.conf` [V] |

## 3. Where ISO size really comes from

ISO = 2349.8 MiB (axiom-2026.11.21). Decomposition from the Nov-14 work tree (ISO 2354.9 MiB):

| Component | MiB | Share |
|---|---|---|
| `airootfs.sfs` (xz) | 1767 | 75% |
| `efiboot.img` (FAT, UEFI) | 265 | 11% |
| `initramfs-linux.img` (ISO9660 copy) | 238 | 10% |
| `vmlinuz-linux` | 16 | <1% |
| rest (syslinux, ucode, ISO overhead) | ~60 | 3% |

[V] sizes by `ls -la`. Key insight: **the initramfs and kernel are stored twice** (`efiboot.img` is a FAT image holding its own copy of kernel+initramfs+ucode). So about 500 MiB, 21% of the ISO, is kernel/initramfs.

### 3.1 Initramfs is 238 MiB (normal Arch initramfs is tens of MiB) [V]
`lsinitcpio -a`: "Early CPIO: 219.82 MiB, Size: 18.34 MiB". Contents by size: `usr/lib/firmware` 147 MiB (nvidia GSP blobs 77 MiB alone, amdgpu, intel), `usr/lib/modules` 57 MiB, microcode 17 MiB, `bcachefs` binary 9 MiB, udev 13 MiB. The early part is stored uncompressed; the xz setting only affects the 18 MiB main part. The firmware comes from the `kms` hook (GPU drivers pull their firmware) with no `autodetect` (impossible on a generic live medium). [A: the reason the firmware lands in the uncompressed early CPIO under mkinitcpio 42 / early hooks `udev archiso_pxe_nbd` I did not trace to source; see Q1.]

### 3.2 Installed rootfs: 4976 MiB across 745 packages (declared: 197) [V]

| Bucket | MiB (installed) | Notes |
|---|---|---|
| `code` (VS Code) + `electron42` | 1102 (22%) | `usr/lib/code` 808 MiB of which built-in `extensions` 407 MiB. Not installed on the target system (installer's `BASE_PACKAGES` has no `code`); only the live session gets it. |
| firmware (linux-firmware-* split, sof, ucode) | 579 (12%) | intel 138, nvidia 104, marvell 79, atheros 53, mediatek 37, amdgpu 28, sof 55. Whole-hardware matrix on a generic medium. |
| firefox | 302 (6%) | |
| Qt6 (all qt6-*) | 233 | Needed (shell and apps). |
| kernel + modules | 162 | `/usr/lib/modules` 182 MiB. |
| fonts (noto-fonts 107, etc.) | 149 | |
| llvm-libs | 165 | mesa dependency (software rendering). Needed in practice. |
| podman/distrobox/flatpak stack | ~105 | For Hub features, ADR-028/034. |
| python 74, perl 72, nodejs+npm 73 | 219 | nodejs/npm pulled for... see Q3. |
| rescue/"releng inheritance" (explicit names) | ~250 | vim-runtime 39, nmap 27, sequoia-sq 22, espeak-ng 18, brltty 10, bcachefs-tools 9, cloud-init 9, archinstall 8, mc 7, openpgp-card-tools 7, edk2-shell 6, man-pages 6, nvme-cli 6, lynx, openconnect, open-vm-tools, ... |
| `usr/share/locale` | 241 | 216 locales, ISO is English-first. |
| `usr/share/man`+doc+info | 140+108+9 | |
| GTK3 | 53 | second toolkit, only because of firefox/mousepad/polkit-gnome. |
| labwc | 1 | negligible; the dual-compositor cost is small. |

Compressed contribution of each bucket was not measured per package (average ratio 0.355 = 1767/4976). [A] code+electron compress worse than average (asar + JS, already dense); expect about 350-450 MiB of the 1767 MiB sfs. Verify per recommendation by building without it.

### 3.3 Repository payload (not shipped, but heavy)
`iso/out-phase3-fix/evidence/` is **56 GiB** (four `p6*` directories of about 4.4 GiB each, apparently VM disk images), `iso/out-phase3` 5.6 GiB. Host disk is at 90% (26 GiB free). [V] Not ISO bloat, but it limits iteration (see 6.4).

## 4. Where build time comes from [V from sentinel mtimes, one build]

| Stage | Time | Share |
|---|---|---|
| mkdir/pacman.conf to packages done (download + pacstrap 745 pkgs) | ~6 min (09:11-09:17) | 29% |
| `_mkairootfs_squashfs` (xz) | ~11 min (09:17-09:28) | 52% |
| ISO assembly (xorriso) | ~2 min | 10% |
| rest | ~2 min | |

Total about 21 min per build, dominated by xz on 5 GiB of already-compressed content. The wipe of the work tree at the start of `build-phase3-iso.sh` forces all of it on every run, including one-line QML edits. [V]

Compression benchmark (857 MiB real sample, 12 cores):

| Setting | Bytes (MiB) | vs current | Time |
|---|---|---|---|
| xz, bcj x86, 1M block, 1M dict (current) | 235.3 | baseline | 113 s |
| zstd 19, 1M block | 252.6 | +7.4% | 75 s |
| zstd 15, 1M block | 273.7 | +16.3% | 26 s |
| zstd 3, 256K block | 308.2 | +31% | 5 s |

Scaled to the 1767 MiB image [A]: zstd-19 about +130 MiB, zstd-15 about +290 MiB, zstd-3 about +550 MiB. Squashfs step would drop from ~11 min to about 7 / 2.5 / 0.5 min. Matches the Fedora releng data (zstd-15 +11%, zstd-1 +26% size, ~5x faster; [pagure releng 9127](https://www.pagure.io/releng/issue/9127)). Runtime read speed (decompression on page faults) was **not** measured: zstd decodes several times faster than xz in general [A], and Fedora cites xz as a CPU cost on live media ([releng 8581](https://www.pagure.io/releng/issue/8581)).

## 5. Boot and runtime baseline [V from docs/research/phase3/performance.md]

One QEMU/KVM run, 2 GiB, 2 vCPU, **software rendering**, labwc harness (pre-Hyprland): login prompt 67.5 s, shell IPC ready 88.9 s; **Quickshell RSS 433 MB / PSS 389 MB**, labwc 72 MB, guest used 676 MB of 2048 MB; idle CPU 0.00% for both. `systemd-analyze` was unusable (waiting for time sync). Nothing measured for Hyprland, nor on bare metal, nor for the installed system. All Hyprland/boot performance numbers are therefore **unmeasured** [V: `docs/engineering/BENCHMARKS.md` says "NOT YET MEASURED"].

Findings from reading config:
- Hyprland: blur off, shadows on (range 24, power 3), animations on with 10+ curves, rounding 16 (`iso/phase3/airootfs/etc/axiom/hypr/hyprland.lua`). Shadows and animations are GPU cost, not RAM; on virtual GPUs session forces software rendering (`LIBGL_ALWAYS_SOFTWARE=1`). [V] Whether they matter on real GPUs is [Q].
- Live-medium services enabled by default (`etc/systemd/system/multi-user.target.wants`): ModemManager, bluetooth, sshd, hv_{fcopy,kvp,vss}_daemon, vboxservice, vmtoolsd, vmware-vmblock-fuse, cloud-init (5 units), pcscd.socket, choose-mirror, livecd-talk, systemd-resolved plus NetworkManager. [V] Hyper-V/VMware/VBox daemons are skipped by `ConditionVirtualization` upstream on bare metal [A: not checked per unit]; still ModemManager/sshd/cloud-init cost boot time and RAM and enlarge attack surface on the live medium.
- The shell is one Quickshell process (one Qt scene graph per surface) [V ADR / perf doc]; 433 MB RSS is the largest single runtime cost, an order of magnitude above labwc.

## 6. Opportunities (each with all required fields)

Effort: S under a day, M a few days, L a week+. Benefits labelled [V] measured or [A] estimate.

### 6.1 Drop `code` (and electron42) from the live ISO
- **Problem:** 1102 MiB installed (22% of rootfs); not on the installed system; Hub installs it on demand.
- **Solution:** remove `code` from `iso/phase3/packages.x86_64`; keep it in the Hub catalogue (already in `catalog/developer-hub.json` per ADR-021 list).
- **How:** fewer packages to pacstrap and squash.
- **Benefit:** [A] ISO -350 to -450 MiB, build -3 to -4 min (xz time scales with bytes: 113 s per 857 MiB).
- **Disadvantages:** no VS Code in an offline live session; Hub demo of "install code" would need network (it already does).
- **Complexity:** S. **Compat risk:** low; check tests `phase7-hub-apps.py` do not require `code` in the live image [Q2].
- **Verdict:** do it first. Biggest single win.

### 6.2 Prune releng rescue/legacy packages
- **Problem:** ~250 MiB installed of tools that do not match the product (developer desktop, not a rescue disc): nmap, irssi, lynx, mc, clonezilla/partimage/fsarchiver, pptp/vpnc/wvdial/xl2tpd, brltty/espeakup/espeak-ng, cloud-init, hyperv/open-vm-tools/vbox, jfs/nilfs/f2fs utils, linux-atm, b43-fwcutter, memtest, refind, edk2-shell, man-pages.
- **Solution:** start from a short list (base, linux, firmware, installer deps, desktop deps); keep filesystem tools actually used by the installer (btrfs, e2fs, dosfs, ntfs/exfat if disk handling needs them) and archinstall deps.
- **How:** edit the list; `pacman -Qi`-style diff; run `tests/qemu-boot.sh`, `phase6-install.py` as regression.
- **Benefit:** [A] -250 MiB installed, about -80 to -100 MiB compressed; fewer boot units (cloud-init, ModemManager, vbox, hv) and smaller attack surface.
- **Disadvantages:** loses rescue use (ADR scope: "Live/Rescue Medium" in `iso_application`; decision for the owner, Q4); brltty/espeakup are accessibility features, keep or replace deliberately.
- **Complexity:** M (each removal needs the installer and boot test). **Compat risk:** medium (archinstall may need some utilities; mkinitcpio-archiso needs some).
- **Verdict:** worth it, in small batches; keep accessibility until a replacement exists.

### 6.3 Initramfs diet (affects the ISO twice)
- **Problem:** 238 MiB initramfs duplicated into `efiboot.img` (265 MiB) = about 500 MiB of ISO. 147 MiB is firmware via `kms`; PXE hooks pull nbd-client/curl/nfsmount/mount.cifs; bcachefs 9 MiB.
- **Solution:** (a) drop `archiso_pxe_{common,nbd,http,nfs}` hooks (archiso docs describe them as network-boot only); (b) test live boot without `kms` (simpledrm/efifb gives a framebuffer, GPU drivers load from the squashfs); (c) drop `bcachefs-tools` unless the installer offers bcachefs; (d) optionally `MODULES_DECOMPRESS`/xz settings do not change the uncompressed early part, so rely on (a)-(c).
- **How:** edit `iso/phase3/airootfs/etc/mkinitcpio.conf.d/archiso.conf`.
- **Benefit:** [A] initramfs 238 to maybe 60-90 MiB; ISO -300 to -350 MiB because of the double copy; faster early boot (less to read/decompress).
- **Disadvantages:** (b) removes early KMS: Plymouth/boot splash (ADR-025) and graphical LUKS prompt on the installed system would lose smooth modeset and might fall back to simpledrm; the installed system's initramfs is built separately by the installer and is unaffected. PXE boot of the live image lost.
- **Complexity:** S for (a)/(c), M for (b) (needs boot evidence on real GPUs). **Compat risk:** (b) medium, hardware-dependent; cannot be validated in QEMU alone.
- **Verdict:** (a)+(c) yes now; (b) only after real-hardware tests. Highest ISO-size-per-effort after 6.1 and the compression change.

### 6.4 Keep the repo from eating the disk
- **Problem:** 56 GiB of old QEMU evidence in `iso/out-phase3-fix/evidence`, 90% full host disk; a full build needs ~8 GiB work tree + ISO + cache.
- **Solution:** make the evidence recorders keep only logs/screenshots/serial output, delete disk images after the test, and move bulk artifacts out of the tree.
- **Benefit:** [V] 56 GiB reclaimable (verify the content before deleting). **Disadvantages:** none beyond evidence policy (AGENTS.md wants retained evidence; images are not evidence, logs are). **Complexity:** S. **Verdict:** do it; I did not delete anything.

### 6.5 Squashfs compression: choose by purpose
- **Problem:** xz costs 11 min/build and CPU on live read; release size is what xz is good at.
- **Solution:** two profiles: `dev` builds use zstd level 3 to 15 at 256K-1M blocks; `release` keeps xz or zstd-19. `airootfs_image_tool_options` is a profiledef variable so it can be overridden by script via an env var.
- **Benefit:** [V on sample] zstd-15: -77% squashfs time (113 to 26 s per 857 MiB), +16% size; zstd-3: -96% time, +31% size. Whole-image estimate: squashfs 11 min to ~2.5 min (zstd-15) [A].
- **Disadvantages:** dev ISO bigger by 300-550 MiB; two configs to keep tested; release path must be exercised in CI/QEMU at least once per milestone. Boot-speed benefit not yet measured.
- **Complexity:** S. **Compat risk:** low (kernel supports squashfs zstd; the archiso initramfs mounts via kernel).
- **Verdict:** worth it for dev builds. For release, measure live boot time (xz vs zstd-19) on the same ISO before changing (Q5).

### 6.6 Skip rebuilds: reuse the work tree and cache packages
- **Problem:** `_rm_work "$WORK"` wipes everything; all 745 packages are re-pacstrapped; a one-line QML change costs ~21 min. Packages download from the network each time unless host cache is warm. Note mkarchiso already has sentinel files and resumes steps if the work dir is kept.
- **Solution (layered):**
  1. Do not wipe the work dir for dev builds; delete only the sentinels of steps that depend on changed inputs (`base._make_custom_airootfs`, `base._mkairootfs_squashfs`, `base._prepare_airootfs_image`, `iso._build_iso_image`). The pacstrap result stays. [A: need to check mkarchiso internals for what depends on what]
  2. Better: ship Axiom's own files as a **small package** (`axiom-desktop`, PKGBUILD installing shell/apps/greeter/provision to `/usr/local/...` or `/usr/share/axiom`) served from a **local repo** (`repo-add`, `file://` Server in `pacman.conf`). Package-level rebuild is seconds; pacstrap only reinstalls that package. Same package also feeds the installed system, removing the duplicated `BASE_PACKAGES` mirror in `installer/axiom_install.py`.
  3. Local mirror/cache: `CacheDir` pointing to a persistent dir (the installer driver already shares the host cache per commit c252539), plus a `file://` local copy of core/extra for reproducible builds.
- **Benefit:** [A] cold build unchanged (~21 min, ~10 with zstd), warm no-package-change build about 3-4 min with zstd (squashfs + ISO), 1-2 min if combined with a smaller dev package set.
- **Disadvantages:** stale-cache risk (a kept work dir can hide breakage; release builds must stay clean), a PKGBUILD to maintain, signing/trust of the local repo (`SigLevel` Optional for local file repo only; do not weaken the remote repos' `Required`). The existing script rule "never disable signature verification" must stay true.
- **Complexity:** step 1 S-M, step 2 M-L (it also changes how files are owned/permissioned, `file_permissions`), step 3 S. **Compat risk:** medium for step 2 (touches installer and the ownership model; needs ADR per AGENTS.md).
- **Verdict:** step 1 + 3 now, step 2 as the long-term architecture (one package to ship both ISO and installed system).

### 6.7 Remove or lighten the duplicate toolkit stack
- **Problem:** GTK3 (53 MiB) is pulled by firefox, mousepad, polkit-gnome, portal-gtk; Qt6 for the shell.
- **Solution:** replace `mousepad` with an Axiom/Qt editor or drop it; replace `polkit-gnome` with a Quickshell polkit agent (Quickshell has a polkit module; confirm in current version [Q6]); keep firefox (it needs GTK anyway).
- **Benefit:** [A] since firefox keeps GTK3, saving is only ~5-10 MiB (mousepad, polkit-gnome, gtksourceview). Low.
- **Verdict:** **not worth it** for size now. Revisit only if the Axiom editor lands for other reasons.

### 6.8 Locale/doc/man trimming
- **Problem:** locale 241 MiB, man 140, doc 108, info 9 (about 500 MiB uncompressed; maybe 120-150 MiB compressed [A]).
- **Solution:** pacman `NoExtract` in the **build** `pacman.conf` (`usr/share/locale/*` except `en*`, `usr/share/doc/*`, `usr/share/man/*`, `usr/share/info/*`), applied via the same `pacman.conf` that mkarchiso reads. Keep locales needed by installer language support (ADR-035 mentions a locale map; check which).
- **Benefit:** [A] -100 to -150 MiB ISO, build -1 to -2 min. **Disadvantages:** no man pages on the live system; installed system is a separate pacstrap and unaffected (the installer would need its own NoExtract if wanted); partially-translated live UI; some packages' post-install hooks assume files exist (rare). **Complexity:** S. **Compat risk:** low-medium.
- **Verdict:** worth it for docs/man/info; locale trimming only after checking the installer language list.

### 6.9 Firmware set
- **Problem:** 579 MiB installed (about 12%), nvidia 104 MiB (nouveau GSP) etc.
- **Solution:** none recommended broadly. Possible: drop `linux-firmware-marvell` (79 MiB, old SoC/wifi) and `linux-firmware-nvidia` only if hardware testing shows nouveau isn't used (it is the default on NVIDIA). `sof-firmware` (55 MiB) is needed for modern laptops' audio.
- **Benefit:** [A] up to ~80-180 MiB installed, about 30-70 compressed. **Disadvantages:** real hardware not booting its GPU/Wi-Fi/audio is the worst outcome for a first-run desktop. **Complexity:** S. **Compat risk:** high.
- **Verdict:** only marvell is a low-risk candidate; leave the rest. Do not prune firmware without a hardware matrix.

### 6.10 Boot services on the live ISO
- **Problem:** ModemManager, sshd, cloud-init (5 units), vbox/vmware/hv daemons, choose-mirror, livecd-talk enabled on a graphical installer medium.
- **Solution:** disable (do not install) the unneeded ones; `systemd-analyze critical-chain/blame` first. NetworkManager-wait-online and `pacman-init` (keyring populate) are likely the true serial cost on first boot [A].
- **Benefit:** [A] a few seconds and 20-60 MiB RAM; the earlier perf run noted a job waiting for time sync (~tens of seconds in a no-network guest, a VM artefact). **Disadvantages:** sshd on live is a debugging convenience for tests (`tests/` may rely on it, Q2). **Complexity:** S. **Compat risk:** low.
- **Verdict:** worth it after measuring; first get a real `systemd-analyze` baseline.

### 6.11 Runtime: Quickshell memory and Hyprland effects
- **Problem:** 433 MB RSS shell [V, labwc harness, software GL]. Software GL multiplies per-window buffers, so the figure may be inflated vs a real GPU [A].
- **Solution:** measure first on real hardware with Hyprland; then profile QML (Qt Quick scene graph, `QSG_` env visual debugging, loaders for rarely-used popups, image `sourceSize`, avoid layer effects, shader effects). Turn Hyprland shadows/animations into a "performance" toggle only if measured; blur is already off.
- **Benefit:** [A] unknown; the 433 MB figure is the largest runtime lever. **Disadvantages:** engineering time; visual regressions. **Complexity:** M. **Verdict:** measure now, optimize only on evidence (AGENTS.md: no performance claims without measurements).

### 6.12 ISO layout: avoid the second kernel copy
- **Problem:** `efiboot.img` is 265 MiB because it contains kernel + initramfs.
- **Solution:** after 6.3 the FAT image shrinks proportionally. A UKI or loading kernel from the ISO9660 side requires different boot loader (systemd-boot cannot read ISO9660; GRUB can) and is a boot-chain replacement (ADR needed).
- **Benefit:** [A] beyond 6.3, up to another ~250 MiB. **Disadvantages:** bootloader change on a boot path that is already QEMU-verified; hardware boot risk. **Complexity:** L. **Verdict:** not now.

### 6.13 Alternative image formats (EROFS)
- **Problem/Idea:** Fedora is moving live media to EROFS ([Fedora EROFSforLiveMedia](https://www.fedoraproject.org/wiki/Changes/EROFSforLiveMedia)): on-par size, slightly better build time for KDE.
- **Verdict:** archiso supports `airootfs_image_type="erofs"` (since v77 [A, not checked against the installed archiso version]); gains are small vs 6.5. **Not worth it** now.

### 6.14 Bootstrap tarball
`bootstrap_tarball_compression=zstd -19 --long` only affects `bootstrap` build mode, which is not built here [V]. No action.

## 7. Comparison notes (reliable facts only; the rest is flagged)

- **Arch releng/archiso:** same defaults as here (xz, bcj, 1M block). Releng ISO is a rescue medium with no desktop. [A from memory of upstream profile; upstream docs could not be fetched: gitlab.archlinux.org answered with an Anubis block.]
- **Fedora:** moved Live media to plain squashfs with xz 1M block (-142 MiB on Workstation F31), debated zstd (faster, +11-26% size) and is moving to EROFS. Their conclusion: size vs compose-time tradeoff is a project decision; the same applies here (sources above).
- **Omarchy / Alpine / NixOS / minimal distros:** not measured by me and not fetched. Axiom's host runs Omarchy 4.0.6 (`docs/updatephase6.md`). General facts I would hold only as [A]: Alpine's live ISO is small because of musl/busybox and a tmpfs-loaded apkovl; NixOS ISOs share a read-only store with a squashfs zstd/xz image. None transfers directly to an Arch/glibc/systemd desktop, so no copy-from-other-distro proposal is made.

## 8. Recommended implementation order

1. **Measure baselines first** (S): `systemd-analyze time/blame/critical-chain` and idle RAM on the current ISO in QEMU with network and on at least one real machine; Hyprland session RSS/PSS. Without this nothing in 6.10/6.11 can claim a gain.
2. **Quick wins for size** (S): 6.1 (drop code), 6.3a/c (PXE hooks, bcachefs), 6.8 (docs/man/info NoExtract).
3. **Dev build speed** (S): 6.5 zstd dev profile via env override; 6.6 steps 1 and 3 (keep work dir, persistent CacheDir).
4. **Package pruning** (M): 6.2 in batches with `phase6-install.py`, `qemu-boot.sh`, `phase7-*` regressions after each batch.
5. **Boot services** (S): 6.10 with measurements.
6. **Repo hygiene** (S): 6.4.
7. **Longer term** (M-L): 6.6 step 2 (axiom-desktop package + local repo, one ADR; also eliminates installer BASE_PACKAGES drift), 6.3b (kms), 6.11 QML profiling, offline install source (ADR-035 item 6) which interacts with ISO size: an offline pacman repo inside the ISO would add package size, so decide it together with the size budget.

Estimated combined result of steps 2-4 [A]: ISO 2350 to roughly 1.3-1.5 GiB (code -400, initramfs/efiboot -300, rescue -90, docs -120), cold build from ~21 min to ~12 min with xz or ~6 min with zstd-15.

## 9. High-impact quick wins (summary)

| Change | ISO | Build | Effort |
|---|---|---|---|
| Remove `code` | -350..-450 MiB [A] | -3..-4 min [A] | S |
| Drop PXE hooks + bcachefs from initramfs | -150..-300 MiB (double copy) [A] | small | S |
| NoExtract docs/man/info | -50..-100 MiB [A] | -1 min | S |
| zstd-15 dev squashfs | +290 MiB [A], dev only | squashfs -77% [V sample] | S |
| Keep work dir/cache | none | warm 21 to ~4 min [A] | S-M |

## 10. Open questions

- Q1: Why is the early CPIO 220 MiB and what exactly belongs to it (firmware from `kms`)? A `mkinitcpio -v` log of the build would settle it; the build.log in evidence may already show it.
- Q2: Do `tests/phase7-*` or the Hub rely on `code`, sshd or other live-session packages being present?
- Q3: What requires `nodejs`/`npm`/`python-pipx` on the ISO (73+ MiB)? Probably Hub toolchain install paths; not verified.
- Q4: Is the product still a "Live/Rescue Medium" (profiledef) or a developer install medium? Determines how aggressive 6.2 can be.
- Q5: Real-hardware live boot time and read speed xz vs zstd; I measured size/compression time only.
- Q6: Does the installed Quickshell version offer a polkit agent (6.7), and would an Axiom polkit agent respect the project's privilege rules?
- Q7: Is the work tree at `/var/tmp/axiom-work` still wanted? I did not touch it.
- Q8: Offline install source (ADR-035 item 6): size budget vs network requirement.

## 11. Not checked

No bare-metal numbers, no Hyprland idle numbers, no per-package compressed sizes, no boot-time (`systemd-analyze`) data on the current ISO, Omarchy/Alpine/NixOS internals not fetched, archiso upstream docs not reachable (Anubis block).
