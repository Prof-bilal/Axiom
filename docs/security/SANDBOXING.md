# Sandboxing and enforcement

Status: Linux primitives selected for evaluation; exact profiles require VM tests. Warden is RESEARCH, not a dependency. Last verified: 2026-10-18.

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

The supplied name is ambiguous. Upstream searches found distinct projects, including [thesimonho/warden](https://github.com/thesimonho/warden), [dsvxmedia/warden](https://github.com/dsvxmedia/warden), and [warden.blog](https://warden.blog/). Their existence does not identify the intended dependency or establish security properties. Do not select one based on its name or README claims.

Before adoption: identify exact repository, license, maintainer and immutable commit; inspect Linux implementation, packaging, policy parsing and defaults; map supported filesystem, process, network, credential and audit controls to tests; verify native/container backends, supported architectures and kernel requirements; exercise bypasses and missing-prerequisite behavior. Record limitations and supply-chain/update ownership in an ADR. Determine whether it can mediate the selected capability executor or only external MCP/tool workers. Never assume a tool sandbox can safely authorize host package or boot changes. If unsuitable, record evidence and reuse systemd/Linux controls without building a competing general-purpose sandbox.

## Experiments

In disposable QEMU guests, attempt prohibited reads/writes/egress, descriptor leakage, system/session-bus calls, namespace escape, resource exhaustion and cancellation. Run mainline and LTS kernels. Verify credentials cannot enter logs or environment dumps; system services should evaluate systemd credentials for scoped provisioning, while desktop provider keys require an appropriate user secret store and explicit unlock behavior.

Sources: [systemd.exec](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html), [cgroups v2](https://docs.kernel.org/admin-guide/cgroup-v2.html), [seccomp](https://docs.kernel.org/userspace-api/seccomp_filter.html), [Landlock](https://docs.kernel.org/userspace-api/landlock.html), [portals](https://flatpak.github.io/xdg-desktop-portal/docs/).
