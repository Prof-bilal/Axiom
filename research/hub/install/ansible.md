# Ansible (ansible)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| pipx (recommended) | `pipx install --include-deps ansible` | no | yes | Unverified flag; pipx must be installed. |
| Arch repos | `sudo pacman -S ansible` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install ansible` | yes | yes | Can be old. |
| Fedora | `sudo dnf install ansible` | yes | yes | Unverified. |

## Manual install
Not needed; use pipx or a distro package.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `externally-managed-environment` | PEP 668. | Use pipx. |
| `ansible: command not found` | PATH. | `pipx ensurepath`. |
| SSH host key errors | Unknown host. | Add host keys deliberately; do not disable checks globally. |

## Sources
- https://docs.ansible.com/ansible/latest/installation_guide/ (unverified this session)
