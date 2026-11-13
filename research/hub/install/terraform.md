# Terraform (terraform)

Status: unverified this session. Note HashiCorp licence change; OpenTofu is the open-source fork.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| HashiCorp apt repo | follow https://developer.hashicorp.com/terraform/install (Debian/Ubuntu) then `sudo apt install terraform` | yes | yes | Unverified exact repo lines. |
| HashiCorp dnf repo | follow same docs, then `sudo dnf install terraform` | yes | yes | Unverified. |
| Arch | `sudo pacman -S terraform` | yes | yes | Unverified. |
| Binary zip | download from https://releases.hashicorp.com/terraform/ | no | yes | Unverified filename; verify SHA256SUMS. |

## Manual install
1. Download `terraform_<ver>_linux_amd64.zip` from releases.hashicorp.com (unverified name).
2. `unzip` into `~/.local/bin`.
3. Check: `terraform version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `terraform: command not found` | PATH. | Add `~/.local/bin` to PATH. |
| Provider download blocked | Network or proxy. | Set proxy; check registry access. |

## Sources
- https://developer.hashicorp.com/terraform/install (unverified this session)
