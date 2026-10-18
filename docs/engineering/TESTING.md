# Testing strategy

Status: foundation specification; distro tests do not exist yet. Last researched: 2026-10-18.

| Layer | Required evidence | Gate owner |
|---|---|---|
| Unit | Validators, policy decisions, provider normalization, transaction state | Implementer |
| Component | Timeouts, cancellation, malformed input, persistence migration | Implementer + QA |
| D-Bus contract | Introspection/versioned signatures, errors, sender identity, signals | Systems + QA |
| Security | Prompt injection, forged consent, unauthorized peer, secret leakage | Independent security |
| Integration | UI → policy → typed executor → audit; offline/provider failure | QA |
| QEMU / ISO | UEFI boot, Plasma Wayland, network/audio smoke, logs | Linux-base + QA |
| Installer | Blank disposable disk, layout, users, reboot, failure recovery | QA |
| Update / rollback | Version N→N+1, interrupted transaction, ESP consistency | Release + security |
| Performance | Controlled baseline and variance; see benchmarks | Performance |
| Hardware | GPU, Wi-Fi, Bluetooth, sound, suspend, battery | QA |

Every test identifies phase, fixture/build hash, environment, expected result, timeout and retained logs. Tests must be isolated, deterministic where feasible and leave no host changes. Security cases cover denial, downgrade, stale authorization, compromised MCP output, symlink/path traversal/TOCTOU, D-Bus/Polkit abuse, exfiltration and audit failure. Passing compilation is insufficient.

Run pure documentation/schema/unit checks on unprivileged GitHub-hosted runners. Arch package/ISO jobs use pinned clean builders with no secrets on untrusted pull requests. KVM availability on hosted runners must be checked; use isolated ephemeral self-hosted runners or explicit TCG jobs when needed. Never run untrusted PR code on a persistent privileged release runner. Signing runs separately after trusted promotion.

VM fixtures have no host home mount, shared clipboard, real credentials, arbitrary USB passthrough or bridged production LAN. Default test egress is disabled except explicit fixture/update cases. Use synthetic provider responses first; live provider tests are opt-in, redacted and budget-bounded.

Failure artifacts include serial console, journal, service logs, package manifest, boot entries and transaction/audit state. Redact before upload; retain according to declared CI policy. A failing required gate blocks phase advancement; flaky tests need a tracked owner and cannot silently be ignored.

Source: [QEMU system emulation](https://www.qemu.org/docs/master/system/introduction.html). See [ISO workflow](ISO_BUILD.md), [release gates](RELEASE.md), [phases](../PHASES.md).
