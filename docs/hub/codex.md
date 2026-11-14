# OpenAI Codex CLI

- Id: `codex` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: npm `@openai/codex`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
OpenAI Codex CLI is a terminal coding agent from OpenAI that reads, edits and runs code in a local repository. It is for developers who use OpenAI models and want an agent in the terminal.

## Facts
- Name: Codex CLI
- Publisher: OpenAI
- Official website: https://github.com/openai/codex (repository; OpenAI developer docs not fetched)
- Licence: Apache-2.0. Source: https://github.com/openai/codex
- Latest version: not found (release list was empty in the fetched page; see https://github.com/openai/codex/releases/latest)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Requirements: conflicting third-party sources (Node.js 22 for npm route; glibc 2.31+ or musl). Vendor docs not confirmed. Source: https://itecsonline.com/post/how-to-install-codex-cli-linux (third-party)
- Access: requires a ChatGPT plan that includes Codex or an OpenAI API key. Source: https://github.com/openai/codex (search result summary)

## Logo
Bundled icon: `apps/hub/icons/codex.png`.

## Screenshots
Partial. One image in the repository README:
- ![Codex CLI splash](https://github.com/openai/codex/raw/main/.github/codex-cli-splash.png) Caption: Codex CLI splash image from the official repository.
Only one image found, so the three-screenshot minimum is not met.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| npm (official README) | `npm install -g @openai/codex` | no |
| Prebuilt binary | `download from https://github.com/openai/codex/releases/latest` | no |

- Needs a ChatGPT plan or an OpenAI API key.

- Source: https://github.com/openai/codex

## Install options (research draft; unverified. Search was rate-limited; commands from model knowledge.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| npm | `npm install -g @openai/codex` | no (user npm prefix) | yes | Commonly documented route (unverified this session). |
| Homebrew | `brew install codex` | no | yes | Works on Linuxbrew (unverified). |
| GitHub release binary | download from https://github.com/openai/codex/releases | no | yes | Fallback. Filename unverified. |

## Manual install (draft)
1. Download the Linux binary from https://github.com/openai/codex/releases (unverified name).
2. Put it in `~/.local/bin` and make it executable.
3. Check: `codex --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| npm `EACCES` | Root-owned global prefix. | User npm prefix; no sudo. |
| `codex: command not found` | PATH. | Add `~/.local/bin` or npm global bin to PATH. |
| Auth prompt on first run | Needs OpenAI account or key. | The user signs in themselves. Do not enter keys in shared code. |

## Sources
- https://github.com/openai/codex
- https://github.com/openai/codex/releases/latest
- https://itecsonline.com/post/how-to-install-codex-cli-linux
