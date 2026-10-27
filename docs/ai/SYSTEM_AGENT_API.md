# System Agent API

Status: proposed V1 contract, no methods implemented. Phase 6 may develop schemas and read-only/dry-run paths; mutation handlers remain disabled until Phase 7 authorization and audit gates pass. Last verified: 2026-10-18.

## Shared contract

Ten capabilities cover evidence, application/workspace launch, bounded cleanup, approved user services and package lifecycle. No additional namespace is authorized by mentioning it in the product vision. Schema notation below is language-neutral: `string`, `bool`, `uint`, `uint64`, arrays, enums and bounded numbers denote required typed fields. Every object rejects unknown properties. Before implementation, materialize versioned machine-readable schemas and D-Bus mappings; these examples are proposals, not fabricated upstream APIs.

All requests include `schema_version=1`, `request_id`, `capability`, `arguments`; identity comes from authenticated transport, never caller-provided UID. Return envelope: `{request_id,status,result?,error?,audit_id,rollback:{available,coverage,reason}}`. Stable shared errors: InvalidArgument, Unauthorized, ApprovalRequired, ExpiredGrant, Unsupported, Cancelled, AuditUnavailable, VerificationFailed, InternalError. Errors redact secrets and distinguish partial/uncertain execution from no action. Inputs have length/count/size/time limits; package names and unit IDs are parsed and resolved rather than shell-escaped.

Execution for every row: authenticate → validate → resolve bounded resources/plan → policy/consent → executor revalidation → durable audit intent → execute → verify → audit result. Root operations additionally require action-specific Polkit authorization bound to original caller. No writes, including privileged snapshot creation, happen before their own authorization. Snapshot preparation may precede final execution approval only under a separately approved bounded preparation request; final approval binds the exact mutation plan and coverage. Grants are one-use, expiring and plan/resource/policy bound. Root mutations are CRITICAL even if the underlying product use case is often described as SENSITIVE. See [permissions](../security/PERMISSIONS.md).

All audit events include identity, capability/version, redacted arguments, decision, policy/grant correlation, timings, affected resources, effect/outcome, verification and actual rollback coverage. Root mutation journal survives root rollback by explicit storage design; user history retention is separate. Every capability needs schema/denial/cancellation/failure/peer-authentication tests plus the row-specific security tests. No root API exposes arbitrary commands, paths, repositories, package hooks or D-Bus destinations.

## system.info

- Purpose: Explain hardware and OS state.
- Arguments: `{}`. Return: `{"kernel":string,"os":string,"memory_bytes":uint64,"snapshot_support":bool}`.
- Example arguments: `{}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; no path, command or extra argument may expand the described scope.
- Permission: OBSERVE; effective classification can only increase.
- Execution path / privilege: shared lifecycle → user; read /proc and OS metadata.
- Side effects / rollback: No mutation; local disclosure only.
- Audit: shared event plus `system.info` resource identifiers and observed effects; redact private file/process details.
- Verification: Kernel/OS values match system sources; bounded memory value.
- Failure modes: shared errors plus Unavailable telemetry; partial execution must be visible.
- Security tests: shared suite plus spoofed system metadata, secret/hostname redaction.

## processes.list

- Purpose: Identify resource-heavy workloads.
- Arguments: `{"limit":uint[1,100],"sort":enum[cpu,memory]}`. Return: `{"items":[{"pid":uint,"name":string,"cpu":number,"rss_bytes":uint64}],"sample_ms":uint}`.
- Example arguments: `{"limit":10,"sort":"memory"}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; no path, command or extra argument may expand the described scope.
- Permission: OBSERVE; effective classification can only increase.
- Execution path / privilege: shared lifecycle → user; own-UID proc metadata only.
- Side effects / rollback: No mutation; process names may reveal activity.
- Audit: shared event plus `processes.list` resource identifiers and observed effects; redact private file/process details.
- Verification: Returned PIDs belong to caller at sampling; label transient samples.
- Failure modes: shared errors plus ProcessExited, TelemetryUnavailable; partial execution must be visible.
- Security tests: shared suite plus cross-UID access, PID reuse, sensitive command-line omission.

## storage.analyze

- Purpose: Explain space use in an enrolled workspace.
- Arguments: `{"root_id":string,"max_depth":uint[0,8]}`. Return: `{"bytes":uint64,"entries":uint,"incomplete":bool}`.
- Example arguments: `{"root_id":"workspace-current","max_depth":3}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; no path, command or extra argument may expand the described scope.
- Permission: OBSERVE; effective classification can only increase.
- Execution path / privilege: shared lifecycle → user; descriptor-rooted bounded walker.
- Side effects / rollback: Read-only; bounded I/O; report excluded mounts.
- Audit: shared event plus `storage.analyze` resource identifiers and observed effects; redact private file/process details.
- Verification: Sum checked on fixture; label inaccessible/sparse/reflink accounting.
- Failure modes: shared errors plus UnknownRoot, PermissionDenied, BudgetExceeded; partial execution must be visible.
- Security tests: shared suite plus symlink swaps, traversal, mount crossing, huge trees.

## apps.open

- Purpose: Launch an installed trusted desktop application.
- Arguments: `{"desktop_id":string}`. Return: `{"launch_id":string,"dispatched":bool}`.
- Example arguments: `{"desktop_id":"org.kde.konsole.desktop"}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; no path, command or extra argument may expand the described scope.
- Permission: NORMAL; effective classification can only increase.
- Execution path / privilege: shared lifecycle → user; desktop launch API, no shell.
- Side effects / rollback: Starts app; app may perform its own actions; cannot restore prior app state.
- Audit: shared event plus `apps.open` resource identifiers and observed effects; redact private file/process details.
- Verification: Verify desktop ID exists and dispatch accepted; do not claim visible window without evidence.
- Failure modes: shared errors plus UnknownApp, LaunchFailed; partial execution must be visible.
- Security tests: shared suite plus malicious desktop IDs, argument injection, unsafe custom desktop files.

## workspace.open

- Purpose: Open a previously enrolled local project.
- Arguments: `{"workspace_id":string}`. Return: `{"workspace_id":string,"opened":[string],"partial":bool}`.
- Example arguments: `{"workspace_id":"project-main"}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; no path, command or extra argument may expand the described scope.
- Permission: NORMAL; effective classification can only increase.
- Execution path / privilege: shared lifecycle → user; resolve saved directory and approved app IDs.
- Side effects / rollback: Opens directory/apps only; no repo scripts, containers or shell; no exact undo.
- Audit: shared event plus `workspace.open` resource identifiers and observed effects; redact private file/process details.
- Verification: Verify root identity and dispatch outcomes independently.
- Failure modes: shared errors plus UnknownWorkspace, MissingPath, PartialFailure; partial execution must be visible.
- Security tests: shared suite plus imported workspace commands, symlink replacement, unapproved remote URLs.

## packages.install

- Purpose: Install a reviewed package from configured signed repositories.
- Arguments: `{"packages":[string],"plan_id":string}`. Return: `{"job_id":string,"versions":[string],"verification":string}`.
- Example arguments: `{"packages":["ripgrep"],"plan_id":"opaque-reviewed-plan"}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; a plan ID is server-issued, owner-bound, expiring and includes resolved effects and versions.
- Permission: CRITICAL; effective classification can only increase.
- Execution path / privilege: shared lifecycle → root broker; fixed package adapter serialized against package lock.
- Side effects / rollback: Package/config/hooks/system state changes; snapshots limited; no universal uninstall undo.
- Audit: shared event plus `packages.install` resource identifiers and observed effects; redact private file/process details.
- Verification: Re-read installed database and required health checks; compare approved dependency/version plan.
- Failure modes: shared errors plus PlanChanged, LockBusy, SignatureFailure, HookFailure, PartialFailure; partial execution must be visible.
- Security tests: shared suite plus option injection, untrusted repo/AUR rejection, modified plan, malicious hook impact.

## services.start

- Purpose: Start a specifically allowed user service.
- Arguments: `{"unit":string,"scope":enum[user]}`. Return: `{"job_id":string,"state":string}`.
- Example arguments: `{"unit":"approved-dev.service","scope":"user"}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; no path, command or extra argument may expand the described scope.
- Permission: SENSITIVE; effective classification can only increase.
- Execution path / privilege: shared lifecycle → user; user systemd D-Bus; exact allowlist.
- Side effects / rollback: Starts workload and its effects; stop is compensation, not complete undo.
- Audit: shared event plus `services.start` resource identifiers and observed effects; redact private file/process details.
- Verification: Inspect job and active state; unit-specific health if declared.
- Failure modes: shared errors plus UnitNotAllowed, DependencyFailed, Timeout; partial execution must be visible.
- Security tests: shared suite plus template/name injection, transient unit escape, system-scope request.

## services.stop

- Purpose: Stop a specifically allowed user service.
- Arguments: `{"unit":string,"scope":enum[user]}`. Return: `{"job_id":string,"state":string}`.
- Example arguments: `{"unit":"approved-dev.service","scope":"user"}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; no path, command or extra argument may expand the described scope.
- Permission: SENSITIVE; effective classification can only increase.
- Execution path / privilege: shared lifecycle → user; user systemd D-Bus; exact allowlist.
- Side effects / rollback: Interrupts work; start may compensate but cannot restore lost state.
- Audit: shared event plus `services.stop` resource identifiers and observed effects; redact private file/process details.
- Verification: Inspect stopped state/job and report remaining processes.
- Failure modes: shared errors plus UnitNotAllowed, StopFailed, Timeout; partial execution must be visible.
- Security tests: shared suite plus critical session-unit denial, dependency side effects, forged scope.

## storage.clean

- Purpose: Remove only previewed application-owned expendable cache entries.
- Arguments: `{"cleanup_plan_id":string}`. Return: `{"removed":uint,"freed_bytes":uint64,"skipped":uint}`.
- Example arguments: `{"cleanup_plan_id":"opaque-cache-plan"}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; a plan ID is server-issued, owner-bound, expiring and includes resolved effects and versions.
- Permission: SENSITIVE; effective classification can only increase.
- Execution path / privilege: shared lifecycle → user; descriptor-relative delete inside enrolled owned cache.
- Side effects / rollback: Irreversible cache removal; no arbitrary user-file deletion; no implied snapshot protection.
- Audit: shared event plus `storage.clean` resource identifiers and observed effects; redact private file/process details.
- Verification: Match approved inode identities and count; report changed/skipped entries.
- Failure modes: shared errors plus PlanExpired, ResourceChanged, PermissionDenied, PartialFailure; partial execution must be visible.
- Security tests: shared suite plus symlink/rename races, hard links, traversal, home/root targets, changed ownership.

## system.update

- Purpose: Perform a full reviewed Arch system upgrade.
- Arguments: `{"plan_id":string}`. Return: `{"job_id":string,"reboot_required":bool,"verification":string}`.
- Example arguments: `{"plan_id":"opaque-full-upgrade-plan"}`.
- Validation: reject unknown fields, enforce bounded schema and exact enrolled/allowlisted identities; a plan ID is server-issued, owner-bound, expiring and includes resolved effects and versions.
- Permission: CRITICAL; effective classification can only increase.
- Execution path / privilege: shared lifecycle → root broker; serialized fixed pacman full-upgrade adapter.
- Side effects / rollback: Packages/hooks/config/root/boot may change; partial upgrades forbidden; rollback needs coherent root and boot recovery.
- Audit: shared event plus `system.update` resource identifiers and observed effects; redact private file/process details.
- Verification: Check package database, kernel/module/initramfs/boot consistency and service health; reboot proof in VM.
- Failure modes: shared errors plus PlanChanged, LockBusy, DownloadFailed, SignatureFailure, HookFailure, RecoveryRequired; partial execution must be visible.
- Security tests: shared suite plus partial-upgrade attempts, boot space exhaustion, power loss, unsigned packages, audit failure.

## Deliberate exclusions

Root service manipulation, arbitrary file writes/deletes, power actions, bootloader edits, formatting, firewall/user/security changes, key access, Git pushes and external sends remain unavailable. AUR builds are excluded from privileged package installation. Persistent routines and external MCP requests cannot bypass these exclusions. Package operations use existing pacman behavior; do not implement a second package manager or pretend hooks are individually reversible.

Evidence: [D-Bus](https://dbus.freedesktop.org/doc/dbus-specification.html), [Polkit](https://polkit.pages.freedesktop.org/polkit/polkit.8.html). Recovery specifics and exclusions are governed by [Btrfs rollback](../system/BTRFS_ROLLBACK.md); adversarial coverage by [threat model](../security/THREAT_MODEL.md).
