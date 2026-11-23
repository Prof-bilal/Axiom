# Phase 8 pre-work 04: Linux feature gap analysis

Date: 2026-11-23. Research and roadmap only; no source changed. Scope: what a
daily-driver Linux desktop needs that Axiom lacks, checked against code first.
Other reports in this folder (audit, git, ISO optimization, differentiation)
are referenced, not repeated.

Evidence labels: **V** verified in this repo (grep/read), **A** assumed (not
tested at runtime), **R** recommended, **O** open question.

## 1. Method and limits

- Inventory: read AGENTS.md, PHASES, ROADMAP, ADR-030/033, `iso/phase3/packages.x86_64`,
  `installer/axiom_install.py`, `hyprland.lua`, shell services/surfaces, Settings pages,
  Hub catalog. Each "Missing" below was grepped across `shell/ apps/ iso/phase3/airootfs
  system/ installer/ greeter/ provision/ catalog/ docs/decisions` (keywords in section 4).
- Omarchy: read the official manual (https://learn.omacom.io/2/the-omarchy-manual) and the
  repo page (https://github.com/basecamp/omarchy). Individual manual pages on GitHub returned 404,
  so security and snapshot details are from the manual summary only. Omarchy is not installed
  on the sandbox host in a readable form, so no code was read.
- Fedora, Ubuntu, Arch, EndeavourOS, NixOS, Bazzite, COSMIC, elementary, Manjaro: **no network
  fetches were made for these**; comparisons rest on well-known public behavior (A). Primary
  sources to confirm before an ADR: https://docs.fedoraproject.org, https://ubuntu.com/server/docs,
  https://wiki.archlinux.org, https://nixos.org/manual, https://docs.bazzite.gg,
  https://github.com/pop-os/cosmic-epoch, https://elementary.io/docs.
- Axiom's ADR-001 removes Omarchy as a foundation; it is used here as a feature reference only.

## 2. Stage 1: Axiom inventory (verified)

| Area | Status | Evidence |
| --- | --- | --- |
| Desktop environment | Implemented | Quickshell QML shell (panel, dock, launcher, activities, control centre, session menu); Hyprland default, labwc fallback (ADR-029/031) |
| Hyprland workflows | Partially | Floating-only, 4 fixed workspaces, snap halves, Alt+Tab switcher, minimize hack. No tiling, no per-app workspace rules beyond float/fit, no keybinding overlay |
| Launcher | Implemented | `shell/src/launcher/Launcher.qml` (desktop entries); command palette and typed actions planned (Track 1 / D2) |
| Terminal | Implemented | foot via `axiom-terminal`, OSC 7, finish notification |
| File manager | Implemented | `apps/files` (trash, restore, hostile names). No thumbnails, no mounts/devices sidebar, no network shares (grep: udisks, mtp, smb = 0) |
| Settings | Partially | Pages: About, Appearance, Bluetooth, DateTime, DefaultApps, Displays, Dock, Keyboard, Network, Notifications, Power, Sound, Users. No Printers, Privacy/Security, Accessibility, Language/Region, VPN, Firewall |
| Installer | Implemented | Native QML live installer (ADR-035) + archinstall driver; LUKS optional, systemd-boot, btrfs, swap zstd, snapper setup on first boot, locale/timezone/keyboard |
| Boot experience | Implemented | Plymouth + framebuffer boot UI (ADR-025/027) |
| Login/session | Implemented | greetd graphical greeter (ADR-024), lock screen via ext-session-lock + PAM |
| Idle lock / auto-lock | **Missing** | `IdleBlank.qml` only turns screens off; no lock on idle, none before suspend (grep PrepareForSleep, hypridle = 0); no Lock keybind in `hyprland.lua` (menu and IPC only) |
| Networking | Partially | NetworkManager, Wi-Fi join/reject (Phase 5 evidence). No VPN UI or WireGuard/OpenVPN plugins in the installed set (openvpn only on live ISO package list), no hotspot, no per-network metered flag |
| Bluetooth | Implemented | bluez + Settings page (no controller in VM, real hardware unproven) |
| Audio | Implemented | PipeWire/WirePlumber, volume OSD, Settings Sound. No per-app mixer (F6) |
| Display mgmt | Partially | Scale with revert, wlr-randr; no night light (grep = 0), no multi-monitor layout UI beyond read-only |
| Power mgmt | Partially | power-profiles-daemon, idle screen-off, brightness. Hibernate not wired (2 doc mentions only); no battery-aware defaults, no low-battery action |
| Package mgmt / software install | Implemented | pkgd polkit helper, Software Center search/install/remove, Hub (pacman, Flatpak ADR-034, npm/pipx, AppImage, .deb via distrobox ADR-028). AUR not supported |
| Updates | Implemented | `axiom-pkg-update` with snapshot first, rollback by number (ADR-033). No firmware updates (fwupd = 0), no scheduled/auto update check surfaced |
| Backup / recovery | Partially | snapper root snapshots and rollback tested (20/20). `/home` is not backed up (F7 idea only); no boot-time snapshot selection (systemd-boot has no snapshot menu; grub-btrfs/limine = 0); ISO ships clonezilla/testdisk but not as a recovery product |
| Hardware support | Partially | linux-firmware, ucode, sof-firmware on live ISO; installed set has no `sof-firmware`, no NVIDIA stack, no printer/scanner, no fingerprint. Phase 10 owns the matrix |
| Notifications | Implemented | org.freedesktop.Notifications server, toasts, history, DND, per-app mute |
| Screenshots / recording | Implemented | CaptureBar: grim, wf-recorder, wl-copy (ADR-030). Verified on host; QEMU/pkg verification pending per ADR. No preview card/annotation (D4), no OCR |
| Clipboard | Partially | wl-clipboard present; **no history** (cliphist = 0); Files has its own internal clipboard |
| Accessibility | **Missing** | Only text-size setting and "reduce transparency" planned; no screen reader (orca = 0, brltty/espeakup on live ISO only), no high contrast, large cursor, sticky keys, on-screen keyboard |
| Security | Partially | Polkit-gated helpers, bubblewrap, no UI as root. **No firewall** (nftables is mentioned once in docs, no ruleset), no AppArmor/SELinux, no Secure Boot/TPM unlock, no secret store/keyring (libsecret, gnome-keyring = 0), no FIDO2/fingerprint PAM |
| Printing / scanning | **Missing** | cups, sane, avahi = 0 |
| Removable media | **Missing** | udisks2 not in package sets; gvfs present but no automount, no UI to eject |
| Input methods / i18n | Partially | Keyboard layout page and installer locale map; no IME (fcitx5/ibus = 0), no emoji picker, no language/region settings page post-install |
| Screen-share portal | **Assumed gap (A)** | Package list has xdg-desktop-portal-wlr but not `xdg-desktop-portal-hyprland`, and no `portals.conf`; browser screen sharing on the Hyprland session is untested. Open question O3 |
| AI integration | Planned | Phase 11/12, ADR-023; Hub lists Ollama, Claude/others only as installable tools |
| Axiom Hub | Implemented | `apps/hub`: catalog, installing page, local install, installed page; one-click update-all planned |
| Memory/swap tuning | Partially | archinstall swap zstd (zram); no earlyoom/systemd-oomd decision (grep = 0) |
| Mirrors / time | Implemented | choose-mirror on live; timesyncd enabled. Installed system has no reflector/mirror refresh (reflector = 0 in installed set) |

## 3. Stage 2: competitor reference (what users get)

| Distro | Behavior worth studying | Source status |
| --- | --- | --- |
| Omarchy | One Super+Alt+Space menu for everything (install, style, update, toggles); universal clipboard with history (Super+Ctrl+V); OCR to clipboard (Tesseract); screenshots with editor; dictation (Voxtype); reminders; Super+K binding overlay; snapshots on each update bootable from Limine; fingerprint for lock/sudo, FIDO2 for sudo; firewall allowing only SSH and LocalSend; mandatory LUKS; web apps in own profiles; hibernate toggle; four update channels; omarchy-debug/reinstall. Weak: tiling-first, Secure Boot/TPM unsupported, VPN and accessibility not covered in the manual | V (manual) |
| Fedora Workstation | firewalld on by default; SELinux enforcing; fwupd/GNOME Software firmware updates; offline updates; Btrfs default with snapshots optional; Orca, Sticky Keys, on-screen keyboard via GNOME; IBus; CUPS with driverless IPP; PackageKit | A |
| Ubuntu | ufw installed (off by default); AppArmor; Software Updater with livepatch; Snap store; fwupd; hardware enablement kernels; accessibility menu in panel; "Additional drivers" for NVIDIA; automatic printer discovery | A |
| Arch / EndeavourOS | Wiki-first; EndeavourOS adds `eos-welcome`, `reflector-simple`, `rate-mirrors`, a Welcome app that bundles update/mirror/clean-up tasks, and `eos-update-notifier`; NVIDIA driver auto-detect in installer | A |
| NixOS | Declarative generations with boot menu rollback of the whole system (including bootloader entries); strong reproducibility. Not adoptable without replacing pacman | A |
| Bazzite | Image-based (rpm-ostree), atomic rollback, gaming defaults, HDR, Steam Gaming Mode, ujust recipes | A |
| Pop!_OS COSMIC | Native Rust compositor, tiling toggle, panel applets, Settings with accessibility, a11y screen reader, workspace management, built-in firmware and recovery partition | A |
| elementary OS | Strict per-app permissions via Flatpak, sideload UI, Night Light, Do Not Disturb, Pantheon accessibility | A |
| Manjaro | Hardware detection (`mhwd`) installs NVIDIA drivers, kernel manager GUI, Timeshift snapshots | A |

Pattern across mainstream desktops: **firewall on, printing, removable media,
accessibility, input methods, firmware updates, and a secret store are all
default.** Omarchy omits several (accessibility, VPN, printing) because it
targets keyboard-driven developers; Axiom should not copy that omission because
its identity is a mouse-and-keyboard desktop for new users (`PHASES` release goal).

## 4. Stage 3: comparison and prioritization

Priority: P0 blocks "daily driver" release, P1 expected within Track 1, P2 after.
Complexity: S/M/L. Grep terms used for "missing" claims are in section 2.

### Essential foundations

| Feature | What it does | Axiom | Reference | Why needed | Pri | Cx | Depends | Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Idle auto-lock and lock-before-suspend | Locks after N min and before sleep | Missing (screen-off only) | All mainstream; Omarchy hypridle | Unlocked laptop on a table is a security hole; lock screen already exists | P0 | S | LockScreen, IdleBlank | Reuse the existing `IdleMonitor`; add `lockMinutes` setting and a `PrepareForSleep` inhibitor-based lock; add a Lock keybind (Super+L) |
| Default firewall | Deny-inbound default | Missing | Fedora firewalld, Omarchy ufw | Wi-Fi on public networks | P0 | S | Phase 7 pkgd | nftables ruleset (already in base, no new daemon) enabled by the installer; ADR for choice versus ufw/firewalld; Settings status page (read-only first) |
| Removable media | Auto-mount, eject, unlock | Missing | GNOME/KDE via udisks2 | USB sticks are the first thing a user plugs in | P0 | M | polkit, Files | udisks2 + gvfs-udisks; Files devices sidebar; polkit rules limited to the active session |
| Printing | CUPS with driverless IPP, Settings page | Missing | Fedora/Ubuntu | Needed for offices/schools | P1 | M | avahi, Settings | `cups` + `cups-filters` + `avahi` + `nss-mdns`, socket-activated; Settings > Printers; scanner (SANE) deferred |
| Clipboard history | Text/image history picker | Missing | Omarchy, GNOME ext | Daily productivity | P1 | S | wl-clipboard | `cliphist` or in-shell service; excluded for password manager entries (use `CLIPBOARD_STATE=sensitive`); size and retention limits |
| Secret store / keyring | Secret Service for Firefox, SSH, Wi-Fi | Missing | Fedora, Ubuntu | Browsers and Git credentials otherwise fall back to plaintext | P1 | M | greeter PAM | Decide `gnome-keyring` vs KeePassXC secret service in an ADR; unlock via PAM at greeter; Phase 11 builds on it |
| Accessibility baseline | Screen reader, high contrast, large cursor, sticky keys, reduced motion | Missing | GNOME, COSMIC | Legal and ethical floor; also tests honesty claims | P1 | L | Settings, Theme | Orca with AT-SPI check on Quickshell (A: Quickshell may not expose AT-SPI; O1); ship what works and state limits; large cursor and reduced motion are easy wins |
| Input methods and emoji | IME for CJK, compose, emoji picker | Missing | Fedora IBus, Ubuntu | Global user base | P1 | M | Keyboard page | fcitx5 with Wayland text-input-v3; verify under Quickshell text fields (O2) |
| Language and region page | Change locale after install | Partial | GNOME | Installer-only today | P1 | S | settings store | Settings > Language and Region writing `/etc/locale.conf` through a narrow helper |
| Screen-share portal | Browser/meeting screen sharing | Assumed gap | All | Video calls | P0 | S | portals | Add `xdg-desktop-portal-hyprland` and `portals.conf`; test in QEMU with a browser |
| Fonts and emoji coverage | CJK/emoji glyphs | Partial (`noto-fonts` only) | Fedora | Missing glyph boxes | P1 | S | none | add `noto-fonts-cjk`, `noto-fonts-emoji` |

### Desktop experience

| Feature | What | Axiom | Reference | Why | Pri | Cx | Depends | Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Keybinding overlay | Shows all shortcuts (Super+K) | Planned | Omarchy | Discoverability | P1 | S | hyprland.lua | Generate from the bind table so it cannot drift |
| Night light | Warm display schedule | Missing (F6 idea) | GNOME, elementary | Comfort; frequently requested | P2 | S | Hyprland CTM/hyprsunset or wl-gammarelay | Needs measurement of GPU-less QEMU limit; keep in Phase 10 |
| Per-app volume mixer | Sliders per stream | Missing (F6) | GNOME, KDE | Calls vs music | P2 | S | PipeWire | Phase 10 |
| Thumbnails in Files | Image/PDF previews | Missing | all | Usability | P1 | M | Files | `ffmpegthumbnailer` and gdk-pixbuf via `tumbler` or in-app; resource limits against hostile files |
| Default media/image/PDF viewers | Open common files | Missing (grep imv/mpv = 0) | all | Double-click on a photo does nothing useful | P0 | S | mimeapps | Add small viewers (e.g. `imv` or gwenview-free alternative, `mpv`, `zathura` or `evince`) and mime defaults |
| Archive handling | Extract/compress in Files | Not verified | all | Basic file task | P1 | S | Files | Check and add `unzip`/`7zip`/`bsdtar` UI action |
| Network shares | SMB/SFTP in Files | Missing | all | Offices | P2 | M | gvfs-smb | After D6 Connections |

### Developer experience

| Feature | What | Axiom | Reference | Pri | Cx | Recommendation |
| --- | --- | --- | --- | --- | --- | --- |
| Toolchains, containers, editors | Hub catalog | Implemented | Omarchy menu | done | | Phase 9 completes |
| Shell niceties (fzf, zoxide, ripgrep, man-db/tldr) | Fast shell | Partial (zshrc; man-pages on live only) | Omarchy | P2 | S | Phase 9 optional set |
| Dev-focused local sharing (LocalSend-like) | LAN file send | Missing | Omarchy | P2 | M | Prefer Hub entry, not default; needs firewall rule decision |
| Terminal multiplexer, lazygit, btop | TUIs | btop, tmux on ISO | Omarchy | P2 | S | Hub |

### System management

| Feature | What | Axiom | Reference | Why | Pri | Cx | Depends | Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Boot-time snapshot rollback | Pick a snapshot when the system will not boot | Missing | Omarchy Limine, NixOS, openSUSE | Current rollback needs a working system | P1 | L | ADR-002/005 | Research systemd-boot vs `limine`/`grub-btrfs`; do not change the loader without an ADR; a recovery USB (Phase 13) is the fallback |
| Snapshot retention and space | Cleanup policy | Open in ADR-033 | Snapper timeline | P0 | S | Disk fills otherwise | Set snapper limits and show usage in Settings |
| `/home` backup / restore points | User data copy | Missing (F7) | Timeshift (Manjaro), macOS | P1 | M | Snapshots do not protect `/home` | Phase 8 doc plus Phase 9 optional: btrfs home snapshots (read-only, local) and external-drive send |
| Firmware updates | Vendor firmware via LVFS | Missing | Fedora, Ubuntu | P1 | M | fwupd | Phase 10; include in Hub/Settings update view |
| Mirror refresh on installed system | Healthy updates | Missing | EndeavourOS | P1 | S | reflector timer or fixed mirror set; avoid slow default mirrors | 
| Update notifier and schedule | Shows "N updates" | Missing | all | P1 | S | Software Center | Check-only timer; never auto-install without snapshot |
| OOM and memory handling | Avoid freezes | Missing decision | Fedora systemd-oomd | P1 | S | Enable `systemd-oomd` (already in systemd) and verify with test |
| Hibernate | Disk suspend | Missing | Omarchy | P2 | M | Needs swap file offsets on btrfs and LUKS resume; Phase 10 |
| Crash/log reporting | Bug report with system info | Missing | Omarchy `omarchy-debug` | P1 | S | `axiom-debug` script that collects journal/pkg list locally, no auto-upload |
| Disk health/storage settings | Disk usage, SMART | Missing | GNOME Disks | P2 | M | Settings > Storage, read-only first |
| Multi-user and parental | Users page exists | Partial | all | P2 | | Keep |

### Security and privacy

| Feature | Axiom | Reference | Pri | Cx | Recommendation |
| --- | --- | --- | --- | --- | --- |
| Firewall (above) | Missing | | P0 | S | |
| Secure Boot and TPM unlock | Missing (Secure Boot listed unresolved in ADR-002) | Fedora, Ubuntu; Omarchy lacks | P2 | L | `sbctl` + UKI + TPM2 LUKS unlock research ADR after Phase 13 signing exists |
| Fingerprint and FIDO2 login | Missing | Omarchy, Fedora | P2 | M | `fprintd` + PAM profile; greeter already shows PAM text (ADR-024); Phase 10 |
| Privacy dashboard and camera/mic indicators | Missing (F8) | GNOME, COSMIC | P2 | M | Needs PipeWire permission portal checks; Phase 11 |
| Mandatory access control | Missing | Fedora SELinux, Ubuntu AppArmor | P2 | L | Do not adopt now; Landlock/bubblewrap is the ADR-023 route |
| Per-app permission UI for Flatpak | Missing | elementary | P2 | M | Surface `flatpak override` state in Hub details |
| Disk encryption | Implemented (optional LUKS) | Omarchy mandatory | P1 | | Recommend default-on, user-visible choice (O4) |

### Application ecosystem

| Feature | Axiom | Reference | Pri | Cx | Recommendation |
| --- | --- | --- | --- | --- | --- |
| Browser | Firefox | all | done | | Keep; portals and keyring need testing |
| Office, mail, PDF form fill, media player | Missing | Fedora/Ubuntu | P1 | S | Hub featured entries (LibreOffice, a PDF viewer), no bundling |
| Web apps | Idea F3 | Omarchy | P2 | M | Keep Track 3 |
| Gaming (Steam, Proton) | Not planned | Bazzite | P2 | M | Out of scope for the release; Hub category later (multilib decision) |
| AUR access | Not supported | Omarchy, EndeavourOS | P2 | L | Do not enable by default; unsandboxed build scripts conflict with ADR-032 |
| Driver management (NVIDIA) | Missing | Ubuntu, Manjaro | P1 | L | Phase 10 detection, with explicit consent |

### AI-native and advanced and differentiating

| Feature | Axiom | Reference | Pri | Recommendation |
| --- | --- | --- | --- | --- |
| OCR to clipboard | Missing (Capture D4 includes OCR) | Omarchy | P2 | Keep in D4; Tesseract is optional package |
| Dictation | Missing | Omarchy Voxtype | P2 | Local-only, later; belongs after Phase 12 voice ADR |
| Reminders and quick notices | Missing | Omarchy | P2 | Small; can ride on D2 actions |
| Typed actions, agent grants | Planned | None mature | | Axiom's identity; see differentiation report (reports/phase-8 sibling) |
| Windows VM / app compat | Missing | Omarchy Docker Windows, Bazzite Bottles | P2 | Track 3; separate ADR |
| Image-based/atomic OS | Not applicable | Bazzite, NixOS | | Out of scope: Axiom stays Arch + pacman + snapper (ADR-001/005) |

## 5. Biggest gaps

1. No auto-lock and no lock before suspend, though the lock screen exists.
2. No firewall.
3. No removable media, printing, or default media/image/PDF viewers.
4. No accessibility support beyond text size; no IME or emoji.
5. Unverified screen-share portal on Hyprland; no secret store.
6. Recovery depends on a booting system (no snapshot boot menu); `/home` is unprotected.
7. Firmware, mirror refresh, update notification and OOM handling absent.

## 6. Changes made to docs/PHASES.md (and why)

Small additive edits only; no completed phase touched.
- Phase 8 section: added a "Gap-analysis additions (2026-11-23)" list of P0/P1 items and an
  acceptance rule that each has a QEMU check and a written limit where unproven.
- Phase 10: added firmware updates, fingerprint/FIDO2, hibernate, night light/per-app mixer,
  NVIDIA detection, boot-time snapshot rollback research.
- Phase 13: added Secure Boot/TPM research ADR and recovery media content for non-booting systems.
- Phase 9: added optional shell tools and `/home` restore points note.
- Track 3: promoted nothing; F6/F7/F8 cross-referenced.
- Header table row for Phase 8 extended with the new items.

## 7. Open questions

- O1 Does Quickshell expose AT-SPI so Orca can read the shell? Needs a runtime test; if not, accessibility must be stated as partial.
- O2 Do Quickshell text inputs honor text-input-v3 for fcitx5?
- O3 Does screen sharing work in Firefox on Hyprland without portal-hyprland (portal-wlr under Hyprland)?
- O4 Should LUKS default to on?
- O5 Firewall tool choice: nftables ruleset versus ufw/firewalld (ADR needed).
- O6 Keyring: gnome-keyring versus KeePassXC; interacts with Phase 11 secret store.
- O7 Is a boot-menu change (Limine/grub-btrfs) worth leaving systemd-boot, or is recovery USB enough?
- Not checked: Hub update-all state, runtime state of items marked "A", and any uncommitted edits in the working tree beyond the files read.
