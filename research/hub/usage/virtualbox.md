# VirtualBox

## When to use
- You want to run another operating system (Windows, Linux, or others) as a virtual machine on your desktop.
- You need to test software on a different OS without touching your main installation.
- You want snapshots so you can revert a VM to an earlier state after an experiment.
- You want to import or export VMs in the OVF format to share them.

## How it works
- VirtualBox is a hosted, or type-2, hypervisor: it runs on top of an existing host OS (Windows, macOS, Linux, or Solaris).
- You create a VM with the wizard in VirtualBox Manager, then install a guest OS into it.
- Virtual disks are image files that can be moved between hosts.
- Snapshots save a VM's state (settings, disk, and optionally memory) and form a branching tree you can revert to.
- Settings can be changed in the GUI or with the `VBoxManage` command-line tool; some changes need the VM powered off.
- Guest Additions inside the guest improve performance and enable shared folders and display resizing.

## Not for
- Lightweight, fast-starting app isolation; containers from Docker or Podman are quicker.
- Scripted, reproducible VM environments; Vagrant builds on it for that.
- Production virtualization of server fleets; use a server hypervisor.

## Sources
- https://www.virtualbox.org/manual/ch01.html
