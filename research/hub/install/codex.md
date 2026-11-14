# OpenAI Codex CLI (codex)

Status: unverified. Search was rate-limited; commands from model knowledge.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| npm | `npm install -g @openai/codex` | no (user npm prefix) | yes | Commonly documented route (unverified this session). |
| Homebrew | `brew install codex` | no | yes | Works on Linuxbrew (unverified). |
| GitHub release binary | download from https://github.com/openai/codex/releases | no | yes | Fallback. Filename unverified. |

## Manual install
1. Download the Linux binary from https://github.com/openai/codex/releases (unverified name).
2. Put it in `~/.local/bin` and make it executable.
3. Check: `codex --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| npm `EACCES` | Root-owned global prefix. | User npm prefix; no sudo. |
| `codex: command not found` | PATH. | Add `~/.local/bin` or npm global bin to PATH. |
| Auth prompt on first run | Needs OpenAI account or key. | The user signs in themselves. Do not enter keys in shared code. |

## Sources
- https://github.com/openai/codex (unverified this session)
