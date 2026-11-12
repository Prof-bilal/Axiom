# Track 0: Positioning research

Date: 2026-11-09. Rounds: 4. Sources: Google/web, Hacker News, X (indirect),
DistroWatch/ProtonDB/Steam (via reporting), Stack Overflow survey, distro news
sites. **Reddit could not be accessed by the research tools** (blocked); Reddit
signal below is second-hand only. Treat single-source numbers as unverified.

## Question

Who is Axiom's first user, and what gap is nobody filling?

## Round 1: Landscape

| Segment | Owner(s) | Evidence |
|---|---|---|
| Gaming | CachyOS, Bazzite, SteamOS | CachyOS #1 on DistroWatch page hits (Aug 2026) and ProtonDB; 13.36% of Steam Linux users (May 2026) |
| Windows refugees | Zorin OS, Linux Mint | Zorin OS 18: 2M downloads in under 3 months after Win10 EOL, ~72-78% from Windows machines (self-reported) |
| Safe default dev box | Ubuntu LTS, Fedora | Ubuntu used by 27.7% of professional devs (SO 2025) |
| Opinionated, stylish dev desktop | **Omarchy** | Omacom Foundation: $10.6M itemized ($12.6M claimed) in pledges; "100,000 downloads in a week"; 37signals mandates it |
| AI in the OS | Omarchy 4, Ubuntu/Fedora (gradual) | Omarchy 4 "Quattro" (beta, Aug 2026): crash watcher → agent diagnosis, pick 1 of 9 agents, usage widget. Canonical: local AI, "Ubuntu is not an AI product" |

Market size: Linux is ~3-4.5% of global desktops (StatCounter / Cloudflare,
2026), rising; ~14.7% in India in one StatCounter reading. Developers: Windows
49.5%, macOS 32.9%, Linux outside WSL 16.7% (SO 2025).

## Round 2: Pain (Hacker News, surveys)

**Omarchy criticism on HN** (the closest competitor, so the most useful):
- Security: "Any User Process Can Escalate to Root", a fake-sudo design and
  rootful containers, "vulnerable defaults"; software installed by `curl | sh`.
- "Not a distro, just DHH's dotfiles" on Arch; updates locked to its own repo.
- Agents were added for everyone by the founder's decision, and some users
  refuse 4.0 ("I just want a terminal, a browser and working USB").
- Founder politics dominate threads, so community trust is polarized.

**Why people leave or can't fully switch** (informal polls, old articles):
1. Needed app missing or poor (~30% in one poll; Adobe is the usual example)
2. Games and anti-cheat (~19%)
3. Document and file compatibility (~13%)
4. Hardware (~12%)
5. Hostile help culture ("RTFM"), confusing docs, GNOME's workflow felt alien

## Round 3: X, YouTube, makers, customization

- The Mac → Linux developer wave is driven by influencers (DHH, ThePrimeagen,
  PewDiePie). DHH himself says it's "mindshare more than market share".
- Ricing is a large hobby (r/unixporn), but it's done with dotfiles and hand
  configs. Tiling WM setups "take days". **No well-known GUI tool lets
  beginners build and share a full desktop setup safely.**
- Indie makers: tool sprawl and "projects dying silently in the backlog" are
  common complaints; the existing answers are SaaS apps (Indie CMD, Notion,
  Linear). No OS-level answer was found.
- AI desktops: Windows Agent Runtime (preview), Claude Cowork (macOS/Windows),
  others on macOS. On Linux, only small or unproven "AI OS" projects plus
  Omarchy. HN interest centers on **sandboxing agents** (Docker Sandboxes,
  microVMs, DesktopMCP using portals/AT-SPI).

## Round 4: Testing the gap

- Agent risk is real, not theoretical: HN "AI agent runs amok in Fedora"
  (an agent on a compromised account pushed questionable patches into
  Anaconda). Commenters asked for key isolation, attribution and trust limits.
- Omarchy's weak points (security, Arch/dotfile fragility, forced AI,
  drama) are exactly what Axiom's non-negotiables already address: no root
  for the UI or AI, narrow privileged APIs, attribution, recovery, local-first
  and AI optional.
- Bazzite's 2026 vendor/contributor drama and Omarchy's politics show that
  **governance and calm matter** to users choosing a distro.
- Counter-evidence: "never the year of the Linux desktop" is a 20-year
  pattern. Distribution and ecosystem barriers, not features, decide most
  adoption.

## Conclusions (challenge included)

1. **"AI-native developer desktop" is no longer unique.** Omarchy shipped it
   with $10M+ and a famous founder. Axiom can't win by being first or loudest.
2. **Don't fight gaming (CachyOS/Bazzite) or general Windows refugees
   (Zorin/Mint) head-on.** Those segments are owned.
3. **The open gap: Omarchy's audience without Omarchy's problems.**
   Developers who want a stylish, opinionated desktop but:
   - don't want to live in dotfiles or Arch breakage → **GUI Profiles with
     rollback** (ideas 1 and 2),
   - don't trust agents with root → **opt-in, sandboxed, attributed AI** (the
     existing Axiom boundary),
   - want help shipping, not just coding → **Project Hub / Capture**
     (idea 4). Nobody else does this.
4. **Primary user:** developers and indie makers coming from macOS or
   Windows. **Secondary on-ramp:** Windows users, via a "Windows-like"
   profile plus migration, but not as the main marketing target.

**Draft positioning:** *Axiom: the developer desktop you can make your own,
with AI you can actually trust, and tools that help you ship.*

## Risks

- A solo project against a funded competitor: you must pick a narrow wedge
  and ship it well.
- Owning the shell and compositor is expensive. Profiles depend on it, so
  that work must stay focused.
- Popularity metrics (DistroWatch hits, download counts) are weak proxies.

## Validate next (cheap, before building)

1. A landing page with the positioning above plus a waitlist
   (`docs/LANDING_PAGE_DESIGN.md` exists): measure signups per visit.
2. Interview 10 developers who tried Omarchy/Hyprland and quit: why?
3. A post on HN/X: "Omarchy-style desktop, GUI-customizable, agents with no
   root". Measure reaction before writing code.

## Sources

- Omarchy 4 AI features: https://itsfoss.com/news/omarchy-ai-agent-focus.md
- Omacom funding: https://runtimewire.com/article/dhh-omacom-foundation-12-6m-omarchy-linux
- Omarchy root escalation (HN): https://news.ycombinator.com/item?id=49499854
- Omarchy security practices (HN): https://news.ycombinator.com/item?id=49447682
- "Omarchy Is Not A Distro" (HN): https://news.ycombinator.com/item?id=48257612
- CachyOS/ProtonDB: https://boilingsteam.com/cachy-os-is-king-now-and-the-distro-world-settles/
- CachyOS Steam share: https://www.pcgameshardware.de/Linux-Software-26761/News/CachyOS-Linux-Distribution-Steam-Umfrage-Mai-2026-1544511/
- Zorin 2M downloads: https://www.techrepublic.com/article/news-zorin-os-2m-downloads-windows-10-support-ends/
- Linux market share: https://itsfoss.com/linux-market-share/ , https://technologychecker.io/blog/linux-market-share , https://tech.slashdot.org/story/26/08/02/0631208/
- SO 2025 OS usage: https://windowslatest.com/2026/10/05/microsoft-distinguished-engineer-fires-back-at-anti-windows-11-rage-bait-says-more-developers-use-windows-than-linux-or-macos
- Why users can't quit Windows (poll): https://blog.desdelinux.net/en/why-did-you-decide-to-leave-windows/
- DHH on Linux: https://world.hey.com/dhh/get-in-losers-we-re-moving-to-linux-5e1b93cd
- AI agent incident (HN): https://news.ycombinator.com/item?id=48484584
- AI distros: https://itsfoss.com/ai-focused-linux-distros.md , https://pasqualepillitteri.it/fr/news/17278/linux-ai-os-1-0-star-ia-locale-pas-premiere-distro
- Ubuntu AI plan: https://news.ainauten.com/markdown/canonical-lays-out-a-plan-for-ai-in-ubuntu-linux
- Desktop agents: https://andrew.ooo/answers/windows-agent-runtime-vs-apple-intelligence-vs-android-gemini-may-2026/
- Bazzite drama: https://www.gamingonlinux.com/2026/01/bazzite-linux-founder-releases-statement-asking-gpd-to-cease-using-their-name
- Indie maker tool sprawl: https://indiehackers.com/post/i-built-an-all-in-one-workspace-for-indie-hackers-because-i-was-tired-of-juggling-5-tools-c3383dd37c
- Ricing difficulty: https://jie-fang.github.io/blog/basics-of-ricing
