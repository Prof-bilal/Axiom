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

## Phase 3 graphical session

```sh
# Build the desktop image (official Arch repos only; runs unprivileged).
scripts/build-phase3-iso.sh

# Boot it, wait for the shell, drive input, capture display evidence, power off.
tests/qemu-session.sh iso/out-phase3/<image>.iso

# Fast host-side loop against the shell (needs a headless harness: sway).
tests/phase3-smoke.sh
```

The shell can also be parsed/validated without a compositor:

```sh
QT_QPA_PLATFORM=offscreen qs -p shell   # reports QML errors
```

Evidence (serial log, screenshots, package manifest, checksums) is written to
`iso/out-phase3/evidence/` (gitignored). The ISO builds from
`iso/phase3/pacman.conf` (core/extra only) and stages `shell/` into
`/usr/local/share/axiom/shell`; the profile is never mutated.

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
