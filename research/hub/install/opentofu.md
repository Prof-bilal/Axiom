# OpenTofu (opentofu)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Installer script | `sh -c "curl -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && sh install-opentofu.sh --install-method standalone"` | no (standalone) | yes | Unverified. Download, read, then run. |
| Arch AUR | `yay -S opentofu-bin` | no | yes | Unverified. |
| Tarball / zip | download from https://github.com/opentofu/opentofu/releases | no | yes | Unverified filename. |

## Manual install
1. Download `tofu_<ver>_linux_amd64.zip` from GitHub releases (unverified name).
2. Unzip into `~/.local/bin`.
3. Check: `tofu version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `tofu: command not found` | PATH. | Add `~/.local/bin` to PATH. |
| Provider install fails | Registry network. | Check proxy/DNS. |

## Sources
- https://opentofu.org/docs/intro/install/ (unverified this session)
