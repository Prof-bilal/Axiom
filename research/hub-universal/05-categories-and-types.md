# 05. Categories and software types for Axiom Hub 2.0

Date: 2026-11-25. Research only; no code or repository changes except this file.
Markers: [V] verified against the cited URL in this session; [A] assumption or
general knowledge not checked here.

Identity context [V: docs/PRODUCT.md]: Axiom is an experimental AI-native Linux
desktop for developers, focused on privacy, bounded system agents, recovery and
first-principles UX. AI is optional and replaceable; core desktop, files and
terminal must work without it. The Hub therefore must not make AI software the
default story. [V: docs/DESKTOP_DESIGN.md] requires that every visible item map
to a real backend, so each type below needs real detection metadata.

Sources used: AppStream metadata chapter
(https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html);
Freedesktop menu category registry
(http://specifications.freedesktop.org/menu/latest/category-registry.html,
reached after a 301 from specifications.freedesktop.org);
Flathub MetaInfo guidelines
(https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines).
The Arch wiki page was blocked by an access check, so Arch facts are [A].

## 1. Types and detection

| Type | Detection from metadata | Default store view? |
| --- | --- | --- |
| Desktop GUI application | AppStream `type="desktop-application"` [V]; Flathub requires this type for graphical apps [V]; `.desktop` file with a non-terminal `Exec` [A] | Yes (Apps) |
| Web application | AppStream `web-application` [V, type list] | Only if launchable as a desktop item; otherwise no |
| CLI tool | AppStream `type="console-application"` [V, Flathub requires it]; no `.desktop`, or `Terminal=true` [A]; binary in `provides` [V] | No; own CLI section, also listed under Developer |
| Developer tool (IDE, SDK, language server) | GUI IDE: desktop-application with `Development` plus additional category `IDE` [A]. SDK or LSP: console-application [V] or SDK extension of type `runtime` [V] | Yes (Developer) for IDEs; SDKs and LSPs only in Developer view |
| Library | No AppStream type [A]. Package names `lib*` or `*-devel` and no binary [A] | No. Never shown as an app |
| System service or daemon | AppStream `service` type, with `<launchable type="service">` naming the unit [V] | No. Admin/System view only |
| Desktop extension or plugin | AppStream `addon` [V, Flathub requires this]. GNOME Shell extensions and browser extensions are outside the Axiom session model [A] | No. Shown inside the host app's page |
| AI application | No AI type. Desktop or console type plus `Science` or `Utility` and an Axiom tag [A] | Yes, in AI view only |
| Local AI model (weights) | No AppStream type [A]. Axiom catalogue kind `model` with file format (GGUF or safetensors), size, licence, checksum | No. AI view only |
| AI runtime (Ollama, llama.cpp) | Usually console-application or service [A]. Flatpak `runtime` is an SDK, not an AI runtime [V] | No. Shown as a dependency of models |
| Font | AppStream `font` [V, type list] | No. Customise view |
| Icon or GTK theme | AppStream `icon-theme` [V]. GTK themes have no type [A] | No. Customise view |
| Driver | AppStream `driver` [V, type list] | No. System view |
| Firmware | AppStream `firmware` [V]; LVFS is the usual channel [A] | No. System view |

Rule: the store reads type first, then domain category. Type decides install
flow and confirmation; category decides only where the item is shown.

## 2. Category mapping

Main Freedesktop categories [V]: AudioVideo, Audio, Video, Development,
Education, HealthFitness, Game, Graphics, Network, Office, Science, Settings,
System, Utility. Audio and Video entries must also carry AudioVideo [V].
Additional categories such as IDE, Debugger, WebBrowser, Emulator, Building and
Electronics exist in the menu spec [A, not re-verified]; they need a main
category.

| Requested category | Freedesktop / AppStream mapping | Status |
| --- | --- | --- |
| Development tools | Development | Mapped [V] |
| IDEs and code editors | Development + IDE [A] | Mapped; editors without IDE tag are ambiguous (Geany, Emacs) |
| Browsers | Network + WebBrowser [A] | Mapped |
| AI applications | None | Missing. Use Science or Utility plus an Axiom tag `ai`. Do not invent freedesktop names |
| Local AI models and runtimes | None | Missing. Axiom-own kind, not a category |
| Security tools | No main category fits cleanly; `System`, `Utility`, or `Security` additional [A] | Ambiguous |
| Networking | Network [V] | Mapped |
| Design and graphics | Graphics [V] | Mapped |
| Multimedia | AudioVideo, Audio, Video [V] | Mapped |
| Productivity | Office [V] | Mapped |
| System utilities | System, Utility, Settings [V] | Mapped; overlap is high |
| Gaming | Game [V] | Mapped |
| CLI tools | None; console-application type [V] | Type, not category. Category optional |
| Linux system packages | None. Arch groups such as `base` and `base-devel` are install sets, not app categories [A] | Not a store category. Use the System view |

Flathub guidance says generic terms (GUI, Application, GTK, Qt) must not be
categories and should go in `keywords` [V]. Use the same rule: AI, security and
model labels are Axiom tags, not freedesktop categories.

Missing or ambiguous: AI, models, runtimes, CLI (type only), libraries, and
security. Recommendation: store three independent facets:
type (section), domain (freedesktop category), and tags (AI, security, offline).

## 3. Discovery: separate views or one grid

Options:
- A. One grid with type filters: simple code, but a font, a driver and a browser
  share one ranking. A user can install a driver with one click, which conflicts
  with the safety rule.
- B. Separate views on one catalogue and one search index.
- C. Separate apps with separate catalogues: duplicated metadata and search.

Recommendation: B. Top-level views are Apps, Developer, AI, Command line and
System. Customise (fonts, themes, extensions) sits under Apps or System. Search
is global and shows a type badge on each result.

Reasons:
- Discoverability: each view ranks by its own signals. A grid buries CLI tools.
- Safety: system packages, drivers and services need different confirmations
  and must not sit beside a browser.
- Install behaviour: PATH, disk space and reboot differ per type (section 4).
- Updates: system packages may need reboot or snapshot; models rarely update
  but are large; apps update often.

Exception: an "All" tab may exist for search results only, not as a default.

## 4. Install behaviour per type

| Type | Destination | Prerequisite | Confirmation shown |
| --- | --- | --- | --- |
| Desktop app | Sandboxed or user package; `.desktop` in user applications dir [A] | Portal permissions | Name, source, size, requested permissions |
| CLI tool | `~/.local/bin` (user) or `/usr/bin` via the privileged package API (system) [A] | PATH includes destination; check for name shadowing | Binary name, destination, PATH status |
| Developer tool | Same as app; SDKs under user prefix | Disk space | Size, version, whether PATH is changed |
| Library | Not installed by the store | Dependency of another package only | Not offered |
| Service | systemd unit in system scope | Narrow privileged API with caller, operation and target checks [V, AGENTS.md] | What runs at boot, privileges, enable and start are separate |
| Extension | Host app's extension directory | Host restart or session logout on Wayland [A] | Host app, permissions, restart needed |
| AI application | As app or CLI | Data directory | Network use, data location |
| Model | `~/.local/share/axiom/models/<name>/` [A] | Runtime compatible with format and quantisation; RAM or VRAM | Size on disk, licence, download source, checksum, hardware fit |
| AI runtime | As CLI or service, user scope preferred | Hardware backend | Size, backend, service or not |
| Font | `~/.local/share/fonts`, font cache refresh [A] | None | Font family, size |
| Icon or theme | `~/.local/share/icons` or `~/.themes` [A] | Restart of apps that cache theme | Size, affected apps |
| Driver or firmware | System, through privileged package API | Reboot; snapshot or rollback point | Reboot required, rollback available, vendor source |

Axiom already has rollback for boot kernels (commit f2816b0, ADR-036 in the
repository log), so system installs can promise a rollback point only where
that mechanism covers the change [V, git log subject line; the ADR was not read].
Never promise universal undo [V, AGENTS.md].

## 5. Ranking and featured content

- Apps: curated and popular, with screenshots and icons. Featured by use case
  (writing, design, games). Quality metadata counts: screenshots, description.
- Developer: maintained status, recent release, licence, language servers and
  SDK versions. Featured by language stack (Rust, Python, Node, C).
- AI: hardware fit first (RAM or VRAM, quantisation), then licence, then
  popularity. Always show a privacy line: local or network. No AI item is
  featured on the default Apps view.
- Command line: alphabetical plus "already installed" and "used by your
  tools". No marketing featured slot.
- System: no featured slot. Sort by risk and reboot requirement, and show
  security advisories. Recommended only from a signed Axiom list.

## 6. Exclude from MVP

- Libraries: not user-installable; they add noise.
- Drivers and firmware: reboot, vendor trust and rollback need a proven path first.
- System services: privileged; needs the narrow API from Phase 6/7 work.
- Browser extensions: outside the Axiom session model [A].
- GNOME Shell extensions: Axiom targets its own shell, not GNOME [A].
- Model weights: large, licence-heavy and hardware-specific. Ship one curated
  model later, after the runtime is proven.
- GTK theme packs: low value and no type metadata.

Include in MVP: desktop apps, developer tools (IDE and SDK via one flow), CLI
tools with PATH checks, AI applications without models, fonts and icon themes.

## Open questions

1. Is the Flathub category list complete for Axiom's needs? Not re-verified here.
2. Should Arch package groups feed the System view, or only curated lists?
3. Will model metadata use an AppStream extension or an Axiom-only catalogue?
4. Which AI runtime is first-class: Ollama, llama.cpp, or both?
5. Should the Hub use one catalogue format for Flatpak and native packages?
6. Does Hub 2.0 need separate Customise and System views, or one "Advanced" view?
7. Which privileged API handles CLI installs to `/usr/bin` without giving the UI root?

Skipped: full Flathub and Arch wiki verification (blocked); freedesktop
additional category list and Desktop Entry Terminal key were not re-checked.
Risk: the store could show a CLI or model without a working PATH or enough disk
space, so install checks must run before the confirmation.
