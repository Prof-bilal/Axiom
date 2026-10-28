# Desktop shell investigation

Status: Phase 3 authorized by the owner's 2026-10-28 execution brief. The
window foundation and native controls remain in validation, and the integrated
shell now has a first implementation slice for Dock, top bar, launcher,
notifications and workspace state. Runtime acceptance is still open; a
rendered QML surface is never treated as integration evidence.

The workflow is reference → investigation → evidence → behavior model → Linux
implementation research → Axiom specification → implementation → validation.
Public macOS documentation describes observable UX only. Source inspection is
preferred for Linux; REA supplements it. No Apple assets or proprietary copies
of macOS are inputs. See [repository audit](repository-audit.md), the [Phase 3
readiness packet](../../docs/research/PHASE3_READINESS.md), [REA setup](../../docs/research/REA_SETUP.md),
the [REA UI workflow](../../docs/research/REA_UI_REVERSE_ENGINEERING.md), and
the [license map](../../docs/research/OPEN_SOURCE_DESKTOP_LICENSES.md).

Each investigated feature has eight records:

| Record | Required content |
| --- | --- |
| evidence.md | Source URL/revision, date, observation, evidence type and scope |
| behavior.md | Observable states, triggers and transitions |
| architecture.md | Ownership, IPC, lifecycle, privilege and failure boundaries |
| interaction-map.md | Pointer, keyboard, focus and cancellation flows |
| linux-references.md | Source files inspected, version, findings and license |
| unknowns.md | Unproven claims, constraints and experiment to resolve each |
| axiom-spec.md | Reference, evidence, Linux implementation, Axiom decision, reason, difference |
| validation.md | Expected/actual behavior, environment, commands, artifacts and gaps |

An evidence record distinguishes DOCUMENTED, SOURCE-INSPECTED, RUNTIME-OBSERVED,
PROPOSED and UNKNOWN. A rendered surface never proves integration. A capability
is unavailable until its backend is available; data from titles/app IDs is
untrusted, displayed as plain text and never interpolated into commands.

Execution order is 3.0 research infrastructure, 3.1 window foundation, 3.2 window
controls, 3.3 Dock, 3.4 top bar, 3.5 launcher, 3.6 Control Center, 3.7 notifications,
3.8 workspace overview, 3.9 file-manager specification, 3.10 integration/polish.
Canonical status lives in [PHASES](../../docs/PHASES.md). Later feature directories
start with explicit investigation scope rather than fabricated findings. The
integrated implementation is intentionally limited to APIs inspected in the
pinned Quickshell package; persistence, accessibility, multi-monitor and
service-control behavior remain explicit validation gates.

The foundation is additionally investigated in [window-foundation](window-foundation/axiom-spec.md).
No UI, service, authentication policy or host Hyprland configuration is installed
by the research system. Runtime tests should use disposable windows/guests.
