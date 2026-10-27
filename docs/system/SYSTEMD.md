# Service and system integration

Status: V1 design rules. Last researched: 2026-10-18.

systemd remains the init/service manager; systemd-boot is the accepted UEFI boot direction, now re-opened for investigation against Omarchy's Limine/UKI chain by [ADR-013](../DECISIONS.md) and experiment E28. Legacy BIOS installation is outside the initial hardware contract. linux-lts is a separate tested fallback, not a custom kernel.

Desktop UI and provider-facing runtime run in the user session. A privileged operation broker exposes only reviewed typed methods and delegates to established system services. Flow replaces the speculative performanced proposal: evaluate one per-user flowd only when its phase, event/recovery lifecycle and measured overhead justify persistence. Do not add a parallel performance daemon; memoryd/connectd also require lifecycle justification. NetworkManager owns connections; BlueZ owns Bluetooth; PipeWire with WirePlumber owns media policy. Axiom should integrate, not create parallel managers.

Each future unit must document its owner, activation, shutdown, writable state, network needs, resource ceiling and reason for persistence. Prefer D-Bus/socket activation when it improves lifecycle without hiding failures. Use bounded restart and start-rate limits; readiness must mean the interface is usable. Handle termination, drain bounded work and report interrupted transactions.

Review `User=`/`DynamicUser=`, `NoNewPrivileges=`, `ProtectSystem=`, `ProtectHome=`, `PrivateTmp=`, capability bounding, address-family and syscall restrictions per unit. Test actual operations and denials: a hardening score is not a security proof. Privileged package workers may need different restrictions than the planner.

Use systemd credentials for system-service secret delivery where suitable; do not put secrets in command lines or environment files. User-session provider tokens need a separately reviewed desktop secret-store design. Credentials are not protection against a compromised authorized recipient.

Future checks, after units exist and installed systemd matches the target: `systemd-analyze verify path/to/unit.service`; on a disposable target `systemd-analyze security unit.service` and `journalctl -b -u unit.service`. Do not imply these commands validate nonexistent units. Journals redact sensitive fields and correlate capability request IDs.

Sources: [execution environment and credentials](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html), [resource controls](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html), [boot manager](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html), [NetworkManager](https://networkmanager.dev/docs/), [BlueZ Device API](https://github.com/bluez/bluez/blob/master/doc/org.bluez.Device.rst), [PipeWire](https://docs.pipewire.org/), [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/).

## Flow user-manager integration

[Flow](FLOW.md) owns resource policy, not unit lifecycle or the cgroup hierarchy. Preserve manager ownership/delegation and existing Hyprland/Quickshell session/application/background units. Prefer approved runtime properties through the owning manager; direct cgroup writes are limited to a separately verified delegation and reviewed operation (for example the targeted-reclaim experiment where no supported manager method exists). Never write arbitrary paths beneath the machine hierarchy. [systemd delegation](https://systemd.io/CGROUP_DELEGATION/).

Probe controller availability, effective parent settings, property/method support and identity/generation on mainline and LTS. Freeze/thaw and runtime property access must be tested with the installed manager, not inferred from latest documentation. No broad Polkit manage-units grant to a performance process. Root/system configuration stays separately authorized. Resource changes are not service stop/restart authority. [systemd manager API](https://www.freedesktop.org/software/systemd/man/latest/org.freedesktop.systemd1.html).

A flowd candidate stays outside groups it might restrict. Independent thaw/reconciliation must survive controller failure; unit stop/restart alone does not promise automatic thaw. Benchmark bounded sampling, wakeups, restart storms and recovery time before persistence is accepted. Shared systemd-oomd policy is version-pinned and reviewed; Flow does not race it with another killer.
