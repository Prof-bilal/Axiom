# Product requirements

Status: Phase 0 proposal; no release or hardware promise.

| ID | Requirement | Evidence |
| --- | --- | --- |
| R01 | Boot a minimal Axiom graphical session in x86-64 QEMU | Image manifest, UEFI boot, serial/journal and display evidence |
| R02 | Launch, focus, switch and close real Linux apps | Session integration test in guest |
| R03 | Provide a coherent Axiom Shell without fake state | Phase 3 QEMU walkthrough and restart/failure tests |
| R04 | Keep core desktop usable offline and without AI | Network/provider outage tests |
| R05 | Make privileged actions typed, scoped, attributable and deny-by-default | Security contract and adversarial tests |
| R06 | Recover eligible system changes honestly | Btrfs/update/recovery evidence with exclusions |
| R07 | Add optional local/cloud AI without changing OS authority | Adapter conformance and permission tests |
| R08 | Measure responsiveness and resource cost | Controlled baseline/candidate reports with uncertainty |
| R09 | Publish only after installer, hardware, license and update gates pass | Phase 9 release checklist |

Nonfunctional requirements: readable and accessible UI, visible focus,
reduced-motion support, no secret leakage, no unrestricted agent shell, standard
Wayland consent, bounded resources, cancellation, truthful unsupported states
and reproducible QEMU evidence. Requirements change only with the phase and
architecture contracts updated together.
