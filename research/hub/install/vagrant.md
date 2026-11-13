# Vagrant (vagrant)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| HashiCorp apt/dnf repo | follow https://developer.hashicorp.com/vagrant/install then `sudo apt install vagrant` | yes | yes | Unverified repo lines. |
| Arch | `sudo pacman -S vagrant` | yes | yes | Unverified. |
| Binary zip | download from https://releases.hashicorp.com/vagrant/ | no | yes | Unverified. |

## Manual install
Download the zip, unzip into `~/.local/bin`, check `vagrant --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| No provider found | VirtualBox or libvirt missing. | Install a provider (see virtualbox entry). |
| Permission on /dev/kvm (libvirt) | User not in libvirt/kvm group. | Add user to group (root, re-login). |

## Sources
- https://developer.hashicorp.com/vagrant/install (unverified this session)
