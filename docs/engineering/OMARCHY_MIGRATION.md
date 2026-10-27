# Omarchy-derived Axiom foundation — migration report

Status: **RESEARCH + migration plan, 2026-10-27.** This report records what was inspected,
what is proposed, and what remains unproven. It does not authorize implementation; the
migration stops at documentation, upstream pins and this plan. Evidence is upstream source,
release metadata and repository files inspected on 2026-10-27; nothing here was executed as a
runtime experiment unless explicitly marked.

Related: [ADR-013](../DECISIONS.md), [phases](../PHASES.md), [ecosystem](../ai/ECOSYSTEM.md),
[ecosystem work plan](ECOSYSTEM_PLAN.md), [Warden integration](../security/WARDEN_INTEGRATION.md),
[third-party notices](../../THIRD_PARTY_NOTICES.md).

## 1. Decision

Axiom will evaluate **Omarchy as its upstream Arch/Hyprland/Quickshell foundation** while
retaining ownership of product identity, shell UX, design system, AI runtime, Shield, Sentinel,
Flow, context integration, model evaluation, recovery UX, system APIs and developer experience.

Axiom must not become "Omarchy with a different wallpaper." Omarchy supplies infrastructure;
Axiom supplies the product.

## 2. Upstream relationship and pinned revisions

| Role | Repository | Revision | License |
| --- | --- | --- | --- |
| Migration base (stable) | `https://github.com/omacom/omarchy` | tag `v4.0.6` → `237f1b4071a0bff2296c6d740ba2b9fd695ebfa0` | MIT |
| Divergence tracking | same | `quattro` at research time `39d56653d649312453316f2536fcfb9982f08fb8` (`version` = `4.0.0.alpha`) | MIT |
| ISO tooling | `https://github.com/omacom/omarchy-iso` | `main` `3c36557fd58fe8dcd963f47eb9145f48a543a658`; protected `quattro` `50832fb585edb1e16cc9b8f6726b13cc3bfecefe` | MIT |
| Stable boot artifact | `https://iso.omarchy.org/omarchy-4.0.6.iso` | SHA256 `b542db5fecc37395d9af6654a8146ebed225f275ae4d5a6fcf432e40afe7bb88` | — |
| Package repository | `https://github.com/omacom/omarchy-pkgs` | no GitHub releases; package versions come from the built image manifest | MIT (verify at build) |
| Shell toolkit | `https://github.com/quickshell-mirror/quickshell` | tag `v0.3.2` → `4f508be500dea6e5732cc3d50382a0048b17e7b1` | LGPL-3.0-only |
| Compositor | `https://github.com/hyprwm/Hyprland` | release `v0.56.2`; Omarchy ships its own builds | BSD-3-Clause |

Notes:

- The canonical Omarchy repository is `omacom/omarchy`; the historical `basecamp/omarchy` URL
  redirects there.
- The default branch `quattro` is a **pre-release** for the next feature line. Stable artifacts
  come from release tags and `omarchy-pkgs`, not branch tip. Axiom pins the release tag and
  tracks `quattro` read-only.
- `omarchy-iso` publishes no GitHub releases or tags; the exact commit used for the stable ISO
  must be resolved from its build history or CI metadata during the preflight and recorded here.
- The upstream repositories form a cooperating set (`omarchy`, `omarchy-iso`, `omarchy-pkgs`,
  mirror). Tracking upstream means tracking pinned versions of that set, not one branch.

## 3. Upstream change flow

```text
Omarchy upstream (pinned set)
        ↓
review upstream diff / release notes
        ↓
classify: security | feature | config | cosmetic
        ↓
Axiom compatibility review (shell, policy, licensing, recovery)
        ↓
security / performance / boot tests
        ↓
port, adapt or reject on the migration branch
```

Axiom never auto-merges upstream changes. Axiom will diverge substantially in branding, shell,
AI runtime, security enforcement and system APIs.

## 4. Current Axiom baseline

- Phases 0 and 1 are EXIT MET with retained evidence; Phase 2 is authorized for a Plasma 6
  desktop that this migration supersedes.
- The security, AI/agent/ecosystem, Flow/performance, Btrfs, packaging and systemd contracts are
  desktop-neutral and reusable.
- The identity/desktop layer is Plasma/KWin-coupled: `AGENTS.md`, `README.md`,
  `docs/ARCHITECTURE.md`, `TECH_STACK.md`, `MVP.md`, `ROADMAP.md`, `PHASES.md`, `PRD.md`,
  `VISION.md`, `SUBAGENTS.md`, `desktop/DESKTOP_UX.md`, `desktop/WAYLAND.md`,
  `desktop/DESIGN_SYSTEM.md`, `system/PERFORMANCE.md`, `system/FLOW.md`, `system/SYSTEMD.md`,
  `ai/ECOSYSTEM.md`, `engineering/ECOSYSTEM_PLAN.md`, `engineering/TESTING.md`,
  `engineering/BENCHMARKS.md`, the `plasma-qml` skill and the Phase 2 additions in
  `iso/profile/packages.x86_64` + `iso/profile/README.md`.
- The repository has no root `LICENSE`; licensing and trademark review are explicitly unresolved.

## 5. Component audit matrix

Classification: KEEP, MODIFY, REPLACE, REMOVE, RESEARCH. "Effort" is relative, not a schedule.

| Component | Omarchy implementation | Axiom requirement | Class | Reason | Security | Performance | Licensing | Testing |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Arch base | Arch x86-64/aarch64 | Arch x86-64 first | KEEP | Matches ADR-001 | Signed repos, recorded inputs | Unchanged | Arch packages | Rebuild + boot |
| pacman / PKGBUILD | pacman + Omarchy repo priority | pacman, reviewed PKGBUILDs | KEEP | Matches ADR-001 | Signature required, no AUR in privileged path | Unchanged | PKGBUILD licenses | Install/upgrade/remove |
| systemd | systemd units, logind, oomd | systemd | KEEP | Matches ADR-002 | Unit hardening review | Unchanged | LGPL-2.1+ | Unit lifecycle |
| Kernel | custom `linux-omarchy` | upstream `linux` + `linux-lts` fallback | RESEARCH | Axiom's ADR-002 asks for upstream kernels | Unknown patch surface | Unknown | GPL-2.0 | Mainline + LTS boot |
| Compositor | Hyprland | Hyprland | REPLACE KWin | Wayland compositor, window/workspace ownership | Hyprland permission model; no input-capture defaults | Measure idle/frame cost | BSD-3-Clause | Session, IPC, multi-monitor |
| Shell toolkit | Quickshell | Quickshell | REPLACE Plasma shell | QML shell surfaces, one process | Shell is trusted code; lock/shell crash path to test | jemalloc + lean config; idle cost unmeasured | LGPL-3.0-only | Panel/launcher/lock/a11y |
| Omarchy shell | `shell/**`, plugins, themes | Axiom Shell | MODIFY / REPLACE UX | Axiom identity and UX | Shell config is trusted code | Measure | MIT (repo) | Shell acceptance |
| `omarchy-*` CLI | hundreds of commands | Axiom system APIs + own CLI | MODIFY | User-facing authority and naming must be Axiom's | Avoid broad privileged helpers | Command startup cost | MIT | CLI contract tests |
| Greeter | SDDM Wayland | SDDM (branded) | KEEP / MODIFY | Replaces abandoned `plasma-login-manager` assumption | Greeter is privileged UI | Login latency | GPL-2.0-or-later | Autologin/normal login |
| Boot chain | Limine + UKI | Limine/UKI vs systemd-boot | RESEARCH | Conflicts with accepted ADR-002; recovery integration | Signed boot target not solved upstream | Boot time | Limine BSD-2 / GPL? verify | Encrypted boot + rollback |
| Plymouth | Plymouth + Omarchy themes | Plymouth + Axiom splash | MODIFY | Reuse mechanism, replace identity | Asset publication | Boot time | GPL-2.0+ | Splash evidence |
| Snapshots | Btrfs + snapper, root only | Btrfs + snapper with tested coverage | KEEP / MODIFY | Root-only coverage is a known limit | Rollback authority | Snapshot cost | GPL-2.0 | Failure/power-loss tests |
| Update system | `omarchy update`, migrations, channels | Axiom-owned update/rollback | MODIFY | Axiom must own semantics and branding | Signed packages; guard behavior | Update duration | MIT | Upgrade/divergence test |
| Installer/ISO | archiso-derived, prebuilt root image + archinstall format | Omarchy-derived flow | MODIFY | Owner direction prefers proven path over Calamares-first | Disk target, LUKS, Secure Boot | Install time | MIT | Disposable-disk install |
| Networking | NetworkManager + resolved | NetworkManager + resolved | KEEP | Matches ADR/systemd docs | No second manager, firewall defaults reviewed | Unchanged | GPL/LGPL | Network smoke |
| Audio | PipeWire/WirePlumber + ALSA UCM | PipeWire/WirePlumber | KEEP | Matches ADR | UCM/filter data provenance | Measure | GPL/LGPL | Audio smoke |
| Bluetooth | BlueZ + helpers | BlueZ | KEEP / MODIFY | Reuse | Pairing/auth review | Unchanged | GPL-2.0 | Pair/forget tests |
| Notifications | Quickshell service | Axiom notifications | MODIFY | Axiom identity and consent UX | Untrusted content rendering | Measure | LGPL (Quickshell) + MIT | Injection/action tests |
| Clipboard | Quickshell clipboard plugin | Axiom clipboard | MODIFY | Sensitive-content exclusion required | Clipboard history privacy | Unchanged | LGPL + MIT | Sensitive exclusion |
| OSD / panels | Quickshell plugins | Axiom Control Center/panels | MODIFY | Axiom IA and tokens | Trusted UI | Measure | LGPL + MIT | Keyboard/a11y |
| Screenshots/recording | Omarchy capture stack | Axiom capture | MODIFY | Consent and Wayland boundaries | Hyprland screencopy permission ASK | Capture overhead | MIT/GPL mix | Consent/denial |
| Wallpapers/themes/fonts/icons/sounds | 23 themes + asset set | Original Axiom assets | REPLACE | Identity; licensing gaps | Provenance | Asset size | Mixed/unattributed — RESEARCH | License inventory |
| Hardware detection/GPU | `omarchy-hw-*`, vendor fixes | Reuse where valid | KEEP / MODIFY | Valuable upstream work | Device access review | Boot/hardware behavior | MIT | Hardware smoke in VM |
| Firewall/SSH/sudo | ufw, opt-in SSH, passwordless sudo option | Axiom security invariants | MODIFY | No inherited weakening | Stronger Axiom defaults | Unchanged | MIT/GPL | Listener/denial tests |
| Secure Boot / TPM | requires disabling both | Signed boot/UKI + LUKS2 target | RESEARCH / DIVERGENCE | Upstream limitation | Central to Axiom trust | Boot path | mixed | Feasibility experiment |
| Power/sleep | power profiles, clamshell, zram | Reuse primitives, Axiom toggles | KEEP / MODIFY | Reuse mature behavior | Suspend/lock review | Measure | MIT/GPL | Suspend/resume |
| Developer tooling | mise, editors, containers | Axiom install checklist | MODIFY | Selection belongs to user profile | No socket to agents | Startup cost | mixed | Provisioning tests |
| Dotfiles model | `~/.config` vs packaged defaults + hooks | Keep ownership separation | KEEP | Updates survive user config | Config provenance | Unchanged | MIT | Upgrade test |
| Plugins/menu extensions | plugin system + JSONC menu | RESEARCH | RESEARCH | Possible extensibility input | Plugin trust | Measure | MIT | Plugin boundary tests |
| AI/agent commands | `omarchy-agent*`, agents panel | Axiom AI runtime | REPLACE | Authority model and UX are Axiom's | No inherited "bypass" modes | Agent overhead | MIT | Contract tests |

### Required removals (from a future Axiom image, not from this repository)

Visible Omarchy product identity, Omarchy themes/wallpapers/logos, `omarchy-*` user-facing naming
where Axiom owns the surface, and any agent behavior that bypasses Axiom authorization.

### Required replacements

KWin/Plasma shell → Hyprland + Quickshell; `plasma-qml` workflow → `quickshell-ui`; Omarchy
branding → original Axiom identity; Omarchy agent integration → Axiom runtime.

## 6. License findings

- `omacom/omarchy` and `omacom/omarchy-iso` are MIT; `omarchy-pkgs` is MIT per repository
  metadata (verify at build). Required copyright/license notices must be preserved.
- Quickshell is **LGPL-3.0-only**; linking/distribution obligations apply (source/relink
  availability, license text, no relicensing). Hyprland is BSD-3-Clause. SDDM, Plymouth and
  other system components carry their own licenses.
- Bundled asset provenance is incomplete upstream: theme wallpapers have no in-tree
  attribution; the icon font partially documents glyph sources; sounds were not located;
  vendor icons are trademarks. These are **RESEARCH / redistribution blockers** and must be
  resolved before any Axiom release — see [THIRD_PARTY_NOTICES](../../THIRD_PARTY_NOTICES.md).
- Axiom still has no root `LICENSE`, and first-party ModelCheck still has no license file. The
  release license-inventory gate remains open.

## 7. Sibling-project verification

| Product | Repository | Revision verified | License | Real capability | Axiom gap |
| --- | --- | --- | --- | --- | --- |
| Warden | `Prof-bilal/Warden` | `main` `f7c9793167398c86a61148c746cb4d934be11727` (old pin `cd5e8bf…` is the `axiom/integration` tip) | MIT | Go CLI; bubblewrap namespaces + setpriv `no_new_privs` + strace; host-side HTTP(S) allowlist proxy; JSONL audit; fail-closed; no seccomp/Landlock; no typed API | Typed policy/execute interface, request→policy builder, audit-ID correlation; bypass matrix NOT RUN |
| RepoSpine | `Prof-bilal/RepoSpine` | `main` `9ea06ec33a69a613a91831cd7c533a11ca16b032` | MIT | TypeScript/pnpm, Node ≥22.13; SQLite + tree-sitter; budgeted context; freshness; CLI/SDK/MCP; **repo-scoped** | Multi-root/system context; stable interface for the Axiom parent |
| ContextGit | `Prof-bilal/ContextGit` | `main` `8acd4e7df4ca583334745c20f17968094ced6162` | Apache-2.0 | Python core + CLI + HTTP/SSE API + MCP + Tauri 2 app; task/branch/worktree isolation code present | Headless runtime API confirmation; non-repo/session mode is on an unmerged branch |
| ModelCheck | `Prof-bilal/ModelChecker` | `main` `eddcf746c30399c77e494cc6dfcfa9398e64c1bb` | No LICENSE; `cli/package.json` MIT | Node CLI: `init`, `baseline`, `verify`, `compare`, `run`, `list`; local verdicts; no MCP | License file; integration with provider/model configuration; Ollama support |
| Morphix | `Prof-bilal/Morphix` | `main` `1ee76d1189b843d306f4987a71cf49fdaae2b683` | MIT OR Apache-2.0 | Rust/Tauri; Plasma 6 detection, packs, planner, snapshots | No releases; transaction/rollback and adapter writes unimplemented; Plasma-only |

Documentation already claimed the `axiom/integration` branch in every sibling repo; that
branch exists, but for Warden it differs from `main`, and the pinned revision/label in
`DECISIONS.md` is incorrect. Corrected in the updated docs.

## 8. Security differences (Omarchy vs Axiom)

| Area | Omarchy | Axiom position |
| --- | --- | --- |
| Secure Boot | Documented requirement to disable it | Evaluate signed boot/UKI as a divergence; no claim yet |
| TPM | Documented requirement to disable it | Evaluate measured boot/TPM sealing as RESEARCH |
| Disk encryption | LUKS passphrase by default, no TPM unlock described | Keep LUKS2; evaluate TPM unlock only after feasibility |
| Boot chain | Limine + UKI + snapshots; direct-boot hides menu | Compare against systemd-boot; recovery must remain reachable |
| Snapshots | Root only; `/home` not covered | Preserve explicit coverage limits; no universal undo |
| Privilege | Opt-in passwordless sudo | Do not inherit; keep per-request authorization |
| Agents | Agents often launched in "don't-stop-to-ask" modes | Axiom never grants model authority; typed policy + Warden |
| Shell | Quickshell single trusted process | Treat shell as trusted code; separate lock/shell risk |
| Firewall/SSH | ufw on, SSH opt-in | Stronger Axiom defaults; no unexpected listeners |

## 9. Performance and desktop differences

- Quickshell is one long-running Qt/QML process per config; upstream recommends jemalloc and
  documents API breaks in minor releases plus a private-Qt rebuild requirement. Idle RSS/CPU is
  **not measured upstream** and must be measured locally in E29.
- Hyprland owns windows, workspaces and input; the shell observes through IPC and layer-shell
  surfaces. Axiom must not recreate a compositor.
- Quickshell lacks a launcher UI, clipboard manager, OSD UI, a logind module and
  reduced-motion handling; those are explicit Axiom Shell work items.
- Plasma/KWin and Hyprland/Quickshell cannot own the same seat simultaneously; Plasma can only
  be a transition login-session fallback, not a concurrent stack.

## 10. First boot target and rollback

**First implementation target (after this documentation pass):** pinned stable Omarchy → boot in
QEMU → Axiom branding → Hyprland + Quickshell → Axiom shell starts → networking/audio preserved
→ encryption/recovery where validated → no visible Omarchy branding → reproducible build
instructions. Nothing more.

**Rollback plan for the migration:**

1. All documentation and pin work lives on `migration/omarchy-foundation`; `main` is untouched.
2. Upstream mirrors and worktrees are gitignored under `workspace/upstream/`; deleting them
   removes all fetched upstream content without touching Axiom history.
3. ADR-013 supersedes ADR-003 but preserves the original record; restoring the Plasma direction
   is a matter of adding a new ADR, not rewriting history.
4. Phase 1 `iso/` evidence and validators remain in place and are marked legacy rather than
   deleted.

## 11. Research answers (owner's 22 questions)

1. **Reuse:** Arch/pacman/systemd, Hyprland, Quickshell, Plymouth, SDDM, NetworkManager/
   resolved, PipeWire/WirePlumber, BlueZ, hardware helpers, dotfiles ownership model, Btrfs/
   snapper mechanisms, the update/migration mechanism's shape.
2. **Upstream relationship:** pin stable release tags plus package versions; track `quattro`
   read-only; classify every diff; no auto-merge.
3. **Shell vs distro infrastructure:** Omarchy is mostly Hyprland/Quickshell configuration,
   shell UX, CLI, hardware scripts and installer/update tooling; the kernel, mirror and ISO live
   in sibling repositories.
4. **Quickshell sufficiency:** sufficient for panels, docks, lock, notifications, tray, audio,
   network, Bluetooth, UPower and polkit; missing launcher UI, clipboard manager, OSD UI,
   reduced-motion handling and a logind module — Axiom Shell work.
5. **Obsolete Axiom work:** Plasma packages, `plasma-qml`, the `plasma-login-manager` assumption,
   Plasma layout/splash/branding plans, Calamares-first installer wording.
6. **Reusable work:** all security/AI/agent/ecosystem contracts, Flow, Btrfs recovery contract,
   packaging rules, testing/evidence process, validators, Phase 0/1 evidence.
7. **Updates vs customization:** use Omarchy's `~/.config` vs package-default separation, hooks
   and migrations; Axiom never edits packaged upstream files in place.
8. **Installer branding:** rebrand the Omarchy-derived ISO/configurator in a later phase.
9. **Secure Boot strategy:** upstream requires disabling it; Axiom's target is signed boot/UKI +
   LUKS2, recorded as RESEARCH and never claimed implemented.
10. **RepoSpine headless:** yes — CLI, SDK and MCP exist; the stable interface Axiom needs is
    still missing.
11. **RepoSpine multi-root:** not supported today; a workspace layer is required.
12. **ContextGit headless:** CLI/API/MCP and an importable Python core exist; the declared
    primary UI is a Tauri app, not Electron.
13. **Per-child isolation:** task/branch/worktree isolation code is present; non-repo/session
    mode is on an unmerged branch.
14. **Smallest Warden interface:** a typed policy/execute contract over the bubblewrap backend
    with stable error and audit shapes.
15. **Policy generation:** Axiom capability → validated request → request-bound Warden grants;
    Warden never decides intent.
16. **ModelCheck integration:** it gates provider/model promotion; a candidate must pass the
    baseline comparison before becoming a default.
17. **ModelCheck placement:** local first, with CI verdict artifacts later.
18. **Morphix usefulness:** the plan/snapshot/transaction concept remains useful; the Plasma-only
    implementation does not fit the new foundation.
19. **Shell-agnostic Morphix:** required if retained; a Hyprland/Quickshell adapter or a
    shell-agnostic redesign is a separate future decision.
20. **Default vs optional:** foundation, Axiom Shell, AI runtime and Shield ship by default;
    RepoSpine, ContextGit, ModelCheck and Morphix remain optional packages/tools with graceful
    absence.
21. **Idle CPU/RAM:** unmeasured; belongs to E29 and the Foundation POC.
22. **Version compatibility:** a pinned compatibility matrix across Omarchy, Quickshell,
    Hyprland, SDDM/Plymouth and sibling revisions, tested per phase.

## 12. Migration risks

- `quattro` moves fast; only stable tags/packages are reproducible.
- Limine/UKI conflicts with accepted ADR-002 systemd-boot and needs an explicit decision.
- Quickshell's private-Qt ABI and timed API breaks require pinned rebuilds.
- Secure Boot/TPM divergence is unproven and may be the largest security gap.
- Snapshot rollback covers root only; `/home` is excluded.
- Upstream update migrations can overwrite Axiom customization unless ownership boundaries are
  explicit.
- Sibling projects are early; several existing Axiom claims are false and must be corrected.
- Bundled asset licensing is only partially traceable.
- Quickshell has no upstream reduced-motion mechanism and a shell/lock crash path was reported.

## 13. Experiments required before implementation commitment

| ID | Experiment | Pass condition |
| --- | --- | --- |
| E26 | Boot pinned stable Omarchy in QEMU with Axiom identity | Clean UEFI boot, Hyprland/Quickshell session, no Omarchy branding, retained logs |
| E27 | Pinned Quickshell Axiom shell smoke | Panel, launcher, notifications, audio, network start and remain responsive |
| E28 | Boot chain choice on encrypted Btrfs | Limine/UKI or systemd-boot selection supports rollback and fallback kernel |
| E29 | Quickshell idle cost and ABI rebuild | Measured idle RSS/CPU; pinning/rebuild policy documented |
| E30 | Secure Boot/TPM feasibility | UKI + LUKS2 boot path proven or explicitly rejected with evidence |
| E31 | RepoSpine/ContextGit headless context | Bounded context returned and per-agent branches isolated |
| E32 | Warden policy generation/audit/bypass | Request-bound grants, correlated audit, fail-closed proven on mainline and LTS |
| E33 | Upstream divergence upgrade | Axiom customization survives an Omarchy-derived update |

## 14. What this report does not do

No Omarchy code is merged or vendored. No implementation phase is started. No branding is
designed. No Secure Boot/TPM support is claimed. No sibling repository is modified. Historical
Phase 0/1 evidence is unchanged.
