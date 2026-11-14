# Claude Code (claudecode)

Status: verified (official docs listed via search). Note the search showed the docs domain as code.claude.com.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Native installer (recommended) | `sh -c "curl -fsSL https://claude.ai/install.sh | bash"` | no | yes | Official route for Linux and WSL. Auto-updates in background. Needs no Node.js per community guides. |
| npm | `npm install -g @anthropic-ai/claude-code` | no (user npm prefix) | yes | Official docs list it; requires Node.js 18+ (docs; one guide says 22). Do not use sudo. |
| Alpine/musl | native installer needs `libgcc`, `libstdc++`, `ripgrep`, plus `USE_BUILTIN_RIPGREP=0` | yes (distro package install) | yes | Per official install page. |

## Manual install
1. Use the native script, or on npm systems use the npm command above.
2. Check: `claude --version` and `claude doctor`.
3. Sign in on first run (the user does this themselves).

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `claude: command not found` | Install dir not on PATH. | Add the install dir (see `claude doctor` output) to PATH. |
| npm `EACCES` on global install | Root-owned prefix. | User npm prefix (`npm config set prefix ~/.npm-global`); never `sudo npm install -g`. |
| Health check warnings | Mixed or stale installs. | Run `claude doctor` and follow its output. |
| Musl install fails | Missing libgcc/libstdc++/ripgrep. | Install the packages above and set `USE_BUILTIN_RIPGREP=0`. |

## Sources
- https://code.claude.com/docs/en/getting-started/installation
- https://code.claude.com/docs/en/setup
- https://code.claude.com/docs/en/install
