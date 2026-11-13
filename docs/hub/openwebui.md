# Open WebUI

- Id: `openwebui` · Category: Development · Weight: medium · Licence (catalog): MIT
- Catalog sources: pip `open-webui`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Open WebUI is a self-hosted web interface for interacting with local and remote LLMs, commonly deployed with Docker alongside Ollama. It is for teams and individuals who want a browser-based chat front end they run themselves.

## Facts
- Name: Open WebUI
- Publisher: Open WebUI project
- Official website: https://docs.openwebui.com/ (docs); repository https://github.com/open-webui/open-webui
- Licence: Open WebUI License with a branding requirement (since April 2025 per secondary sources); older pages list BSD-3-Clause or MIT. Check the LICENSE file. Source: search summaries; repository README.
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Platforms: macOS, Linux (x86_64 and ARM64), Windows. Source: https://docs.openwebui.com/getting-started/quick-start.md (search summary)

## Logo
Bundled icon: `apps/hub/icons/openwebui.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| pip (Python 3.11) | `pip install open-webui && open-webui serve` | no |
| uv | `DATA_DIR=~/.open-webui uvx --python 3.11 open-webui@latest serve` | no |
| Docker | `docker run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:main` | docker group |

- Needs an LLM backend such as Ollama.
- The pip route opens on localhost:8080; Docker on localhost:3000.
- Python 3.13 is reported unsupported by a secondary source.

- Source: https://docs.openwebui.com/

## Install options (research draft; unverified. Search not run.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| pip | `pip install open-webui` (use pipx or venv) | no | yes | Unverified. Use `pipx install open-webui`. Python version must match docs. |
| Docker | `docker run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:main` | root or docker group | yes | Unverified command; check repo README. |
| Podman | same image with `podman run` | no (rootless) | yes | Unverified. |

## Manual install (draft)
Use pipx or Docker; no separate manual install.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `port is already allocated` | Port 3000 used. | Change the host port in `-p`. |
| pip install fails on Python version | Unsupported Python. | Use a supported Python (check README). |
| Cannot reach Ollama | Backend URL wrong. | Set the Ollama URL in settings (unverified env var). |

## Sources
- https://docs.openwebui.com/getting-started/quick-start.md
- https://docs.openwebui.com/tutorials/docker-install
- https://github.com/open-webui/open-webui
