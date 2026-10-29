# Development workflow

Status: Phase 0 reset. Development is QEMU-first and evidence-driven. No
browser mock, screenshot or themed upstream desktop counts as an Axiom runtime.

## Current checks

```sh
python3 scripts/validate-repo.py
python3 scripts/test-concepts.py
python3 scripts/check-iso-profile.py
```

The Phase 1 profile and harness remain historical evidence. In a host with the
required Arch/QEMU tooling, the existing reproducible smoke command is:

```sh
tests/qemu-boot.sh iso/out/<image>.iso
```

The reset will add a base-image build entry point only after the Phase 0
architecture and package inputs are reviewed. The intended loop is:

```text
build base -> launch disposable QEMU -> boot real Wayland session
-> inspect serial/journal/display behavior -> retain evidence -> iterate
```

All guest runs must avoid host home mounts, real credentials, bridged production
networking and arbitrary USB/clipboard sharing. Record the image/build hash,
firmware, guest resources and logs for each graphical milestone.

## Debugging boundaries

Debug the base with serial output and guest journals; debug the compositor with
Wayland protocol logs and a disposable user session; debug shell surfaces as an
unprivileged client. Do not run UI as root or weaken Wayland/portal consent to
make a test pass. Reset a VM by discarding its disposable disk and evidence
directory, never by modifying a host installation.
