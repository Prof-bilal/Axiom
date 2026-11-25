# Axiom Hub 2.0: universal software store, research and architecture

Status: research and design only. No code changed. Date: 2026-11-25.
Detail files: `research/hub-universal/01..07-*.md` (one per research area; each tags claims `[V]` verified from a primary source, `[S]` search snippet only, `[A]` assumption, `[X]` unverified or blocked).
Decision record to follow this doc: `docs/decisions/037-universal-software-store.md` (Proposed).

## 0. Verification status (read first)

- Several primary sources were blocked from this environment: the ArchWiki and archlinux.org (bot protection), the Flatpak docs, and some WebFetch calls. Those points are marked `[X]` or `[A]`. They are not guessed.
- Flathub's public search API could not be confirmed. `flathub.org/api/v1/apps` returns 404 today. Plan around the AppStream index instead.
- The AUR campaign figures come from search snippets (`[S]`), and their counts differ by source. Use them only as motivation, not as numbers to quote.
- Nothing here is measured. Performance numbers are estimates until the Stage 6 measurements exist.

## 1. Existing Axiom Hub assessment

Source: `apps/hub/`, `system/pkgd/axiom-pkgd`, `reports/phase-8/01-repository-audit.md`.

- **Static catalogue.** `apps/hub/catalog.js` has 97 hand-curated entries, of which 85 are `verified: true`. The old handoff says 81 apps, so its docs are stale.
- **Search is local only.** It filters the catalogue by name and summary (`apps/hub/rules.js`). There is no network search, and it cannot show apps outside the list.
- **Install sources.** pacman goes through `axiom-pkgd` (`sync`, `remove`). Flatpak runs `--user`. npm and pip run in user scope. There is no AUR, GitHub, AppImage or .deb path. This matches ADR-021 (no AUR in v1) and ADR-028 (.deb via distrobox).
- **Single-package install does a full upgrade.** On an installed system `axiom-pkgd sync` runs `pacman -Syu --needed <pkg>`. This is correct for Arch (no partial upgrade) but means one app install upgrades the whole system. This needs an explicit user decision (Q3).
- **Cancel is unsafe.** The Hub kills the QML wrapper process, not the root `pacman` it started, so a root transaction can keep running. The Hub can also report "Canceled." after a successful install.
- **Progress is weak.** `parseProgress` expects percentages that pacman rarely prints. The reliable signal is pacman's `(n/m) installing <pkg>` line.
- **Installed-app list is catalogue-only.** `installedIds` only matches catalogue entries, so apps installed outside the Hub are invisible.
- **Busy requests are dropped silently** while a transaction runs.
- **Done since:** the desktop icon cache fix (`fix/icon-cache`) and the installer progress fix (`fix/installer-progress-monotonic`).

## 2. Universal search architecture

Principle: index metadata locally, search the index, and touch the network only to refresh metadata. Search never installs and never runs a privileged command.

```
Hub window (unprivileged QML)
  -> search session (child process of the Hub, unprivileged)
       -> adapters: pacman (local sync DB), Flathub (AppStream, cached),
          distro AppStream catalogue (/var/lib/swcatalog/xml)
       -> SQLite FTS5 index in XDG_CACHE_HOME (one table of normalized records)
  -> install job (systemd transient unit, via polkit-gated axiom-pkgd for root,
                  or user scope for Flatpak)
```

Decisions:
- **No new daemon for the MVP.** The search service is a child process owned by the Hub window. A user daemon is justified only if installs must survive closing the window (Q4). Each keystroke is served from the index, not a new process.
- **pacman search reads the local sync DB** (`pacman -Ss`, `-Si`, read-only, no root). Freshness: the UI shows "last synced" time. Do not run `pacman -Sy` from search, because that is a partial upgrade on Arch. For a fresh search without touching the system DB, use a temporary copy of the sync DB (the approach `checkupdates` takes). `[A]`, to verify on this machine.
- **Flathub metadata** comes from the AppStream index at `dl.flathub.org`. It is downloaded with a conditional GET (ETag or If-Modified-Since) and refreshed at most once per 24 hours. Index URL and format to verify before implementation (`[X]`).
- **Index size and speed** are estimates: roughly 15,000 to 25,000 rows, FTS5 with prefix matching. In-memory JS is possible but has slow cold start and weak ranking (`[A]`).
- **Results stream per source.** A slow source must not block the others.

Sources:

| Source | Search mechanism | Metadata | Update | Status in MVP |
|---|---|---|---|---|
| Arch official repos | local sync DB via `pacman -Ss/-Si` `[V]` | name, version, repo, arch, description, URL; size from `-Si` | system `-Syu` | yes |
| Flathub | AppStream index (cached) `[V]`; public search API not confirmed `[X]` | id, name, summary, developer, licence, version, permissions | `flatpak update --user` | yes |
| AppStream system catalogue | local XML under `/var/lib/swcatalog/xml` `[V]` | component id, type, categories | with package updates | yes (matching aid) |
| GitHub Releases | REST API, 60 req/h anonymous, 5000 req/h authenticated `[V]` | release, assets, checksums, attestations | release-based | only curated, hash-pinned entries |
| AppImageHub | community feed, format declared unstable `[V]` | name, links | none | no, allowlist later |
| Vendor repos (VS Code, Chrome) | per-vendor index | varies | per vendor | via distrobox later (ADR-028) |
| AUR | RPC | build scripts | makepkg | no (own ADR) |

## 3. Unified package metadata

One normalized record per application, with one row per source:

```
App { canonical_id, name, summary, kind, categories[], screenshots[], licence,
      sources: [ Source { type, ref, version, arch, download_size, installed_size,
                          publisher, maintainer, trust_class, signature, last_updated } ] }
```

- `canonical_id` is the AppStream component id (reverse-DNS, globally unique, ASCII) when one exists. Otherwise it is a derived key from the source and its native name, and it is never shown as a claim of identity. `[V]` (AppStream metadata spec).
- `kind` is one of: desktop app, developer tool, CLI tool, AI app, font, icon theme, system package, library, driver, service, extension, model. Only the first to fourth go to the MVP store views (section 9).
- `download_size` and `version` field names from each source are unverified `[X]`.

## 4. Deduplication, matching, ranking

Matching order (never by name alone):
1. Exact AppStream id.
2. Distro AppStream id (via the distro catalogue), then the `.desktop` id in `<launchable type="desktop-id">`.
3. A curated override file for known mismatches (for example `mousepad` vs `org.xfce.mousepad`).
4. Name normalization is only a flagged suggestion for the user. It is never an automatic merge across sources.

Hard rules: never merge two apps with different publishers. Show the source difference rather than hiding it.

Ranking (transparent, not popularity theatre):
- Exact id match, then verified publisher, then official repo, then name match, then curated order.
- Popularity: use only public, source-specific numbers, and never compare them across sources. Flathub install counts are approximate 30-day figures, not active users. Arch pkgstats is an opt-in percentage. `[V]`

Default source (decided by you): official repo first. Flathub only when the repo has no package, or when the repo version is old and the Flathub build is from the vendor or a verified publisher. Never default to an unverified Flathub build or to AUR.

Installed or duplicate: if an app is already installed from another source, the review page warns before a second install. Install state is read from the system (`pacman -Qq`, `flatpak list`), not only from the catalogue.

## 5. One-click install architecture

Flow: Get -> review (trust, permissions, size, source) -> confirm -> job -> progress -> launcher entry appears.

- **Privileged actions** go only through `axiom-pkgd` via polkit (`auth_admin`). Verbs are fixed argv, one per action, for example `install-repo <pkg>`, `remove <pkg>`, `update`, `rollback <n>`. Input is validated (`PKG_NAME`); names such as `-Syu`, `$()` and `;` are refused. This follows ADR-033.
- **Snapshot first** on installed systems (snapper). Refuse without snapper. The current `install` verb (`pacman -U`) does not snapshot, so this must be added.
- **Flatpak** installs stay in user scope. Add `flathub` only on first use. Use `flatpak repair --user` as the recovery path. `[V-s]`
- **AppImage** (later): runs under bubblewrap (ADR-032). Desktop integration is ours. Updates through zsync info `[S]`.
- **Jobs** run as systemd transient units, so they keep running when the Hub window closes (owner decision Q4). The Hub re-attaches by unit name and reads state and journal. Cancel stops the whole unit (its cgroup). `[A]` for re-attach and cancel behaviour on this host; a daemon is added only if re-attach fails.
- **Cancel rule:** cancel is allowed during download only. After pacman starts the commit phase, the button is disabled. Killing pacman mid-commit can leave `/var/lib/pacman/db.lck` and a broken state. `[A]`
- **Queue:** one pacman transaction at a time (`flock` in the helper, plus pacman's own lock). One Flatpak transaction per user. A busy request is queued and shown, not dropped.
- **Idempotency:** a job key (source, ref, action) must be unique among running jobs, so a double click cannot start the same install twice.
- **Progress:** pacman's `(n/m) installing` lines are the phase signal. Download bytes can be estimated from the partial-file size. Percentages are estimates, labelled as such.
- **Desktop entries and icons:** after install, refresh the icon cache (`gtk-update-icon-cache`) and the desktop database, so the launcher and dock show the app. This is the same cause as the icon fix already done.
- **Uninstall and update** use the same job path. Core packages stay protected (existing guard in `axiom-pkgd`).

Open decision (Q3): installing one app runs `pacman -Syu`. Options are to keep it, with an explicit "this will upgrade the system" line and a snapshot first, or to refuse single-package installs on partial upgrades. The recommendation is to keep the full upgrade and show it clearly, because the alternative is an unsupported partial upgrade.

## 6. Security and trust model

Principles:
- Axiom never runs an install script or build script from metadata. No `curl | bash`, no `makepkg` from the store in the MVP.
- Signatures and checksums are necessary checks, not proof of safety. Say so in the UI.
- Fail closed: a missing or failed check blocks the install, or downgrades the trust class and asks for explicit consent.

Trust classes (decided here; wording to review):

| Class | Evidence required | What the user sees | Extra confirmation |
|---|---|---|---|
| 1. Official distribution repo | pacman package signed by a trusted packager key (`LocalFileSigLevel=Required`) `[V]` | "From Arch Linux, signed by Arch packagers." | no |
| 2. Verified official publisher | Flathub verification (domain or repo login proves publisher control) `[V]` | "Published by X. Verified by Flathub." Not a code audit. | no |
| 3. Established community repo | maintained source, active updates, no flagged history | "Community build. Not checked by the publisher." | yes, brief |
| 4. Unverified third-party | no verification, or checksum from the same channel as the file | "Not verified. Install only if you trust the publisher." | yes, explicit |
| 5. Suspicious or unsupported | flagged, abandoned, end-of-life, or failed a check | "Not recommended. Unsupported or flagged." | blocked by default |

Flatpak permissions are shown on the review page. The broad grants to highlight are `device=all`, `filesystem=home` or `host`, `session-bus` and `share=network`. The `--show-permissions` output format is not confirmed `[X]`.

Limits to state honestly:
- A pacman signature proves the packager key signed the file. It does not prove the software is safe.
- Flathub verification proves publisher control, not a code audit.
- AppImage has no sandbox by default, and an embedded signature is not validated by merely displaying it.
- No SBOMs are available for Arch packages or Flathub apps `[S]`.
- Malware scanners for AUR (traur, ks-aur-scanner) have false-positive reports. Axiom must not claim malware detection.
- Vulnerability data: OSV can be queried online or from a bulk dump `[S]`. The Arch security tracker appears stalled `[X]`.

## 7. Open-source comparison

Full table in `research/hub-universal/06-open-source-comparison.md`. Summary:

| Project | Licence | Language | Fit |
|---|---|---|---|
| GNOME Software | GPL-2.0 `[V]` | C | reference only (GitLab is primary; GitHub is a mirror) |
| KDE Discover | licence not confirmed `[X]` (expected GPL-2+) | C++ | reference only |
| Bazaar | GPL-3.0 `[V]` (repo now archived on GitHub; current home GNOME GitLab) | GTK4 | reference for UI; Flathub-only |
| COSMIC Store | GPL-3.0 `[V]` | Rust | reference; README says work in progress |
| Pamac | GPL-3.0 `[V]` | Vala | reference; includes AUR, which is out of scope |
| bauh | Zlib `[V]` | Python | stale (last release 2024) |
| Gear Lever | GPL-3.0 `[V]` | Python | AppImage only |
| AppInstall | licence conflict `[V]` | — | not recommended |
| Glue Apps, Octopi | not found `[X]` | — | not evaluated |

AppStream is LGPL-2.1 `[V]`, and polkit's licence is unconfirmed `[X]`.

## 8. Build, fork or integrate

Decision: **option 3, build a new frontend on existing backends**, with AppStream for metadata and polkit for authorization. Do not fork a GPL store.

Why:
- A fork of a GPL store would bring its UI, its licence, and its AUR and Snap code, which Axiom does not want in the MVP.
- Axiom's Apache-2.0 licence (`LICENSE`) and its UI (glass tokens, Quickshell) are not in any reviewed project.
- The package managers stay the real backends: pacman, Flatpak, AppStream. We do not reinvent them.
- Reuse AppStream data, which is the standard catalogue format.

Open legal point (Q5): a client under Apache-2.0 talking over D-Bus to a GPL-2.0 PackageKit daemon. The MVP avoids this by not using PackageKit at all. Flatpak and pacman are called directly, so the question only matters if PackageKit is adopted later.

## 9. Recommended MVP

In scope:
- Search across Arch repos and Flathub, grouped by app, with source chips.
- Store layout: sidebar (Discover, Apps, Developer, Command line, System, Customise), hero banner, horizontal rows, one "Get" button per card, source picker on the app page.
- Kinds: desktop apps, developer tools, CLI tools, AI apps without models, fonts, icon themes.
- Install, remove and update through the existing polkit path with snapshots. Flatpak in user scope.
- Review page with trust class, permissions, size, source and the full-upgrade notice.
- Installed apps from the system listings, not only the catalogue.
- Fixes to the current Hub bugs listed in section 1 (cancel, busy drop, progress, finish error).

Out of MVP: AUR, GitHub Releases beyond curated entries, AppImage, vendor packages through distrobox, AI models, GNOME and browser extensions, libraries, drivers, firmware, services, GTK theme packs, and an in-app PackageKit backend.

Categories and views follow `research/hub-universal/05-categories-and-types.md`: one catalogue and one index, with separate top-level views. Libraries, drivers, firmware and services are never in the default Apps view.

## 10. Future features

- AUR with PKGBUILD review, its own ADR, and a warning that the build runs code. Re-check the AUR RPC limits first (the 4000/day figure is dated `[S]`).
- GitHub Releases from projects that publish signed or attested releases (`gh attestation verify` `[V]`).
- Vendor packages through distrobox (ADR-028), with `distrobox-export` for the menu entries `[S]`.
- AI models: a separate model store with disk size, licence, checksum, and runtime and hardware fit.
- AppImage with bubblewrap and zsync updates (ADR-032).
- Update notifier and staged rollback per app.

## 11. Performance considerations

Budgets to measure, not claim:
- First paint of the store, keystroke-to-results, and install start (time to first progress line).
- Estimates only: index rebuild on a metadata refresh, and idle RAM of the search session.
- Measurement method: scripted timings in the QEMU guest, with retained evidence (AGENTS.md: performance claims need measurements).
- Avoid repeated metadata downloads (conditional GET, 24-hour TTL) and avoid `pacman -Sy` from search.

## 12. Implementation roadmap

Stage 0 (this doc and ADR-037): done in draft. Needs review, and the open questions answered.
Stage 1: source adapters (pacman local DB, Flathub AppStream cache), one normalized record, dedupe with override file, unit tests on recorded fixtures.
Stage 2: search and catalogue; remove the 97-entry list; search results stream per source.
Stage 3: install engine: `install-repo` verb with snapshot, transient-unit jobs, cancel rule, queue, idempotency, desktop refresh. Requires Q3 answered.
Stage 4: review page, trust classes, source picker, duplicate warning.
Stage 4b: store UI rebuild (sidebar, hero, rows, cards) using the existing glass tokens. Verify with screenshots.
Stage 5: installed-app record from system listings, updates, uninstall.
Stage 6: tests (adapters, normalization, argv builders, adversarial names, CI), QEMU acceptance on a networked guest, and performance measurements, with evidence.

Each stage is a separate branch and PR, merged only after CI and the QEMU evidence for that stage.

## 13. Technical risks and limitations

- **Upstream formats.** The Flathub index format, its URL, and the Flatpak permission output are not confirmed. A change upstream breaks search or review.
- **Partial-upgrade pressure.** Single-package installs on Arch are either a full upgrade or unsupported. Users may not expect the upgrade.
- **Stale pacman DB.** If the sync DB is old, search results are old. The UI must say so.
- **Trust is a judgement.** Classes and wording are our choices. A clear warning is not a guarantee of safety, and the UI must not say it is.
- **Cancellation.** Cancel is safe only before the commit phase. A mid-commit kill can leave pacman's lock or a broken install.
- **Licences.** Reference projects are GPL. Axiom uses only the public formats (AppStream, desktop entries) and its own code. The PackageKit legal question (Q5) stays open.
- **Scope creep.** AUR, AI models and vendor packages each need their own ADR and tests, and must not slip into the MVP.
- **Unverified research.** Several sources were blocked, and some licences were not confirmed. See section 0.

## Open questions

Decided by you (2026-11-24/25): MVP sources are Arch repos and Flathub; GitHub only verified; vendor via distrobox later. The old catalogue is removed. Default source is the official repo first. Store-style UI.

Answered by the owner (2026-11-25): Q1 yes, keep a small "Recommended" list. Q2 yes, merge Software Center into the Hub. Q3 full upgrade after a snapshot, with a notice. Q4 installs must survive closing the window: jobs run as systemd transient units and the Hub re-attaches; no daemon unless re-attach fails.

Still open:
- **Q1 Featured list:** keep a small curated "Recommended" list after removing the catalogue, or show only search results?
- **Q2 Software Center:** merge `apps/software` (pacman-only browser) into the Hub? Recommendation: yes.
- **Q3 Install policy:** keep the full upgrade (`-Syu`) with a snapshot and a clear notice, or refuse single-package installs?
- **Q4 Lifetime:** must installs survive closing the Hub window? If yes, a user daemon is justified.
- **Q5 Licence:** is a D-Bus client under Apache-2.0 talking to a GPL-2.0 PackageKit daemon acceptable? Only relevant if PackageKit is adopted.
- **Q6 Flathub:** confirm the current index URL, format, and whether a public search endpoint exists.
- **Q7 Arch:** confirm `pacman -Ss` output format and the temporary-DB refresh method on this host.
- **Q8 Flatpak:** confirm `flatpak info --show-permissions` output and the `repair` flags.
- **Q9 Licences:** KDE Discover and polkit licences, Glue Apps and Octopi repos.
- **Q10 Model metadata:** schema for the later AI model store.
