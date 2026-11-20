# Handoff: installer pick-lists (Phase 6 polish, Part A)

## Goal
In the installer's "Language and time" step, Language, Keyboard and Time zone must be
pick-lists changed with Left/Right arrows. No typing. Graphical login is NOT in scope.

## Owned files (edit only these)
- `installer/axiom-installer` (step 1 fields in `start_setup()`, around lines 306-320)
- `tests/installer/` and `tests/phase6-install.py` (only if they type into these fields)

Do not touch `greeter/`, `shell/`, `iso/`, `docs/decisions/`, or `installer/axiom_install.py`
except to read it. If you need another file, stop and report it.

## What to change
1. Language: `kind: "choice"`, curated list of UTF-8 locales, for example
   en_US, en_GB, de_DE, fr_FR, es_ES, it_IT, pt_BR, nl_NL, pl_PL, ru_RU, tr_TR, ja_JP, zh_CN.
   Default `en_US`.
2. Keyboard: `kind: "choice"`, curated list, for example us, uk, de, fr, es, it, br-abnt2.
   Default `us`.
3. Time zone: two choice fields, Region then City. City `choices` are rebuilt when Region
   changes, using the existing `on_change` hook in `form()`. Source:
   `timedatectl list-timezones`, grouped by the first path segment. Default from
   `AXIOM_TZ` (fallback `UTC`).
4. Keep the existing `form()` choice behaviour: Left/Right cycles, and it does not accept typed text.
5. Update the step hint text to say "Left/Right change" instead of implying typing.
6. Do not weaken `validate_form` in `axiom_install.py`. Choices narrow input; validation stays.

## Acceptance criteria
- Pressing letters on these three rows changes nothing.
- Left/Right changes each value; Region change updates the City list.
- Defaults still match the old values (`en_US`, `us`, `UTC`).
- Existing installer tests still pass; any test that typed into these fields is updated.

## Tests (run from repo root; all must pass before reporting done)
- `python3 scripts/validate-repo.py`
- `python -m pytest -q`
- Add one small test for the choice cycling and Region-to-City rebuild, using the
  existing test style in `tests/installer/`.

## Report back with
- `git diff --stat` and the full diff of the owned files.
- The full output of both test commands.
- Anything you could not verify, stated plainly.
Do not commit.
