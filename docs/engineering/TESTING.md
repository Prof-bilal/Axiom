# Testing strategy

Status: foundation strategy with Phase 1 boot tests and incremental Phase 3
native-session checks. This is not a passed distro release gate.

| Layer | Required evidence | Gate owner |
|---|---|---|
| Unit | Validators, policy decisions, provider normalization, transaction state | Implementer |
| Component | Timeouts, cancellation, malformed input, persistence migration | Implementer + QA |
| D-Bus contract | Introspection/versioned signatures, errors, sender identity, signals | Systems + QA |
| Security | Prompt injection, forged consent, unauthorized peer, secret leakage | Independent security |
| Integration | UI → policy → typed executor → audit; offline/provider failure | QA |
| QEMU / ISO | UEFI boot, Hyprland/Quickshell session, shell smoke, network/audio smoke, logs | Linux-base + QA |
| Installer | Blank disposable disk, layout, users, reboot, failure recovery | QA |
| Migration / upstream | Pinned Omarchy boot, branding removal, Axiom Shell start, upstream-divergence upgrade | Migration + QA |
| Update / rollback | Version N→N+1, interrupted transaction, ESP consistency | Release + security |
| Performance | Controlled baseline and variance; see benchmarks | Performance |
| Hardware | GPU, Wi-Fi, Bluetooth, sound, suspend, battery | QA |

Every test identifies phase, fixture/build hash, environment, expected result, timeout and retained logs. Tests must be isolated, deterministic where feasible and leave no host changes. Security cases cover denial, downgrade, stale authorization, compromised MCP output, symlink/path traversal/TOCTOU, D-Bus/Polkit abuse, exfiltration and audit failure. Passing compilation is insufficient.

Run pure documentation/schema/unit checks on unprivileged GitHub-hosted runners. Arch package/ISO jobs use pinned clean builders with no secrets on untrusted pull requests. KVM availability on hosted runners must be checked; use isolated ephemeral self-hosted runners or explicit TCG jobs when needed. Never run untrusted PR code on a persistent privileged release runner. Signing runs separately after trusted promotion.

VM fixtures have no host home mount, shared clipboard, real credentials, arbitrary USB passthrough or bridged production LAN. Default test egress is disabled except explicit fixture/update cases. Use synthetic provider responses first; live provider tests are opt-in, redacted and budget-bounded.

Failure artifacts include serial console, journal, service logs, package manifest, boot entries and transaction/audit state. Redact before upload; retain according to declared CI policy. A failing required gate blocks phase advancement; flaky tests need a tracked owner and cannot silently be ignored.

Source: [QEMU system emulation](https://www.qemu.org/docs/master/system/introduction.html). See [ISO workflow](ISO_BUILD.md), [release gates](RELEASE.md), [phases](../PHASES.md).

## Current Phase 3 checks

The [window foundation validation record](../../research/desktop-shell/window-foundation/validation.md)
owns actual outcomes, package versions, limitations and retained results. The
default `python3 tests/window-state-smoke.py` reads only the current user's real
native models and independently compares them with compositor queries, then
tests an absent backend. It creates no desktop surface or window action.

Inside a disposable QEMU/KVM guest, set `AXIOM_TEST_VM=1` explicitly before
`tests/window-state-smoke.py --lifecycle --monitors` or
`tests/window-state-placement.py`. Those tests create only owned Foot windows
and uniquely named headless outputs, check identity/focus/placement/mixed scale,
and remove their fixtures. They refuse mutation without both the opt-in and a
QEMU/KVM virtualization check; this is accident prevention, not product authority.

`tests/window-state-disconnect.py` relays real compositor IPC through temporary
owned sockets and drops its relays without changing compositor sockets. Its
`--request-only` case keeps event transport alive and tests explicit request
revalidation/restoration. Fresh-process reinitialization is a separate result.
It supplies no synthetic window state.

The host-side `tests/window-state-lock.py <owned-state-directory>` uses the
fixture's QMP keyboard, actual upstream lock and published fixture credential.
It does not change authentication/lock settings or print/store the password.
This tests read-only observation in locked/unlocked states, not future shell
overlay placement or operation denial while locked.

`tests/window-state-cost.py` compares the native-model fixture with the actual
Axiom observation adapter: warm IPC-ready startup and five-minute stabilized
PSS/CPU intervals. Its boundary does not measure input-to-frame latency or the
unfinished desktop shell. Follow the [benchmark protocol](BENCHMARKS.md) and
retain raw samples; performance results do not replace functional acceptance.

The current 3.2 mutation harness is
`AXIOM_TEST_VM=1 python3 tests/window-controls-integration.py`. It starts an
owned Quickshell probe and two owned Foot windows, then verifies same-target
maximize/restore, fullscreen/exit, private-workspace minimize/restore and
close. It refuses to run outside a QEMU/KVM guest. The harness is functional
evidence only; keyboard/pointer interaction, browser/Electron behavior and
latency/PSS/CPU baselines remain separate gates.

Foundation validation also checks research Markdown links and requires all eight
records once a feature dossier starts. Scope-only README files remain explicitly
uninvestigated; passing this structural check does not prove the research or
runtime evidence is correct.
