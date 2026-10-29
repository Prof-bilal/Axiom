# Axiom security contract

Status: Phase 0 design; enforcement is not implemented. The full contract is
in [security/SECURITY.md](security/SECURITY.md), with threats, permissions and
sandboxing linked there.

The non-negotiables are: UI and agents run unprivileged; no unrestricted sudo
or arbitrary shell passthrough; every privileged API independently authorizes
caller, operation and target; missing or invalid authority denies; secrets do
not enter repository files or logs; core desktop works without cloud AI; and
Wayland/portal consent is never weakened for automation. Models, MCP output,
files, web content and downloaded artifacts are untrusted data, not authority.

Future Warden integration is an adapter behind typed Axiom capability policy,
not the policy authority. Security gates apply before any mutation, installer,
agent action or release claim.
