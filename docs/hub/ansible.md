# Ansible

- Id: `ansible` · Category: Development · Weight: light · Licence (catalog): GPL-3.0
- Catalog sources: pacman `ansible`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Ansible is an agentless IT automation tool that configures systems and runs playbooks over SSH. It is for system administrators and DevOps teams who automate configuration and deployment.

## Facts
- Name: Ansible (ansible-core and the Ansible community package)
- Publisher: Ansible project (open source; see repository)
- Official website: https://www.ansible.com/ (docs: https://docs.ansible.com/)
- Licence: GNU GPL v3 or later (PyPI classifier GPLv3+). Source: https://pypi.org/pypi/ansible
- Latest version: 13.7.0 per a PyPI mirror, dated 2026-05-19 (not confirmed on pypi.org directly). Source: https://simple-repository.app.cern.ch/project/ansible
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: pip or distro packages; project README recommends pip. Source: https://github.com/ansible/ansible

## Logo
Bundled icon: `apps/hub/icons/ansible.png`.

## Screenshots
Not found. Ansible is a CLI with no screenshots in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra, full collections) | `sudo pacman -S ansible` | yes |
| Core only | `sudo pacman -S ansible-core` | yes |


- Source: https://archlinux.org/packages/extra/any/ansible
- Source: https://wiki.archlinux.org/title/Ansible

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| pipx (recommended) | `pipx install --include-deps ansible` | no | yes | Unverified flag; pipx must be installed. |
| Arch repos | `sudo pacman -S ansible` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install ansible` | yes | yes | Can be old. |
| Fedora | `sudo dnf install ansible` | yes | yes | Unverified. |

## Manual install (draft)
Not needed; use pipx or a distro package.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `externally-managed-environment` | PEP 668. | Use pipx. |
| `ansible: command not found` | PATH. | `pipx ensurepath`. |
| SSH host key errors | Unknown host. | Add host keys deliberately; do not disable checks globally. |

## Sources
- https://docs.ansible.com/ansible/latest/installation_guide/
- https://github.com/ansible/ansible
- https://pypi.org/pypi/ansible
- https://simple-repository.app.cern.ch/project/ansible
