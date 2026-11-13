# k9s

## When to use
- You want to browse and manage a Kubernetes cluster interactively from a terminal instead of typing many kubectl commands.
- You are switching between namespaces or contexts often and want quick navigation.
- You want to view logs, describe, edit, or delete resources from one screen.
- You want a read-only session for safe inspection with `--readonly`.

## How it works
- Start it from a terminal; flags such as `-n` (namespace), `-c` (starting view), `--context`, and `--readonly` set the initial view.
- Type `:` then a resource name, plural, short name, or alias (for example `:pod`) to open that resource's list; add a namespace to scope it.
- Filter with `/` (regex supported), inverse-filter with `/!`, filter by label with `/-l`, or fuzzy-find with `/-f`.
- `:ns` switches namespaces and `:ctx` switches contexts.
- Keys act on the highlighted item: `d` describes, `v` views, `e` edits, `l` shows logs, `ctrl-d` deletes (with confirmation), and `?` lists all mnemonics.

## Not for
- Scripting, automation, or CI pipelines; use kubectl or Helm.
- Installing or upgrading packaged applications; use Helm.
- A graphical desktop IDE experience; Lens fits that better.

## Sources
- https://k9scli.io/topics/commands/
