# VirtualBox

- Id: `virtualbox` · Category: System · Weight: heavy · Licence (catalog): GPL-2.0
- Catalog sources: pacman `virtualbox`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Oracle VirtualBox is a free, cross-platform type-2 hypervisor for running virtual machines on Windows, macOS, Linux and Solaris hosts. It is for developers, testers and users who need virtual machines on a desktop.

## Facts
- Name: Oracle VirtualBox
- Publisher: Oracle
- Official website: https://www.virtualbox.org/ and https://www.oracle.com/virtualization/virtualbox/
- Licence: base package GPL (per search summary); Extension Pack under the Personal Use and Evaluation License (PUEL). Source: https://docs.oracle.com/en/virtualization/virtualbox/7.1/g32958-01 (search result)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found (vendor minimums not confirmed)
- CPU: not found
- Disk: not found
- Linux: distro repositories or Oracle APT repository; Extension Pack must match the VirtualBox version. Source: search summary (third-party guide)

## Logo
Bundled icon: `apps/hub/icons/virtualbox.png`.

## Screenshots
Not found in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package | `sudo pacman -S virtualbox virtualbox-host-modules-arch` | yes |
| For non-default kernels (linux-lts, zen): DKMS modules plus headers | `sudo pacman -S virtualbox virtualbox-host-dkms linux-lts-headers` | yes |
| Allow your user to manage VMs | `sudo usermod -aG vboxusers $USER` | yes |

- Pick the host-modules package that matches your kernel; the wrong one makes VirtualBox fail to start VMs.
- Guest additions ISO: virtualbox-guest-iso.

- Source: https://wiki.archlinux.org/title/Vbox
- Source: https://discuss.cachyos.org/t/info-on-how-to-install-virtualbox-on-cachyos/2488

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S virtualbox virtualbox-host-modules-arch` | yes | yes | Unverified package names; match the module to the running kernel. |
| Debian/Ubuntu | `sudo apt install virtualbox` | yes | yes | Unverified. |
| Vendor .deb | download from https://www.virtualbox.org/wiki/Linux_Downloads | yes | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `modprobe vboxdrv failed` | Kernel modules not built for running kernel. | Install the matching host modules (Arch: `virtualbox-host-dkms` for custom kernels, unverified). Reboot. |
| `VERR_VMX_IN_VMX_ROOT_MODE` | KVM is using VT-x. | Unload kvm modules or use another hypervisor (unverified). |
| User cannot start VMs | Not in vboxusers group. | `sudo usermod -aG vboxusers $USER`, re-login. |

## Sources
- https://docs.oracle.com/en/virtualization/virtualbox/7.1/g32958-01
- https://www.oracle.com/virtualization/virtualbox/
- https://www.virtualbox.org/wiki/Linux_Downloads
