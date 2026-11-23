# Axiom differentiation and documentation research (Phase 8 pre-work)

Agent 5, research only. Date: 2026-11-23. No source code was changed. Scope: what is genuinely
different about Axiom, what exists in code versus only in docs, and which ideas are worth pursuing.
Sibling reports (audit, git, ISO optimization, feature gaps) live in `reports/phase-8/`; this report
does not duplicate them.

Labels: **[V]** verified in code/tests I read; **[D]** documented only; **[A]** assumption;
**[R]** recommendation; **[Q]** open question. Priority: P0 now (Phase 8-10 window), P1 phase D,
P2 Phase 11-12, P3 later/experimental.

---

## 0. Executive summary

- **[V]** Axiom's real, shipped distinguishing substance today is narrow: (1) a polkit-gated,
  argv-only root helper with *separate* actions for install/update/rollback/system-install and a
  snapper snapshot-before-update rule (`system/pkgd/axiom-pkgd`,
  `iso/phase3/airootfs/usr/share/polkit-1/actions/org.axiom.installer.policy`,
  `tests/apps/pkgd.test.mjs`); (2) a unified install front-end (Hub + file-drop App Installer) over
  pacman/flatpak/AppImage/deb-via-distrobox with minisign + bwrap + audit-line logic
  (`apps/appinstaller/installfile.js`); (3) a custom Quickshell desktop and a live-desktop native installer
  (ADR-035); (4) an unusually strict, evidence-first project process (AGENTS.md rules, QEMU gates).
- **[V]** Everything AI-native (assistantd, ActionService, broker, Jarvis, lessons, routines, MCP,
  Flow, Connect/cross-device, Warden enforcement, Phase 11 capabilities) is **design only**. There
  is no `ai/`, `services/` or `security/` directory, and `grep` for `assistantd|ActionService|landlock`
  in code finds only docs, the landing page and the ADR-032 bwrap code. The docs say so honestly
  ("no runtime exists", "not implemented").
- **[R]** The strongest *credible* positioning is not "AI-native" (crowded) but **"the developer
  desktop where every system change is typed, attributed, and undoable"**: the Phase 7 rollback
  spine + typed actions + audit, extended outward. AI becomes a *client* of that spine in Phase 12.
- **Marketing-only / overclaim risk found:** see section 7. The landing page is largely honest
  (it labels items built/designed/planned); the risks are in repository docs that read like
  capability (Hub "Install verified: 81", Axiom Flow, "Warden enforcement path") and in the ADR-022
  claim that profiles "cannot run code".

---

## 1. Stage 1: documentation inventory vs code reality

| Claim / feature | Where documented | Code reality | Verdict |
|---|---|---|---|
| Axiom Shell (panel, dock, launcher, switcher, OSD, notifications, snap, capture bar) | PHASES, DESKTOP_DESIGN, ADR-017/029/030 | `shell/src/{panel,dock,launcher,menu,notifications,osd,switcher,snap,capture,...}`, `shell/services/*.qml` (14 services) | **[V] exists** (QEMU evidence claimed per phase; Hyprland migration partly unverified per ADR-029/030 status "Proposed") |
| Axiom-owned compositor | AGENTS.md, ARCHITECTURE | Default session is Hyprland (ADR-029/031) with labwc fallback; no Axiom compositor | **[V] not owned.** "Axiom owns the compositor/session boundary" is only true at the session/config level |
| Core apps: Files, Settings, Software, Hub, App Installer, live installer | ADR-017/021/035 | `apps/{files,settings,software,hub,appinstaller,liveinstaller}` | **[V] exists** |
| Snapshot-before-update + rollback | ADR-033, BTRFS_ROLLBACK | `axiom-pkgd` update calls `snapper -c root create` first and refuses without snapper; rollback numeric id only; `tests/apps/pkgd.test.mjs`, `tests/phase7-update-rollback.py` | **[V] exists.** ADR-033 still says "Proposed / separate polkit actions required"; code *has* the four actions, so the ADR is stale |
| Separate polkit actions | ADR-033 | `org.axiom.installer.{install,update,rollback,system-install}` in policy file | **[V]** |
| Signature verification, policy, bwrap sandbox, audit JSONL for local installs | ADR-032 (Proposed) | `installfile.js` has `minisignArgv`, bwrap argv, `auditLine`; unit-tested in `installfile-logic.test.mjs` | **[V] logic exists**; end-to-end QEMU proof listed as not done in ADR; `minisign`/`bubblewrap` are in `packages.x86_64` |
| Hub: 97 apps | docs/hub/README.md, research/hub | `apps/hub/catalog.js` has 97 ids | **[V] catalog exists.** "Install verified: 81" means the install command was *checked against a source* (HANDOFF.md: "install command checked against a source"), **not** installed in QEMU. Easy to misread |
| Developer Hub (curated toolchain presets, podman datastores with SENSITIVE class and an "undo" field) | ADR-021, `catalog/developer-hub.json` | JSON catalog + installer step removed from installer (commit ef93734: "installer tools step removed") | **[V] data exists**; presets are plain package lists (this is the weakest "differentiator", comparable to Omarchy/Bazzite presets) |
| Capture (grim, wf-recorder) | ADR-030 | `shell/src/capture/CaptureBar.qml` | **[V] exists**, wf-recorder QEMU verification pending |
| Graphical greeter, boot UI, framebuffer TUI installer | ADR-024/025/027 | `greeter/`, `tui/`, `provision/`, `installer/` + `tests/installer/*` | **[V] exists** (unusual for a distro this size) |
| Typed `ActionService`, command palette, Launcher+ | ADR-022 seam S5, PHASES Track 1 | `ApplicationService.qml` only; no ActionService | **[D] not built** |
| `assistantd`, provider router, MCP integration, Duet/Team, lessons, routines, broker, Axiom Sessions | ADR-023, docs/ai/* | None. Docs: "no runtime exists", "no methods implemented" | **[D] design only** |
| Phase 11 capability/scope/audit layer; Warden as enforcement | docs/security/*, WARDEN_INTEGRATION | None. SANDBOXING.md: "enforcement behaviour is RESEARCH"; ADR-032 explicitly declines Warden in favor of bwrap | **[D] design only**; Warden is a separate pre-1.0 Node project in `workspace/Warden` |
| Axiom Flow (resource orchestration) | docs/system/FLOW.md, PERFORMANCE.md | None; "all measurements NOT YET MEASURED" | **[D] design only** |
| Connect / cross-device / Android | docs/connect/* | None; "LATER, no promise" | **[D] design only** |
| Profiles (look layer), Zones, Projects, Connections, Automate, Write | ADR-022, tracks 1-4 | None | **[D] planned (phase D)** |
| Landing page demos (agents, AI pipeline, idea stage) | `landing-page/components/*` | Scripted demos, explicitly labelled "DESIGN EXAMPLE / scripted / no model" and status tags built/designed/planned | **[V] honest**, but see section 7 |
| `workspace/{ContextGit,ModelChecker,Morphix,RepoSpine,Warden}` | ECOSYSTEM.md | Real separate projects with their own tests (ContextGit has a large pytest suite); not part of the ISO | **[V] exist, not integrated**. Note Morphix targets KDE Plasma, not Axiom |

Note: `docs/updatephase6.md`, `docs/handoff/phase3-wip/` and ADR statuses lag the code in places
(ADR-033, ADR-030, ADR-032 all "Proposed" while implemented). **[R]** A documentation-truth pass
should mark ADR status from evidence (belongs to the audit report, flagged here only because it
affects marketing accuracy).

---

## 2. Stage 2: analysis

### 2.1 Genuine differentiators (real or near-real)
1. **Narrow, separately-authorized privileged helper + mandatory snapshot** [V]. Most distros give
   the GUI store a single broad polkit action (PackageKit) or `sudo`. Axiom's four-action split and
   "refuse to update without a way back" is a real, testable safety property.
2. **Unified installer front-end with provenance** [V logic, QEMU pending]: one drop target for
   AppImage/Flatpak/pacman/deb with signature state, policy decision, sandbox profile and audit ID.
   Competing stores (GNOME Software, Discover, Bazaar) do not show a unified audit trail or run
   AppImages in bwrap by default.
3. **Process rigor as a product trait** [V]: QEMU evidence per phase, "claims need a retained test"
   (ADR-022 R5, Track 4 "claims we must not make"). Unusual and credible for a trust-centric OS.
4. **Honest local-first AI contract** [D]: authority from a deterministic broker, never prompt text;
   taint rule; one-use SENSITIVE grants. Design quality is high and aligned with the research
   literature (section 4). Not yet an advantage because nothing runs.

### 2.2 Common elsewhere (do not market as unique)
Arch base + archiso; btrfs+snapper rollback (openSUSE, Garuda, EndeavourOS recipes, Manjaro);
Hyprland glass look (Omarchy, many riced setups); curated dev presets (Omarchy, Bazzite dev images,
Pop!_OS); Flatpak/distrobox integration (Bazzite, Fedora Atomic, Vanilla OS); screenshot/record bar
(every DE); installer with disk encryption (Calamares).

### 2.3 Promising but underdeveloped
- Snapshot rollback UI (Software Center list + rollback exists; F7 "Backups UI" is a future idea).
  Known limits not yet handled: /boot, ESP and `/home` are outside the root snapshot domain (SUSE
  docs: bootloader rollback unsupported; community reports of unbootable states when kernels are on
  a separate /boot). Needs the BTRFS_ROLLBACK.md layout decisions verified in the installer.
- Install audit trail (JSONL, user-owned file) is **tamperable by the user's own processes** [A];
  fine for UX attribution, not a security log. Root-side journal for pkgd needs verification.
- Developer Hub: data-driven with `class`/`undo` fields, which is a good seed for typed actions,
  but presently just package lists.

### 2.4 Needs stronger foundations first
Everything in docs/ai, docs/security (beyond polkit/bwrap), Flow, Connect. Prerequisites in order:
typed `ActionService` (S5) -> Phase 11 broker with its own UID and audit store -> sandbox runner
(bwrap/systemd-run + Landlock probe) -> only then any model-facing surface.

### 2.5 Marketing-only (today)
See section 7.

### 2.6 Real user demand (evidence in repo research, not re-verified externally)
Track 0/2/3 report: Omarchy's audience wants customization without fragile dotfiles, code-running
themes (KDE Store `rm -rf` incident), forced AI and root-escalation defaults. **[A]** these are
secondary agent-gathered findings; recommend 5 to 10 real interviews (Track 0 already suggests this)
before committing the 38-week phase D list.

---

## 3. Stage 3: external research summary (with sources)

| Topic | Finding | Source |
|---|---|---|
| Agent sandboxing on Linux | Claude Code reportedly uses bubblewrap + proxy domain allowlist; Codex CLI/Cursor use Landlock + seccomp; Sandlock (2026 paper) combines Landlock, seccomp-bpf and seccomp user-notify with a narrow supervisor; `ai-jail` wraps bwrap+Landlock+seccomp. Most of this is secondary reporting; verify against primary repos before citing publicly | https://dev.to/crabtalk/sandboxing-ai-agents-beyond-docker-and-wasm-5d8n, https://arxiv.org/html/2605.26298, https://docs.rs/crate/ai-jail/latest/source/README.md |
| MCP security | Tool poisoning (injection through tool descriptions/results), rug pulls (definition changes post-approval; most clients do not re-prompt), tool shadowing, confused deputy; spec leaves authN/Z to implementers. Matches Axiom's MCP.md stance (pin versions, no ambient grants, same approval boundary) | https://cheatsheetseries.owasp.org/cheatsheets/MCP_Security_Cheat_Sheet.html, https://labs.cloudsecurityalliance.org/research-rb/csa-whitepaper-mcp-security-agentic-attack-surface-20260516/, https://simonwillison.net/2025/Apr/9/mcp-prompt-injection/, https://arxiv.org/pdf/2603.22489 |
| Capability tokens / agent OS prior art | aaOS (userspace Linux prototype, narrowing capability tokens, audit trail, headless), `@kernel.chat/agent-os` alpha (signed tokens with TTL and invocation limits), AOS paper (deterministic control plane mapped onto Linux primitives), AgenticOS manifest-to-minimal-capability model. None is a shipping desktop | https://github.com/Joncik91/aaOS, https://arxiv.org/pdf/2606.01508, https://arxiv.org/pdf/2606.21129 |
| Snapper/btrfs limits | Separate /boot breaks grub-btrfs-style snapshot boot; read-only snapshot boots need writable /var (overlayfs hook); /home and /var/log need separate subvolumes; SUSE: bootloader rollback unsupported. Best reference: Arch wiki Snapper page and SUSE docs | https://documentation.suse.com/en-us/sles/15-SP7/html/SLES-all/cha-snapper.html, https://github.com/david-cortes/snapper-in-debian-guide, https://wiki.archlinux.org/title/Talk:Snapper |
| Flatpak portals | Portals give per-use, user-mediated access; Flatseal-style static overrides are always-on and invisible at use time. Argues for Axiom surfacing portal grants rather than static overrides | https://docs.flatpak.org/en/latest/sandbox-permissions.html, https://www.linux-magazine.com/Issues/2026/310/Flatseal |
| Immutable/atomic competitors | Fedora Atomic/bootc, Bazzite: image-based, "hard to break", but friction with dev tools (1Password/SSH via Flatpak). Axiom's mutable-Arch + snapshots trades image purity for flexibility | https://knowledgebase.frame.work/how-to-manage-flatpaks-in-bazzite-H1Z3HcO3Jx, https://blogs.gnome.org/mcatanzaro/2025/07/21/fedora-must-carefully-embrace-flathub/ |

Limitations: search was standard-depth, several sources are blogs/forums; none of the above was
verified by running anything. Treat as direction, confirm before any public claim.

---

## 4. Report catalogue

Each item: description; user problem; technical approach; status; priority. Idea-level fields
(original concept / external tech / improvement / benefit / complexity / risk / advantage) are
condensed into the table text.

### 4.1 Existing differentiators

**E1. Typed, separately-authorized privileged helper (axiom-pkgd + polkit actions)**
- Description: one root helper, validated verbs, four polkit actions, argv only. [V]
- Problem: GUI stores that ask for broad root; approving an install implicitly approving a rollback.
- Approach: already built; next, polkit `auth_admin` message binding, retention for snapshots.
- Status: shipped, tested (`pkgd.test.mjs`). Gaps: arguments are not bound into polkit approval
  (polkit authorizes the action, not the package list; docs/security/SANDBOXING.md says the same),
  so the *helper* must keep re-validating. **[R]** add a root-side journal outside the snapshotted
  domain (BTRFS_ROLLBACK.md already requires it).
- Advantage: real. Complexity low. Risk: shell script helper (`axiom-pkgd`, 74 lines) is fragile;
  consider a small Python/Rust rewrite when verbs grow. Priority P0.

**E2. Snapshot-before-update with refuse-without-rollback**
- Status: shipped [V]. Limits: root domain only; /boot/ESP and kernels; /home excluded by design.
- Improvement **[R]**: verify installed layout keeps kernel+initramfs inside the root subvolume
  (or add a pacman hook copying them), add retention (snap-pac-style number cleanup), expose
  "restore point" UI (F7). Priority P0 (it is the base of the whole trust story).

**E3. Unified App Installer / Hub with provenance (signature state, policy, bwrap, audit ID)**
- Status: logic [V], QEMU evidence [Q]. Problem: unverified binaries from the web with full home access.
- Approach: ADR-032. Limits: bwrap without `--unshare-net` shares network (documented); AppImage
  desktop integration may need portals; user-writable audit file is attribution not forensics.
- **[R]** retain the QEMU proof ADR-032 lists ("probe cannot read ~/.ssh") before any marketing line.
  Priority P0.

**E4. Native live-desktop installer + custom boot/greeter stack**
- Status: shipped [V] (ADR-035, tests/installer). Differentiation is polish and honesty, not novelty
  (Calamares exists). Priority: maintain.

**E5. Evidence-first engineering contract** (QEMU per milestone, claims-need-tests). [V] Keep; a
public "verified claims" page generated from retained evidence would turn process into product
(P1, cheap).

### 4.2 Partially implemented

**P1. Developer Hub / curated dev environments** [V data, partial]
- Problem: day-one dev setup. Approach: presets in `developer-hub.json`, rootless podman datastores
  loopback-only, `undo` text per item. Gap: not wired as a first-run flow after the installer tools
  step was removed; "undo" is prose, not executable inverse; no project-level environments.
- **[R]** make each item's undo a typed inverse (`remove packages`, `podman rm`) executed via the
  same helper, and add per-project toolchains via distrobox/devcontainers rather than global installs
  (ADR-028 already uses distrobox). Priority P1. Competes with Omarchy/Bazzite; differentiate by
  undo + audit.

**P2. Capture bar** [V]: commodity. Differentiation only via D4 (OCR/annotate/upload-on-click) and
the not-yet-possible cursor sidecar. Priority P1, low novelty.

**P3. Hub catalog verification** [V partial]: upgrade "verified" from "command checked against a
source" to "installed in CI/QEMU and launched". **[R]** a nightly QEMU or container smoke job
publishes real pass/fail per app. Priority P1; makes the 97-app claim real.

**P4. Settings store with schema versioning (ADR-018, seam S2)** [V partial]: the foundation for
profiles and "updates never break your settings". Needs migration tests across two schema versions
before that claim (Track 4 already says so). Priority P1.

### 4.3 Planned innovations (documented, not built)

**N1. Typed ActionService (seam S5)** — P0 foundation. Description: one catalog of actions
(id, argument schema, sensitivity class OBSERVE/NORMAL/SENSITIVE/CRITICAL, undo coverage) that the
Launcher, command palette, keybinds, Hub and later AI all call. Approach: JSON schema catalog +
a QML service that validates and dispatches to pkgd/systemd user units/xdg tools. Benefit: the
single biggest enabler; makes AI an additive client. Complexity medium. Risk: scope creep into a
daemon (ADR-022 S9: no new daemon without ADR; implement as shell service first). Advantage: high
(coherent product spine). Status [D]/partial in `ApplicationService.qml`.

**N2. Profiles (look layer, then layout/behavior; data-only, import/export)** — P1. Problem:
fragile dotfile theming, code-running themes. Approach: JSON profile validated by schema; no code.
External: Morphix is the sibling concept (KDE). Risk: "cannot run code" must be proven with an
adversarial corpus before it is claimed. Advantage: medium-high if it stays declarative.

**N3. Phase 11 security layer: capability grants, scopes, audit, secrets** — P2. Approach per docs:
broker as dedicated UID, polkit for root actions, bwrap/systemd-run sandbox for workers, Landlock
probing, audit store outside snapshot domain, secret store (R4 deferral). Complexity high.
Risk: marketing the design as protection; prompt injection beats published defenses under adaptive
attack (ADR-023). Advantage: potentially the core differentiator but zero code today.

**N4. Phase 12 AI layer (Duet/Team, broker-enforced authority, taint narrowing)** — P2. Status
design only. Keep everything in ADR-023 that is deterministic. **[R]** defer "lessons" (needs a
passing experiment per the ADR itself) and Team mode; ship one agent with typed actions and a kill
switch first.

**N5. Zones, Launcher+, Projects, Connections, Creator profile, Automate, Write** — P1 to P2, per
ADR-022 ordering. Honest ranking by distinctiveness: Launcher+/ActionService high; Zones medium;
Projects low (Track 4 itself says do not market it); Connections medium (SSH config GUI, avoids secrets
until Phase 11); Automate high-risk; Write low.

**N6. Axiom Flow (resource orchestration over cgroups/systemd)** — P3. Linux already has
systemd-oomd, `systemd-run`/slices, power-profiles-daemon, ananicy-cpp. A new orchestrator needs
measured stalls (PSI) first. **[R]** begin with measurement only: record `/proc/pressure/*` during
dev workloads in QEMU/hardware, and use systemd slices for agents; no new daemon.

**N7. Connect / cross-device / workspace continuation** — P3. Reuse KDE Connect (GSConnect protocol)
rather than a new stack, as the docs already say. "Workspace manifest" (declarative, untrusted
input) is a nice idea compatible with Projects. Complexity high, Android specifics unreliable.

### 4.4 Research-backed opportunities (new; not in docs or only implied)

**R1. "Agent jail" runner as a shared primitive (bwrap + Landlock + seccomp + systemd-run scope)**
- Concept: one `axiom-run` launcher that builds the sandbox from a typed manifest; reused by
  AppImage installs (ADR-032), developer sessions (Lane 1), MCP stdio servers and Hub datastores.
- External: bubblewrap, Landlock (probe ABI), seccomp, systemd transient units for cgroup limits
  and one-command kill; `ai-jail`/Sandlock as reference designs; Claude Code/Codex patterns.
- Benefit: one reviewed isolation path instead of several ad-hoc ones. Complexity medium. Risk:
  user namespaces disabled (ADR-032 already specifies "say not sandboxed"), shared kernel, network
  egress needs a proxy/allowlist to be meaningful. Advantage: high, and buildable *before* AI.
  Status: bwrap argv exists only for AppImage. Priority P1 (extract) / P2 (extend). Needs ADR.

**R2. Unified "Permissions and activity" view (Privacy dashboard, F8) built on existing signals**
- Show: Flatpak portal grants (`flatpak permissions`, document portal), camera/mic/screen-cast
  active streams from PipeWire, bwrap sandbox profiles, install audit lines, snapshots. Use
  portals' per-use consent as the story versus Flatseal-style static overrides.
- Benefit: concrete, visible security UX using existing Linux data; no AI. Complexity medium.
  Risk: portal data completeness varies by backend. Advantage: high and honest. Priority P1.

**R3. Reversibility ledger (typed undo coverage per action)**
- Every ActionService action declares `undo: full | partial(reason) | none` (the Hub JSON `undo`
  field and PERMISSIONS "rollback coverage" already point here). Show it *before* approval.
- Benefit: delivers the "never promise universal undo" rule as UI. Complexity low-medium.
  Advantage: strong, matches the brand. Priority P1 with N1.

**R4. Pre-flight diff for system changes**
- For updates: show pacman transaction preview (`pacman -Syu --print`, kernel/driver flags,
  `checkupdates`), Arch news check, and snapshot state before the root prompt. Deterministic, no AI.
- Benefit: addresses the real fear of Arch updates; direct user demand. Complexity low. Priority P0/P1.

**R5. Boot-safe rollback hardening**
- Verify rollback works when kernel updates are included: kernel/initramfs inside root subvolume,
  Limine/GRUB snapshot entries (grub-btrfs needs overlayfs hook for read-only boots), a
  "last known good" boot entry, and a post-update boot-success marker (systemd boot counting /
  `systemd-bless-boot` style). Source: Arch/SUSE limits in section 3. Complexity medium-high.
  Priority P0 because current evidence covers `snapper rollback` + reboot only.

**R6. Local-first assistive features where AI is genuinely better, otherwise classic tools**
- Good AI fits: explain a failed update/journal error (read-only, redacted), propose an
  ActionService plan from natural language (always approved), commit-message/changelog help.
  Bad fits (use classic): search (plocate), cleanup (deterministic rules), resource tuning (PSI +
  systemd), update decisions. Keeps "core works without cloud AI". Priority P2.

**R7. MCP gateway with pinned tool manifests** — treat every MCP server as a low-trust Lane 1
caller: pin tool description hashes and re-prompt on change (defends rug pulls), strip descriptions
from the model-visible text where possible, no ambient credentials, per-tool grants. Source: OWASP
MCP cheat sheet, CSA whitepaper. Complexity medium. Priority P2; reuses R1.

**R8. Verified-claims page generated from evidence** (see E5). P1.

### 4.5 Experimental concepts (high uncertainty, optional)

- **X1. Capability-token agents via file descriptors / per-agent UID + systemd user scopes**
  (aaOS / AOS-paper pattern). Research prototype outside the ISO first. P3.
- **X2. Taint tracking at the broker** (ADR-023 rule): needs an experiment with adversarial prompt-
  injection corpus; success criterion measurable (block rate, false-prompt rate). P3.
- **X3. Lessons for weaker models** (ADR-023 item 5): explicitly experiment-gated; SkillsBench
  evidence is mixed. Keep gated. P3.
- **X4. Workspace continuation via declarative manifest** across two Axiom machines. P3.
- **X5. Local-model "system doctor"** (Ollama/llama.cpp, read-only, journal explainer) as the
  first AI feature, because it is read-only and fits OBSERVE class. P2.
- **X6. Forensic/undercover/encrypted-persistence live modes (F1, F2, F11)**: niche; only F1/F2
  have clear users (security/privacy crowd). P3.

### 4.6 Features NOT worth pursuing (now)

- **Own compositor** (reject for the foreseeable future): Hyprland/labwc already provide it; the AGENTS.md
  wording "Axiom owns the compositor boundary" should be read as session/config ownership. Wayland
  cursor/click streams for Screen-Studio-style videos are blocked by portal/wlroots limits (Track 4).
- **Forced or default-on cloud AI, always-on screen capture/Recall-style memory.** Contradicts the
  privacy rules and is the main complaint against competitors.
- **Marketplace of code-running themes/plugins** (KDE Store incident; ADR-022 rejected).
- **Photoshop/Office/Fusion compatibility promises** (Wine reliability); offer honest status only.
- **A new cross-device protocol** (reuse KDE Connect), **a new package manager or Flatpak
  replacement**, **a custom resource scheduler** before PSI measurements.
- **AI as control loop for boot/session/resources** (already barred by PHASES).
- **Embedding Vicinae/Raycast clones** (license/process cost; ADR-022 rejected).
- **Team/"swarm" agent mode and lessons before a single-agent broker is proven.**
- **Shipping Warden as the enforcement authority** (Node, pre-1.0; ADR-032 chose bwrap). Keep it
  as an optional adapter at most.
- **Hub scale as a headline** ("97 apps"): breadth is not a moat; depth (verified, sandboxed,
  undoable) is.

---

## 5. Recommended differentiation stack (ordered)

1. Make rollback bulletproof and visible (E2, R4, R5): the one proven trust asset.
2. Extract a single sandbox runner (R1) from ADR-032 and prove it in QEMU.
3. Ship typed ActionService with reversibility metadata (N1, R3); route Hub/Launcher/palette through it.
4. Privacy/permissions dashboard (R2) and verified-claims page (R8): visible, honest, no AI.
5. Profiles look layer (N2), declarative only, with an adversarial corpus.
6. Phase 11 broker, then one read-only local AI feature (X5), then Duet (N4).

This sequencing keeps every non-negotiable intact: nothing here needs unrestricted root for AI,
every privileged step stays a narrow polkit action, and the desktop works without any model.

## 6. Open questions

- **[Q]** Does the installed system keep kernels and initramfs inside the snapshotted root, and is
  there a boot entry for snapshots? (check installer/`axiom-provision`; not verified here.)
- **[Q]** Has the ADR-032 QEMU proof (unsigned AppImage asks admin, bwrap cannot read `~/.ssh`) been run?
- **[Q]** Is root-side pkgd logging stored outside the rolled-back domain?
- **[Q]** Real demand: no primary interviews exist; Track 0/2/3 are agent-gathered secondary data.
- **[Q]** Hyprland migration: ADR-029/030/031 status vs actual QEMU evidence (UI-M1 "verification pending").
- **[Q]** Should Warden be retained at all given ADR-032's decision and its Node/pre-1.0 status?

## 7. Marketing-only or overclaim-prone items found

1. **Hub "Install verified: 81 (97 apps)"** (`docs/hub/README.md`): means "command checked against
   a source", not "installed and launched". Rename to "install command sourced" or make it true (P3 above).
2. **AI pipeline, agents and "Policy / sandbox / Verified" demos** on the landing page: scripted, and
   labelled so, but the visuals imply a working policy engine, sandbox and assistantd. Keep the
   "DESIGN EXAMPLE" bars prominent and avoid screenshots of them in external posts.
3. **"Axiom owns the compositor/session boundary"** (AGENTS.md, PRODUCT): compositor is Hyprland/labwc.
4. **Warden as "the visible enforcement path" / "concrete answer: is this AI system safe?"**
   (`docs/security/WARDEN_INTEGRATION.md`): not implemented; ADR-032 itself rejects Warden for now;
   SANDBOXING.md says enforcement is RESEARCH.
5. **Axiom Flow and PERFORMANCE.md**: all numbers "NOT YET MEASURED"; no claim about responsiveness
   is allowed until PSI/latency data exists.
6. **Profiles "cannot run code"** (ADR-022 text): true by design only; Track 4 already lists it as a
   claim not to make until a validator and adversarial corpus exist.
7. **ADR status drift**: ADR-030/032/033 marked "Proposed" while code exists; ADR-033 still lists
   separate polkit actions as "required before shipping" though they are present. Not marketing, but it
   misleads readers about what is real.
8. **Cross-device / Android / MCP / AI router** docs are explicit about "LATER/RESEARCH"; low risk, but
   they should not appear in feature lists.

The landing page's own status tags (`built | designed | planned`, `idea-sections.tsx`) are the right
mechanism; recommend the same three-state tag in README and hub docs.

## 8. Assumptions and limits of this report

- Code verification was by file reads and greps of the current worktree (branch
  `phase7-installer-hub-rollback`, with many uncommitted changes); I did not run tests, QEMU or builds.
- I did not read every QML file; "exists" means the named files and tests exist and contain the cited
  logic, not that behavior was exercised.
- External sources are web search summaries (several blogs/forums/arXiv preprints); confirm primary sources
  before external use.
