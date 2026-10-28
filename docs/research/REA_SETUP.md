# REA setup and verified scope

Date: 2026-10-28. Installed **rea-agents 6.8.0**, Node **24.22.1**, Linux x86-64.
Official source: [morluto/rea](https://github.com/morluto/rea),
[installation guide](https://github.com/morluto/rea/blob/main/docs/installation.md).
The source main branch may describe unreleased behavior; the installed MCP
catalog is authoritative for this environment.

Installation followed the documented global flow:

```sh
npm install --global rea-agents@6.8.0
rea setup --client codex --dry-run --json
rea setup --client codex --yes --json
rea doctor --client codex --skill --json
```

Setup returned `ready`, applied only `configured_codex` and `installed_skill`,
preserved unrelated configuration and retained its config backup. The explicit
owner brief authorized installation/configuration. No Hopper/Ghidra/IDA or
unrelated clients were installed/configured. The bundled
`~/.agents/skills/reverse-engineer-anything` skill is aligned (version 49,
229 tools). This host installation is outside the repository dependency set.

Codex registration in `~/.codex/config.toml`:

```toml
[mcp_servers.rea]
command = "/home/abullah/.config/nvm/versions/node/v24.22.1/bin/rea"
args = ["mcp"]
```

That absolute launcher depends on this Node installation; after Node removal or
upgrade rerun scoped setup and verify the registration. Do not commit a user's
entire Codex configuration, credentials, environment or provider settings.

## MCP verification

A local stdio JSON-RPC client launched `rea mcp`, sent `initialize` with protocol
2024-11-05, `notifications/initialized`, `tools/list`, then `tools/call` for
`binary_session` (expected package 6.8.0) and `inspect_desktop_application`.
Server identity was `rea` 6.8.0; the complete first catalog page advertised
**229 tools** with no next cursor. Both tool calls returned without `isError`.
The process exited after stdin closed. This verifies a functioning MCP transport
and tool execution, separately from static registration.

The ongoing agent tool inventory did not contain REA. A new/reconnected Codex
session must load the registration before native connector calls are available.
Until then the verified stdio MCP route and official CLI remain usable; do not
claim hot-loading happened. `doctor` reports live-server state `unknown` because
it cannot inspect another client's connection.

Read-only investigation target: installed
`/usr/lib/qt6/qml/Quickshell/Hyprland`, bounds 40 entries / 4096 probe bytes.
REA returned 14 examined entries, zero candidate families and no probe issues.
This target's small QML plugin directory is not a packaged desktop application;
the classifier did **not** decompile QML or establish runtime behavior. Source
inspection and installed qmltypes remain the useful implementation evidence.
The returned directory identity commits to inspected paths/metadata/read ranges,
not all content bytes. Evidence parent:
`ev_26cea19451e33edc06e0a6888e2cecaf301677b55fbf0c12a72613d827ec10eb`;
summary: `ev_056eb0d504af8726ebd1a3258db52d9278b87aa4e8ac38c581553620fef9a80e`.
Raw MCP results were retained locally under `/tmp/axiom-rea-mcp-*.json`; the
durable scope/results are recorded here, not dependent on temporary files.

Reproduce the transport and bounded tool-call verification without installing or
reconfiguring anything:

```sh
python3 scripts/verify-rea.py
```

This verifier pins expected server 6.8.0, uses deadlines, checks both actual tool
results and shuts down only the server it launches. A different package/version
requires reviewing the evidence before changing that expected version.

## Capabilities and limitations

The catalog includes desktop package inspection, JavaScript/Electron analysis,
native binary sessions, assembly/decompilation through configured providers,
resource/archive analysis and opt-in runtime/browser capture. Individual tools
can invoke external engines or execute/attach to targets; catalog presence is
not availability or permission to run them. Consult the selected tool's actual
schema and effects before invocation. No runtime attach or target execution was
performed in this investigation.

Linux process ownership checks require procps-compatible `ps`. Deep native
analysis providers Ghidra/IDA/JADX/Kuna were unconfigured in the setup plan;
no decompilation readiness is claimed. Static bounded package inventory worked
without them. Source code is preferred when available, as for Hyprland and
Quickshell. Additional tracing/capture experiments need declared targets and
bounded effects, not unrestricted access to the owner's applications.

There is **no macOS host, Mac VM, Apple application bundle or recorded macOS
runtime** available. REA cannot discover live macOS Dock internals, WindowServer
behavior, animation constants, Apple private APIs or hardware timing here.
Public Apple UX documentation supplies observable references only. No Apple
assets, unofficial OS images or undocumented internals are implementation inputs.
