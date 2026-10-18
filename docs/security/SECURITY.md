# Security architecture

Status: design contract; no enforcement implementation exists. Last verified: 2026-10-18.

## Invariants

1. AI never receives unrestricted root, sudo, or a general privileged shell.
2. UI runs as the user; privileged code exposes narrow, validated APIs.
3. Secrets never enter plaintext repository files, prompts, telemetry, or routine definitions.
4. Providers remain replaceable; core desktop functions work without cloud AI.
5. Routines execute deterministically and actions remain attributable.
6. Sensitive actions require explicit scoped authorization; critical operations never execute silently.
7. Every mutation verifies its result; rollback is offered only for tested coverage.
8. Missing identity, policy, required sandbox controls, or durable mutation audit causes denial.
9. Wayland protections stay intact. No unrestricted input injection workaround.
10. Performance claims require measurements. Every persistent daemon and new privileged component needs justification.
11. Reuse mature Linux primitives; do not create a second unrelated sandbox around a verified Warden integration without documented need.

## Boundaries

Treat model output, MCP output, downloaded files, web pages, repository instructions, and routine imports as untrusted data. They cannot grant authority. assistantd owns planning and provider transport as an unprivileged user process. A policy module mediates requests; a narrow system-agentd system service independently validates peer identity and authorization at execution. Session actions remain in a user executor. Names and D-Bus interfaces are proposed, not implemented APIs.

Polkit authenticates/authorizes particular privileged actions; it does not sanitize arguments or replace agent intent approval. Bind both decisions to the same immutable request. Never install blanket allow-active rules or use generic command execution actions. Consult [permissions](PERMISSIONS.md), [threat model](THREAT_MODEL.md), and [sandboxing](SANDBOXING.md).

## Data and audit

Separate user history (SQLite, user-only access, configurable retention/deletion) from a root-owned mutation journal. Record request ID, actor, originating tool, capability version, redacted arguments, policy version, authorization decision, start/end timestamps and monotonic duration, affected resources, result, network destination summary, verification, and rollback coverage. Do not record file contents, bearer tokens, full process environment, or arbitrary provider payloads by default. Journal accepted mutations durably before execution. Detect interrupted requests after restart; never automatically replay uncertain mutations. Local root can tamper with local logs: do not claim tamper-proof history. Deletion of user history must explain separately retained system-security records.

## Review and response

Security owns adversarial review independently of implementation. Changes crossing privilege, device, provider, or storage boundaries require misuse tests and explicit residual risk. Report vulnerabilities privately to maintainers through an established private channel; until a security contact is configured, do not publish exploit details in public issues. Release readiness requires a working private reporting route. Offline recovery and administrator-directed maintenance remain available without AI.

Sources: [Polkit](https://polkit.pages.freedesktop.org/polkit/polkit.8.html), [D-Bus specification](https://dbus.freedesktop.org/doc/dbus-specification.html), [systemd execution controls](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html).
