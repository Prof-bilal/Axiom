# OpenCode (opencode)

Status: partially verified (project README via search). Docs page not confirmed.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Install script | `sh -c "curl -fsSL https://opencode.ai/install | bash"` | no | yes | README quick install. Pipes to shell; review first if needed. Installs to `~/.opencode/bin` (per guide). |
| npm | `npm install -g opencode-ai@latest` | no (use user npm prefix) | yes | Needs Node.js 18+ (per guide). Avoid sudo. |
| Homebrew | `brew install anomalyco/tap/opencode` | no | yes | README tap. Older formula names also appear online. |
| Bun / pnpm / yarn | `bun install -g opencode-ai` (unverified) | no | yes | Alternative global installs. |

## Manual install
1. Use the npm route if the script is not acceptable.
2. Or download the release binary from the GitHub releases of the opencode project (URL unverified).
3. Place the binary in `~/.local/bin`.
4. Check: `opencode --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `opencode: command not found` | `~/.opencode/bin` not on PATH. | Add `export PATH="$HOME/.opencode/bin:$PATH"`. Or set `OPENCODE_INSTALL_DIR`. |
| npm `EACCES` on global install | Root-owned global prefix. | Set a user npm prefix (`npm config set prefix ~/.npm-global`), do not use sudo. |
| Provider auth errors | No API key configured. | Configure the provider key yourself; do not paste keys into shared logs. |

## Sources
- https://cdn.jsdelivr.net/gh/anomalyco/opencode@master/README.md
- https://computingforgeeks.com/setup-opencode-ai-coding-agent/
- https://opencode.ai/docs (unverified)
