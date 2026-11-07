# Axiom landing page

Next.js (App Router, static export). No runtime server, no CMS, no tracking.

```sh
npm install
npm run dev      # http://localhost:3000
npm run build    # static site in out/
```

Page copy and carousel content live in `lib/home.ts`. Screenshot alt text must
match the captures in `public/shots/`. Detailed milestone facts on supporting
pages come from `docs/PHASES.md` and `docs/research/*/evidence.md`. Screenshots in
`public/shots/` are crops of the retained QEMU captures in
`docs/research/phase5/screenshots/`.

Page rules: no download button until redistribution is authorized (see
`THIRD_PARTY_NOTICES.md`), no source link while the repository is private, and
every limitation stays listed under "What does not work yet".

## Page structure

- `/`: full width hero, Axiom introduction, feature list, future AI vision, a
  carousel of the desktop captures, and a short in development call to action.
- `/desktop/`: screenshots of the shell, core apps, and system controls.
- `/approach/`: ownership boundaries, reused infrastructure, and design principles.
- `/progress/`: completed milestones, measurements, and all known limitations.
- `/roadmap/`: upcoming phases and their intended outcomes.

Navigation and the footer are shared; the current page is marked in the navigation.
Each route has its own title and description. Static exports use directory indexes
(`trailingSlash`) so direct visits work on ordinary static servers.

The homepage distinguishes the working desktop from planned AI. Keep detailed
engineering evidence on Progress and avoid moving the full roadmap back onto Home.

Verification: `npm run build`, `npm run typecheck`, and `git diff --check`.
Browser review should cover 375px and desktop widths, keyboard focus, the skip link,
all navigation destinations, and full-size screenshot links. These are static pages:
no loading, form-validation, permission, or server-error states are introduced.

Product claims stay aligned with `docs/PRODUCT.md`, `docs/VISION.md`,
`docs/PHASES.md`, `apps/README.md` and `shell/README.md`. Screenshots are gathered
in one carousel; the hero, introduction and feature list come before the future
AI vision, gallery and closing invitation.

Homepage editorial direction: benefit-led marketing, with plain language and product
visuals. Keep test counts, platform internals, phase numbers and detailed limitations
on the supporting pages. Retain a short development notice and label AI as future work.

## Visual direction and motion

The marketing presentation draws inspiration from the full-height graphic hero,
monospace details, fine section rules and broad editorial layout at
https://omarchy.org/ (reference inspected 2026-11-07). Axiom's wordmark geometry,
canvas field, palette, copy and implementation are original; no reference artwork,
source code, music or product claims are included.

`components/hero-experience.tsx` owns the interactive masthead. It uses the fixed
Axiom cyan palette. The previous accent/pause toolbar has been removed. The edge
field is static at rest; mouse movement creates a short pixel wake that settles
after one second. Reduced motion disables the wake and letter entrance. The canvas
stops scheduling frames off-screen or when the document is hidden. Resize,
visibility, pointer and media listeners are removed on unmount.

`app/marketing.css` holds the editorial design overrides. Homepage content stays
server-rendered. Scroll reveals animate already-visible content and never hide it
behind a JavaScript-ready class, so a failed script leaves the page readable.
Manual review targets: pointer movement and settling, narrow widths,
reduced motion, route return, and visibility changes. Browser review is pending
when no connected browser is available.

Hero refinement: full viewport width, connected shaded letterforms, compact monospace
headline and centered announcement. The canvas uses seeded 10px edge pixels and a
maximum 18-point mouse trail that fades within 950ms. Touch input does not add trails.
Reduced motion retains a static edge field.

The first two sections after the hero are the Axiom introduction and feature list.
Those are the clean product story to keep stable while later sections evolve.

The homepage keeps product screenshots in one 13-slide carousel. The feature list
uses text-led benefits, followed by a marketing description of the future AI vision.
The carousel supports previous/next buttons, direct slide selection and arrow keys;
it has no autoplay. Its screenshot captions are written for visitors rather than
copied from QA evidence. The navigation remains available to detailed pages.

## Landing page research

Reviewed official pages on 2026-11-07 for content structure, not copied copy or
artwork:

- Omarchy (Omarchy project): https://omarchy.org/ — point of view, a strong visual
  opening, then grouped product stories, proof and community.
- Kali Linux (OffSec): https://www.kali.org/ — a clear audience and value, then
  capability groupings and options; its breadth does not fit an early desktop.
- elementary OS (elementary): https://elementary.io/ — task-oriented features,
  app stories, screenshots and project principles.
- Fedora Workstation (Fedora Project): https://fedoraproject.org/workstation/ —
  clear routes to editions; download paths rely on mature releases.

Axiom adapts the product-story, feature and screenshot patterns. Install,
hardware support, downloads, community counts and release claims are deferred
until evidence or distribution channels exist. AI stays framed as future vision.
