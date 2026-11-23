# 02 - Git management (Agent 2), 2026-11-23

## Commit and push
- Branch: `phase7-installer-hub-rollback`, commit `1c1361341f2b43e8a6c50cc25f98b3e0dbdf91d4` (113 files, +1990/-977), pushed non-force; `git ls-remote` SHA == local SHA. Upstream set.
- Staged: all tracked modifications (`git add -u`), staged deletions (PromptDialog.qml, ControlCenter.qml), and new project files: `apps/files/InlineName.qml`, `shell/src/dock/magnify.js`, `shell/src/status/*`, `tests/shell/dock-magnify.test.mjs`, `iso/phase3/airootfs/usr/share/icons/default/index.theme`. docs/PHASES.md was committed as modified at that moment.
- Excluded (still untracked/unstaged): `reports/` (audit), `-boot` (empty junk file), `.shiki/` (572M, worktrees), `iso/qa-*`, `iso/diag-installer*`, `iso/manual-run`, `iso/phase3-hyprtest`, `iso/*.log` (QEMU run artifacts, ~3.3G incl. 2.8G `qa-phase7-install10`), and the unstaged deletion of `.contextgit/context.md` (ContextGit managed state; the tracked file contains only the managed block, and deleting it is a tool/user decision). No secrets found (only the documented VM test password default in a test script). No .gitignore changes made.
- Recommended .gitignore additions (needs approval): `iso/qa-*/`, `iso/diag-*`, `iso/manual-run/`, `iso/phase3-hyprtest/`, `iso/*.log`, `.shiki/`, `/-boot`.
- Side effect to know: `scripts/test-concepts.py` copies the whole worktree to /tmp, so the 3 GB untracked iso dirs make it fail with "Disk quota exceeded". I removed the leftover temp copies. Clear/ignore those dirs before running it.

## CI (GitHub Actions `foundation-validation`, `.github/workflows/validate.yml`)
`gh` hangs in this sandbox, so results come from the public REST API. 67 runs total.
- Run 67 (1c13613), 66 (6a613f8), 65 (ef93734), 64 (login-tui-penguin 67d20fe): **failure**. Failing step: "Foundation validation" (`validate-repo.py`); concept and ISO steps skipped. Cause (reproduced locally): 4 broken links from `docs/LANDING_PAGE_DESIGN.md` to `branding/landing-concepts/*.png`. origin/main (run 63, ab5a299, "Clean repository for open-source contributors") removes this check/files and passes, so phase7 is red because it is based on pre-cleanup main 91d7b3b.
- Local: validate-repo 4 errors; check-iso-profile 0 errors; test-concepts 3 failures/errors (1 real = same broken-link test, 2 from disk quota above).
- Runs 56-63 on other branches/main: success.
- Open PRs/releases: could not query (gh hangs); no tags exist locally.

## Branch inventory
Local main is 91d7b3b, behind origin/main (ab5a299, 1 commit, a cleanup touching 48 files, 50+/852-). Ahead/behind below is vs origin/main (the real main), plus vs phase7.

| Branch | SHA | Ahead/behind origin/main | vs phase7 (ahead/behind) | Class |
|---|---|---|---|---|
| origin/main | ab5a299 | 0/0 | 1 ahead of phase7's base | 1 |
| main (local) | 91d7b3b | 0/1 | | 3 (fast-forward only) |
| phase7-installer-hub-rollback (current) | 1c13613 | 65/1 | - | 1 / 2 |
| login-tui-penguin (local) | 3756038 | 62/1 | 0/3 behind | 3 (fully in phase7) |
| origin/login-tui-penguin | 67d20fe | 62/1 | 0 unique | 3; local copy "ahead 51" of remote, all in phase7 |
| worktree-ui-glass-restyle (worktree) | e038afa | 20/1 | 11 unique, 56 behind | 5 (glass restyle incl. terminal; overlaps phase7 UI, likely superseded; conflicts in hub/appinstaller) |
| claude/festive-kapitsa-cc5d7e (+origin) | 281f810 | 9/1 | 0 unique | 3 |
| claude/axiom-ui-update-plan-feba12 (+origin) | 14120ac | 4/1 | 0 unique | 3 |
| phase-7 (local, worktree) / origin/phase-7 | e4f669c / bf77105 | 1/1, 3/1 | 0 unique | 3 |
| claude/handoff-missing-assets-audit-bca728 | 91d7b3b | 0/1 | 0 | 4 (== old main) |
| claude/student-funding-eligibility-eb8c56 (worktree) | 91d7b3b | 0/1 | 0 | 4 (== old main; used by phase-7 worktree dir, check) |
| frontend (local, worktree .shiki/phase6) | 91d7b3b | 0/1 | 0 | 4 local; origin/frontend f5fade2 is 12 ahead of old main (landing-page README), 5 manual review; local is "ahead 12" lines in tracking = behind origin |
| license-and-community (+origin) | f836c5f | 16 commits behind main side, 0 unique | 0 | 3 (ancestor of main) |
| phase6 (+origin), changehero (+origin, worktree) | 0150c22, f2d525f | 0 unique | 0 | 3 (ancestors of main) |
| axiom (local) / origin/axiom | c9e924d / bc57348 | 0 unique vs main | 0 | 3 for history; local axiom is 1 ahead of origin/axiom (Jarvis research commit) -> 5: check whether it is on any branch, then push to `research` |
| origin/omarchy, origin/migration/omarchy-foundation | 880d385, b2354d0 | 0 unique | 0 | 3/4 (obsolete reset history, ancestors of main) |

Exact columns: "0 unique" means `git rev-list --count branch ^phase7` / `^origin/main` is 0 unless a number is shown. Local `axiom` c9e924d unique commit vs origin/axiom: 1. Worktrees in use: .claude/worktrees/{ui-glass-restyle, festive-kapitsa-cc5d7e, axiom-ui-update-plan-feba12, student-funding-eligibility-eb8c56}, .shiki/worktrees/{phase6, changehero}; these block branch deletion until removed.

## Long-term branches created
`phases`, `research`, `mergebeforemain` created from `origin/main` (ab5a299: the current published main, so they do not start behind it), pushed to origin non-force, upstream set. No name/prefix conflicts (checked local+remote for `phases*`, `research*`, `mergebefore*`). Remote SHAs verified == ab5a299. I stayed on phase7 throughout.

## Integration plan for main
1. Merge origin/main into phase7 (or rebase-free merge on `mergebeforemain`): dry-run `git merge-tree` reports exactly 2 conflicts: `.gitignore` and `docs/PHASES.md`. Resolve by keeping both ignore sets and PHASES.md phase-7 content (coordinate with agent 4's PHASES edit).
2. Fix remaining CI cause: after merge, rerun `validate-repo.py`, `test-concepts.py` (with iso run dirs ignored), `check-iso-profile.py`; expect green as main is.
3. Stage via `mergebeforemain`: merge phase7 into it, run CI, then fast-forward/PR into main. Preserve all 65 phase7 commits (merge commit, no squash) since they include Phase 7 installer/Hub/rollback ADRs.
4. Superseded branches (login-tui-penguin, festive-kapitsa, axiom-ui-update-plan, phase-7) are contained in phase7, so no separate merges are needed. `worktree-ui-glass-restyle` (11 unique commits, many conflicts with phase7 hub/appinstaller) needs a human decision before any merge; do not merge.
5. Required tests: validate-repo, test-concepts, check-iso-profile, QML/JS tests under tests/, and the Phase 7 QEMU evidence per AGENTS.md before main.
6. Renames suggested: `phase7-installer-hub-rollback` -> keep; `worktree-ui-glass-restyle` -> `archive/ui-glass-restyle`; `axiom` -> `research` content (Jarvis docs) or `archive/jarvis-research`; old `claude/*` -> `archive/*`. Safe deletions only after approval and after removing worktrees: class 3/4 branches above.

## Open decisions needing approval
1. Add the .gitignore entries above and decide on `.contextgit/context.md` deletion (restore or commit deletion).
2. Fast-forward local `main` to origin/main.
3. Disposition of `worktree-ui-glass-restyle` (11 unique commits) and local `axiom` (1 unpushed commit); push `axiom` work to `research`?
4. Archiving/deleting class 3/4 branches and removing the six worktrees.
5. Merge of origin/main into phase7 (2 conflicts) to turn CI green.
6. `gh` hangs here; confirm open PRs manually.
