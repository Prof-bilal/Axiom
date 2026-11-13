# Ansible

## When to use
- You need to configure or update many Linux hosts the same way, repeatably.
- You want to describe the desired state of servers in YAML files that can be version-controlled.
- You want to run the same change across an inventory of groups of machines and see per-host results.
- You want configuration management without installing a permanent agent on each managed host.

## How it works
- The control node is where Ansible is installed; you run `ansible` or `ansible-playbook` from there.
- An inventory lists the managed nodes and groups that plays target.
- A playbook is a YAML file containing plays, which run top to bottom.
- Each play has ordered tasks; each task calls one module (for example `ansible.builtin.ping`).
- Run `ansible-playbook -i inventory playbook.yaml`; Ansible gathers facts, runs each task, and prints a per-host recap.
- Agentless operation over SSH is the design from the official overview, but the pages I read did not state the connection method explicitly.

## Not for
- Provisioning the cloud or servers themselves; use Terraform or OpenTofu.
- Packaging and deploying applications onto Kubernetes; use Helm.
- Interactive cluster browsing; use k9s.
- Roles, collections and connection details beyond the basics: not covered in the pages I read. Not found.

## Sources
- https://docs.ansible.com/ansible/latest/getting_started/index.html
- https://docs.ansible.com/ansible/latest/getting_started/get_started_playbook.html
