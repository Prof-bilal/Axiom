# MCP integration

Status: protocol considered; external integrations are RESEARCH until bounded capability execution works. Last verified: 2026-10-18.

The official latest endpoint resolved to the [2026-07-28 specification](https://modelcontextprotocol.io/specification/2026-07-28) during research. Pin an exact negotiated protocol revision and SDK in implementation; do not code against an unversioned latest URL. MCP standardizes communication, not trust or host privilege.

## Integration manifest

Every integration must identify owner, purpose, pinned server/source version, transport, authentication, secret references, tools and JSON schemas, resource scopes, network destinations, sandbox prerequisites, data retention, audit events, timeout/output limits and adversarial tests. Approve tool-list/schema changes before enabling them. Tool descriptions, resources and results are untrusted content and cannot rewrite policy.

Use local stdio only for reviewed executable identities launched in a scoped worker. Do not grant home, system bus, SSH/GPG agents or provider keys ambiently. For HTTP, implement the selected revision's authorization requirements and validate intended resource/audience; never pass a token issued for another service through to a server. Do not expose unauthenticated listeners beyond loopback. Local transport identity and remote OAuth are separate from OS capability permission.

Requests to operate the OS must cross the same typed API and approval boundary as native UI actions. An MCP server cannot authorize itself or ask the executor to run arbitrary shell. Sandboxing external tools does not justify granting them host administrator privileges. Unknown tool, missing isolation, stale authentication or changed schema fails closed.

## Verification

Test prompt injection, tool-description poisoning, changed tool lists, malformed/deep/oversized schemas, output floods, token audience mismatch, leaked credentials, local port exposure, reconnect/replay, path escape and network exfiltration. Attribute history to both initiating agent and integration, redact tokens and tool contents, and bound retention. Evaluate Warden only through the [sandboxing research gate](../security/SANDBOXING.md).

Sources: [official specification](https://modelcontextprotocol.io/specification/2026-07-28), [official security repository](https://github.com/modelcontextprotocol/modelcontextprotocol/security). Recheck transport and authorization requirements at implementation time; no deployed MCP compatibility is claimed.
