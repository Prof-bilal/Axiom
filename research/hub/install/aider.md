# Aider (aider)

Status: unverified. Search was rate-limited; commands from model knowledge.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| pipx (recommended) | `pipx install aider-chat` | no | yes | Needs pipx (`sudo pacman -S python-pipx` / `sudo apt install pipx`, root for that step). |
| pip in a venv | `python3 -m venv ~/.local/share/aider-venv` then `~/.local/share/aider-venv/bin/pip install aider-chat` | no | yes | Avoid system pip (PEP 668 errors on modern distros). |
| aider-install helper | `python3 -m pip install aider-install` then `aider-install` | no | yes | Unverified. |

## Manual install
Not needed. Use pipx.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `externally-managed-environment` | PEP 668 system Python. | Use pipx or a venv, not system pip. |
| `aider: command not found` | pipx bin dir not on PATH. | Run `pipx ensurepath`, then open a new shell. |
| Python version too old | Aider needs a recent Python. | Install a newer Python and use `pipx install --python`. |

## Sources
- https://aider.chat/docs/install.html (unverified this session)
