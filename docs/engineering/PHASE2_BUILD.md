# Phase 2 foundation build

The Axiom-owned build entry point is [`scripts/build-phase2-foundation.sh`](../../scripts/build-phase2-foundation.sh).
It stages pinned upstream checkouts into an ignored work directory, applies only
the compatibility changes listed in the build output, and invokes the pinned
`ghcr.io/omacom/omarchy-iso` builder without editing either upstream checkout.

## Pinned inputs

- Omarchy `v4.0.6`: `237f1b4071a0bff2296c6d740ba2b9fd695ebfa0`
- `omarchy-iso` `main`: `3c36557fd58fe8dcd963f47eb9145f48a543a658`
- archiso submodule: `424e78130db2af6c1ceb55b442d7914b1109ff2b`
- Builder image: `ghcr.io/omacom/omarchy-iso@sha256:e82623936fa1a69700b48e98b058df6eaab18b737c27473a7234a40fdecb9413`

The wrapper records these revisions, the builder digest, the package input
filters, and the resulting ISO checksum under `iso/out/phase2/current/`.
Those outputs are intentionally gitignored; retain them with the release
evidence bundle rather than committing multi-gigabyte artifacts.

For offline/reproducible rebuilds, set `AXIOM_NODE_TARBALL` to an absolute
Node.js Linux x64 tarball. If omitted, the wrapper reuses
`iso/out/phase2/cache/node-v26.12.1-linux-x64.tar.gz` when present, verifies it
with SHA-256, and records the path and digest in `inputs.txt`. Without a cache,
the staged upstream builder falls back to its network download.

## Foundation scope

The Phase 2 image contains the generic QEMU foundation: Hyprland, Quickshell,
SDDM, NetworkManager, PipeWire/WirePlumber, Snapper, Limine and the pinned
`linux-omarchy` kernel. Optional vendor packages are excluded when the pinned
rolling repositories do not provide them; the exclusion is recorded in
`compatibility-adjustments.txt`.

The staged profile changes only visible product identity and the shell launch
boundary. Internal `/usr/share/omarchy` compatibility paths remain until the
Axiom Shell migration replaces them. This keeps upstream runtime assumptions
isolated from the Axiom-visible session name, boot labels and launcher.

## Validation recipe

1. Run `bash scripts/build-phase2-foundation.sh` on an Arch host with Docker,
   `/dev/kvm`, QEMU and OVMF available.
2. Check `iso.sha256`, `inputs.txt`, `build.log` and
   `iso-identity-paths.txt`.
3. Boot the exact ISO in disposable QEMU. The live root must report
   `IMAGE_ID=axiom`, mount `AXIOM_202610`, expose the Axiom shell payload and
   reach the serial login without unexpected Docker/UFW listeners.
4. Install the foundation package set into a disposable target disk and check
   the installed root for Axiom `os-release`, the `linux-omarchy` Limine
   artifacts, enabled NetworkManager/systemd-resolved/SDDM, the Axiom session
   entry and the `axiom-shell-launch` Hyprland autostart.

The current disposable target used a 32 GiB qcow2 because the 16 GiB fixture
was too small for the rolling firmware transaction. The target is not a release
installer claim: the pinned Omarchy revision is ISO-only and its legacy
automated script still references removed `install.sh`/`install/helpers/all.sh`.
That boundary is retained as a migration finding for the later installer phase.
