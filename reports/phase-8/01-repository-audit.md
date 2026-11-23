# Phase 8 pre-flight: repository audit (Agent 1)

Date: 2026-11-23. Branch `phase7-installer-hub-rollback`. Read-only audit; no source or config changed, nothing built, no sudo.
Tools: shellcheck, ruff and qmllint are NOT installed, so no lint was run. Run: `node --test tests/apps/*.test.mjs` (106/106 pass), `python3 -I scripts/validate-repo.py` (4 errors, below), `python3 -I scripts/check-iso-profile.py` (0 errors). Tree is being edited concurrently by other agents (InstallFile.qml changed mid-audit); line refs are as read.

Legend: **[V]** verified in code/command, **[A]** assumption, **[R]** recommendation, **[Q]** open question. Complexity: S (<1 h), M (hours), L (days).

## 1. Executive summary

The privileged surface is small and mostly well built: argv-only QML process calls (positional `sh -c ... "$1"` patterns, no string interpolation found), a validated installer form, sha512 hash via stdin, 0600 creds files, `passwd -l root`, narrow helper verbs. No secrets were found in tracked files. There is no AI/agent code yet (no `ai/`, `services/`, `security/`), so the AGENTS.md AI boundary rules are not yet exercised.

The main risks are not injection bugs but **installed-system completeness and trust-model gaps**: the installed system omits runtime dependencies of shipped apps (screenshots, signature check, sandbox, Flatpak, podman, polkit agent), the polkit rules that make Settings work are hard-wired to a user name the installer forbids, the package-signature trust root does not exist in the repo, `sync` does partial upgrades, and a rollback does not cover the separate `/boot` partition. CI does not run any of the real tests.

## 2. Areas inspected

`installer/axiom_install.py`, `system/installer`, `system/pkgd/*`, `provision/*`, `iso/phase3` (profiledef, packages, pacman.conf, polkit rules/policy, systemd units, customize_airootfs.sh, hyprland.lua, axiom-session), `apps/appinstaller`, `apps/files/FileBackend.qml`, `shell/src/capture`, `.github/workflows/validate.yml`, `tests/`, `docs/decisions/030-035`, `docs/PHASES.md`, repo hygiene (`git status`, `.gitignore`). Not deeply read: most shell QML (7.5k lines), greeter QML, landing-page, research/, branding.

## 3. Critical findings

None found that is exploitable by an unprivileged remote party. The High items below are the ones that break the product promise.

## 4. High severity

### H1. Installed system lacks runtime deps of shipped apps  (Reliability) P1, S
[V] `installer/axiom_install.py:34-45` `BASE_PACKAGES` vs `iso/phase3/packages.x86_64`. Present in the ISO but absent from the installed package set (computed by diff): `grim`, `wf-recorder`, `wl-clipboard`, `minisign`, `bubblewrap`, `flatpak`, `distrobox`, `podman`, `polkit-gnome`, `modemmanager`, `rsync`, `man-db`, `less`, `dosfstools`, `exfatprogs`, `ntfsprogs`, `usbutils`, `nvme-cli`, `smartmontools`, `tpm2-tools`, `libfido2`.
Consumers: `shell/src/capture/CaptureBar.qml:66-76` (grim, wf-recorder, wl-copy), `apps/appinstaller/installfile.js:114,141` (minisign, bwrap), `apps/appinstaller/InstallFile.qml` (flatpak, distrobox/podman), `provision/axiom-provision:83-103` (`podman pull`, Quadlet; Developer Hub items would fail), `shell/src/session/PolkitDialog.qml:13` (expects polkit-gnome fallback), `docs/decisions/032-...md:36` ("minisign must be added to the ISO package list").
[A] Possibly intentional (ADR-035 deferred an offline/tool source), but nothing in docs says screenshots or AppImage install are ISO-only. [Q] Was the installed system QEMU-tested for Capture and AppImage install? Phase 8 exit lists screenshots/recording on the installed system.
[R] Add the missing runtime packages to `BASE_PACKAGES` (or a catalogue-driven second set) and add a test that every command the shell/apps exec is covered by the installed package list.

### H2. Polkit rules 50/51 only match user `axiom`, which installed systems can never have  (Reliability/UX) P1, S
[V] `iso/phase3/airootfs/etc/polkit-1/rules.d/50-axiom-session-power.rules` and `51-axiom-system-settings.rules` test `subject.user == "axiom"`; `installer/axiom_install.py:26-27` puts `axiom` in `RESERVED`; `OVERLAY` (lines ~70-80) copies rules 50 and 51 to the target. On an installed system the rules never match, so Wi-Fi join, time zone, power profile and (with other sessions) shutdown fall back to stock polkit (admin prompt or deny). Phase 5 exit evidence was gathered on the live image only.
[R] Match by group (e.g. a dedicated `axiom-users` group or `wheel` + local + active) or substitute the installed username at install time; add an installed-system QEMU check.

### H3. Package signature trust root does not exist; arch installs skip client-side verification  (Security) P1, M
[V] `git ls-files | grep keys` and `find iso/phase3 -path '*axiom/keys*'` return nothing: `/usr/share/axiom/keys/axiom.pub` (`apps/appinstaller/InstallFile.qml` keyPath, ADR-032) is not shipped, so any `.minisig` verifies as "failed" and everything else is "unsigned". `iso/phase3/pacman.conf:47` `LocalFileSigLevel = Optional` means `pacman -U` (run as root by `system/pkgd/axiom-pkgd:20`) installs unsigned local `.pkg.tar.*` after only an admin prompt. The `arch` branch (`InstallFile.qml:42-47`) performs no hash/signature check and the polkit prompt text ("install this package") names no package. Package install scripts run as root, so this is "admin approves a blob they cannot inspect".
[R] Ship the key (or document that signatures are not yet enforced), show file name + sha256 in the prompt (pass via pkexec argv is visible to polkit only through the action message; use the helper to log it), and set `LocalFileSigLevel = Required` on the installed system unless the user explicitly approves.

### H4. `axiom-pkgd sync` performs a partial upgrade (`pacman -Sy <pkg>`)  (Reliability) P1, S
[V] `system/pkgd/axiom-pkgd:69-70`: `pacman -Sy --noconfirm --needed -- "$pkg"`. Syncing the database without upgrading and then installing a package is explicitly unsupported on Arch and can break shared-library dependencies. It also takes no snapshot (only `update` does, line 48).
[R] Use `pacman -S --needed` without refreshing, or snapshot + `-Syu`, and snapshot before `install`/`remove` too.

### H5. Rollback does not restore `/boot` (kernel/initramfs)  (Reliability) P1, M
[V] `installer/axiom_install.py` `build_config`: `/boot` is the FAT32 ESP (mountpoint `/boot`, systemd-boot, not a btrfs subvolume), kernels `linux` + `linux-lts`. `snapper rollback` restores `/usr/lib/modules` but not `/boot/vmlinuz-linux` / initramfs. After a kernel update then rollback, the booted kernel no longer matches `/usr/lib/modules/<ver>` (modules fail to load). ADR-033 does not mention this. [A] The linux-lts entry mitigates partially. No `snap-pac`/boot-sync hook exists (`grep` of packages and installer found none).
[R] Mount the ESP at `/efi` and keep kernels in `/boot` on btrfs (XBOOTLDR-style), or add a pacman hook that includes `/boot` in snapshots. Add this as a Phase 7 regression test (update kernel, rollback, reboot). [Q] Was `tests/phase7-update-rollback.py` run with a kernel bump?

### H6. CI runs none of the real tests  (Maintainability) P1, S
[V] `.github/workflows/validate.yml` runs only `validate-repo.py`, `test-concepts.py`, `check-iso-profile.py`. The 106 node tests in `tests/apps/`, `tests/test_session_default.py`, `tests/test_ui_assets.py` and `tests/installer/` are not run. `validate-repo.py` currently fails (4 broken links, see M5), so CI is red on the current tree.
[R] Add `node --test tests/apps/*.test.mjs` and `python -m pytest -q tests/installer tests/test_*.py` to CI.

## 5. Security findings (Medium and Low)

| ID | Sev | Finding | Evidence | Fix (priority/complexity) |
|---|---|---|---|---|
| S1 | Medium | Live image: `axiom` is in `wheel` with an empty password (`passwd -d`), and polkit admin identities include wheel; with PAM `nullok` a local process can `pkexec axiom-pkgd ...` as root with an empty password. Live-only. | `iso/phase3/airootfs/root/customize_airootfs.sh:7-12`; no `sudoers.d`/polkit admin override tracked [A: PAM nullok on archiso not checked] | Document as live-only, or drop `wheel` from the live user and rely on rule 52 (P2, S) |
| S2 | Low | All four polkit actions funnel through one binary: `org.axiom.installer.install` is bound by `exec.path` to `axiom-pkgd`, which also accepts `update/rollback/remove/sync`. ADR-033 item 5 ("approving an install does not approve a rollback") is not enforced; `pkexec axiom-pkgd rollback N` shows the "install a package" message. Still gated by admin auth, so impact is consent clarity. | `org.axiom.installer.policy` `exec.path` annotations; `axiom-pkgd:34-63`; `axiom-pkg-update/rollback` are wrappers that call the same binary | Split verbs into distinct binaries, drop update/rollback/snapshot from `axiom-pkgd` (P2, S) |
| S3 | Low | `approve` verb is a logging no-op; approval is not bound to the later install, and the audit file lives in the user's `~/.local/state/axiom/install-audit.jsonl` (user-writable, forgeable). | `axiom-pkgd:25-33`, `InstallFile.qml:105-126` | Treat as UX only; if audit is a claim, log via the helper to the journal (P3, S) |
| S4 | Low | `remove` accepts any package name (`-Rns`), including `linux`, `pacman`, `polkit`, `axiom` deps; no protected list. | `axiom-pkgd:64-71` | Protect a core set; snapshot first (P2, S) |
| S5 | Low | Live image runs `sshd` with `PermitRootLogin yes` / `PasswordAuthentication yes` (archiso default) and root has an empty hash; sshd refuses empty passwords by default but the service listens on the live LAN. | `iso/phase3/airootfs/etc/ssh/sshd_config.d/10-archiso.conf`, `etc/shadow` (`root::14871`), `multi-user.target.wants/sshd.service` | Disable sshd on the live image by default, `PermitRootLogin no` (P2, S) |
| S6 | Low | `/etc/sudoers.d/10-wheel` is created with default umask then chmod 0440 (tiny window); `profile.json` 0644 world-readable (contains username, git email, hub item ids; no secrets). | `axiom_install.py:462-464, 431` | Create with `os.open(..., 0o440)`; consider 0600/0640 for profile (P3, S) |
| S7 | Low | No firewall in the installed set and `openssh` installed (service not enabled; OK). Phase 8 already lists default firewall. | `BASE_PACKAGES` has no nftables/ufw | Phase 8 item |
| S8 | Info | Provision/catalogue validation is good: catalogue-only packages (`PKG_RE`), image regex, ports bound to 127.0.0.1, generated secrets 0600. `online()` uses a fixed mirror URL over HTTPS. | `provision/axiom-provision:21-110` | none |
| S9 | Info | Installer: disk re-validated before wipe (`check_target`), not removable/mounted; passwords never in argv; `ERASE` typed in UI. Password policy is length >= 10 plus small denylist. | `axiom_install.py:109-123, 195-208` | none |

[V] Shell-injection review: every `sh -c` in `apps/` and `shell/` (`FileBackend.qml:236,245,317,433,465`, `CaptureBar.qml:66,73`, `PackageBackend.qml:82`, `InstallFile.qml:126`, `Osd.qml:73`) passes data as positional args; none concatenates user input into the script string. `FileBackend.qml:465` `find -iname` uses `globEscape`. No finding.
[V] AI boundaries: no AI daemon, agent, or sudo passthrough exists in tracked source; nothing to violate yet. The Phase 12 design must reuse the `axiom-pkgd` pattern (typed verbs) and not add free-form shell.

## 6. Bugs and reliability (other)

- R1 (Medium, S) Doc/code drift on the default compositor: `iso/phase3/airootfs/etc/axiom/compositor` contains `hyprland`, but `usr/local/bin/axiom-session:7` says labwc is the default, and `docs/decisions/031-...md:3` says "Proposed, not yet the default". `docs/PHASES.md` marks UI-M1 "verification pending". Resolve: accept ADR-031 or revert the file.
- R2 (Medium, M) ADRs 030-035 are all `Status: Proposed` ("implementation in progress / QEMU verification pending") while `PHASES.md` header says Phase 7 complete (2026-11-23). Evidence for Phase 7 exit (kernel bump + rollback, see H5) should be linked or statuses updated.
- R3 (Low, S) `axiom-snapper-setup` first-boot script (`axiom_install.py:48-70`) does `umount /.snapshots; rm -r /.snapshots` with `set -e`; if it fails after the umount the system is left half-configured with the done-marker unset (it retries, OK) but no fstab backup precedes the `sed -i` on `/etc/fstab` and boot entries. [A] Not run by me.
- R4 (Low, S) `post_install` rewrites `boot/loader/entries/*.conf` with plain `open().write` and `open(vc, "w")` (`axiom_install.py:~395-410, 450`): not atomic; failures after archinstall leave the target mounted only until `cleanup` (handled).
- R5 (Low, S) `apps/liveinstaller/installer.js:170` contains an unfinished `TODO(human)` for mapping failures to plain-language messages; failures currently show generic "error N".
- R6 (Low, S) `update` uses `pacman -Syu --noconfirm` with no mirror/keyring refresh and no Arch news check; a stale keyring on an old install fails the update (snapshot already taken, so leaves a junk snapshot). Retention policy is an open "follow-up" in ADR-033.

## 7. Performance concerns

[V] Only `tests/phase3-perf.py` exists; ADR-031 says Hyprland uses more GPU/RAM than labwc and "measure before switching the default" while the default is now Hyprland (R1). [A] Not measured by me. `axiom-session` forces `LIBGL_ALWAYS_SOFTWARE=1` on virtual machines. Software rendering plus blur/glass is the likely cause of VM slowness. [R] Record the Hyprland vs labwc idle RAM/CPU numbers before Phase 8 claims. Files search `find ... | head -c 800000` is bounded (fine).

## 8. Temporary fixes and workarounds

- `iso/*/airootfs/etc/pacman.d/hooks/zzzz99-remove-custom-hooks-from-airootfs.hook`: upstream archiso workaround (Arch bug 49347), expected.
- `tests/phase5-coords.json` and phase tests drive the UI by screen coordinates (fragile, but tied to evidence rules).
- `LIBGL_ALWAYS_SOFTWARE=1` on VMs; labwc fallback path in `axiom-session` retained "temporarily" per ADR-016.
- `apps/liveinstaller/installer.js:170` TODO. `grep -rn "TODO|FIXME|HACK"` found nothing else in code (docs excluded).
- Hard-coded values: user `axiom` in polkit rules (H2), `/usr/local/bin/*` absolute paths in policy files, mirror URL in `provision/axiom-provision:23`, `vt = 1` greetd.

## 9. Tech debt and repo hygiene

- T1 (Medium, S) 77 GB under `iso/`; untracked, un-ignored build/QA dirs: `iso/qa-*`, `iso/diag-installer*`, `iso/manual-run`, `iso/phase3-hyprtest`, `iso/qemu-*.log`, `iso/*.run.log`. `.gitignore` covers only `iso/work*/`, `iso/out*/`. Risk: accidental `git add -A` of logs with credentials-like blobs (the QA transcripts contain base64 file transfers; I checked a sample: image payloads, not secrets). Stray empty file `./-boot` (0 bytes, untracked, name starts with `-`) and untracked `.shiki/`. [R] extend `.gitignore` (`iso/qa-*/`, `iso/diag-*`, `iso/manual-run/`, `iso/*.log`), delete `-boot` (P2, S).
- T2 (Medium, S) `scripts/validate-repo.py` fails: `docs/LANDING_PAGE_DESIGN.md` links to `branding/landing-concepts/0{1..4}-*.png`, which are not in the tree (`ls branding`: identity, mascots, reference, theme, wallpaper). Add the images or fix the links.
- T3 (Low) Three near-identical airootfs profiles (`iso/profile`, `iso/phase3`, `iso/phase3-hyprtest`) with duplicated pacman hooks and unit symlinks; `.claude/worktrees/` contains full ISO work trees (`iso/work-ui/build`) that grep scans must exclude. Large binaries tracked: `apps/hub/screenshots/*.gif` 9 MB, wallpapers 1.7 MB each (repo bloat, consider Git LFS or on-demand fetch).
- T4 (Low) `apps/files/PromptDialog.qml` staged deletion plus untracked `InlineName.qml`: ensure no stale references (`grep` before commit). `.contextgit/context.md` deleted in working tree.
- T5 (Low) Large uncommitted diff (~70 modified files across apps, branding, ISO) on top of the phase-7 branch; commit or split before Phase 8 (git manager agent's area).
- T6 (Low) Test gaps: no tests for `provision` beyond unit logic, no automated test that every exec'd binary is in the package lists (H1), no polkit-rule test for installed users (H2), no lint in CI (shellcheck/qmllint/ruff absent on this host).

## 10. Recommended improvements (ordered)

1. Make the installed package set match what the apps exec (H1), with a static test.
2. Fix polkit rule subject matching (H2).
3. Decide and enforce package signature policy; ship the key (H3).
4. Fix `sync` semantics and snapshot all mutating verbs (H4); split pkgd verbs into separate polkit-bound binaries (S2).
5. Solve `/boot` snapshot coverage (H5), verify with an installed-system kernel-update rollback test.
6. Wire real tests into CI (H6); fix `validate-repo.py` links (T2).
7. Reconcile ADR statuses and the compositor default (R1, R2).
8. Live image hardening: sshd off, wheel membership (S1, S5).
9. Clean `.gitignore` and stray files (T1).

## 11. MUST FIX before Phase 8

Phase 8 (printing, removable media, screenshots/recording, clipboard, idle lock, i18n, accessibility, firewall, hardening) is verified "on the installed system", so:

1. **H1** installed package gaps (screenshots/recording/clipboard literally cannot work on the installed system).
2. **H2** polkit rules for the real installed user (removable media, settings and power actions depend on them).
3. **H4** `pacman -Sy <pkg>` partial upgrade.
4. **H5** `/boot` not covered by rollback (or explicitly record as a limitation in ADR-033).
5. **H6 / T2** CI runs the real tests and is green.
6. **R1 / R2** ADR/compositor status reconciled so Phase 8 builds on a known default.
7. **H3** decide the package-signature policy (ship key or state "unsigned allowed with admin approval" in ADR-032).

Can wait: S1-S7, R3-R6, T3-T6.

## 12. Unresolved questions

- Was the installed (not live) system run in QEMU with Capture, AppImage install and Settings network changes? (H1, H2)
- Is PAM `nullok` active on the live image, making S1 exploitable? Needs a live boot to confirm.
- Did `tests/phase7-update-rollback.py` include a kernel update? (H5)
- Intended install-time source for optional tools (ADR-035 item 6 leaves offline source undecided).
