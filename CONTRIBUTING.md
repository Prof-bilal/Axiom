# Contributing to Axiom

Thanks for helping build Axiom. This guide covers how to pick something up, how
to get a change merged, and the few rules that are never relaxed.

By taking part you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to help

You don't have to write QML or compositor code to be useful:

- **Test in a VM.** Boot an ISO, try to break something, and file a bug with
  steps to reproduce it. Testing on real hardware is especially valuable
  (Phase 10).
- **Fix a `good first issue`.** These are small and come with the files to look
  at.
- **Shell and apps** (`shell/`, `apps/`): Quickshell/QML and JavaScript.
- **System tooling** (`installer/`, `greeter/`, `provision/`, `tui/`): Python.
- **Testing** (`tests/`): QEMU acceptance suites and unit tests.
- **Design**: icons, layouts and accessibility review against
  [DESIGN](docs/DESIGN.md).
- **Docs and translations**: clearer explanations, and help preparing for
  internationalization (Phase 8).

For anything larger than a bug fix, **open an issue first** so we can agree on
the approach before you spend time on it. Phase gates decide what's in scope,
so look at [PHASES](docs/PHASES.md) for the current phase.

## Set up

Axiom builds on an **Arch Linux** (or Arch-based) host with KVM:

```sh
sudo pacman -S --needed archiso qemu-desktop edk2-ovmf tigervnc python nodejs
git clone https://github.com/<you>/Axiom.git
cd Axiom
```

Fast checks that need no VM and no root:

```sh
python3 scripts/validate-repo.py                      # docs, links, skills, ISO profile
python3 scripts/test-concepts.py
python3 -m unittest discover -s tests/installer -v
node --test tests/apps/*.test.mjs
QT_QPA_PLATFORM=offscreen qs -p shell                 # QML parse check (needs quickshell)
```

Full image loop (about 30 minutes to build):

```sh
scripts/build-phase3-iso.sh
scripts/run-vm.sh iso/out-phase3/axiom-*.iso
```

The QEMU acceptance suites and their options are in [TESTING](docs/TESTING.md).
More build detail is in [DEVELOPMENT](docs/DEVELOPMENT.md) and [BUILD](docs/BUILD.md).

## Making a change

1. **Fork and branch** from `main`. Use a short descriptive branch name, such as
   `fix-trash-restore`.
2. **Keep it small.** One coherent change per pull request. Don't mix in
   unrelated refactors or formatting changes.
3. **Test it.** Run the fast checks above. If you changed what the desktop does
   when it runs, run the matching QEMU suite and say in the PR which suite you
   ran and what it printed. If you can't run QEMU, say so; a maintainer will run
   it.
4. **Update the docs** when behavior or architecture changes. Major technology
   changes (compositor, toolkit, installer engine) need an ADR in
   [docs/decisions/](docs/decisions/) first.
5. **Sign off your commits** (see below) and open the pull request using the
   template.

### Commit messages

Write a short summary line in the imperative mood (`Fix trash restore for
names with newlines`), then a blank line, then why the change was needed if
that isn't obvious.

### Sign-off (DCO)

Axiom uses the [Developer Certificate of Origin](https://developercertificate.org/)
rather than a CLA. You keep the copyright on your work. Signing off certifies
that you wrote the change, or otherwise have the right to submit it under the
project's license. Add the sign-off with `-s`:

```sh
git commit -s -m "Fix trash restore for names with newlines"
```

This adds a line to the commit message:

```text
Signed-off-by: Your Name <you@example.com>
```

## Rules that are never relaxed

These come from [AGENTS.md](AGENTS.md) and the [security contract](docs/SECURITY.md).
A pull request that breaks one of them won't be merged, however useful it is
otherwise.

- **No unrestricted root for AI or UI.** The UI never runs as root. Agents get
  no sudo and no arbitrary shell passthrough.
- **Narrow privileged APIs.** Every privileged operation authorizes the caller,
  the operation and the target separately, and denies when authority is
  missing or invalid.
- **No secrets in the repository or logs.** Passwords and keys never reach log
  files, test output or evidence directories.
- **Don't weaken Wayland or portal consent** to make automation or a test pass.
- **The core desktop works without AI or the network.**
- **No fake UI.** A browser mock, hardcoded desktop state or screenshot can't
  count as a working feature. Graphical features are proven by booting the
  real image.
- **Performance claims need measurements.** Include the numbers and how you
  got them.
- **Reuse mature Linux.** Don't replace the kernel, init, drivers or package
  management without an ADR.

## AI-assisted contributions

Using AI coding tools is fine. You are still the author:

- Read, understand and test everything you submit. "The model wrote it" isn't
  a reason we'll accept for a bug.
- Mention in the PR description that the change was AI-assisted.
- Don't submit generated text, code or images you don't have the right to
  license under Apache-2.0.

Agent workflows used in this repository are described in
[AGENT_WORKFLOW](docs/AGENT_WORKFLOW.md).

## Reporting bugs and requesting features

Use the issue templates. A useful bug report includes the ISO date or commit,
the VM settings or hardware, exact steps, what you expected, and what happened.
Attach the serial log or `journalctl -b` output when you have it, but remove
anything private first.

**Security problems go through [SECURITY.md](SECURITY.md), never a public issue.**

## Licensing of contributions

Axiom is licensed under [Apache-2.0](LICENSE). By submitting a
contribution you agree to license it under those terms, as described in
section 5 of the license. Changes to the archiso-derived files under `iso/`
stay GPL-3.0-or-later, the license marked in their SPDX headers. Third-party code or
assets must have a compatible license and be listed in
[THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md), with their license notices kept.
The Axiom name and logo are covered by [TRADEMARKS](TRADEMARKS.md), not the
code license.

## Getting help

Ask in an issue or a pull request. Questions are welcome; there's no need to
know everything before you start.
