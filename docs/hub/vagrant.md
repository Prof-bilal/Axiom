# Vagrant

- Id: `vagrant` · Category: Development · Weight: heavy · Licence (catalog): BSL
- Catalog sources: pacman `vagrant`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Vagrant is a tool for building and managing reproducible development virtual machines from configuration files. It is for developers who want consistent local environments across machines.

## Facts
- Name: Vagrant
- Publisher: HashiCorp
- Official website: https://developer.hashicorp.com/vagrant (downloads: https://developer.hashicorp.com/vagrant/downloads)
- Licence: not confirmed in this pass (licence information is on the downloads page, not fetched)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: HashiCorp APT and RPM repositories, then `vagrant --version`. Source: https://developer.hashicorp.com/vagrant/install

## Logo
Bundled icon: `apps/hub/icons/vagrant.png`.

## Screenshots
Not found in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra, BUSL-1.1) | `sudo pacman -S vagrant` | yes |

- The package page snapshot is from December 2024; confirm it is still in extra.
- Vagrant needs a provider such as VirtualBox or libvirt.

- Source: https://archlinux.org/packages/extra/x86_64/vagrant

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| HashiCorp apt/dnf repo | follow https://developer.hashicorp.com/vagrant/install then `sudo apt install vagrant` | yes | yes | Unverified repo lines. |
| Arch | `sudo pacman -S vagrant` | yes | yes | Unverified. |
| Binary zip | download from https://releases.hashicorp.com/vagrant/ | no | yes | Unverified. |

## Manual install (draft)
Download the zip, unzip into `~/.local/bin`, check `vagrant --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| No provider found | VirtualBox or libvirt missing. | Install a provider (see virtualbox entry). |
| Permission on /dev/kvm (libvirt) | User not in libvirt/kvm group. | Add user to group (root, re-login). |

## Sources
- https://developer.hashicorp.com/vagrant/downloads
- https://developer.hashicorp.com/vagrant/install
