# Service and system integration

Status: V1 design rules. Last researched: 2026-10-18.

systemd remains the init/service manager; systemd-boot is the UEFI boot direction. Legacy BIOS installation is outside the initial hardware contract. linux-lts is a separate tested fallback, not a custom kernel.

Desktop UI and provider-facing runtime run in the user session. A privileged operation broker exposes only reviewed typed methods and delegates to established system services. Do not create performanced, memoryd or connectd until their phase and a persistent lifecycle require them. NetworkManager owns connections; BlueZ owns Bluetooth; PipeWire with WirePlumber owns media policy. Axiom should integrate, not create parallel managers.

Each future unit must document its owner, activation, shutdown, writable state, network needs, resource ceiling and reason for persistence. Prefer D-Bus/socket activation when it improves lifecycle without hiding failures. Use bounded restart and start-rate limits; readiness must mean the interface is usable. Handle termination, drain bounded work and report interrupted transactions.

Review `User=`/`DynamicUser=`, `NoNewPrivileges=`, `ProtectSystem=`, `ProtectHome=`, `PrivateTmp=`, capability bounding, address-family and syscall restrictions per unit. Test actual operations and denials: a hardening score is not a security proof. Privileged package workers may need different restrictions than the planner.

Use systemd credentials for system-service secret delivery where suitable; do not put secrets in command lines or environment files. User-session provider tokens need a separately reviewed desktop secret-store design. Credentials are not protection against a compromised authorized recipient.

Future checks, after units exist and installed systemd matches the target: `systemd-analyze verify path/to/unit.service`; on a disposable target `systemd-analyze security unit.service` and `journalctl -b -u unit.service`. Do not imply these commands validate nonexistent units. Journals redact sensitive fields and correlate capability request IDs.

Sources: [execution environment and credentials](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html), [resource controls](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html), [boot manager](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html), [NetworkManager](https://networkmanager.dev/docs/), [BlueZ Device API](https://github.com/bluez/bluez/blob/master/doc/org.bluez.Device.rst), [PipeWire](https://docs.pipewire.org/), [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/).
