# VirtualBox (virtualbox)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S virtualbox virtualbox-host-modules-arch` | yes | yes | Unverified package names; match the module to the running kernel. |
| Debian/Ubuntu | `sudo apt install virtualbox` | yes | yes | Unverified. |
| Vendor .deb | download from https://www.virtualbox.org/wiki/Linux_Downloads | yes | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `modprobe vboxdrv failed` | Kernel modules not built for running kernel. | Install the matching host modules (Arch: `virtualbox-host-dkms` for custom kernels, unverified). Reboot. |
| `VERR_VMX_IN_VMX_ROOT_MODE` | KVM is using VT-x. | Unload kvm modules or use another hypervisor (unverified). |
| User cannot start VMs | Not in vboxusers group. | `sudo usermod -aG vboxusers $USER`, re-login. |

## Sources
- https://www.virtualbox.org/wiki/Linux_Downloads (unverified this session)
