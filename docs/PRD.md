# Product requirements

Status: proposed prototype requirements; no acceptance result exists. Owner roles: architect for scope, security for trust boundaries, QA for evidence, release for delivery.

| ID | User problem and required behavior | Acceptance evidence |
| --- | --- | --- |
| R01 | Boot a cohesive Arch/Hyprland Axiom Shell environment on x86-64 UEFI | Clean QEMU boot, Wayland session and retained journal |
| R02 | Find launcher, settings, AI overlay and action history with keyboard | Keyboard-only walkthrough plus accessibility inspection |
| R03 | Ask for useful operations without delegating a root shell | 5–10 typed capabilities, schema validation and deny tests |
| R04 | Understand the exact target/impact before granting authority | Trusted confirmation bound to normalized request; replay/tamper tests |
| R05 | See who changed what | Correlated request, policy, execution, verification and recovery events |
| R06 | Recover an eligible system change | Btrfs/Snapper failure/reboot proof with boot assets and exclusions documented |
| R07 | Choose cloud or local inference without changing OS contracts | Adapter conformance with one cloud and Ollama, offline core desktop test |
| R08 | Evaluate speed using reproducible evidence | Controlled baseline/candidate reports, variance and regressions |
| R09 | Install/update safely in a disposable VM | Disk-target confirmation, clean install, full update and recovery tests |

Nonfunctional requirements: per-user data isolation; bounded request/time/output limits; failure closed before privileged side effects; redacted audit records; explicit network consent for content leaving the device; deterministic operations; signed package verification; usable cancellation and partial-failure reporting. Availability of core desktop must not depend on provider availability.

The prototype is a validation product, not a daily-driver support promise. Hardware support initially targets the VM matrix; GPUs, suspend, Wi-Fi, Bluetooth and battery require physical evidence before claims. Accessibility, localization and distribution license inventory are release gates, not decorative polish.

Changes to requirements must update MVP/phase gates and capability/security contracts together. Trace requirement IDs into future tests and release evidence. [Testing](engineering/TESTING.md) defines the test layers; [MVP](MVP.md) resolves scope.

## R10: Flow responsiveness under contention

The existing performance requirement R08 includes [Flow](system/FLOW.md): show logical workload usage/pressure, manually apply and restore an enrolled Efficient preset, and demonstrate whether foreground latency/stalls improve under matched load. Acceptance uses the [Flow benchmark matrix](engineering/BENCHMARKS.md), includes background progress and service overhead, and never substitutes a free-RAM number for responsiveness. Unsaved work, media/build/network activity, override and unsupported-controller cases must remain safe. No production automatic app sleep, container pause or new daemon is required for this first proof. Shield/Sentinel retain their separate protection/testing responsibilities; future worker budgets do not require implementing those products here.
