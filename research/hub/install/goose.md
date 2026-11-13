# Goose (goose)

Status: partially verified (install script URL from multiple search sources; security caveat is from one secondary site).

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| CLI script | `sh -c "curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash"` | no | yes | Repo moved to aaif-goose; older `block/goose` URLs may be outdated. Read the script before running. |
| Homebrew | `brew install block-goose-cli` | no | yes | Name from search; unverified. |
| Desktop app | .deb/.rpm from GitHub releases | yes | yes | Desktop is separate from CLI. |
| Update | `goose update` | no | yes | Per Homebrew note. |

## Manual install
1. Download `download_cli.sh` from https://github.com/aaif-goose/goose/releases (stable tag) and read it.
2. Run it: `bash download_cli.sh`.
3. Check: `goose --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `goose: command not found` | Install dir not on PATH. | Add the install dir (check script output) to PATH. |
| 404 on install URL | Old `block/goose` path. | Use the `aaif-goose` release URL above. |
| Config under `~/.config/goose` missing | First run not done. | Run `goose configure` (the user sets provider keys). |

## Sources
- https://goose-docs.ai/docs/getting-started/installation
- https://block.github.io/goose/docs/getting-started/installation (older)
- https://www.starryhope.com/linux/goose-omarchy/
