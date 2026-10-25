# Sandboxing and enforcement

Status: Linux primitives selected for evaluation; exact profiles require VM tests. Warden is a first-party project, but its enforcement behaviour is RESEARCH until measured. Last verified: 2026-10-25.

| Primitive | Intended role | Limitation / validation |
|---|---|---|
| Polkit | Authorize narrow privileged actions using original caller identity | Not a sandbox; approval does not validate arguments |
| systemd sandboxing | Service isolation, read-only mounts, restricted device/address families, no new privileges | Options depend on service/kernel; test real access, not only configuration syntax |
| namespaces + bubblewrap | Isolate untrusted local tool processes and mount views | Shared kernel; user-namespace availability varies; never expose host system bus or credentials |
| cgroups v2 | CPU/memory/process/I/O budgets and cancellation | Resource control does not authorize data access |
| seccomp | Reduce available syscalls after initialization | Cannot replace filesystem/path policy; architecture and library needs vary |
| Landlock | Restrict supported unprivileged filesystem/network operations | Probe ABI and kernel configuration; unsupported rights cannot be assumed enforced |
| capabilities | Remove unnecessary root powers | A reduced capability set alone is not isolation |
| XDG portals | Mediated user-visible file/screen/remote-desktop access | Backend support and consent vary; portal tokens are not general agent permission |

Untrusted tools receive no network, secret, broad home mount, agent socket, host D-Bus socket, device node or inherited privileged descriptor by default. Grant individual needs explicitly. Provider network transport belongs outside the no-network tool worker; prevent that component from becoming a generic proxy. Reject a launch when required isolation is unavailable. Do not silently fall back to unsandboxed execution. Avoid composing redundant enforcement stacks; document the single owner of each policy and the kernel mechanism implementing it.

## Warden evaluation gate

**Identified upstream (2026-10-24):** [Prof-bilal/Warden](https://github.com/Prof-bilal/Warden) — the MCP-sandbox runtime at [warden.blog](https://warden.blog/) (npm `warden-sandbox-cli`). License **MIT**; language **Go**; default branch `main`. Reference revision `cd5e8bf2717bd0003194aba8beecd01f33704af9` (2026-10-17, unsigned); latest published release **v0.1.17** (2026-09-14; `SHA256SUMS` plus per-platform binaries). The name is ambiguous in general (unrelated projects include [thesimonho/warden](https://github.com/thesimonho/warden) and [dsvxmedia/warden](https://github.com/dsvxmedia/warden)); only this repository is the intended dependency, and its identity does not by itself establish security properties.

**Inspected statically (not runtime):** the Linux backend applies bubblewrap namespaces (user/net/pid/ipc) with an egress allowlist proxy whose hostname check runs before DNS resolution; deny-by-default bind-mount visibility (ungranted paths return `ENOENT`, not `EACCES`); an explicit environment allowlist; and wall-clock/memory limits with process-tree kill. Fail-closed: with no usable backend it refuses to run rather than execute unsandboxed. Upstream self-reports an 8/8 proof harness and 7/7 attack containment on Linux (Arch x86-64), re-measured in CI; these are upstream claims, not our measurements.

**Unresolved / not verified:** the bypass matrix in [Experiments](#experiments) is **NOT RUN** — no namespace, seccomp, Landlock, network-egress, descriptor-leak or cancellation test has been executed on mainline or LTS kernels here. Upstream's own threat model documents limits (symlinks within granted paths, HTTP/HTTPS-only proxy interception, no CPU throttling, not hardened against a determined local attacker). **First-party and intended shaping:** `Prof-bilal/Warden` is authored by Axiom's owner, so licence permission, maintenance and the intended shaping of Warden into Axiom's execution-enforcement layer — policy **derived from the approved typed request**, audit correlated to Axiom request/audit IDs — are within project control; see [ecosystem](../ai/ECOSYSTEM.md). Ownership removes the permission and supply-chain *authority* questions; it does **not** remove the evidence requirement. The bypass matrix above is still **NOT RUN**, and the policy-generation/audit-correlation behaviour is unimplemented. Continue to treat the README, CI badges and upstream self-reported escape tests as claims, not measurements.

Before adoption: identify exact repository, license, maintainer and immutable commit; inspect Linux implementation, packaging, policy parsing and defaults; map supported filesystem, process, network, credential and audit controls to tests; verify native/container backends, supported architectures and kernel requirements; exercise bypasses and missing-prerequisite behavior. Record limitations and supply-chain/update ownership in an ADR. Determine whether it can mediate the selected capability executor or only external MCP/tool workers. Never assume a tool sandbox can safely authorize host package or boot changes. If unsuitable, record evidence and reuse systemd/Linux controls without building a competing general-purpose sandbox.

## Experiments

In disposable QEMU guests, attempt prohibited reads/writes/egress, descriptor leakage, system/session-bus calls, namespace escape, resource exhaustion and cancellation. Run mainline and LTS kernels. Verify credentials cannot enter logs or environment dumps; system services should evaluate systemd credentials for scoped provisioning, while desktop provider keys require an appropriate user secret store and explicit unlock behavior.

Sources: [systemd.exec](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html), [cgroups v2](https://docs.kernel.org/admin-guide/cgroup-v2.html), [seccomp](https://docs.kernel.org/userspace-api/seccomp_filter.html), [Landlock](https://docs.kernel.org/userspace-api/landlock.html), [portals](https://flatpak.github.io/xdg-desktop-portal/docs/).
