# Open-source software centers as a foundation for Axiom Hub 2.0

Date of research: 2026-11-25. Research only; no repository, git state or code was changed.

Legend: **[V]** verified against a primary source (URL given, GitHub REST API or the repo page). **[A]** assumption or unverified inference.

## 0. Axiom license baseline

- Axiom `LICENSE` is Apache License 2.0 (read from `/home/abullah/Projects/Axiom/LICENSE`). **[V]**
- Consequence: code linked or copied from GPL-2.0 or GPL-3.0 projects would make that combined work GPL. Apache-2.0 is not compatible with GPL-2.0-only, and Apache-2.0 code may go into GPL-3.0 but not the reverse. Separate processes that talk over D-Bus are a different case from linked or copied code (see section 4). This is a legal question for counsel, not a conclusion of this report.

## 1. Candidate profiles

### 1.1 GNOME Software (`gnome-software`)
- Repo: https://github.com/GNOME/gnome-software is a **read-only mirror**; the canonical repo is https://gitlab.gnome.org/GNOME/gnome-software. **[V]**
- License: GPL-2.0 (GitHub SPDX `GPL-2.0`; COPYING present). Whether it is "or later" was not checked. **[V]** for the SPDX value.
- Language: C. **[V]** (GitHub API)
- Toolkit: GTK (version not confirmed in sources). **[A]** GTK4/libadwaita for current versions.
- Package formats: PackageKit (Debian, RPM), Flatpak, Snap, firmware updates, ODRS ratings. **[V]** (GitHub README)
- Search: yes, via AppStream metadata. **[A]**
- Install architecture: unprivileged UI process; system packages go through the PackageKit D-Bus daemon, which authorizes via polkit. **[A]** (standard architecture; not read from the code in this run)
- Maintenance: last push 2026-11-18 to the mirror. Latest release not retrievable from GitHub (no GitHub release objects). **[V]** push date; release date not verified.
- Issue activity: the mirror reports 0 open issues, which is not meaningful because issues live on GitLab. **[V]**
- UI quality: GNOME HIG-style app; screenshots not reviewed in this run. **[A]**
- Reusable pieces: PackageKit client code, AppStream integration, Flatpak plugin logic. Reuse is GPL-bound.

### 1.2 KDE Discover (`discover`)
- Repo: https://github.com/KDE/discover (GitHub mirror) and the canonical https://invent.kde.org/plasma/discover. **[V]**
- License: **not verified**. GitHub reports license `null`. Both COPYING fetches failed (HTTP 404 on the GitHub blob URL and the raw URL on the default branch). Expected to be GPL-2.0-or-later per KDE convention. **[A]**
- Language: C++. **[V]** (GitHub API)
- Toolkit: Qt and Kirigami (QML). **[A]**
- Package formats: PackageKit, Flatpak, Snap, fwupd (expected). **[A]**; not confirmed in this run.
- Search: yes. **[A]**
- Install architecture: unprivileged UI; privileged work through PackageKit and polkit. **[A]**
- Maintenance: last push 2026-11-24. No GitHub release objects (404 on releases/latest). **[V]** for push date.
- Issues: GitHub mirror reports 0, again not meaningful. **[V]**
- Forking potential: Qt/QML plus GPL-2+ code; a GPL dependency for Axiom, same constraint as GNOME Software.

### 1.3 Bazaar (`bazaar`)
- Which repo is current: **bazaar-org/bazaar is archived and read-only** on GitHub. Its README says the main repo moved to https://gitlab.gnome.org/World/bazaar on 2026-08-18. **[V]**
- `kolunmi/Bazaar` is **not** the current main repo. Fetching it returned the same bazaar-org content, and the GitHub API for `kolunmi/Bazaar` resolves to `bazaar-org/bazaar`. The kolunmi name is therefore a historical name. **[V]**
- License: GPL-3.0 (GitHub SPDX `GPL-3.0`). The GitLab API returned HTTP 406, so the GitLab license is **not directly verified**. **[V]** for GitHub; **[A]** that GitLab matches.
- Language: C (GitHub API). **[V]**
- Toolkit: expected GTK4/libadwaita. **[A]**
- Package formats: Flatpak (a `build-aux/flatpak` directory exists). **[V]** (repo tree); other formats unverified.
- Search: expected yes (it is a storefront for Flathub). **[A]**
- Install architecture: not verified. **[A]** Flatpak-based, so likely user-level with Flatpak handling privilege.
- Maintenance: archived on GitHub; development continues on GNOME GitLab. Last GitHub push 2026-08-18 (archive move). **[V]**
- Open issues on GitHub: 135, frozen. **[V]**
- Note: an archived repo plus a moving upstream is a reason to verify the GitLab tree before reliance.

### 1.4 COSMIC Store (`cosmic-store`)
- Repo: https://github.com/pop-os/cosmic-store. **[V]**
- License: GPL-3.0 (GitHub SPDX). **[V]**
- Language: Rust (GitHub API). **[V]**
- Toolkit: libcosmic / iced. **[A]**; the README is minimal ("WIP COSMIC Store").
- Package formats: Flatpak and Debian/apt, inferred from folder names (flathub-stats, debian). **[A]**
- Search: expected yes. **[A]**
- Install architecture: not verified. **[A]**
- Maintenance: last push 2026-11-24, most recent commit 2026-11-24 ("add fs feature to tokio..."). **[V]**. No GitHub releases (404).
- Issues: 166 open issues, 8 open PRs. **[V]**
- Maturity: README says WIP. Treat as early-stage. **[V]** (self-described)

### 1.5 bauh (`bauh`)
- Repo: https://github.com/vinifmor/bauh. **[V]**
- License: Zlib (GitHub SPDX). **[V]**. Zlib is permissive and compatible with Apache-2.0 in either direction for reuse of attributed source.
- Language: Python. **[V]**
- Toolkit: Qt (PyQt5 inferred from dependencies). **[A]**
- Package formats: AppImage, Debian, Arch including AUR, Flatpak, Snap, native web apps. **[V]** (GitHub description and README)
- Search: yes (multi-backend). **[A]**
- Install architecture: user-level GUI invoking package managers; privileged steps typically via sudo/pkexec. **[A]** This is a pattern to avoid, not reuse.
- Maintenance: **stale**. Last push 2024-10-13; latest release 0.10.7 on 2024-01-10. **[V]**
- Issues: 110 open. **[V]**
- Reuse value: multi-backend abstraction ideas. Low fit for a privileged, polkit-based design.

### 1.6 Gear Lever (`gearlever`)
- Repo: https://github.com/mijorus/gearlever. **[V]**
- License: GPL-3.0. **[V]**
- Language: Python. **[V]**
- Toolkit: GTK4/libadwaita expected. **[A]**
- Package formats: AppImage only (its description is "Manage AppImages with ease"). **[V]**
- Search: not a general catalogue; it manages installed AppImages. **[A]**
- Install architecture: user-level, no root needed for AppImage management. **[A]**
- Maintenance: active. Last push 2026-07-22; latest release 4.6.2 published 2026-07-22. **[V]**
- Issues: 235 open. **[V]**
- Fit: narrow. Useful only as a reference for an AppImage section.

### 1.7 Pamac (`pamac`, Manjaro)
- Repo: https://github.com/manjaro/pamac. **[V]**
- License: GPL-3.0 (GitHub SPDX). **[V]**
- Language: Vala (GitHub API). **[V]**
- Toolkit: GTK4 for pamac-manager; GTK3 for the tray. **[V]** (repo description)
- Backends: libalpm, AUR, AppStream, Flatpak, Snap. **[V]**
- Install architecture: a daemon (`pamac-daemon`) runs as root behind polkit, with the GUI as a user process. **[A]** (architecture not read from the code in this run; the description only lists backends.)
- Maintenance: active. Last push 2026-11-24; latest release v11.7.5 on 2026-04-23. **[V]**
- Issues: 63 open. **[V]**
- Fit: the closest working Arch-based precedent for a polkit-gated GUI over alpm. GPL-3.0 constrains reuse.

### 1.8 Arch GUI options (verified and not found)
- **pacseek**: https://github.com/moson-mo/pacseek. Terminal UI, not GUI. License MIT, language Go, last push 2026-09-07, 25 open issues. **[V]**. Useful as a search-UX reference; not a GUI store.
- **Octopi**: not verified. Search returned no repo, so license and release are unknown. **Not verified.**
- **Arch's own**: Arch Linux does not ship an official GUI software center in the sources checked. **[A]** (absence claim; not searched exhaustively.)

### 1.9 Glue Apps (candidate)
- **Not found.** Two searches returned no repo, license or project for "Glue Apps" as a Linux software center. **Cannot be verified.** Please provide the repo URL if this name refers to a specific project.

### 1.10 AppInstall (candidate)
- Repo: https://github.com/InledGroup/appinstall (GitHub API name `InledGroup/appinstall`). **[V]**
- License: **conflicting and not confirmed.** GitHub returns `NOASSERTION` ("Other"); the SourceForge listing says GPLv3. The repo's LICENSE file was not read. **Unresolved.** **[V]** for the conflict.
- Language: Python. **[V]**
- Scope: an installer for .deb, .rpm, AppImage and PWA, plus a cleaner and an antivirus scanner. It is an installer, not a store with curated catalogue search. **[V]** (repo description)
- Maintenance: last push 2026-11-04; 0 open issues. **[V]**
- Fit: poor. Unclear license, and its scope overlaps with the existing tool space rather than a store. Not recommended.

### 1.11 Related candidate surfaced by search (not in the requested list)
- GitHub Store (OpenHub-Store/GitHub-Store): reported Apache-2.0 by search results, AppImage and .deb output, GitHub Releases as catalogue. **Only search-reported; repo not fetched.** **[A]**. Possibly relevant as an Apache-2.0 reference. Verify before use.

## 2. Standards and shared primitives (reusable regardless of the chosen UI)

| Component | Repo | License (GitHub SPDX) | Language | Last push | Notes |
|---|---|---|---|---|---|
| AppStream | https://github.com/ximion/appstream | LGPL-2.1 [V] | C | 2026-11-24 [V] | Metadata standard and libraries. LGPL permits dynamic linking from a proprietary or Apache-2.0 app. |
| PackageKit | https://github.com/PackageKit/PackageKit | GPL-2.0 [V] | C | 2026-11-23 [V] | D-Bus abstraction over package managers. 177 open issues [V]. Runs as a separate daemon, so GPL is a process boundary, not a link. |
| polkit | https://github.com/polkit-org/polkit | GitHub reports NOASSERTION [V]; expected LGPL-2.0-or-later [A] | C | 2026-11-23 [V] | Authorization for privileged D-Bus calls. License confirmation needed. |

## 3. Comparison table

| Project | Repo (verified) | License | Lang | Toolkit | Formats | Search | Privileged path | Maintenance (as of 2026-11-25) | Fork fit for Axiom |
|---|---|---|---|---|---|---|---|---|---|
| GNOME Software | GNOME/gnome-software (GitLab canonical) | GPL-2.0 [V] | C | GTK [A] | PackageKit, Flatpak, Snap, fwupd [V] | Yes [A] | PackageKit + polkit [A] | Mirror push 2026-11-18 [V] | Low: GPL-2 |
| KDE Discover | KDE/discover (invent canonical) | Not verified (GitHub null); [A] GPL-2+ | C++ | Qt/Kirigami [A] | PackageKit, Flatpak, Snap [A] | Yes [A] | PackageKit + polkit [A] | Push 2026-11-24 [V]; no releases [V] | Low: GPL + Qt |
| Bazaar | bazaar-org/bazaar (archived); GNOME GitLab World/bazaar | GPL-3.0 [V] (GitLab unverified) | C | GTK4 [A] | Flatpak [V] | Yes [A] | Flatpak [A] | Archived; moved 2026-08-18 [V] | Low: GPL-3, moving target |
| COSMIC Store | pop-os/cosmic-store | GPL-3.0 [V] | Rust | libcosmic [A] | Flatpak, apt [A] | Yes [A] | Not verified | Push 2026-11-24 [V]; 166 issues [V] | Low: WIP, GPL-3 |
| bauh | vinifmor/bauh | Zlib [V] | Python | Qt [A] | AppImage, deb, Arch/AUR, Flatpak, Snap, web apps [V] | Yes [A] | sudo/pkexec [A] | **Stale**: push 2024-10-13, release 2024-01-10 [V] | Medium license fit, low architecture fit |
| Gear Lever | mijorus/gearlever | GPL-3.0 [V] | Python | GTK4 [A] | AppImage only [V] | No (manager) | User-level [A] | Release 4.6.2 on 2026-07-22 [V] | Narrow: AppImage only |
| Pamac | manjaro/pamac | GPL-3.0 [V] | Vala | GTK4 [V] | alpm, AUR, AppStream, Flatpak, Snap [V] | Yes [V] | Daemon + polkit [A] | Push 2026-11-24; release 2026-04-23 [V] | Low: GPL-3 but closest Arch model |
| pacseek | moson-mo/pacseek | MIT [V] | Go | TUI [V] | Arch/AUR [V] | Yes [V] | Not GUI | Push 2026-09-07 [V] | Reference only |
| Octopi | not found | Not verified | - | - | - | - | - | Not verified | Unknown |
| Glue Apps | not found | Not verified | - | - | - | - | - | Not verified | Unknown |
| AppInstall | InledGroup/appinstall | Conflict (NOASSERTION vs GPLv3) [V] | Python | - | deb, rpm, AppImage, PWA [V] | No (installer) | Not verified | Push 2026-11-04 [V] | Not recommended |
| AppStream (lib) | ximion/appstream | LGPL-2.1 [V] | C | - | metadata | - | - | Push 2026-11-24 [V] | High: reuse |
| PackageKit (daemon) | PackageKit/PackageKit | GPL-2.0 [V] | C | - | many backends | - | D-Bus daemon [V] | Push 2026-11-23 [V] | High as a separate service |
| polkit | polkit-org/polkit | Expected LGPL-2+ [A]; GitHub NOASSERTION [V] | C | - | - | - | authorization [V] | Push 2026-11-23 [V] | High as a separate service |

## 4. Architecture analysis: what to reuse, what to avoid

**Reusable, low-risk (license-permissive or process-separated):**
- AppStream (LGPL-2.1): catalogue metadata and search. Dynamic linking is the normal path. This is the strongest reuse point. **[V]** license.
- polkit: authorization for privileged D-Bus calls. Axiom's rules require narrow APIs that check caller, operation and target independently. polkit supplies the check, Axiom supplies the action definitions. **[A]** polkit license needs confirmation.
- PackageKit as a separate system daemon, reached over D-Bus. The GPL-2.0 applies to PackageKit itself; a D-Bus client in Apache-2.0 code is a separate program. Counsel should confirm. **[A]**

**Avoid as a code base:**
- GNOME Software, Discover, Pamac, COSMIC Store, Bazaar: all GPL-2 or GPL-3. Forking any of them would carry copyleft into Axiom's Hub, which conflicts with Apache-2.0 distribution.
- bauh: its architecture runs privileged steps through user-level tools. Conflicts with the "UI never runs as root, privileged APIs are narrow" rule.
- AppInstall: license unresolved.

**Reinventing package managers:** Option 3 below keeps the package managers in place (PackageKit, Flatpak, alpm where needed) and writes only the frontend, a thin privileged broker and the policy. This fits the "do not reinvent package managers" requirement.

## 5. Recommendation

**Option 3: build a new frontend on existing backends**, with **AppStream** for metadata and **polkit** for authorization, and **PackageKit** and **Flatpak** as backends reached over D-Bus. Do not fork a GPL project.

Justification:
1. **License:** Every full-featured store found is GPL-2.0 or GPL-3.0 (GNOME Software, Discover, Bazaar, COSMIC Store, Pamac, Gear Lever). Forking one would make Axiom's Hub GPL. Apache-2.0 reuse of LGPL (AppStream) and separate-process use of GPL daemons (PackageKit) keeps Apache-2.0 intact. **[V]** license values.
2. **Maintenance:** Pamac and Gear Lever are maintained (2026 releases or pushes). Discover and GNOME Software are maintained but upstream-driven. COSMIC Store is WIP. bauh is stale. Bazaar is archived with a moving upstream. None is a stable fork target. **[V]**
3. **Don't reinvent package managers:** Option 3 uses PackageKit, Flatpak and alpm underneath. It writes only the UI, the broker and the policy.
4. **Axiom's architecture rules:** A new frontend lets the Hub follow the rules in `AGENTS.md` (UI never runs as root, narrow privileged APIs, separate authorization of caller, operation and target), which the existing stores do not all satisfy.

**Why not option 4 (hybrid)?** A hybrid would mean importing parts of a GPL store (for example Discover's PackageKit client code). That reintroduces copyleft. Reading GNOME Software or Pamac as design reference is fine; copying code is not. Treat them as reference only, unless the license decision is made deliberately.

**Why not option 1 (extend)?** Extending means taking the upstream as the base, which is option 2 in practice. It is not an option here given licenses and the Axiom shell model.

**Caveat:** This recommendation depends on confirming the polkit and PackageKit licensing boundary and the Discover license. Both are open questions below.

## 6. Open questions

1. Confirm the Discover license from its canonical invent.kde.org LICENSES/COPYING (both fetches failed here).
2. Confirm the polkit license from its COPYING file (GitHub shows NOASSERTION).
3. Confirm the GitLab license and current commit date for `gitlab.gnome.org/World/bazaar` (GitLab API returned 406).
4. Legal review: is a Apache-2.0 D-Bus client talking to a GPL-2.0 PackageKit daemon a clean separation? Get counsel's view before relying on it.
5. Glue Apps: provide the repo URL or the intended product name. It could not be found.
6. Octopi: verify its repo and license; the search returned nothing.
7. AppInstall: read the LICENSE file in `InledGroup/appinstall` to resolve the NOASSERTION vs GPLv3 conflict.
8. GitHub Store (OpenHub-Store): verify its Apache-2.0 license and whether it is a viable reference, since it was found only in search results.
9. Confirm the backend list and privileged architecture of GNOME Software, Discover and Pamac by reading their source, not only their descriptions. Architecture claims marked [A] are unverified.
10. Decide whether to reuse AppStream data (the public Flathub and distro catalogues) or to run a private catalogue, since this affects the search capability requirement.
11. Decide whether the Hub must support AppImage management (Gear Lever's scope) or only Flatpak and native packages.
