# Terraform

- Id: `terraform` · Category: Development · Weight: light · Licence (catalog): BSL
- Catalog sources: pacman `terraform`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Terraform is HashiCorp's infrastructure-as-code tool for provisioning cloud and on-premises resources from declarative configuration. It is for platform and DevOps engineers, and Terraform Enterprise is the self-hosted commercial product.

## Facts
- Name: Terraform (CLI) and Terraform Enterprise (self-hosted)
- Publisher: HashiCorp
- Official website: https://developer.hashicorp.com/terraform
- Licence: Terraform CLI moved from MPL 2.0 to the Business Source License (BSL) in August 2023. Source: search summary citing HashiCorp announcement (not fetched). Terraform Enterprise is a licensed product.
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found for CLI; Terraform Enterprise third-party guide says 8 GB RAM and 4 cores (unofficial). Source: https://oneuptime.com/blog/post/2026-02-23-how-to-install-terraform-enterprise-on-linux/view
- CPU: not found for CLI
- Disk: not found
- Install: HashiCorp APT and RPM repositories. Source: https://computingforgeeks.com/install-terraform-getting-started-linux/ (third-party)

## Logo
Bundled icon: `apps/hub/icons/terraform.png`.

## Screenshots
Not found in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra, BUSL-1.1 licence) | `sudo pacman -S terraform` | yes |
| Official binaries and repos | `see https://developer.hashicorp.com/terraform/install (APT, DNF, zip)` | varies |

- Terraform moved from MPL 2.0 to BSL 1.1 in August 2023; OpenTofu is the open-source fork.

- Source: https://archlinux.org/packages/extra/x86_64/terraform/
- Source: https://developer.hashicorp.com/terraform/install

## Install options (research draft; unverified this session. Note HashiCorp licence change; OpenTofu is the open-source fork.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| HashiCorp apt repo | follow https://developer.hashicorp.com/terraform/install (Debian/Ubuntu) then `sudo apt install terraform` | yes | yes | Unverified exact repo lines. |
| HashiCorp dnf repo | follow same docs, then `sudo dnf install terraform` | yes | yes | Unverified. |
| Arch | `sudo pacman -S terraform` | yes | yes | Unverified. |
| Binary zip | download from https://releases.hashicorp.com/terraform/ | no | yes | Unverified filename; verify SHA256SUMS. |

## Manual install (draft)
1. Download `terraform_<ver>_linux_amd64.zip` from releases.hashicorp.com (unverified name).
2. `unzip` into `~/.local/bin`.
3. Check: `terraform version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `terraform: command not found` | PATH. | Add `~/.local/bin` to PATH. |
| Provider download blocked | Network or proxy. | Set proxy; check registry access. |

## Sources
- https://computingforgeeks.com/install-terraform-getting-started-linux/
- https://developer.hashicorp.com/terraform/enterprise/install/pre-install-checklist
- https://developer.hashicorp.com/terraform/install
- https://oneuptime.com/blog/post/2026-02-23-how-to-install-terraform-enterprise-on-linux/view
