# Track 3 / Agent 1: solo-dev and indie-maker pains and existing tools

Date: 2026-11-10. Method: ~8 web searches (standard mode), no deep page fetches. reddit.com blocked. Evidence is mostly Indie Hackers, Product Hunt, HackerNoon, DEV, GitHub PRs and aggregator pages: anecdotal, not systematic. Items tagged [UNVERIFIED] come from my background knowledge or from aggregators that disagree with each other. Prices are approximate; check vendor pages. No direct quotes were fetched verbatim beyond what search snippets paraphrased; "evidence" below is paraphrase of the cited page unless in quotes.

## Area 1. Focus / project management with many side projects

### Pains
1. **Choosing what to work on today.** A Product Hunt thread "Solo founders: How do you decide what to work on each day?" has a founder saying solo judgment is "susceptible to the whims of the day", leading to low-leverage side quests. [PH discussion]
2. **Context-switch cost between projects.** HackerNoon "death valley of unfinished side projects" lists juggling projects as a cause of abandonment; switching is mentally demanding. Indie Hackers has repeated "multiple projects vs one" threads (recurring, so a durable pain).
3. **Cold-start cost / forgetting where you left off.** A PH maintainer of 20+ OSS projects says each must be small enough to cold start in under 15 minutes, else too complex for a solo maintainer. This implies "resume context" is the real bottleneck.
4. **Stale and abandoned repos, dirty worktrees, unpushed work.** Several hobby tools exist purely for this (drydock, dev-pulse, ovw, dangit, monogit): the number of small OSS tools is itself evidence of demand and of no dominant product.
5. **Scope creep / "too much at once".** Traversy "5 reasons side projects fail": trying to do too much, focus on one or two.
6. **Planning tools are heavy and team-shaped.** [UNVERIFIED, general knowledge] Linear/Notion/Jira model teams; for one person the overhead of maintaining the board outweighs value, so boards go stale.
7. **Time tracking is manual or editor-bound.** WakaTime only sees editors with plugins; Toggl needs manual start/stop. [partly UNVERIFIED]
8. **No portfolio-level view** across projects (which has momentum, which has users, which is stale). Existing git TUIs show git state only, not business state (users, revenue, validation status).

### Tools
| Tool | Price (approx) | Platforms | Linux |
|---|---|---|---|
| Linear | free tier; paid ~per seat [UNVERIFIED] | web, desktop, mobile | Web/Electron app works |
| Todoist | free; Pro ~$4-5/mo [UNVERIFIED] | all | yes (desktop app/web) |
| Things 3 | one-time, Apple only | macOS/iOS | no |
| Notion | free; paid per seat | all | web/unofficial desktop |
| Obsidian | free personal | all | yes (AppImage/Flatpak) |
| Indie CMD [UNVERIFIED, could not confirm details] | ? | ? | ? |
| WakaTime | free; ~$8-9/mo (aggregators disagree) | editor plugins, any OS | yes (CLI plugin) |
| Toggl Track | free up to 5 users; Starter ~$9, Premium ~$16-18 per user/mo (aggregators disagree) | all | yes (desktop/web) |
| GitHub Projects | free | web | n/a |
| Sunsama | ~$16/mo annual, ~$20 monthly | web/desktop/mobile | web only effectively |
| Akiflow | ~$17-19/mo annual | web/desktop/mobile | web/Electron [UNVERIFIED] |
| Motion | ~$19/mo annual up; AI credits overage | web/desktop/mobile | web |
| git TUIs: drydock, dev-pulse, ovw, dangit, monogit, Git Vision (gv), gitocular, gitling | free OSS | terminal | yes |
| Wakapi | self-hosted WakaTime-compatible | server | yes |

### Gaps
- Nothing combines: local git state + "last touched" + a chosen *next action* per project + a daily "pick one" nudge. Git TUIs list state but do not decide or plan; planners (Sunsama/Motion) plan but do not see the repos.
- No product-level metadata (stage: idea/validating/building/launched, users, revenue) alongside git.
- All the cheap planners are cloud subscriptions aimed at knowledge workers with calendars, not makers with 10 repos.

## Area 2. Idea validation

### Pains
1. **Waitlist signups are weak evidence.** Several fake-door sources say waitlists mislead; "a polite 'that's cool' is a no". [preuve.ai, koji.so, kubaik]
2. **Getting traffic to the test page** is the real problem; the page is easy, the audience is not (advice is to run ads to matching ICP). [fake-door guides]
3. **Building before validating** (months of coding, then silence). IH/PH launch-fail posts repeat this.
4. **Interviews are hard to get and hard to run** (Mom Test discipline, finding people) [UNVERIFIED: the search did not cover Mom Test specifically].
5. **Interpreting results**: single-blog benchmarks like "5% conversion = strong" are not standards. [swetrix/others; flagged by source as one blog]
6. **Competitor/market research is manual** and AI-agent fake-door factories are emerging (IH "10 fake door SaaS apps in 30 days"), raising noise and making your signal weaker.
7. **Builder bias**: peers (other makers) are the easy audience, but they are not customers.

### Tools
Carrd (~$19/yr Pro [UNVERIFIED]), Tally (free forms [UNVERIFIED]), Google Trends (free), Buffer-style fake door as the canonical story (5,000+ signups before code, cited), Stripe payment links / pre-sell, Typeform, Framer/Webflow, validator SaaS (preuve.ai, Koji, etc. seen in search; quality unverified), PostHog/Plausible analytics, Reddit/HN/IH posts as manual signal. All are web, so Linux availability is not an issue.

### Gaps
- No single place that ties an *idea record* -> hypothesis -> test page -> result -> kill/continue decision. Everyone stitches Carrd+Tally+Sheets.
- Nothing is local/private-first; idea validation is also the thing the dev has many of (links to area 1).

## Area 3. Launch and marketing

### Pains
1. **No audience at launch.** Hashnode "Lessons from launching on PH as a solo dev (with zero audience)"; IH posts describe ~80 upvotes and 3 signups after months of coding; "the error isn't the launch, it's the silence before it".
2. **Product Hunt audience is other makers**, not customers. [IH, PH posts]
3. **Launching solo is hard / one-shot**: "launch once, see signups drop, stop marketing" (SaaS guide). Counter-case: one solo founder reached #8 PotD with 500+ users, so it is possible but depends on prep.
4. **Build in public is a second job and burns out**: IH "I'm terrible at building in public ... without it becoming a second job"; sources note ratcheting expectations after a viral post leads to burnout, and that BIP audiences are builders, not customers.
5. **Rework: every artefact is hand-made** (changelog, release notes, tweet, thread, PH copy, demo video). [UNVERIFIED as a measured pain; inferred from the above]
6. **Launch-day assets are the bottleneck** (demo video/GIF, screenshots, copy). Ties to area 4.
7. **HN Show HN timing and framing matters** (IH launch-fail posts). Failure on HN and PH is common and public ("launched on HN and Product Hunt: fail").
8. **SEO basics ignored**: [UNVERIFIED, not covered by searches].

### Tools
| Tool | Price | Linux |
|---|---|---|
| Typefully | free tier; paid figures in sources conflict ($8-25/mo entry to ~$19-49 team) | web |
| Buffer | free tier, ~per channel paid [UNVERIFIED] | web |
| Beehiiv | free to ~2.5k subs, paid tiers [UNVERIFIED] | web |
| Product Hunt | free | web |
| Launchlist [UNVERIFIED] | ? | web |
| Hacker News (Show HN) | free | web |
| Indie Hackers | free | web |
| Changelog tools: Headway, Beamer, Released, GitHub Releases, release-please / git-cliff / conventional-changelog (OSS, CLI) [UNVERIFIED details] | free-$ | git-cliff and release-please run on Linux |

### What fails for solo devs (cited)
No pre-launch audience; peer-not-customer audience; one-shot launch then silence; unfinished product at listing time (one listing taken down); expecting launch day to be the strategy instead of a distribution loop.

### Gaps
- Release notes/changelog -> social post -> launch draft pipeline from actual git history is not integrated anywhere I found; git-cliff gives the changelog only.
- Nothing helps schedule *sustainable minimum* marketing cadence for one person.

## Area 4. Product/demo videos

### Pains
1. **Raw screen recordings look amateur**: no auto-zoom, jittery cursor, no background/padding. This is the reason Screen Studio exists; AlternativeTo lists 20+ imitators (DEV: "20 Screen Studio alternatives").
2. **Screen Studio is macOS-only** (and paid) [Screen Studio pricing UNVERIFIED]. Linux users get OBS (no click-driven auto-zoom, per search), SimpleScreenRecorder (X11 era, no effects), Kooha/GNOME recorder (basic).
3. **Wayland capture friction**: portal/PipeWire permission prompts; cursor not captured or double-captured. GNOME issue "Screen recorder doesn't capture cursor"; OpenScreen PRs #157/#158 describe Linux cursor telemetry as `provider:"none"` by default and a generic cursor drawn, with Hyprland-only IPC cursor sampling added. So **auto-zoom on Linux needs cursor/click position that Wayland does not hand out**.
4. **Editing time**: Kdenlive/Camtasia/DaVinci have a steep learning curve for someone who only needs a 60s demo. [UNVERIFIED as measured]
5. **Captions** are an extra step (Whisper-based tools exist) [UNVERIFIED which ones integrate with Linux recorders].
6. **Audio / voiceover quality and scripting** [UNVERIFIED].
7. **Consistency across releases**: re-recording demos for each version by hand.

### Tools
| Tool | Price | Platforms | Linux |
|---|---|---|---|
| Screen Studio | paid [UNVERIFIED amount] | macOS | no |
| OpenScreen (MIT) | free | Win/Mac/Linux (Electron-style) | yes; limited cursor on Linux, Hyprland best-supported per PRs |
| Recordly (AGPL, OpenScreen fork) | free | Win/Mac/Linux | yes |
| Hosaka Studio | commercial | marketed for Linux | yes (not verified for Wayland) |
| Screenix | ? (extension vs app unclear) | ? | claims Linux |
| Loom | free tier, paid ~$12-15/user [UNVERIFIED] | web/desktop | web/limited desktop [UNVERIFIED] |
| Camtasia | ~$180-300 [UNVERIFIED] | Win/Mac | no |
| OBS Studio | free | all | yes (PipeWire capture) |
| Kdenlive | free | all | yes |
| SimpleScreenRecorder | free | Linux | X11-centred |
| Kooha / GNOME Shell recorder / GPU Screen Recorder | free | Linux | yes; GPU Screen Recorder added Wayland cursor capture on AMD/Intel |
| HyperFrames (available in this environment as skill) | -- | HTML-to-video | yes |

### Gaps (Linux)
- No polished, maintained Screen-Studio-class tool with reliable Wayland auto-zoom: the missing input is cursor/click events, which need compositor cooperation (Hyprland IPC works, others do not).
- Capture app + editor + captions are separate tools; no "record, auto-zoom, caption, export" in one flow on Linux.
- Since Axiom owns the compositor/session, it could expose a **sanctioned cursor/click/keystroke event stream to the capture app**: an advantage no upstream Linux tool has.

## OS-level integration vs web/cross-platform

| Pain | OS-level piece | Can be just web / cross-platform |
|---|---|---|
| Pick today's project | Local git awareness (repo discovery, last commit, dirty/unpushed), file indexing for "last touched", a launcher/global shortcut to open "Today" | Ranking logic, UI, sync, notes |
| Cold-start / resume context | Git state, last open files/terminals/session restore (compositor/session), notification nudge | Note storage |
| Stale projects | File watcher / git scan (inotify), notifications | None |
| Time tracking | Idle detection, focused-window/app detection (compositor-provided, Wayland blocks 3rd parties), terminal/editor integration | Reports, invoices |
| Portfolio dashboard (stage, users, revenue) | Optional local git link | Mostly web: analytics/Stripe APIs |
| Idea validation (landing page, waitlist, interviews) | Almost none; maybe capture of competitor screenshots, global-shortcut quick capture of ideas | Carrd/Tally/analytics are web; note/idea DB can be local |
| Competitor research | Screenshot/clip capture, browser integration | Search and summarising |
| Changelog/release notes | Local git history read | LLM drafting, templates |
| Social posts/scheduling | Notifications/reminders only | Typefully/Buffer APIs, web |
| Launch assets (GIF/video/screenshots) | Screen capture via Wayland portal/PipeWire, cursor+click event stream, global recording shortcut, region select, audio capture | Editing/export (can be cross-platform but benefits from event data) |
| Auto-zoom, cursor effects | Compositor-exposed cursor position and click events (the Linux gap) | Rendering/effects timeline (cross-platform) |
| Captions | Mic/system audio capture | Whisper transcription (local, cross-platform) |
| Re-record demos per release | Scripted input/automation (typed-action catalog), window placement | Templates |
| Daily planning nudges | Notifications, idle/focus detection, global shortcut | Calendar sync |

Rule of thumb: anything depending on *what the user is doing on this machine right now* (git/file state, window focus, idle, cursor, screen, audio, shortcuts, notifications) is OS-level and is where Axiom has an unfair advantage; anything depending on *the outside world* (audiences, validation traffic, social APIs, payments) is plain web.

## Cross-cutting observations
- Strongest evidence-backed OS-level wedge: (a) local git-aware "what should I work on / resume" and (b) Wayland-native demo capture with auto-zoom. Both are proven demand (many OSS git dashboards; 20+ Screen Studio clones) but unfilled on Linux with quality.
- Validation and launch pains are mostly audience/market problems; software can reduce artifact-making toil (changelog -> post -> video) but cannot create an audience. Don't promise otherwise.
- Evidence limits: no HN threads surfaced; no Mom Test, SEO, Linux support of planners, or Screen Studio pricing verification. Reddit sentiment not accessible.

## Sources
- Solo founders: how do you decide what to work on each day? https://www.producthunt.com/discussions/solo-founders-how-do-you-decide-what-to-work-on-each-day
- Maintaining 20 OSS projects (PH): https://www.producthunt.com/p/general/i-maintain-20-open-source-projects-across-4-ecosystems-should-i-have-focused-on-just-one
- Multiple projects vs one (IH): https://www.indiehackers.com/post/multiple-projects-at-once-or-focus-on-just-a-single-one-8382d86860
- Death valley of unfinished side projects: https://hackernoon.com/walking-through-the-death-valley-of-unfinished-side-projects-3f5d180b269c
- 5 reasons side projects fail: https://www.traversymedia.com/blog/5-reasons-why-side-projects-fail
- drydock: https://terminaltrove.com/drydock/
- dev-pulse: https://docs.rs/dev-pulse/
- Local-projects terminal dashboard (ovw): https://dev.to/roie/i-built-a-terminal-dashboard-to-keep-track-of-all-my-local-projects-19k3
- Git Vision: https://pkg.go.dev/github.com/jackchuka/gv
- dangit: https://pkg.go.dev/github.com/0xbenc/dangit
- gitling: https://pkg.go.dev/github.com/lcondliffe/gitling
- Fake door test (preuve.ai): https://preuve.ai/blog/fake-door-test
- Fake door guide (koji): https://www.koji.so/docs/fake-door-testing-guide
- Fake door (swetrix): https://swetrix.com/blog/fake-door-test
- 10 fake-door SaaS apps with AI agents (IH): https://www.indiehackers.com/post/10-fake-door-saas-apps-in-30-days-zero-product-code-how-i-m-using-ai-agents-to-validate-before-building-238e959c65
- Launching on PH as a solo dev with zero audience: https://hashnode.com/posts/lessons-from-launching-on-product-hunt-as-a-solo-dev-with-zero-audience/69bd60ff36041cc15a3ff2cf
- Why founders screw up PH launches (IH): https://www.indiehackers.com/post/why-founders-keep-screwing-up-their-product-hunt-launches-and-how-to-actually-get-it-right-15e163c67d
- Launched on HN and PH: fail (IH): https://www.indiehackers.com/product/dual-kind/launched-on-hn-and-product-hunt-fail--MChQEqWpqJBpiigZLPW
- Stop launching solo (PH): https://www.producthunt.com/p/general/stop-launching-solo-it-s-not-brave-it-s-dumb
- Terrible at building in public (IH): https://www.indiehackers.com/post/i-m-terrible-at-building-in-public-how-do-you-do-it-without-it-becoming-a-second-job-5adb379349
- Building in public without burning out: https://dev.to/alexcloudstar/building-in-public-without-burning-out-2857
- Typefully pricing (conflicting aggregators): https://socialrails.com/blog/typefully-pricing
- WakaTime pricing aggregator: https://toolradar.com/tools/wakatime/pricing
- Toggl pricing aggregator: https://costbench.com/software/time-tracking/toggl-track/
- Sunsama/Akiflow/Motion comparison: https://dev.to/pickuma/motion-vs-akiflow-vs-sunsama-ai-calendar-planners-compared-in-2026-525h
- Screen Studio alternatives (AlternativeTo): https://alternativeto.net/software/screen-story
- 20 Screen Studio alternatives (DEV): https://dev.to/justin3go/20-screen-studio-alternatives-everyone-should-know-1o1j
- OpenScreen README mirror: https://cdn.jsdelivr.net/gh/siddharthvaddem/openscreen@main/README.md
- OpenScreen PR 157 (Hyprland cursor telemetry): https://github.com/getopenscreen/openscreen/pull/157
- OpenScreen PR 158: https://github.com/getopenscreen/openscreen/pull/158
- GNOME recorder cursor issue: https://gitlab.gnome.org/GNOME/gnome-shell/issues/1773
- Hosaka Studio (AlternativeTo): https://alternativeto.net/software/hosaka-studio
