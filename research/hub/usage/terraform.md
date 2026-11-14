# Terraform

## When to use
- You need to create or change cloud or on-prem infrastructure (networks, compute, storage, DNS) from versioned configuration files.
- You want a preview of exactly what will be created, changed, or destroyed before anything happens.
- You want reusable infrastructure definitions through modules and share them across a team.
- You manage resources across several providers, such as a cloud plus Kubernetes or GitHub.

## How it works
- You write declarative configuration files describing the resources you want.
- Plan generates an execution plan showing creates, changes, and destroys against current infrastructure.
- Apply carries out the planned operations in dependency order after approval.
- Providers are plugins that talk to platform APIs; the Terraform Registry publishes thousands of them.
- A state file records what Terraform manages and is the basis for computing changes; protect it because it holds the source of truth.

## Not for
- Configuring software inside existing servers; use Ansible.
- Packaging and deploying applications onto Kubernetes; use Helm.
- Interactive cluster browsing; use k9s or kubectl.
- An open-source, community-governed fork of the same workflow; see OpenTofu.

## Sources
- https://developer.hashicorp.com/terraform/intro
