## What and why

<!-- What does this change, and what problem does it solve? Link the issue: Fixes #123 -->

## How it was tested

<!-- Commands you ran and their result, e.g. `python3 -m unittest discover -s tests/installer`.
For runtime changes, name the QEMU suite you ran (tests/phase*-*.py) or say you couldn't run it. -->

## Checklist

- [ ] Commits are signed off (`git commit -s`)
- [ ] `python3 scripts/validate-repo.py` passes
- [ ] Docs or an ADR are updated if behavior or architecture changed
- [ ] No UI or agent code runs as root; privileged paths check the caller, the operation and the target
- [ ] No secrets in code, logs or test evidence
- [ ] AI-assisted: yes / no
