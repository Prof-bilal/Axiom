# Gemini CLI

- Id: `geminicli` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: npm `@google/gemini-cli`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Gemini CLI is Google's open-source terminal AI agent for coding and general tasks, powered by Gemini models. It is for developers who want a Gemini-based agent in the terminal, with a free tier via Google sign-in.

## Facts
- Name: Gemini CLI
- Publisher: Google (repository google-gemini/gemini-cli)
- Official website: https://google-gemini.github.io/gemini-cli
- Licence: Apache License 2.0. Source: https://github.com/google-gemini/gemini-cli
- Latest version: not found (GitHub releases section was empty in the fetched page)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Requirements: Node.js 20 or higher (per search summary of official docs; not re-verified). Source: https://google-gemini.github.io/gemini-cli
- Install: `npm install -g @google/gemini-cli`; preview channel `@preview`. Source: https://github.com/google-gemini/gemini-cli

## Logo
Bundled icon: `apps/hub/icons/geminicli.png`.

## Screenshots
Not found. The repository README has only badges, no screenshots.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| npm (official) | `npm install -g @google/gemini-cli` | no |
| One-off run | `npx @google/gemini-cli` | no |

- Needs Node.js 20 or newer; older Node installs succeed but fail on first run.
- On permission errors, set a user-level npm prefix instead of using sudo.

- Source: https://www.geminicli.com/docs/get-started/installation
- Source: https://npmjs.com/package/@google/gemini-cli

## Install options (research draft; partially verified (package name and methods from search results).)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| npm global | `npm install -g @google/gemini-cli` | no (user npm prefix) | yes | Package name confirmed by search. Node.js 18+ (check docs). |
| npx (no install) | `npx @google/gemini-cli` | no | yes | Runs latest published version. |
| Homebrew | `brew install gemini-cli` | no | yes | Listed in search results. |
| Preview channel | `npm install -g @google/gemini-cli@preview` | no | yes | Weekly; may have issues. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| npm `EACCES` | Root-owned global prefix. | Set user npm prefix; do not use sudo (per docs). |
| `gemini: command not found` | npm global bin not on PATH. | Add `$(npm prefix -g)/bin` to PATH. |
| Auth prompt | Needs Google sign-in or API key. | The user signs in or sets the key themselves. |

## Sources
- https://github.com/google-gemini/gemini-cli
- https://google-gemini.github.io/gemini-cli
- https://www.geminicli.com/docs/get-started/installation
- https://www.npmjs.com/package/@google/gemini-cli
