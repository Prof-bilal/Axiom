# Developer environments: "pick your stack" onboarding

Status: design / RESEARCH — no provisioning is implemented and no method below is
benchmarked. Last researched: 2026-10-25.

Axiom's first-run experience should ask a developer what they use — languages, databases,
services, tooling — then provision a reproducible, reversible environment, instead of
shipping a fixed set of developer tools and hoping. The install-time selection experience
built on these methods is specified in [install checklist](INSTALL_CHECKLIST.md).

## Goal and non-goals

**Goal:** a new user selects from a curated list (e.g. "Node, Python, PostgreSQL, Redis,
Docker"), Axiom records that as a declarative profile and provisions it with least privilege
and a clear undo.

**Non-goals:** replacing the distro package manager; silently installing services; running a
second package manager for system components; promising that database *data* is reversible.

## Curated catalogue (PROPOSED — not implemented)

Grouped so the selection stays short. Nothing is pre-selected; nothing installs without
confirmation. This mirrors the verified `atlas setup` pattern in RepoSpine, where the tool
"installs only what you select" and never installs optional pieces implicitly.

| Group | Entries (proposal) |
| --- | --- |
| Languages / runtimes | Node.js, Python, Go, Rust, Java, .NET, PHP, Ruby |
| Version control / CLI | Git (+ signing helper), ripgrep, fd, jq, yq, tmux |
| Editors / IDEs | VS Code, Neovim, JetBrains Toolbox, Zed |
| Datastores | PostgreSQL, MySQL/MariaDB, MongoDB, Redis/Valkey, SQLite |
| Message/queue/storage | RabbitMQ, MinIO/S3-compatible |
| Containers / VMs | Podman (rootless), Docker, QEMU/KVM, distrobox |
| Cloud / infra CLIs | AWS, GCP, Azure, Terraform, kubectl, Helm |
| Observability | OpenTelemetry collector, Grafana/Prometheus (local) |

Each entry declares: what it is, which provisioning method it uses, whether it needs root,
its permission class and whether it is reversible.

## Provisioning methods

One method per entry, chosen for isolation and reversibility, not convenience.

| Method | Scope | Isolation | Undo | Notes |
| --- | --- | --- | --- | --- |
| **User version managers** (`mise`, `asdf`) | user | process-level only | clean (remove tool version) | Best for languages; per-project pinning; no root; no service isolation |
| **Declarative local env** (`Nix`, `devbox`) | user or system | high (store, no global mutation) | excellent (GC) | Reproducible; Nix learning curve; large store; strong fit for "works on my machine" |
| **Rootless containers** (Podman, distrobox/toolbx) | user | high | good (delete container/volume) | Preferred for services and throwaway toolchains; no root needed |
| **Dev containers** (devcontainer spec) | project | high | good | Standard, editor-integrated; requires a container runtime |
| **System packages** (`pacman`) | root | none | weak (rollback depends on snapshots) | Only for system-level, non-containerisable needs; CRITICAL class |

Default posture: **prefer user-scope, reversible methods** (version managers, rootless
containers, declarative envs). System package installation is the last resort, is SENSITIVE/
CRITICAL, and relies on [Btrfs rollback](../system/BTRFS_ROLLBACK.md) — which does **not**
cover container volumes, database data or cloud state.

## Selection UX (PROPOSED)

1. **Detect first.** Read markers (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`,
   `docker-compose.yml`, `.devcontainer/`) and offer a recommended profile — without
   installing. Detection is evidence, not consent.
2. **Show the plan.** Per selection: method, whether root is needed, disk estimate (a label,
   not a fabricated number unless measured), what will be written where, and the undo path.
3. **Confirm, then provision.** Nothing runs before explicit confirmation; services bind to
   loopback by default; volumes are per-project and named.
4. **Record a profile.** The result is a declarative, versioned profile the user can inspect,
   share and re-apply — not a pile of undocumented mutations.
5. **Stay revocable.** Removing a toolchain or service is a first-class action with the same
   plan/confirm/verify shape, and reports what cannot be undone (data, external effects).

## Security rules

- **Container socket = root-equivalent.** Granting a process the Docker socket effectively
  grants host root; prefer **rootless Podman** and never hand the socket to an agent or a
  tool worker by default.
- **Services are not exposed.** Databases/caches bind to loopback; no default LAN listeners;
  no default credentials; secrets come from the secret store, never from a profile file.
- **No `curl | bash` installers.** Provisioning uses packaged/declared sources with recorded
  provenance. Untrusted one-liners are refused.
- **Agents cannot self-provision.** The Environment child *proposes* a plan; the user
  approves; installation runs through the typed executor with the correct class.
- **Fail closed.** Missing isolation (no rootless capability, no sandbox) disables that entry
  rather than falling back to an unsandboxed install.

## Permission classification

Extends [permissions](../security/PERMISSIONS.md) — no new classes:

| Operation | Class |
| --- | --- |
| Detect stack markers, list catalogue | OBSERVE |
| Install a user-scope version manager / tool | NORMAL (reversible, own-user) |
| Create a rootless container or local service | SENSITIVE (per-request; resolved plan shown) |
| Install system packages, enable a root service, add the user to `docker` group | CRITICAL |

## Reversibility reality

| Action | Undo |
| --- | --- |
| User version-manager tool | Remove the version — reversible |
| Rootless container / volume | Delete container; volume removal destroys data — irreversible if deleted |
| Declarative env (Nix/devbox) | GC the environment — reversible |
| System package install | Only as far as [Btrfs/Snapper](../system/BTRFS_ROLLBACK.md) covers; hooks and config are not universally reversible |
| Database contents | **Not** covered by any Axiom rollback; back up explicitly |

Never present a service or package change as fully reversible. The confirmation UI states the
actual coverage per action, not a blanket "undo" promise.

## Where this lands

| Piece | Phase |
| --- | --- |
| Catalogue + profile schema + detection | 3 (welcome/launcher surface) |
| User-scope provisioning (version managers) | 3–4 |
| Rootless service/container provisioning | 4–6 behind permissions |
| Installer integration | 10 |

## Sources

Reproducible-environment method comparisons and the "pick your tools" setup pattern were
surveyed from public write-ups ([roundup](https://blog.rajpoot.dev/posts/devops/nix-devbox-dev-environments-2026/),
[comparison](https://www.devtoolreviews.com/reviews/devbox-vs-dev-containers-vs-nix-2026),
[mise/devbox/Nix](https://briandetering.net/2026/05/28/best-dev-environment-managers-2026/));
the selection-and-consent UX pattern is verified in RepoSpine's README (`atlas setup`).
Container-socket and rootless specifics must be confirmed against upstream Podman/Docker
documentation at implementation time and are **not** asserted here.
