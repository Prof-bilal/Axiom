# Axiom landing page design brief

Status: concept research and visual directions, 2026-11-03; status refreshed
2026-11-12. This is not a release or hardware promise.

## Product truth to communicate

Axiom is an experimental AI-native Linux desktop for developers: a calm,
local-first workspace built around a real shell, core apps, privacy, safe
automation and honest recovery. The current verified milestone is Phase 6:
the system installs to a blank disk, reboots and logs in, with the Shell, Files,
Settings, Terminal integration and a read-only Software Center already verified
in QEMU. The AI-native layer is planned for Phase 12 and should be shown as
direction or boundary, never as shipped functionality.

## Research takeaways

- Product-led developer pages make the product concrete early. Cursor uses a
  working-software visual and task-oriented narrative rather than leading with
  abstract AI imagery.
- Technical products benefit from visualizing system ownership and workflows.
  Linear's AI page repeatedly pairs capability claims with concrete flows and
  action traceability.
- Dark, high-contrast surfaces with one bright accent suit developer tools, but
  the page should keep copy and UI readable. Vercel's AI page uses product
  examples and connected systems instead of a single generic hero illustration.
- Axiom needs an evidence layer that the reference pages do not: the repo's
  QEMU evidence, phase status and explicit limitations are part of the product
  story. This is an Axiom-specific recommendation derived from the project's
  “proof over promise” contract.

## Recommended page progression

1. Hero: “AI-native Linux for developers” with a real-looking Axiom desktop
   visual and a clear status label such as “Phases 0 to 6 complete · Phase 7 next”.
2. Why Axiom: calm workspace, local-first operation, bounded automation and
   recovery-minded design.
3. Inside the desktop: Shell, Files, Settings, Terminal and Software Center,
   with shipped/read-only labels where appropriate, plus the Phase 6 installer
   and login screens.
4. How it is built: Linux infrastructure remains shared; Axiom owns the
   desktop/session boundary, shell, apps, AI boundary and security UX.
5. Evidence: QEMU verification, 76 Phase 5 checks, and truthful known limits.
6. Roadmap: Phases 7 to 10 (usable core), then Phase D differentiators, then
   Phase 11 security and Phase 12 AI-native layer, clearly marked as future work.
7. Call to action: explore the repository, read the architecture, or follow
   the next milestone. Do not promise a general release or broad hardware
   support yet.

## Visual directions

| Concept | Best use | Trade-off |
| --- | --- | --- |
| [Calm command center](../branding/landing-concepts/01-calm-command-center.png) | Strongest default hero; makes Axiom feel like a finished product | Must pair with evidence below so it does not overstate maturity |
| [System map](../branding/landing-concepts/02-system-map.png) | Architecture and ownership section | More technical; needs a simpler hero above it |
| [Work in motion](../branding/landing-concepts/03-work-in-motion.png) | Workflow storytelling for developers | More expressive and less suited to the evidence-first message |
| [Proof over promise](../branding/landing-concepts/04-proof-over-promise.png) | Best fit for the current open engineering stage | Less emotionally immediate as a first-screen hero |

Recommendation: combine the calm command center hero with the proof-over-
promise evidence section and use the system map lower on the page. This keeps
the page aspirational without confusing planned AI capabilities with the
verified Phase 6 desktop.

## Source ledger

- [Cursor product page](https://cursor.com/product) — task-oriented product
  storytelling and concrete agent workflows; accessed 2026-11-03.
- [Linear AI page](https://linear.app/ai) — capability examples paired with
  traceability, review and connected context; accessed 2026-11-03.
- [Vercel AI page](https://vercel.com/ai) — product examples and connected
  workflows as the visual language for AI infrastructure; accessed 2026-11-03.

