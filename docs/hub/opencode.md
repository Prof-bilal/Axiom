# OpenCode

- Id: `opencode` · Category: Development · Weight: light · Licence (catalog): MIT
- Catalog sources: npm `opencode-ai`
- Install verified: yes · Screenshots: 2 of 3 · Logo: yes

## Overview
OpenCode is an open-source AI coding agent for the terminal, with a build mode for read/write changes and a read-only plan mode. It is for developers who want an agent that works with multiple model providers, including local models.

## Facts
- Name: OpenCode
- Publisher: Anomaly (repository sst/opencode per search results)
- Official website: https://opencode.ai/
- Licence: MIT, per the official site. Source: https://opencode.ai/
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: curl script `curl -fsSL https://opencode.ai/install | bash`; npm `opencode-ai`; Homebrew tap. Source: https://x-cmd.com/install/opencode (third-party listing) and https://opencode.ai/

## Logo
Bundled icon: `apps/hub/icons/opencode.png`.
Official logo: https://raw.githubusercontent.com/anomalyco/opencode/dev/.github/assets/logo-ornate-light.svg (verified-200).

## Screenshots
Partial. The official site has product card images (not UI captures) at:
- ![Desktop card](https://opencode.ai/media/card-loops/desktop.720.b4178eb6.webp) Caption: desktop card image (official site).
- ![Terminal card](https://opencode.ai/media/card-loops/terminal.720.3e61828d.webp) Caption: terminal card image (official site).
Only two non-screenshot images were found, so the three-screenshot minimum is not met.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official install script (OpenCode 1, stable) | `curl -fsSL https://opencode.ai/install | bash` | no |
| npm (OpenCode 1, stable) | `npm install -g opencode-ai` | no |

- The Arch package installs OpenCode 2 (beta, command opencode2); use npm or the script for OpenCode 1.
- OpenCode needs a model provider key or login.

- Source: https://opencode.ai/docs
- Source: https://github.com/anomalyco/opencode

## Install options (research draft; partially verified (project README via search). Docs page not confirmed.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Install script | `sh -c "curl -fsSL https://opencode.ai/install | bash"` | no | yes | README quick install. Pipes to shell; review first if needed. Installs to `~/.opencode/bin` (per guide). |
| npm | `npm install -g opencode-ai@latest` | no (use user npm prefix) | yes | Needs Node.js 18+ (per guide). Avoid sudo. |
| Homebrew | `brew install anomalyco/tap/opencode` | no | yes | README tap. Older formula names also appear online. |
| Bun / pnpm / yarn | `bun install -g opencode-ai` (unverified) | no | yes | Alternative global installs. |

## Manual install (draft)
1. Use the npm route if the script is not acceptable.
2. Or download the release binary from the GitHub releases of the opencode project (URL unverified).
3. Place the binary in `~/.local/bin`.
4. Check: `opencode --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `opencode: command not found` | `~/.opencode/bin` not on PATH. | Add `export PATH="$HOME/.opencode/bin:$PATH"`. Or set `OPENCODE_INSTALL_DIR`. |
| npm `EACCES` on global install | Root-owned global prefix. | Set a user npm prefix (`npm config set prefix ~/.npm-global`), do not use sudo. |
| Provider auth errors | No API key configured. | Configure the provider key yourself; do not paste keys into shared logs. |

## Sources
- https://cdn.jsdelivr.net/gh/anomalyco/opencode@master/README.md
- https://computingforgeeks.com/setup-opencode-ai-coding-agent/
- https://opencode.ai/
- https://opencode.ai/docs
- https://x-cmd.com/install/opencode
