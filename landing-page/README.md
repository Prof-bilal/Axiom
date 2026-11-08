# Axiom landing page

The public site for Axiom OS. Next.js 16 (App Router, React 19, TypeScript), exported
as a fully static site. No runtime server, no CMS, no tracking, no analytics.

It explains the idea (an AI-native Linux desktop where AI proposes and you decide),
shows interactive demos of the design, and states honestly what is built and what is
only designed. It is **not** a screenshot gallery: product screenshots live only on
`/desktop/`.

## Quick start

Requirements: Node.js 20.9 or newer and npm.

```sh
cd landing-page
npm install
npm run dev        # dev server (Turbopack), http://localhost:3000
npm run typecheck  # tsc --noEmit
npm run build      # static site in out/
npm start          # serves out/ with `npx serve`
```

`next.config.ts` sets `output: "export"` and `trailingSlash: true`, so every route is a
directory index (`/progress/index.html`) and works on any static host. The Turbopack
root is pinned to this folder because it lives inside the larger Axiom repository.

## Deploy

Upload `out/` to any static host (GitHub Pages, Netlify, Vercel static, nginx, S3).
There are no environment variables and no server code. If a host serves the site from
a sub-path, add `basePath` in `next.config.ts` and re-export.

Page rules, which apply to every deploy:

- No download button until redistribution is authorized (see `THIRD_PARTY_NOTICES.md`).
- No source link while the repository is private.
- Every limitation stays listed under "What does not work yet" on `/progress/`.
- Nothing designed may read as shipped (see **Honesty rules** below).

## Pages

| Route | Purpose |
| --- | --- |
| `/` | Hero, introduction, then the idea sections (below). |
| `/desktop/` | Real QEMU screenshots of the shell, core apps and system controls. |
| `/approach/` | What Axiom reuses, what it owns, and the rules that do not bend. |
| `/progress/` | Completed phases with evidence, measured numbers, and known limits. |
| `/roadmap/` | The next phase and the planned phases in order. |

Navigation and the footer are shared. The current page is marked in the navigation.

## Home page structure

The hero and the introduction section are the stable core of the page. Everything below
them is a set of interactive, screenshot-free sections in `app/page.tsx`:

| # | Section | Component | What it shows |
| --- | --- | --- | --- |
| 1 | Hero | `components/hero-experience.tsx` | Dot-matrix penguin, canvas AXIOM wordmark, drifting agent icons. |
| 2 | Introduction | `app/page.tsx` (`intro-band`) | "Your computer. Your possibilities." |
| 3 | AI proposes. You decide. | `idea-stage.tsx`, `idea-sections.tsx` (`Pillars`) | A scripted propose / approve / deny demo and four principles. |
| 4 | How an AI request travels | `ai-pipeline.tsx` | The six-step pipeline with a moving packet and "Never" rules. |
| 5 | Ten things AI can do | `idea-sections.tsx` (`CapabilityGrid`) | The ten typed capabilities in plain language, plus what stays locked. |
| 6 | Meet the agents | `agents.tsx` (`Agents`) | Choose one of twelve child agents, ask it to act, watch it run. |
| 7 | Build your own agent | `agents.tsx` (`BuildYourOwn`) | A visual block builder with live safety checks. |
| 8 | Built for developers | `dev-journey.tsx` | A blank disk becoming a workspace, layer by layer. |
| 9 | Yours. Local-first. | `idea-sections.tsx` (`LocalFirst`) | Your machine versus an optional, off-by-default model provider. |
| 10 | Proven Linux underneath | `foundation.tsx` | An interactive stack: what Axiom builds and what Linux provides. |
| 11 | Built. Booted. Verified. | `idea-sections.tsx` (`PhaseTimeline`) | Phases 0 to 13 as a dot timeline. |
| 12 | Straight answers | `faq-chat.tsx` | A question-and-answer chat. |
| 13 | Closing band | `dot-field.tsx` | The call to action over a dot field. The footer uses the same field, still. |

## Repository layout

```
landing-page/
  app/
    layout.tsx          shared shell: nav, footer (with a still DotField), metadata
    page.tsx            the home page and its section order
    globals.css         base tokens and shared components
    marketing.css       editorial overrides, hero and intro styles
    sections.css        all styles for the idea sections and demos
    desktop|approach|progress|roadmap/page.tsx
  components/           client components (demos) and small shared pieces
  lib/
    home.ts             home page FAQ copy
    data.ts             phases, limits, measured numbers, galleries (single source of truth)
    agent-icons.ts      16 pixel icons for the hero's agent layer
  public/
    hero/penguin-frames.webp   sprite sheet used by the hero
    shots/                     QEMU screenshots, used only on /desktop/
```

Copy that states a fact comes from `lib/data.ts`, which is written from
`docs/PHASES.md`. Update it from the docs, never from memory.

## Honesty rules

The AI layer is **designed, not built**. The repository docs say so directly
(`docs/ai/AI_ARCHITECTURE.md`: "V1 design, no runtime exists"). The page follows:

- Every AI demo is labelled "Design example", and says nothing here runs.
- Tags are **Built · verified** (verified in QEMU), **Designed** or **Planned**.
  Use the same three words everywhere.
- Demos are scripted. There is no model, no free text box, and no fake output
  presented as real. Example results end in "(example)".
- Phase numbers come from `docs/PHASES.md`. The AI docs disagree with it about which
  phase brings the agents, so the page does not print phase numbers for them.
- Numbers need a source. Do not add a performance or test count without a recorded run.

When a phase completes, update `phases` and `limits` in `lib/data.ts`, the stats in the
`PhaseTimeline` section copy in `app/page.tsx`, and the FAQ if an answer changes.

## The hero (`components/hero-experience.tsx`)

One canvas draws these layers every frame, in order:

1. **Penguin** (`drawArt`): nine grayscale frames from `public/hero/penguin-frames.webp`
   are sampled onto a 7 px dot grid (8 px on phones). The 9 frames play once per page
   load over about 4 s (`FRAME_MS = 450`, with blending between frames), then hold and
   run a gentle idle loop: slow breathing, a belly and eye pulse, and a drifting halo.
2. **Ambient dots** (edge density field with a slow wave).
3. **Agent icons** (`drawAgents`): sixteen 9×9 pixel icons for the core components and
   twelve child agents drift across the hero. They fade over the text, slow and grow on
   hover, and show a label like `Research · OBSERVE · Designed`.
4. **Wordmark** (`drawSign`): the AXIOM letters, built cell by cell in a placeholder box
   (`.pixel-sign`), with a hover lift and push from the pointer.
5. **Pointer wake**: a fading scatter of bright dots (max 18 points, about 950 ms).

Motion and performance rules:

- The loop runs only while the hero is on screen and the tab is visible.
- Dot colours are quantised (`levels`) so no colour string is built per dot per frame.
- `prefers-reduced-motion`: a static settled frame, no drift, no idle, no hover label.
- All listeners and observers are removed on unmount. Touch input adds no trails.
- Frame time with every layer running has **not** been measured. Record it before
  making any performance claim.

### Regenerating the penguin sprite sheet

The source is `Neon Penguin Orbital Awakening.gif` (553×297, 9 frames; not stored in this
repo). With ffmpeg:

```sh
ffmpeg -y -i "Neon Penguin Orbital Awakening.gif" \
  -vf "scale=368:-1:flags=lanczos,format=gray,eq=contrast=2.4:brightness=0.07:gamma=0.4,tile=9x1" \
  -frames:v 1 -update 1 public/hero/penguin-frames.webp
```

`FW = 368`, `FH = 198` and `FRAMES = 9` in the hero must match the output (3312×198).

### Editing the agent icons

`lib/agent-icons.ts` holds one entry per agent: `name`, `cls` (`OBSERVE`, `NORMAL`,
`SENSITIVE` or `CORE`) and nine strings of nine characters. `1` is the body in the class
colour, `2` is the accent pixel (white; cyan on core icons) and `0` is empty. The accent
pixel blinks out now and then. Keep names in step with `components/agents.tsx`.
Design for the silhouette first, avoid one-pixel details, and preview before shipping.

## Design system

- **Palette:** dark, with cyan as the accent (`--cyan`), mint for highlights
  (`--logo-light`), amber for "designed / needs your attention" (`--orange`) and a red
  for the highest-risk class. Tokens live in `globals.css` and `marketing.css`.
- **Type:** Inter for text, JetBrains Mono for labels, code and tags.
- **Motifs:** square pixels, dot-grid panels, dashed borders for "planned" and "designed",
  solid borders for "built".
- **Demo panels** share one look: a `demo-bar` header strip ("DESIGN EXAMPLE"), a dot-grid
  background, and a status tag. New demos should reuse these classes in `sections.css`.
- **Permission colours** match everywhere: OBSERVE cyan, NORMAL mint, SENSITIVE orange.

## Accessibility and motion

- All demos are real buttons with visible focus rings and `aria-pressed` or `aria-live`
  where state changes. Decorative canvases and icons are `aria-hidden`.
- Every diagram has real text content, so it reads without the animation.
- Auto-playing sequences (pipeline, developer journey, propose/decide stage) run once when
  scrolled into view and have a Replay control.
- `prefers-reduced-motion` removes drift, typing, pulsing and transitions, and shows the
  finished state.
- Scroll reveals animate already-visible content and never hide it behind a script flag,
  so a failed script leaves the page readable.

## Verification

Before a push:

```sh
npm run typecheck
npm run build
git diff --check
```

Then review in a browser at 375 px and a desktop width, with and without reduced motion:
the hero intro and idle loop, hovering agent icons, each demo (including keyboard use),
all navigation destinations, and the footer dots. Browser review is manual; there are no
automated UI tests. These are static pages with no loading, form or server-error states.

## Troubleshooting

- **Dev server spins or scans the whole repository:** the Turbopack root must stay
  pinned in `next.config.ts` (`turbopack.root`).
- **`import.meta.dirname` errors on a host:** `next.config.ts` deliberately uses
  `process.cwd()`, because some hosts load the file as CommonJS.
- **Penguin does not appear:** check that `public/hero/penguin-frames.webp` exists and
  matches the constants above. Until it loads, the hero shows only the dots.
- **A section looks stale after editing CSS:** all demo styles are in `app/sections.css`.

## Visual references and research

Reviewed on 2026-11-07 for structure only; no copy, artwork or code is reused:

- Omarchy (https://omarchy.org/): a strong visual opening, then grouped product stories.
  Axiom's wordmark geometry, canvas field, palette, copy and implementation are original.
- Kali Linux (https://www.kali.org/): clear audience and capability groups.
- elementary OS (https://elementary.io/): task-oriented features and project principles.
- Fedora Workstation (https://fedoraproject.org/workstation/): clear routes to editions.

Install, hardware support, downloads, community counts and release claims stay out of
the page until evidence or distribution channels exist.

Product claims stay aligned with `docs/PRODUCT.md`, `docs/VISION.md`, `docs/PHASES.md`,
`docs/ai/*` and `docs/SECURITY.md`.
