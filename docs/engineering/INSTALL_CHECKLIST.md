# Developer install checklist

Status: design proposal; Phase 6 implementation follows [ADR-021](../decisions/021-installer-and-developer-hub.md). Installer and first-run implementation were Phase 9
work. The doctrine below is grounded in Axiom's permission, recovery and
developer-environment contracts; installer-specific profile formats and first-
boot behavior must be verified before implementation. Last updated: 2026-10-29.

## Goal

At install time, ask a developer what they use — AI tools, editors/IDEs, languages, databases,
containers, cloud CLIs — then provision exactly that, reproducibly and reversibly. Not a fixed
"developer edition" package list, and not a pile of undocumented mutations.

## Where it runs: first boot, not the installer chroot

Decision: the installer **records the selection**; a one-time provisioning job applies it on
**first boot**.

Reasons: a failure mid-provisioning cannot corrupt a half-written install; user-scope tools do
not need root inside the installer; and the installed session is the real environment the tools
must run in. The chosen installer technology remains replaceable and must not define Axiom UX.

## Flow

1. **Installer (reviewed Linux technology; implementation later)** — disk layout → user account →
   **developer checklist** (selection only; no provisioning) → install. The checklist is stored
   as a declarative profile.
2. **First boot** — the provisioning job reads the profile, shows the *resolved plan*, applies
   items in order, verifies each, and reports outcomes.
3. **Re-runnable** — the profile can be viewed, edited and re-applied at any time; re-apply is
   idempotent.

## Rules

1. **Nothing pre-selected; nothing installs without confirmation.** This exact pattern is
   verified in RepoSpine's `atlas setup` ("Nothing is pre-selected and nothing installs without
   your confirmation").
2. **Plan before write.** The user sees what will be written and where, old → new where
   relevant — the pattern Morphix already implements (resolved change plan → snapshot → apply →
   verify → rollback).
3. **Detect, don't assume.** Read repo/stack markers to *recommend*, never to auto-apply.
4. **Per-item isolation.** One failed item does not abort the rest silently; every outcome is
   listed.
5. **User scope by default.** Root only where unavoidable, through the privileged path with
   explicit consent and the correct [permission class](../security/PERMISSIONS.md).
6. **The profile is the source of truth**, not the machine's current state.

## Catalogue (PROPOSED — not implemented)

Grouped so the checklist stays short. "Class" is the [permission](../security/PERMISSIONS.md)
class of the *provisioning action*.

| Category | Entries | Default method | Class | Undo |
| --- | --- | --- | --- | --- |
| AI tools | local model runtime (Ollama), coding-agent CLIs, MCP servers (sandboxed) | user / sandboxed worker | NORMAL | remove binary/data |
| Editors / IDEs | VS Code, Neovim, JetBrains Toolbox, Zed | user first, system fallback | NORMAL→SENSITIVE | remove tooling |
| Languages | Node.js, Python, Go, Rust, Java, .NET | user version manager (`mise`/`asdf`) | NORMAL | remove version |
| Datastores | PostgreSQL, MariaDB, MongoDB, Redis/Valkey | rootless container | SENSITIVE | delete container (data loss if volume removed) |
| Containers | rootless Podman (default), Docker (opt-in) | user rootless | SENSITIVE | remove runtime; volumes are data |
| Cloud / infra CLIs | AWS, GCP, Azure, Terraform, kubectl, Helm | user or system | NORMAL | remove CLI |
| Shell / terminal | zsh or fish, prompt, tmux, git + signing helper | user | NORMAL | revert shell/rc |
| Git identity | name, email, **reference** to a signing key | user | NORMAL | edit config |

Provisioning-method tradeoffs (user version managers vs declarative envs vs rootless
containers vs system packages) live in [dev environments](DEV_ENVIRONMENTS.md); this document
does not repeat them.

## Presets (PROPOSED)

Curated starting points that pre-check items (still fully editable, still nothing auto-applied):
**Backend**, **Frontend**, **Data/ML**, **Systems**, **Minimal**. A preset is a convenience,
never a hidden commitment.

## Explicitly not in the checklist

- AI provider **API keys** — secret store, never a profile file or log.
- System daemons/root services beyond the listed items.
- Editor extensions, marketplace content, or anything that executes on behalf of a vendor.
- Docker socket access granted to agents or tool workers.

## Security rules

- Container socket is **root-equivalent**: rootless Podman is the default, and the socket is
  never handed to an agent.
- Datastores bind to **loopback** only; no default LAN listeners or default credentials.
- No `curl | bash` installers; declared/packaged sources with recorded provenance only.
- An agent cannot self-provision: the Environment child *proposes* a plan; the user approves.
- Fail closed: missing isolation disables an item rather than installing it unsandboxed.

## Failure and recovery

- A failed item is reported with its cause; the rest continue; the run summary distinguishes
  applied / skipped / failed.
- Re-applying the profile repairs a partial run (idempotent per item).
- Irreversibility is stated per item — deleting a datastore volume destroys data and is **not**
  covered by any Axiom rollback.

## Acceptance (tests to write)

1. Offline install: checklist is recorded but provisioning is deferred, not silently dropped.
2. Partial provisioning is visible; re-apply converges.
3. Every default is user-scope; root items require explicit consent and the right class.
4. After provisioning: no unexpected listeners; services loopback-only.
5. The profile round-trips (export, edit, re-apply).

## Open research (must complete before implementation)

- Installer profile/first-boot format and a safe way to persist a post-install payload.
- archinstall-style profile formats and whether one is reusable, with attribution.
- How distro "developer edition" / first-run flows present selection and handle failure.
- Whether any in-installer (online) provisioning is worth the failure risk versus first boot.

## Sources (verified in-repository, this round)

[installer](INSTALLER.md), [dev environments](DEV_ENVIRONMENTS.md), [permissions](../security/PERMISSIONS.md);
RepoSpine `atlas setup` and Morphix plan/snapshot flows as read from their READMEs (2026-10-25).
