# Permissions

Status: proposed V1 contract. Last verified: 2026-10-18.

| Class | Scope | Required handling |
|---|---|---|
| OBSERVE | Redacted local telemetry and installed-app metadata | Explicit session enrollment; policy limits fields and resource scopes. Observation is not permission to upload data. |
| NORMAL | Open approved app or saved local workspace | Session-scoped grants may cover exact bounded actions; visible activity and revocation. |
| SENSITIVE | Package install, user cache deletion, approved service changes, updates, external sends | Show resolved plan, resources, destination and consequences; explicit per-request approval in V1. |
| CRITICAL | Any root-backed mutation, boot/storage/security/user changes or private-key access | Explicit per-request confirmation plus suitable administrator authentication. Boot formatting/key access are excluded from V1. |

Classification is a minimum: effective class is the maximum of capability minimum, resource sensitivity, side effects, and privilege. Thus packages.install and system.update are CRITICAL in V1 because they perform root mutations; labeling package installation SENSITIVE elsewhere never lowers that requirement. A user-service start is SENSITIVE; a root service change is CRITICAL.

## Decision algorithm

Authenticate the transport peer from D-Bus credentials (or OS-authenticated socket credentials), not request-supplied UID. Resolve the exact object, validate schema and scope, derive class, evaluate policy, present a trusted local confirmation UI if required, then authorize at the executor. Bind authorization to actor UID/session, capability and schema version, normalized arguments, resolved resource identity, plan digest, nonce, expiry, and policy generation. Tokens are opaque one-use grants; only the executor consumes them. Reject replay, peer disconnect, stale policy, changed package plan or changed resource identity. Revalidation happens immediately before mutation; request editing invalidates approval. An LLM cannot approve its own action.

Cancel or UI dismissal means deny. No remembered CRITICAL approval. No permission prompt may be rendered from untrusted rich text; display names are escaped and independently resolved. Session locks revoke pending approvals. Headless/background execution cannot bypass approval: defer or fail. A permission is neither a provider API token nor an MCP OAuth scope.

## Tests

Attempt forged UIDs, concurrent token consumption, token replay across capability/UID/session, expired grants, lock during prompt, swapped paths, package plan drift, Polkit cancellation, missing policy, malicious display strings and unavailable audit storage. Every failure denies without mutation. Test ordinary desktop administration still works independently of the agent.

Sources: [Polkit authority](https://polkit.pages.freedesktop.org/polkit/eggdbus-interface-org.freedesktop.PolicyKit1.Authority.html), [D-Bus authentication and bus credentials](https://dbus.freedesktop.org/doc/dbus-specification.html). See [API](../ai/SYSTEM_AGENT_API.md).
