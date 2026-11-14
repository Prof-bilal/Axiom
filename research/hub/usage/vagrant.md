# Vagrant

## When to use
- You want a reproducible development environment that any teammate can recreate with one command.
- You want development machines to match production more closely through scripted provisioning.
- You need to run disposable VMs on a local hypervisor such as VirtualBox or VMware, or on a cloud provider.
- You want to automate setup steps with shell scripts, Chef, or Puppet on the VM.

## How it works
- The environment is defined in a Vagrantfile kept in the project.
- Running `vagrant up` builds and starts everything the Vagrantfile describes.
- A provider does the actual virtualization: VirtualBox, VMware, AWS, or others.
- Provisioners install and configure software inside the machine automatically.
- Typical commands from the wider docs are `vagrant init`, `vagrant ssh`, `vagrant halt`, and `vagrant destroy`; the intro page I read did not cover these, so they are unverified here.

## Not for
- Running production workloads; use real infrastructure managed by Terraform or Ansible.
- Lightweight containers for app development; Docker or Podman are faster to start.
- Managing a live fleet of servers; use Ansible.

## Sources
- https://developer.hashicorp.com/vagrant/intro
