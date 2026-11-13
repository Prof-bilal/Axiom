# OpenTofu

## When to use
- You want the infrastructure-as-code workflow of Terraform in an open-source tool.
- You need to define cloud or on-prem resources in versioned, reusable configuration files.
- You want a plan step that previews changes before they are applied.
- You want shared state with a cloud backend, access controls, and a private registry for a team.

## How it works
- You write declarative configuration describing the desired end state of resources.
- Plan previews the changes OpenTofu will make; Apply carries them out in dependency order, running independent changes in parallel.
- Providers connect to cloud and service APIs; the public registry lists thousands of them.
- A state file tracks real infrastructure and is the basis for computing changes.
- Modules package reusable components, and configurations can live in version control.

## Not for
- Teams already standardized on HashiCorp Terraform tooling and support; Terraform fits that case.
- Configuring software inside running servers; use Ansible.
- Packaging applications for Kubernetes; use Helm.
- Claims about compatibility with Terraform configuration or governance: the page I read did not state them. Not found.

## Sources
- https://opentofu.org/docs/intro/
