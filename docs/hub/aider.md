# Aider

- Id: `aider` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: pip `aider-chat`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Aider is a terminal AI pair-programming tool that works with a local git repository, editing files and creating commits with any supported LLM. It is for developers who want to bring their own API keys and keep changes under git.

## Facts
- Name: Aider
- Publisher: Aider-AI (author Paul Gauthier)
- Official website: https://aider.chat/
- Licence: Apache-2.0 (LICENSE.txt in repository; also listed by Homebrew and pkg.go.dev). Source: https://formulae.brew.sh/formula/aider and https://pkg.go.dev/github.com/AIDER-AI/aider@v0.81.1
- Latest version: not found on the official site (release history at https://aider.chat/HISTORY.html not fetched)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: `python -m pip install aider-install` then `aider-install`; or `pip install aider-chat`; or `brew install aider`. Source: https://pkg.go.dev/github.com/AIDER-AI/aider@v0.81.1 and https://formulae.brew.sh/formula/aider
- Cost: free; users pay their model provider directly. Source: search result summary

## Logo
Bundled icon: `apps/hub/icons/aider.png`.

## Screenshots
Not found. The official homepage has only an embedded video element with no image URL.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| uv (recommended by aider) | `uv tool install --force --python python3.12 --with pip aider-chat@latest` | no |
| pipx (Python 3.9-3.12) | `pipx install aider-chat` | no |
| One-line script | `curl -LsSf https://aider.chat/install.sh | sh` | no |

- uv installs its own Python 3.12 for aider.
- You pay the model provider directly.

- Source: https://aider.chat/docs/install.html
- Source: https://aider.chat/docs/install/pipx.html

## Install options (research draft; unverified. Search was rate-limited; commands from model knowledge.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| pipx (recommended) | `pipx install aider-chat` | no | yes | Needs pipx (`sudo pacman -S python-pipx` / `sudo apt install pipx`, root for that step). |
| pip in a venv | `python3 -m venv ~/.local/share/aider-venv` then `~/.local/share/aider-venv/bin/pip install aider-chat` | no | yes | Avoid system pip (PEP 668 errors on modern distros). |
| aider-install helper | `python3 -m pip install aider-install` then `aider-install` | no | yes | Unverified. |

## Manual install (draft)
Not needed. Use pipx.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `externally-managed-environment` | PEP 668 system Python. | Use pipx or a venv, not system pip. |
| `aider: command not found` | pipx bin dir not on PATH. | Run `pipx ensurepath`, then open a new shell. |
| Python version too old | Aider needs a recent Python. | Install a newer Python and use `pipx install --python`. |

## Sources
- https://aider.chat/
- https://aider.chat/docs/install.html
- https://formulae.brew.sh/formula/aider
- https://pkg.go.dev/github.com/AIDER-AI/aider@v0.81.1
