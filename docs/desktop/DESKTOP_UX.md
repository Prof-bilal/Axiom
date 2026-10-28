# Desktop experience

Status: Phase 3 execution specification, authorized 2026-10-28; window foundation in validation, first native window-controls slice in implementation.

Axiom presents a calm developer workspace: a slim status panel, compact application dock, keyboard-first launcher and a visible agent surface. Original identity comes from layout, typography, precise status and recoverability, not copying another operating system's chrome. Keep standard upstream desktop settings and recovery access available while custom surfaces mature.

V1 custom scope is a coherent Axiom Shell session, launcher/agent entry point and permission/activity views. Phase 3 includes real notification history, Control Center, launcher and workspace overview in the order recorded in [PHASES](../PHASES.md). Complete settings, software center and device center remain LATER. Build on Quickshell/QML and supported Hyprland APIs; Hyprland remains the compositor, window manager and workspace owner. Application UIs use Qt Quick Controls/Kirigami where appropriate; shell surfaces use Quickshell components and Axiom design tokens.

## Core journeys

- Start work: launcher searches installed desktop applications and approved workspaces; offline operation needs no model.
- Ask for a system action: overlay shows a structured plan, affected resources, provider/data destination, required permission and recovery limitations before execution.
- Review activity: show requested/authorized/executed/verified states distinctly, attributable actor and failure details; expose undo only for covered, verified recovery actions.
- Lose connectivity/provider: preserve typed input, explain failure, offer retry; ordinary desktop controls continue working.
- Recover: expose known-good boot/recovery instructions from welcome/update surfaces; never claim every change is undoable.

Authorization UI must be trusted and distinguishable from model-generated content. The assistant cannot manufacture consent, silently accept prompts or draw a fake system-authentication surface. Long operations stay cancellable at documented safe points; cancellation may stop future work without reverting completed effects.

Acceptance includes keyboard-only completion, screen-reader naming, visible focus, 200% text scaling, mixed DPI, multi-monitor, suspend/resume, offline and denied-permission scenarios. Review 1366×768 and 4K layouts and right-to-left text before freezing components.

Sources: [Quickshell](https://quickshell.org/docs/), [Hyprland wiki](https://wiki.hypr.land/), [Qt accessibility](https://doc.qt.io/qt-6/accessible-qtquick.html). See [tokens](DESIGN_SYSTEM.md), [Wayland](WAYLAND.md).

## Control Center: Performance / Flow

Extend the Axiom Control Center performance surface; do not create a separate Flow application or another profile selector. [Flow](../system/FLOW.md) owns policy and supported controls, while [performance](../system/PERFORMANCE.md) owns profiles and targets.

Show System Pressure (with freshness/unknown state), memory use, swap and compression (logical versus actual backing RAM), background/sleeping counts and expandable app groups. Each heavy-app row shows measured resource use and an effective state such as Active, Efficient, Limited, Sleeping or Unsupported. Do not present sample GB values as measurements. Budget percentages state whether they mean one CPU or all eligible CPUs; hard/soft memory boundaries have different warnings.

Actions: **Optimize Now**, **App Resource Rules**, and the existing **Performance Profile**. Optimize Now previews named eligible actions and exclusions, risk, consent and restore limits before execution. It never promises exact RAM recovery, silently kills apps or offers unavailable sleep/container functions as working. No global cache-clean button. Show no-action/unsupported/partial-failure outcomes honestly.

Per-app controls use Adaptive (Normal), Efficient, Never Restrict, bounded High Priority and temporary Keep Active; Sleep When Inactive is gated by compatibility/consent. Never Sleep is a veto, not OOM immunity. Expose advanced budgets progressively rather than twenty kernel knobs. Show who applied a rule, its expiry, inherited limits, activity vetoes and Restore. Foreground selection must remain possible while a workload is asleep; a trusted thaw route stays outside affected groups.

“Why slow?” starts with local deterministic facts, observation interval, stalls and attribution limits; optional AI explanation is separate. History lists interventions and emergency termination source/reason without app content. Notify after a proven oomd event; unknown exit source must remain unknown. Keyboard, screen-reader and reduced-motion acceptance cover pressure updates, confirmation, rule overrides, stale data, failed restoration and sleep-resume behavior. Telemetry collection can be paused/deleted within the bounded history policy.
