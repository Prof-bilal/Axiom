# Open WebUI (openwebui)

Status: unverified. Search not run.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| pip | `pip install open-webui` (use pipx or venv) | no | yes | Unverified. Use `pipx install open-webui`. Python version must match docs. |
| Docker | `docker run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:main` | root or docker group | yes | Unverified command; check repo README. |
| Podman | same image with `podman run` | no (rootless) | yes | Unverified. |

## Manual install
Use pipx or Docker; no separate manual install.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `port is already allocated` | Port 3000 used. | Change the host port in `-p`. |
| pip install fails on Python version | Unsupported Python. | Use a supported Python (check README). |
| Cannot reach Ollama | Backend URL wrong. | Set the Ollama URL in settings (unverified env var). |

## Sources
- https://github.com/open-webui/open-webui (unverified this session)
