# Track A: AI landscape and positioning for Jarvis (2026-11-10)

Method: 3 rounds (broad search; deep fetch of ~15 products; counter-evidence). Reddit blocked. **Primary vendor pages mostly unreachable** (anthropic.com/news/claude-duet returned 404, x.ai/news 403). Nearly all product facts below are from secondary coverage (TechCrunch, ITdaily, Hackernoon, FlavioCopes summarising OpenAI docs, eesel, Basenor, KDnuggets, Microsoft Learn is primary). Prices in this market change monthly; every number is "as reported", re-verify before quoting.

## 1. The four named products: all four exist (names are right, vendors are not who you may assume)

| Owner's name | Real product | Vendor | Launched | What it is | Platforms | Price (reported) | Local/cloud | Privacy/safety facts |
|---|---|---|---|---|---|---|---|---|
| "Grok bot" ("your whole team") | **Grok Bot** (+ "team mode") | SpaceXAI (formerly xAI; Musk's SpaceX unit; Cursor is a partner/acquisition target per The Star) | Beta 11 Aug 2026; team mode ~28 Sep 2026 | Always-on bots, each with a persistent cloud computer (reported ~8 vCPU/16 GB/120 GB), logs into your apps through their UI, retains memory, bots message/hand off to each other; "Chief of Staff" pattern; group chats of 2-6 bots | Desktop, mobile, Cursor, SuperGrok web | CONFLICTING: Cursor paid from $20/mo and SuperGrok from $30/mo (Basenor, team mode); Cursor Ultra $200 / Teams $120 seat (eesel, competitor); SuperGrok Heavy $300; Grok Business $30/seat | Cloud only (xAI-hosted VM) | eesel (competitor, biased): all bots on an account share one computer, files, logins; docs say do not treat bots as a security boundary; actions logged under the human's account; no SOC2/ISO claimed; approvals are guidance, not enforced rules; no dry-run; audit view "upcoming". Enterprise tier adds audit logs/network policy (Sept 3, per Basenor). xAI's wider record: prompt-injection weaknesses documented by Embrace The Red / Simon Willison on Grok 3 |
| "Claude Duet" | **Claude Duet** | Anthropic | Research preview 21 Oct 2026 | Standalone proactive agent: morning brief from inbox/calendar, keeps working after you close it, one long thread (text/voice), real artifacts (docs/sheets/decks). Reported on Opus 5.5. NOT the owner's "one agent beside you live" meaning: it is a background proactive agent | iOS, Android, claude.ai | Included in Pro/Max ($20 and up), background work counts toward limits; US waitlist; Team/Enterprise not yet | Cloud VM+browser per user | 3 action tiers: read/draft autonomous; send/pay/sign/delete need approval; money transfer/trading blocked. Stripe Link virtual card, never sees passwords. Classifiers (auto-approve safe; leak/ID/card detection). Red-teamed, outside pentest, bug bounty (per Hackernoon, citing Anthropic). Complaints (HN, via Hackernoon): cannot inspect VM, files or learned rules; quota drain; polling every few hours can miss events; vendor lock-in; many sites block agents. Unrelated GitHub project also called "claude-duet" exists |
| "ChatGPT Dots" | **dots** | OpenAI | DevDay 29 Sep 2026 | Persistent always-on agents, own cloud computer+browser, reachable via ChatGPT, Codex, Slack, Teams; plugins (4,000+ reported); specialist dots for company roles, "teams of dots" promised later; TechCrunch notes it largely packages what Codex harnesses already did | ChatGPT desktop/browser, Slack, Teams | No separate price: first dot included in ChatGPT Pro ($100/200/500 tiers reported) and Business Premium ($100-125/user); Free/Go/Plus excluded; Pro not in EEA/UK/CH; extra dots paid, prices unpublished | Cloud (can connect ONE personal computer for local files) | Logins via private form (model does not see creds); per-action plugin permissions; Custom Rules (act / ask / hand off); non-disableable auto-review; password/money/purchase always need user. Business/Enterprise not trained on by default; personal plans depend on "Improve the model" setting; staff may review. Notes are separate from ChatGPT memory and NOT viewable/editable per item (only delete whole dot). OpenAI's own test: scope violations rose 8.6% to 19.7% when a dot handled more tasks in between |
| "Muse" (personal tasks) | **Meta Muse** | Meta | 8 Sep 2026 (US) | Personal agent: browse, fill forms, shop, book travel, email, docs, monitor, keep working after close; persistent memory (some editable); proactive messages adjustable | iOS, Android, muse.ai web, WhatsApp; glasses later; US | Reported free for most, paid tiers promised; a $20 Power tier is unconfirmed | Cloud: isolated Linux VM per user; Meta can access the VM to operate/secure it at launch; "Confidential VM" with user key planned, not shipped | "Sentinel" separate agent allows/blocks/asks and mediates all outbound traffic; separable read vs send permissions; Stripe Link one-time cards; activity log, approval cards. Meta admits prompt injection is an open problem and Muse "can and will make mistakes". Incident: Oct 2026 shared-chat URLs embedded chat titles, 6,800+ links findable via passive DNS (Claroc); Meta suspended sharing. Amazon blocks it |

Pattern across all four: cloud VM per user, vendor-held memory, approval gates on send/pay/delete, Stripe-style credential isolation, Slack/WhatsApp-style reach, US/paid-tier gating. **None is local, none is open, none lets you see or edit all agent state, none is OS-integrated.** Naming note: the owner's "Duet = one agent live beside you, Team = many in background" is the owner's own terminology; Claude Duet is a single background proactive agent, and Grok "team mode" is the many-agent case.

## 2. Category map (what each owns, what it charges)

**Cloud personal agents (above 4, plus Google Gemini Spark** [US; reported $100 at launch then moved to AI Pro $19.99, October 2026 renamed "Task mode"; sources are aggregators, unverified] **and Microsoft Scout** [M365 always-on agent, E7 $99/user, Copilot Credits; one source; unverified]).
Own: zero-setup convenience, vendor connectors, consumer reach. Charge: $20-$300/mo bundled in chat plans.

**Self-hosted personal agents: OpenClaw (ex Clawdbot/Moltbot) and Hermes Agent (Nous Research)**, MIT, run on your hardware, many chat channels, skill registries. Own: control and openness. Cost: your model API bills + your security work. Security record is the cautionary tale: Koi Security audited 2,857 ClawHub skills, 341 malicious (335 one campaign "ClawHavoc"; later counts higher, sources vary); CVE-2026-25253 one-click RCE (CVSS 8.8, fixed 2026.2.26); 40k-135k exposed instances (Censys/SecurityScorecard figures vary; early default bound to 0.0.0.0). Hermes: shell access and creds in `.env` by default (comparison sites). NVIDIA NemoClaw = enterprise security layer for OpenClaw. This is the closest thing to Jarvis in shape, and its failure mode is exactly what Axiom's rules prevent.

**Team / "company" agent products:** Grok Bot team mode, OpenAI dots ("teams of dots" and ChatGPT Space promised, pilots only), Microsoft Scout/Agent 365, Windows 365 for Agents (US preview since 28 May 2026). Own: enterprise admin, audit, identity. Charge per seat ($25-125) or credits.

**Agent builders:**
- Consumer config layers: Custom GPTs (shareable, API actions), Gemini Gems, Claude Projects/Skills. Agent Skills (SKILL.md) is now a cross-vendor format (Claude, Codex CLI, Gemini CLI read it). Cheap and bundled in chat plans. Limits: runs in the vendor's cloud, no OS authority.
- Low-code: n8n (Sustainable Use License, self-hostable), Dify (modified Apache-2.0, multi-tenant needs written permission), Zapier Agents, Lindy, Relevance AI, Gumloop, Copilot Studio, Langflow. Credit/task pricing, "looks cheap until an agent loops" (guides). OpenAI's visual Agent Builder reported to shut down 30 Nov 2026 (single roundup, unverified).
- Code frameworks: CrewAI, LangGraph, OpenAI Agents SDK, Claude Agent SDK (vendor-tied per one review). Own: developer flexibility. They give you orchestration, not a safe place to run it or a desktop.
(No verified pricing found for Dify cloud, Lindy, CrewAI, LangGraph: unverified.)

**OS-level / desktop agents**
- Windows: Copilot Actions + agent workspace (separate Windows session, separate agent account, limited known folders, user can watch/take over, disabled by default, experimental; Microsoft Learn is primary and itself lists cross-prompt injection (XPIA) leading to exfiltration or malware as a known risk). Agent Runtime / Execution Containers (per-agent capability grants) described only by secondary blogs, unverified. Closest to Axiom's design on paper, but Windows-only and cloud-model-backed.
- Apple: WWDC June 2026 "Siri AI" (macOS 27), App Intents as integration surface, personal context and on-screen awareness; Gemini-model claim and SiriKit deprecation unconfirmed. Fall 2026 availability.
- Anthropic Claude Cowork: desktop agent on macOS (runs Claude Code in a Linux VM via Apple Virtualization) and Windows; no official Linux build (community port exists). Bundled in paid plans.
- Omarchy 4 "Quattro" (Aug 2026 beta): crash watcher briefs your chosen agent via a `diagnose-crash` skill; choose 1 of 9 agent CLIs; opt-in at first boot; usage widget. No sandbox or permission model described in It's FOSS coverage. DHH says agents wrote nearly all Quattro code. Critics: forced direction for all users, fragile integrations (Codex update broke the widget). It is "agent CLI integration", not an agent platform.
- Ubuntu: Canonical AI strategy (Apr 2026): local inference snaps with OpenAI-compatible API, optional, separable, "Ubuntu is not an AI product"; agents for file management mentioned; sandbox detail thin. Fedora: reportedly IBM Granite and a developer-desktop objective; no official source found (unverified).
- Linux "AI OS" projects: Lisa OS, AgntOS (NixOS), Nomos (destructive-action guard, beta), ThorOS, Linux-AI OS 1.0 Star (LMDE + Ollama, own pages inconsistent), Shadowfetch, Alibaba Cloud Linux 4 Agentic Edition. All small/early; none verified; none a dominant agent-native desktop. Docker Sandboxes/microVMs and DesktopMCP (portals/AT-SPI) are the HN-favoured sandbox patterns (per Track 0).

**Coding-agent session managers (list only):** Conductor, Crystal, Claude Squad, Vibe Kanban, Superset, Nimbalyst, CCManager, ccswarm, Parallel Code, GitKraken Desktop 12 Agent Mode; Claude Code (worktrees v2.1.49) and Codex CLI managed worktrees built in. Mentions only, not verified individually.

## 3. Gaps nobody fills (Axiom can own)

1. **Local-first, user-owned agents.** Every consumer product above is a vendor-hosted VM; Muse says Meta can open yours. Axiom: agents and memory on your disk, any model (local or your key), works with no cloud.
2. **Inspectable, editable agent state.** dots notes cannot be viewed per item; Duet will not list its files or learned rules; Muse memory only partly editable. Axiom: memory and instructions as plain files the user can read, diff, edit, version.
3. **Authority enforced by the OS, not by policy text or a second LLM.** Grok bots: "not a security boundary", approvals are guidance. Muse Sentinel and Duet classifiers are models judging models. Axiom: typed tools, capability grants, deterministic validator, separate unprivileged identities (cf. Microsoft's agent account idea, but open and on Linux). Also attributable audit and recovery, "never universal undo".
4. **User-built agents with typed tools and revocable grants on a real desktop.** Builders (GPTs, n8n, CrewAI) have tools but no safe local OS surface; OS agents (Windows, Cowork) have the surface but are not user-composable. Skills/SKILL.md compatibility gives a head start.
5. **Safe agent supply chain.** OpenClaw's ClawHub proved shared agents/skills are malware vectors. Declarative-only definitions, hash-locked, re-approval on edit (already in AGENT_SYSTEM.md, plus owner's aisskills lockfile) is a real differentiator.
6. **Cost and quota control.** Duet's background work eats chat quota; credit pricing loops. Axiom: deterministic routines with no model calls, hard per-agent budgets.
7. **Linux.** No official Claude Cowork, no dots, Duet, Muse or Grok Bot desktop on Linux; Omarchy and Ubuntu offer integration or local models but no governance layer.
8. **No account/region wall.** US-only waitlists, EEA exclusions, paid tiers $20-$500. Open and free is itself a gap.
Counter-check: gaps 1-3 are only valuable if usable. Incumbents win on "works after 2 minutes, reaches me on WhatsApp". Axiom should not compete on reach.

## 4. Duet vs Team: recommended definitions and order

Definitions (distinct from Claude Duet, say so in docs):
- **Duet**: ONE agent, foreground, visible, interactive. Shares the user's session intent: sees what the user chooses to share (current file, selection, terminal), proposes typed actions, user approves each at the declared class, can take over any time. Session-bound; ends when the user ends it. Own agent identity and audit trail.
- **Team**: several agents, background, bounded. Each has own identity, grants, budget, worktree/sandbox; parent-owned task graph (as already in AGENT_SYSTEM.md); results land as reviewable proposals/diffs, not applied. Runs unattended only inside pre-granted, expiring grants.

**Build Duet first.** Reasons: (a) approval UX, grant model, audit and typed-tool layer are needed by both and are easiest to prove with a human watching; (b) fits "AI never gets unrestricted root, deterministic first", failures are visible and recoverable; (c) background autonomy is where every incumbent is hurting (dots scope violations 8.6% to 19.7%, Grok shared-VM, Muse leak, OpenClaw malware): don't ship it before the grant, budget and audit layers are proven; (d) matches the existing phase plan (user-authored children after Phase 7 sandboxes); (e) one agent is testable in QEMU with retained evidence. Team = Duet agent definition + scheduler + sandbox + budgets, so it is mostly additive. Counterweight: Team is what the market hypes ("your whole team"); keep the data model Team-ready (agent identity, task graph, budgets in the schema from day one) so it is not a rewrite.

## 5. Positioning wording for Jarvis

Do not say: AGI, "your whole team/company", "autonomous", "does everything", "like Jarvis from Iron Man", "safe/secure" unqualified, "private" unless demonstrated, "never makes mistakes". Evidence for caution: AGI called overhyped (Fortune: Ng, Sacks), definitions self-serving (Huang claim critiqued), Gartner "agent washing" (~130 real agentic vendors of thousands; >40% of agentic projects cancelled by 2027 forecast, secondary reporting), Muse admits it "can and will make mistakes".

Can honestly say:
- "Agents you build, run and own on your own machine."
- "Every action is a typed request you can see, approve, attribute and (where supported) recover. The model proposes; the system decides."
- "Works offline. Cloud models are optional and consented per agent."
- "Agents can't get root. Ever. Not by prompt, not by installing a shared agent."
- "Memory is files you can read and edit."
- Duet: "a pair-programming style agent beside you." Team: "a few agents working in the background within limits you set, results waiting for your review."
- Tagline candidates: "AI that works for you, under your rules." / "Build agents. Keep the keys."
- Support claims with a test or measurement (project rule); label planned items "planned".

## 6. Copy / avoid

Copy:
- Approval tiers: autonomous read/draft; ask for send/pay/delete; hard-block money movement (Duet).
- Credential isolation: agent never sees passwords; one-time tokens (Duet/dots/Muse via Stripe Link).
- Per-action permission "act / ask / hand off" rules (dots Custom Rules), plus non-disableable review for high-risk classes.
- Separate agent identity and account (Windows agent accounts); activity log with approve/reject cards (Muse).
- Watch-and-take-over view (dots, Windows workspace).
- Skill format compatibility (SKILL.md) and hash-lockfile install flow (owner's aisskills).
- Opt-in, separable AI (Ubuntu snaps, Omarchy first-boot choice); OpenAI-compatible local API for model swap.
- Worktree isolation for parallel coding agents (session-manager consensus).
- Kill/budget limits, polling not streaming for cheap proactivity (Duet).

Avoid:
- Vendor-hosted memory you cannot view or delete per item (dots).
- One shared computer/credentials across agents (Grok Bot); logging agent actions as the human.
- Approvals that are only prompt text; LLM-only safety judges as the boundary.
- Public share links with guessable/derivable URLs; share-by-default (Muse). Shared agent definitions must be inert metadata.
- Open skill marketplace without signing/scan/lockfile (ClawHub).
- Default 0.0.0.0 listeners, creds in `.env`, shell by default (OpenClaw, Hermes).
- Forcing AI on everyone (Omarchy backlash); cartoon avatars that imply personhood.
- No dry-run for "test runs" that do real work (Grok Bot).
- Quota-draining background work without a visible budget.
- Calling it AGI.

## 7. Open questions for the owner
1. Is Jarvis primarily for coding workflows (agents beside the terminal/editor) or general personal tasks (email, calendar)? The cloud incumbents own the latter; Axiom's gaps are strongest for the former.
2. Which model sources at launch: local only (Ollama-class), bring-your-own API key, or both? This decides the "works without cloud" claim and the hardware floor.
3. Should shared/imported agents exist at all in v1 (needs signing and scan), or only user-authored ones?
4. Is "Duet" naming acceptable given Anthropic's product shares it (trademark/confusion risk)? Consider "Pair" / "Beside" or keep Duet but say clearly it is different.
5. Accept Duet-first and Team-ready schema, with Team unattended mode deferred until after sandboxes (Phase 7 per AGENT_SYSTEM.md)?

Decisions this research enables: confirm four product identities; adopt Duet-first; adopt "no AGI/autonomous" wording rules; make "memory as readable files + typed grants + deterministic checks" the headline differentiator; decide model-source policy; decide naming.

## Sources
- Claude Duet: https://itdaily.com/news/software/claude-duet/ ; https://hackernoon.com/what-is-claude-duet-inside-anthropics-always-on-ai-assistant ; https://siecledigital.fr/2026/10/22/avec-claude-duet-anthropic-veut-concurrencer-meta-muse-et-openai-dots/ (anthropic.com/news/claude-duet returned 404; primary not read)
- dots: https://techcrunch.com/2026/09/29/openai-launches-dots-its-bubbly-agentic-avatar/ ; https://flaviocopes.com/openai-dots/ ; https://www.tomsguide.com/ai/openai-just-launched-dots-heres-why-most-chatgpt-users-cant-try-them-yet ; https://aiweekly.co/alerts/openai-unveils-dots-always-on-chatgpt-agents-at-devday
- Grok Bot: https://www.thestar.com.my/tech/tech-news/2026/08/12/spacexai-unveils-grok-bot-to-work-like-a-team-of-ai-agents ; https://www.eesel.ai/blog/grok-bot ; https://www.basenor.com/blogs/news/grok-bot-now-works-as-a-team-what-that-actually-means ; https://www.mindstudio.ai/blog/what-is-grok-bot ; https://x.ai/news (403)
- Grok security history: https://embracethered.com/blog/posts/2024/security-probllms-in-xai-grok ; https://simonwillison.net/b/8378
- Meta Muse: https://kdnuggets.com/meta-muse-explained-what-it-is-how-it-works-and-what-it-can-do ; https://www.testingcatalog.com/meta-introduces-muse-as-a-proactive-personal-agent/ ; https://ppc.land/meta-halts-muse-share-links-after-6-800-turn-up-in-public-dns-records/ ; https://www.thestar.com.my/tech/tech-news/2026/10/27/new-meta-ai-tool-exposed-thousands-of-private-conversations-online
- Gemini Spark / Microsoft Scout: https://www.mindstudio.ai/blog/what-is-gemini-spark-googles-cloud-ai-agent ; https://theaiagentindex.com/compare/microsoft-scout-vs-gemini-spark
- OpenClaw/Hermes: https://docs.openclaw.ai/start/why-openclaw/openclaw-and-hermes-agent ; https://techradar.com/pro/security/multiple-malicious-openclaw-skills-found-online-including-two-macos-infostealers ; https://clawdocs.org/security/known-vulnerabilities ; https://www.bitdoze.com/openclaw-security-guide/ ; https://toolradar.com/blog/openclaw-vs-hermes-agent
- Windows: https://learn.microsoft.com/en-us/windows/security/book/operating-system-agentic-security ; https://support.microsoft.com/en-us/windows/ai/ai-features/experimental-agentic-features ; https://dev.to/htekdev/windows-agent-runtime-what-microsoft-gets-right-about-agent-sandboxing-420j
- Apple: https://www.mactech.com/2026/06/08/wwdc-2026-apple-introduces-siri-ai-a-major-overhaul-of-its-personal-digital-assistant/ ; https://www.eweek.com/news/apple-siri-ai-wwdc-2026/
- Cowork: https://github.com/johnzfitch/claude-cowork-linux ; https://github.com/anthropics/claude-code/issues/65697 ; https://hn.jakechampion.name/item/46613304
- Omarchy: https://itsfoss.com/news/omarchy-ai-agent-focus/ ; https://runtimewire.com/article/omarchy-quattro-dhh-ai-coding-convert
- Ubuntu/Fedora: https://www.linuxjournal.com/node/1341422 ; https://www.omgubuntu.co.uk/2026/04/ubuntu-ai-features ; https://fossforce.com/?p=2467245
- Linux AI OS: https://www.linuxlinks.com/thoros-ai-first-local-first-voice-driven-operating-system/ ; https://github.com/HasNate618/AgntOS ; https://github.com/Lisa-AgenticOS ; https://x-cmd.com/blog/260925/
- Builders: https://www.mindstudio.ai/blog/no-code-ai-agent-builders ; https://simular.ai/alternatives/best-ai-agent-builders ; https://docs.dify.ai/policies/open-source ; https://spdx.org/licenses/SUL-1.0.html ; https://bootstrapcreative.com/chatgpt-vs-claude-vs-gemini-terminology/
- Hype/AGI: https://www.outlookbusiness.com/deeptech/artificial-intelligence/over-40-of-agentic-ai-projects-will-be-scrapped-by-2027-says-gartner ; https://fortune.com/2025/08/25/tech-agi-hype-vibe-shift-superpowered-ai/ ; https://www.techspot.com/news/113778-jensen-huang-declares-agi-has-arrived-again-again.html ; https://guptadeepak.com/agi-has-not-arrived/
- Session managers: https://docs.kanaries.net/topics/AICoding/parallel-code-agents ; https://nimbalyst-website.pages.dev/blog/best-git-worktree-tools-ai-coding-2026/
- Repo context read: docs/ai/AGENT_SYSTEM.md, AI_ARCHITECTURE.md, docs/research/track-0-positioning.md, docs/decisions/022-differentiation-direction.md, scratchpad ai-d1, ai-d3.
