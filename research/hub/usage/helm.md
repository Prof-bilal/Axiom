# Helm

## When to use
- You need to install a packaged application (a chart) onto a Kubernetes cluster with one command.
- You want to upgrade or roll back an installed application to an earlier revision.
- You need to customize a packaged app's configuration with values files or `--set` overrides.
- You want to find ready-made charts on Artifact Hub or in a chart repository.

## How it works
- A chart is a package of Kubernetes resources; `helm create` builds one and `helm package` prepares it for distribution.
- A release is one installed instance of a chart; each install, upgrade, or rollback increments its revision number.
- Repositories supply charts; manage them with `helm repo add`, `list`, `update`, and `remove`. Helm 3 and later ship with no default repository.
- Values configure a chart: defaults come from the chart (`helm show values`), overridden by `-f` files or `--set`, with `--set` taking precedence.
- Core commands: `helm install`, `helm upgrade`, `helm rollback`, `helm list`, `helm history`, `helm status`, `helm uninstall`.

## Not for
- Ad-hoc inspection or editing of single resources; use kubectl or k9s.
- Provisioning clusters or cloud infrastructure; use Terraform or OpenTofu.
- Plain configuration of hosts; use Ansible.

## Sources
- https://helm.sh/docs/
- https://helm.sh/docs/intro/using_helm/
