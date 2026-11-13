# Gemini CLI (geminicli)

Status: partially verified (package name and methods from search results).

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| npm global | `npm install -g @google/gemini-cli` | no (user npm prefix) | yes | Package name confirmed by search. Node.js 18+ (check docs). |
| npx (no install) | `npx @google/gemini-cli` | no | yes | Runs latest published version. |
| Homebrew | `brew install gemini-cli` | no | yes | Listed in search results. |
| Preview channel | `npm install -g @google/gemini-cli@preview` | no | yes | Weekly; may have issues. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| npm `EACCES` | Root-owned global prefix. | Set user npm prefix; do not use sudo (per docs). |
| `gemini: command not found` | npm global bin not on PATH. | Add `$(npm prefix -g)/bin` to PATH. |
| Auth prompt | Needs Google sign-in or API key. | The user signs in or sets the key themselves. |

## Sources
- https://www.geminicli.com/docs/get-started/installation
- https://www.npmjs.com/package/@google/gemini-cli
