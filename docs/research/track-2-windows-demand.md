# Track 2: Windows/Mac demand → what Axiom builds

Date: 2026-11-09. Method: a 4-agent pipeline (Finder → Judge → 2 MVP
designers). Piracy is used only as a demand signal; Axiom never distributes or
enables cracked software. Reddit was not reachable by the tools, and
WineHQ/ProtonDB ratings are second-hand. Details:

1. [Candidates](track-2/1-candidates.md): 94 rows (~105 apps) that run on
   Windows/macOS without a native Linux version.
2. [Verdicts](track-2/2-verdicts.md): scored on Demand, Gap, Buildability and
   Fit (1-5 each). Result: 8 BUILD rows, 66 BRIDGE, 20 KILL.
3. [MVP: Capture, Connections, Write](track-2/3-mvp-capture-connections-write.md)
4. [MVP: Zones, Launcher, Automate](track-2/4-mvp-zones-launcher-automate.md)

## Final build list (after the MVP agents challenged the judge)

| # | What | Replaces | Form | Effort (1 dev) | Works on the labwc harness? | Top risk |
|---|---|---|---|---|---|---|
| 1 | **Axiom Capture** | ShareX, Snagit, CleanShot | App (already required by Phase 8) | ~8 wk | Yes | Editor size; redaction must destroy pixels; labwc lets any client capture the screen (Phase 11) |
| 2 | **Zones** | PowerToys FancyZones | Settings page plus snapping, via generated labwc regions | ~3 wk | Yes (per-monitor layouts need the Axiom compositor) | labwc limits leaking into the UX |
| 3 | **Launcher+** | Raycast, Alfred, Everything | Extend the existing `Launcher.qml` with a plocate `$HOME` index and script commands | ~4 wk | Yes | Index freshness (~15 min vs instant) |
| 4 | **Connections** | MobaXterm, WinSCP | App over `~/.ssh/config` (Axiom include file), Terminal and Files/GVfs SFTP | ~4.5 wk | Yes | Config injection → `ProxyCommand` code execution; needs strict schemas and a malicious-input test |
| 5 | **Automate** | AutoHotkey (narrow) | Typed-action catalog shared with the Launcher; hotkeys, snippets, curated remaps; AI can only propose | ~5 wk | Partly (abbreviation expansion and per-app input grants need the Axiom compositor) | wtype reliability; users expecting full AHK |
| 6 | **Write** (demoted) | Grammarly | A "fix the selected text" action, not an app; local Harper, LanguageTool opt-in | ~3 wk | Yes | Narrow gap; most use is already covered in browsers and editors |

Total: ~27 weeks for one developer. **Order: Capture → Zones → Launcher+ →
Connections → Automate → Write.** Zones builds the shared labwc config
adapter; Launcher+ builds the shared `ActionService` that Automate reuses.

## Decisions recorded by the pipeline

- **Don't embed Vicinae.** It's GPL-3.0 while Axiom is Apache-2.0, its Node
  extensions have no sandbox (the same risk class as the KDE theme that ran
  `rm -rf`), and Axiom already has a launcher. Offer it as an optional package.
- **Launcher and Automate share one typed-action catalog:** one validator, one
  security review.
- **Bridge, don't build** Photoshop, Office, Figma, Canva, Notion, WhatsApp,
  Tally, etc. One "install as web app" flow covers ~10 web-only rows; tested
  Wine presets come with honest warnings (Photoshop and Office under Wine are
  still unreliable).
- **Kill:** vendor shipping Linux (Affinity, confirmed 2026-11-03), anti-cheat
  games, Apple lock-in, and giant CAD/BIM tools.

## Open issues found (for later phases)

- **Phase 11:** on labwc, any unsandboxed Wayland client can capture the
  screen and inject input. Capture and Automate make this visible; Axiom's
  compositor or a policy layer must gate it.
- **Phase 11:** there is no user secret store on the image (no keyring). It
  needs an ADR before upload tokens or saved SSH passphrases.
- **One-day spikes before building:** labwc snap preview for regions,
  `wl-paste --primary` on labwc, GVfs SFTP with `~/.ssh/config` aliases,
  harper-cli JSON output, wtype in Electron apps, plocate size and latency.

## Overlap with other tracks

- **Capture = the demo-video tool from Track 3** (indie makers). Build it once.
- **Launcher+, Zones and Automate presets** become part of Track 1 profiles
  (for example "Windows-like" ships Zones plus Win-style keys).
