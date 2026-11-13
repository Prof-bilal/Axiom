# Claude Code

- Id: `claudecode` · Category: Development · Weight: light · Licence (catalog): Proprietary
- Catalog sources: npm `@anthropic-ai/claude-code`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Claude Code is Anthropic's agentic coding tool that runs in the terminal, with IDE and desktop front ends, for reading, editing and running code in a project. It is for developers who use Claude models for software work.

## Facts
- Name: Claude Code
- Publisher: Anthropic
- Official website: https://code.claude.com/docs/en/setup (docs); product site https://claude.com/
- Licence: not found (commercial terms; the setup page does not state a licence and the terms page was not fetched)
- Latest version: not found (docs show example version numbers only)
- Typical install size: not found
- Minimum RAM: 4 GB RAM. Source: https://code.claude.com/docs/en/setup
- CPU: x64 or ARM64 processor. Source: https://code.claude.com/docs/en/setup
- Disk: not found
- Linux support: Ubuntu 20.04+, Debian 10+, Alpine Linux 3.19+. Source: https://code.claude.com/docs/en/setup
- Install: native `curl -fsSL https://claude.ai/install.sh | bash`; Homebrew cask; apt, dnf, apk repositories; npm (Node.js 22 or later for the npm package). Source: https://code.claude.com/docs/en/setup
- Access: requires a Pro, Max, Ultra, Team, Enterprise or Console account per the setup page. Source: https://code.claude.com/docs/en/setup

## Logo
Bundled icon: `apps/hub/icons/claudecode.png`.

## Screenshots
Not found. The setup documentation page has no screenshots.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Native installer (recommended, no sudo, no Node.js) | `curl -fsSL https://claude.ai/install.sh | bash` | no |
| npm (Node.js 18+; never with sudo) | `npm install -g @anthropic-ai/claude-code` | no |

- Check the install with claude doctor.
- Needs an Anthropic account or API key; needs 4 GB+ RAM.

- Source: https://code.claude.com/docs/en/installation
- Source: https://code.claude.com/docs/en/setup

## Install options (research draft; verified (official docs listed via search). Note the search showed the docs domain as code.claude.com.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Native installer (recommended) | `sh -c "curl -fsSL https://claude.ai/install.sh | bash"` | no | yes | Official route for Linux and WSL. Auto-updates in background. Needs no Node.js per community guides. |
| npm | `npm install -g @anthropic-ai/claude-code` | no (user npm prefix) | yes | Official docs list it; requires Node.js 18+ (docs; one guide says 22). Do not use sudo. |
| Alpine/musl | native installer needs `libgcc`, `libstdc++`, `ripgrep`, plus `USE_BUILTIN_RIPGREP=0` | yes (distro package install) | yes | Per official install page. |

## Manual install (draft)
1. Use the native script, or on npm systems use the npm command above.
2. Check: `claude --version` and `claude doctor`.
3. Sign in on first run (the user does this themselves).

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `claude: command not found` | Install dir not on PATH. | Add the install dir (see `claude doctor` output) to PATH. |
| npm `EACCES` on global install | Root-owned prefix. | User npm prefix (`npm config set prefix ~/.npm-global`); never `sudo npm install -g`. |
| Health check warnings | Mixed or stale installs. | Run `claude doctor` and follow its output. |
| Musl install fails | Missing libgcc/libstdc++/ripgrep. | Install the packages above and set `USE_BUILTIN_RIPGREP=0`. |

## Sources
- https://code.claude.com/docs/en/getting-started/installation
- https://code.claude.com/docs/en/install
- https://code.claude.com/docs/en/setup
