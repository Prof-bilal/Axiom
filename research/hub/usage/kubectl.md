# kubectl

## When to use
- You need to inspect or change resources in a Kubernetes cluster from a shell or script.
- You want to apply a YAML configuration file to a cluster (`kubectl apply -f`).
- You need detailed state of a pod or other resource to troubleshoot it (`describe`).
- You need to run a command inside a running container (`exec`) or remove resources.

## How it works
- kubectl talks to the cluster's control plane through the Kubernetes API.
- Commands follow the pattern `kubectl [command] [TYPE] [NAME] [flags]`, e.g. `kubectl get pod web`.
- Types are case-insensitive and accept singular, plural, or short forms (`pod`, `pods`, `po`).
- Common operations are `apply`, `describe`, `delete`, and `exec`; `get` and `logs` are also used, but their details were not in the portion of the reference I read.
- It reads `$HOME/.kube/config` by default; `KUBECONFIG` or `--kubeconfig` select another file, and the current context sets the namespace.

## Not for
- Visual browsing of cluster state; use k9s or Lens.
- Installing packaged applications as a unit; use Helm.
- Provisioning the cluster or cloud infrastructure; use Terraform or OpenTofu.

## Sources
- https://kubernetes.io/docs/reference/kubectl/
