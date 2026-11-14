# Lens

## When to use
- You want a desktop GUI to see, debug, and operate Kubernetes clusters from one workspace instead of many terminal commands.
- You are connecting to managed clusters such as EKS, AKS, GKE, or OpenShift and want their resources in one place.
- You want to view pod logs, open a pod shell, or set up port forwarding without typing kubectl commands.
- You want to browse Helm charts and releases visually.

## How it works
- Lens is a desktop app that runs locally and uses your existing cluster credentials; it respects existing RBAC.
- You add clusters (local, or cloud-managed) to the catalog and switch between them.
- The Workloads and resource views show pods, deployments, and other objects, with Config, Network, Storage, and Access Control sections.
- The Navigator, Hotbar, Details panel, and Command Palette organize the workspace.
- Extensions come from a Marketplace, and an integrated terminal is available.

## Not for
- Scripting, automation, or CI; use kubectl or Helm.
- A lightweight terminal-only workflow; k9s is faster over SSH.
- Governed AI agent platforms: the homepage promotes Lens Agents, which is a separate product area, so check its scope before adopting it.

## Sources
- https://lenshq.io/
- https://docs.lenshq.io/
