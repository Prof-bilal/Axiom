# Installation design

Status: Phase 9 research; no installer implementation is authorized. Axiom
will own the target-disk plan, identity, update/recovery semantics and first-run
experience while reusing a proven Linux installer technology when its behavior
and license are verified. The archived Omarchy installer path is not a
requirement or preferred dependency.

The first hardware contract is x86-64 UEFI, GPT, a reviewed filesystem layout,
fresh disposable target media and a fallback kernel. Dual boot, legacy BIOS,
complex manual partitioning, Secure Boot/TPM claims and broad hardware support
remain unproven until separate experiments pass.

Before writes, show target identity/capacity, the complete destructive plan and
an explicit confirmation. Revalidate the target immediately before execution;
protect the running medium and unrelated mounts. Partition/user inputs are data,
not shell commands. Secrets must not appear in logs or generated defaults.

Test cancellation, wrong-target guard, low space, firmware mismatch, offline
requirements, user creation failure, interruption, reboot without media,
package consistency, fallback boot and snapshot/recovery limits on disposable
disks only. The developer stack checklist is recorded separately and is not
silently applied during installation.
