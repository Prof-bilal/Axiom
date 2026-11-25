# Axiom Hub 2.0: install engine research

Status: research only. No code changed. Tags: [V] verified from a fetched page or search summary (URL given; search-summary items are marked [V-s] because the page itself was not opened), [A] assumption to verify, [C] conflict with current code.

Source limits: the ArchWiki pages returned an Anubis block and the flatpak docs fetch was refused by the classifier, so ArchWiki and flatpak claims come from search summaries and man-page mirrors. Verify before relying on exact wording.

## 1. Pacman from a GUI

**Problem.** A GUI install must not leave the system partially upgraded, and must not hold the root helper open for long.

**Options and rules.**
- `pacman -S pkg` on a system that has not been synced: installs against a stale sync DB. Unsupported on Arch. [V-s] ArchWiki System maintenance: `-Sy` alone is unsupported, always pair a sync with `-Syu`. https://wiki.archlinux.org/title/System_maintenance
- `pacman -Syu --needed pkg` (current helper): full upgrade plus the package. Correct per the rule above, but one install upgrades the whole system. [V-s] the same page's "never -Sy" advice.
- `pacman -Sy --needed pkg` (live ISO branch in axiom-pkgd): acceptable only because the live image has no persistent state. [A] keep this branch out of installed systems.

**How it works.** pacman resolves dependencies from the sync DB, then runs one transaction under `/var/lib/pacman/db.lck`. [V-s] https://wiki.archlinux.org/title/Pacman

**Root via polkit.** pkexec runs the helper as root with a cleared environment; polkit decides on an action id from an XML policy file. Each action can set `allow_active`, `allow_inactive`, and `allow_any` to `no`/`yes`/`auth_admin`/`auth_admin_keep`/`auth_self`/`auth_self_keep`. [V-s] https://freedesktop.org/software/polkit/docs/latest/polkit.8.html . The `org.freedesktop.policykit.exec.path` annotation lets an action extend authority to a named program; avoid it for the helper, since it widens what an approved action can run. [V-s] same page. Keep one action per operation: install, sync, remove, update, rollback (already the case in axiom-pkgd).

**Locks.** pacman creates `/var/lib/pacman/db.lck` for each write transaction. An interrupted run can leave the file behind, and a bug report shows an interrupt window during lock creation. [V-s] https://bbs.archlinux.org/viewtopic.php?id=220191 and https://bugs.archlinux.org/task/47188 . Recovery: check no process holds it (fuser), then remove it. [V-s] https://www.scivision.dev/pacman-clear-database-lock/ . Do not automate deletion blindly; the helper should check for a live holder first.

**Progress.** Use `pacman --noprogressbar` for clean lines, or read hooks for stage events (`[ALPM]` hook output). Hook location and format not verified [A]. The current parser (`parseProgress`) only sees percentages and `n/m` fractions; pacman's own output may not contain them, so most of the time the bar will sit on step 0-1 [A].

**Cancellation.** Current code: `proc.running = false` (QML Process kill). Killing pkexec or pacman mid-transaction can leave a half-installed package set, a stale lock, or an unbootable kernel package. [A] pacman may defer some signals during commit; verify. Best practice: do not kill a pacman transaction once it has begun the commit phase; cancel only while downloading (before `pacman` prints "Processing package changes"). [A]

**Risk.** Snapshot first (axiom-pkgd does this for sync and remove on installed systems). Good.

**Complexity.** Low, since the helper exists. **Recommendation:** keep the helper; add lock check (`fuser` or `pacman` exit 1 "unable to lock"), refuse to cancel after download; make cancel mean "stop before commit only."

## 2. Flatpak user installs

**Commands.** `flatpak install --user -y --noninteractive flathub <ref>`, `flatpak update --user`, `flatpak uninstall --user`, `flatpak remote-add --user --if-not-exists`. [V-s] https://docs.flatpak.org/en/latest/flatpak-command-reference.html (not fetched; flags confirmed in current code only).

**Repair.** `flatpak repair --user` prunes invalid objects and reinstalls missing or partial deployed refs; no root needed for the user installation. [V-s] https://man7.org/linux/man-pages/man1/flatpak-repair.1.html

**Parallel safety.** [A] Flatpak uses an OSTree repo with its own locking; two installs into the same user installation are serialized or fail. Keep one flatpak transaction at a time (already the case in HubBackend busy flag).

**Progress.** Output is text lines; percentages appear in install output. [A] Verify with `flatpak install --noninteractive` on a real machine before trusting the parser.

**Cancellation.** Killing flatpak mid-pull leaves partial objects; `flatpak repair --user` is the recovery path. [A] + [V-s] above.

**Desktop export.** [A] Flatpak exports `.desktop` files and icons to `~/.local/share/flatpak/exports/share` for user installs and adds that path to XDG_DATA_DIRS via the flatpak profile script. Verify against https://docs.flatpak.org/en/latest/desktop-integration.html (fetch refused).

**Cost.** Runtimes are shared, so the first install is large (hundreds of MB), later ones small. [A]

**[C]** `flathubRemoteArgv()` runs `remote-add` before every flatpak install. It is idempotent but adds a network round trip and a possible failure point each time. Cache a flag after the first success.

**Recommendation:** keep user-scope flatpak; add a `repair --user` action when an install fails with "not installed"/"corrupt"; keep single-transaction queueing.

## 3. AppImage

**Download and integrity.** Fetch over HTTPS from a pinned release URL; verify a SHA-256 published with the release or signed. [A] AppImage signing exists in the spec draft; verify its status before advertising it. https://github.com/AppImage/AppImageSpec/blob/master/draft.md [V-s]

**Run.** Mark executable, run under bubblewrap (ADR-032). [A] AppImages mount a squashfs via FUSE; many need FUSE or `--appimage-extract-and-run` on systems without it. [A]

**Desktop integration.** Two options: (a) own integration: write a `.desktop` file under `~/.local/share/applications` with `Exec=` pointing to the AppImage path, plus an icon under `~/.local/share/icons/hicolor`; (b) appimaged / AppImageLauncher. [A] The search did not find appimaged docs. Own integration is simpler and keeps the audit trail in the Hub database. Recommendation: own integration.

**Updates.** Embedded update info (`.upd-info` ELF section) with zsync delta updates. `appimageupdatetool -j` checks for updates (exit 1 if one exists), and `-d` shows the embedded info. [V-s] https://appimage-builder.readthedocs.io/en/stable/advanced/updates.html and https://docs.appimage.org/packaging-guide/optional/updates.html . Zsync needs HTTP range requests. Only upstreams that publish .zsync files support delta updates; others get full re-download.

**Uninstall.** Delete the AppImage, the `.desktop` file, the icon, and the DB row. [A]

**Complexity:** medium. **Recommendation:** own integration; `zsync` only where upstream publishes update info.

## 4. GitHub release installs

**Asset choice.** Map `uname -m` to asset names (`x86_64`, `aarch64`); prefer AppImage or a static tarball; reject `.deb`/`.rpm` here (those go to distrobox). [A] Match a regex per catalogue entry, not a guess.

**Place.** Extract to `~/.local/share/axiom/apps/<id>/<version>/`, symlink to `~/.local/bin/<name>`. `~/.local/bin` is on PATH by default on Arch's default shell profile only when the user config includes it. [A] Verify PATH setup in the Axiom shell profile.

**Desktop entry.** Ship a `.desktop` in the catalogue or extract it from the tarball; validate it with `desktop-file-validate` [A].

**Integrity.** SHA-256 from the catalogue entry; reject on mismatch. HTTPS only, follow redirects only to the same host family [A].

**Tracking.** Record every file written (absolute paths) in the Hub DB; uninstall deletes exactly those files and nothing else. [A]

**Risk.** No sandbox: the binary runs with full user rights. Consider bubblewrap for untrusted sources. [A]

**Complexity:** medium. **Recommendation:** MVP only for catalogue-curated entries with pinned hashes; no arbitrary GitHub URLs.

## 5. Vendor packages (.deb/.rpm) via distrobox

**Lifecycle.** One distrobox container per app (or shared "debian-apps" container). Install with apt inside, then export. [A]

**Export.** `distrobox-export --app <name>` copies the .desktop file and icons and prefixes the Exec line with `distrobox-enter ... -e`. `--delete` un-exports; `--list-apps` lists exports; `--bin` exports binaries; `--app` and `--bin` are mutually exclusive. [V-s] https://man.archlinux.org/man/distrobox-export.1.en and https://sources.debian.org/src/distrobox/1.8.2.4-1/docs/usage/distrobox-export.md

**Cost.** A container per app costs disk (a Debian base is roughly 200 to 400 MB, plus app) and startup latency on each launch. [A] Measure before promising a number.

**Uninstall.** Un-export, then remove the app inside the container, then optionally delete the container. [A]

**Risk.** Exported launches go through distrobox-enter, which depends on podman or docker. [A] Requires a container runtime; check the MVP dependency list.

**Recommendation:** defer to post-MVP per ADR-028; the helper must not run .deb extraction as root on the host.

## 6. Installed-application database

**Problem.** Installed state is currently derived from `pacman -Qq`, `flatpak list`, `npm ls`, `pipx list` on every refresh (backends.js `installedIds`). That covers four backends with no own storage, but cannot track AppImage, GitHub release, or distrobox installs.

**Option A (current):** derive every time from backends. Benefit: no drift from the package manager. Risk: no record for backends without a list command.

**Option B:** one DB file, `~/.local/state/axiom-hub/installed.json` (user scope) plus a root-owned record for pacman installs (or pacman remains the record). Schema per row: `id`, `backend`, `ref`, `version`, `installed_at`, `files[]` (absolute paths for AppImage/GitHub), `container` (distrobox), `sha256`. Write atomically (temp file, fsync, rename). [A]

**Reconcile.** On each refresh: for pacman and flatpak, the backend listing is authoritative; drop DB rows whose ref is missing; flag backend-only installs as "unmanaged." For file-based backends, check that every `files[]` path exists; mark missing as "broken." [A]

**Recommendation:** hybrid. Backends stay authoritative for pacman/flatpak/npm/pipx. Add a small JSON DB only for AppImage, GitHub, and distrobox rows, written by the user-scope process. Keep the root helper out of that DB.

## 7. Queue and concurrency

- **pacman:** serialize globally (db.lck). One transaction at a time system-wide, not only per Hub window. [V-s] lock behaviour above.
- **flatpak:** one transaction per user installation. [A]
- **npm/pipx:** one per prefix; [A] npm global installs to the same prefix can race.
- **Downloads:** key every job by `(backend, ref, version)`; a second request while one is queued or running attaches to it. [A] Currently `run()` simply returns if `busy`, which silently drops the request; surface it instead.
- **Failure and rollback:** pacman: snapshot before (done for installed systems); flatpak: `repair --user`; file-based: delete the new version directory and keep the old symlink until the new one is verified; distrobox: delete the new container only.

## 8. Desktop entries and icons

- **Spec.** Desktop file IDs are derived from the path under an `XDG_DATA_DIRS` entry; the first match in XDG_DATA_DIRS wins; files outside an `applications/` subdirectory get no ID. [V-s] https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-1.3.html
- **Database update.** `update-desktop-database` builds `mimeinfo.cache` and defaults to `$XDG_DATA_DIRS/applications`. Desktop environments usually pick up changes on their own; running it is a fallback. [V-s] Debian man page https://unix.com/man-page/debian/1/update-desktop-database/ and Arch wiki Desktop entries.
- **Icons.** `gtk-update-icon-cache -qf <theme dir>` per theme with an `index.theme`; skip if missing. [V-s] Gentoo xdg-utils eclass https://mirrors.edge.kernel.org/gentoo-portage/eclass/xdg-utils.eclass . Note: hicolor user icons at `~/.local/share/icons/hicolor` need a cache run after writes. [A]
- **Quickshell.** Quickshell exposes a DesktopEntries source for launching; verify its API and whether it watches inotify. [A]
- **Recommendation:** after any write, run `update-desktop-database ~/.local/share/applications` and `gtk-update-icon-cache -qf ~/.local/share/icons/hicolor` if present, and emit a Quickshell refresh if the API needs one.

## 9. Dependency resolution for non-pacman backends

- **pacman:** pacman resolves. Axiom must not add its own resolver.
- **flatpak:** runtimes resolved by flatpak from the remote. [A]
- **npm/pipx:** resolved by the tool. [A]
- **AppImage:** none (self-contained); risk is runtime libs the AppImage does not bundle. [A]
- **GitHub release:** none; list required host tools in the catalogue and refuse install if missing. [A]
- **distrobox:** resolved by apt inside the container. [A]

Recommendation: each backend resolves its own dependencies; the catalogue lists required host commands per entry, and the Hub refuses install with a clear message when one is missing (already partly done by `chooseSource`).

## Existing code that conflicts with best practice

1. [C] `axiom-pkgd sync` on an installed system runs `pacman -Syu --needed <pkg>`. This is the Arch-correct form (never bare -Sy), but each one-app install upgrades the whole system and needs a snapshot. Decide: accept it and tell the user, or split into "install with full upgrade" vs "install after upgrade."
2. [C] `axiom-pkgd install` (local package file, `pacman -U`) has no snapshot on installed systems; only `sync`/`remove` snapshot. Inconsistent with ADR-033. Fix in the helper.
3. [C] Cancel kills the pkexec/pacman process mid-transaction. Restrict cancel to the download phase.
4. [C] `run()` silently drops a request while `busy`. Queue it or say so.
5. [C] `flathubRemoteArgv()` runs before every flatpak install.
6. [C] `parseProgress` expects percentages; pacman output rarely contains them. Progress is likely to be a spinner for pacman; say so in the UI or use hooks.

## Open questions

1. Does pacman defer SIGINT/SIGTERM during the commit phase? Verify on a QEMU test box with a deliberate kill at each phase.
2. What exact pacman output and `--noprogressbar` lines should the parser match? Capture real logs.
3. Does flatpak install print percentages in non-TTY mode? Capture real logs.
4. Does Quickshell DesktopEntries watch for changes, or does it need an explicit refresh?
5. Should the installed-DB be user-scope only, or should root record pacman installs too?
6. Is distrobox in the MVP dependency set, or post-MVP per ADR-028?
7. Is AppImage signature verification part of the spec and worth supporting now?
8. Should a single `pacman -Syu` run for every install be accepted in the UX, or should the Hub offer a "Update system first" step?
9. Which icon/desktop refresh commands are present on the Axiom base image?
