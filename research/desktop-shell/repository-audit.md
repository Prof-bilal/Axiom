# Repository audit before Phase 3 implementation

Date: 2026-10-28. Baseline: `b2354d0` (Phase 3 reset). Inspection covered the
187 visible/nonignored paths, document headings/contracts, scripts, tests,
legacy profile, upstream session configuration and installed QML metadata.
Ignored sibling repositories are independent products, not implementation inputs
to import into Axiom. No source code was changed before this inspection.

Architecture remains ADR-013: Arch, Hyprland, Quickshell/Qt QML. Hyprland owns
windows, focus, workspaces and input. Quickshell owns trusted user-session shell
surfaces. Rust/D-Bus services and the AI runtime belong to later phases. No
replacement compositor, web shell, root UI or new generic executor is needed.

Read contracts: ARCHITECTURE, DECISIONS, PHASES, ROADMAP, VISION, PRD, MVP,
TECH_STACK, desktop UX/design/Wayland, SECURITY, TESTING, AGENT_WORKFLOW,
Flow/performance, Phase 1/2 evidence and the Phase 3 reset reports. The reset
report is historical: it says assets were removed, while the current worktree
contains owner-restored untracked branding. Current files take precedence.

| Area | Current evidence | Consequence |
| --- | --- | --- |
| Shell/services/components | No Axiom shell, service or UI source after reset | Build incrementally on native Quickshell APIs |
| Legacy build | archiso profile, build/check scripts, Phase 1 QEMU harness and CI remain | Preserve; Plasma entries here are historical, not the migration base |
| Phase 2 | PHASE2_EVIDENCE says IN PROGRESS; UEFI/build/update/recovery/hardware gaps | Do not claim foundation or Phase 3 release ready |
| VM developer helper | Untracked scripts/run-qemu.sh refers to missing prepare-qemu-guest.sh | Preserve owner's file; do not assume it works |
| Hyprland | Host 0.56.2, commit efb50993780079460b0cbed1363e2166a2de1d9f | Host observations cannot prove disposable guest integration |
| Quickshell | Host 0.3.2, revision 2b4501a282689792b62e94f3fb30d8f512324fe6 | Record divergence from upstream 0.3.2 pin |
| Display | One eDP-1, 1920×1080, scale 1.5 | Mixed DPI/multi-monitor not yet tested |
| Tests | Foundation validator, concept checks, ISO checks, Phase 1 boot | No surviving Phase 3 integration test |
| Upstream | Local Omarchy v4.0.6 source; read shell/services/AppLibrary.qml and config/hypr/hyprland.lua | Source references only; no upstream modifications |

Official assets located: `branding/identity/axiom-wordmark.{svg,png}`;
`branding/theme/axiom/icons/axiom-penguin{,-64}.png` and `axiom-penguin.svg`;
`branding/theme/axiom/backgrounds/aurora.{svg,png}`; palette `colors.toml`,
Foot palette and shell theme TOMLs. Preserve these originals and reuse them.
The asset manifest lists preview screen PNGs that are absent in this checkout;
the README and manifest do not establish that those images exist. Missing
references must be reported, never replaced with invented screenshots.

Ownership: this run adds research, REA documentation and the new shell foundation;
updates canonical phase/UX status. Existing untracked editor configuration and
branding belong to the owner and remain untouched. After announcing the change,
the owner's VM launcher received only `restrict=on` in its user-network backend
to allow isolated foundation testing; its missing preparation helper is bypassed
with `--foundation`, not assumed functional. No other run's
file ownership is declared in `.contextgit/context.md`.

Initial acceptance: working REA MCP handshake and read-only probe; durable
evidence workflow; real Hyprland window/workspace/monitor model; explicit
unavailable state; no fake windows; no mutation of existing host applications.
Window controls and Dock follow only after foundation validation.
