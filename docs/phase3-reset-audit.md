# Phase 3 Reset Audit Report

**Date:** 2026-10-28  
**Status:** PRE-RESET AUDIT  
**Branch:** migration/omarchy-foundation  
**Target:** Complete removal of Phase 3 implementation

---

## Executive Summary

Phase 3 implementation was introduced in commit `f97fa1b` ("Add the Axiom Shell surfaces and owned penguin identity") dated 2026-10-27. This commit added a prototype desktop shell implementation using Quickshell/QML on the Hyprland/Wayland foundation. The implementation includes shell surfaces, window controls, panel/dock components, launcher, Control Center, notifications, and associated branding assets.

**Decision:** The current Phase 3 implementation does not meet Axiom's quality standards. The visual and interaction architecture resembles a prototype/mockup rather than a polished Linux desktop environment. Per user directive, all Phase 3 implementation must be removed and the repository returned to the clean state at commit `8ec7a77` (the last commit before Phase 3 began).

---

## 1. Files Created During Phase 3

### Shell Implementation (`shell/` directory)
- **`shell/shell.qml`** - Main QML shell implementation (36,753 bytes, 1,091 lines)
  - Top bar with workspace chips
  - Floating dock
  - Launcher
  - Control Center
  - Notifications
  - Welcome surface
  - Window actions (close/minimize/maximize)
  - IPC interface (axiom.shell)
  
- **`shell/Theme.qml`** - Semantic color palette and dimensions (1,013 bytes)
  - Defines colors: background, surface, elevated, foreground, muted, accent, selection, border, danger, warning
  - Defines dimensions: panelHeight, dockHeight, target, icon, gap
  - Font family: Liberation Sans

- **`shell/hyprland.lua`** - Hyprland keybinding configuration (305 bytes)
  - Binds SUPER+SPACE to Axiom launcher
  - Example binding for Quickshell IPC

- **`shell/window-actions.py`** - Window control operations (2,679 bytes)
  - Implements: close, maximize, minimize, restore
  - Uses hyprctl dispatchers
  - Validates window addresses before operations
  - Parks minimized windows in special:axiom-minimized workspace

- **`shell/README.md`** - Shell documentation (4,180 bytes)
  - Describes shell features and IPC interface
  - Documents window control behavior
  - Lists check commands

### Test and Validation Scripts (`tests/` directory)
- **`tests/axiom-shell-run.sh`** - Shell loader for test VM (2,691 bytes)
  - Replaces Omarchy Quickshell with Axiom Shell in guest
  - Copies shell sources and mascot assets
  - Manages shell lifecycle

- **`tests/test-window-actions.py`** - Unit tests for window actions (3,152 bytes)
  - Tests: close, maximize, minimize, restore operations
  - Validates address validation and state checks
  - Uses unittest framework with mocks

- **`tests/omarchy-install-axiom-theme.sh`** - Theme installer (2,057 bytes)
  - Installs Axiom theme into Omarchy test guest
  - Optionally replaces SDDM/Plymouth logos with sudo

- **`tests/omarchy-vm-boot.sh`** - VM boot harness (4,922 bytes)
  - Boots pinned Omarchy stable VM image
  - Creates disposable qcow2 overlay
  - Manages SSH and QMP connections

- **`tests/qmp-screenshot.py`** - QMP screenshot utility (pending investigation)

### Branding Assets (`branding/` directory)

#### Identity Assets (`branding/identity/`)
- **`branding/identity/axiom-wordmark.png`** - Wordmark raster (15,607 bytes, 800×188)
- **`branding/identity/axiom-wordmark.svg`** - Wordmark vector (648 bytes)

#### Theme Assets (`branding/theme/axiom/`)
- **`branding/theme/axiom/README.md`** - Theme documentation (709 bytes)
- **`branding/theme/axiom/colors.toml`** - Color palette (657 bytes)
- **`branding/theme/axiom/preview.png`** - Theme preview (184,525 bytes)
- **`branding/theme/axiom/foot.ini`** - Foot terminal config (25 bytes)
- **`branding/theme/axiom/shell.bar.toml`** - Bar config (45 bytes)
- **`branding/theme/axiom/shell.lock.toml`** - Lock screen config (43 bytes)

##### Backgrounds (`branding/theme/axiom/backgrounds/`)
- **`branding/theme/axiom/backgrounds/aurora.png`** - Wallpaper (470,119 bytes, 3840×2160)
- **`branding/theme/axiom/backgrounds/aurora.svg`** - Wallpaper vector (4,500 bytes)

##### Icons (`branding/theme/axiom/icons/`)
- **`branding/theme/axiom/icons/axiom-penguin-64.png`** - Mascot 64×64 (5,362 bytes)
- **`branding/theme/axiom/icons/axiom-penguin.png`** - Mascot (37,739 bytes)
- **`branding/theme/axiom/icons/axiom-penguin.svg`** - Mascot vector (20 bytes)

#### Asset Documentation (`branding/assets/`)
- **`branding/assets/README.md`** - Asset inventory (4,121 bytes)
- **`branding/assets/manifest.json`** - Asset manifest (1,554 bytes)

##### Derived Assets (`branding/assets/derived/`)
- **`branding/assets/derived/axiom-mascot-64.png`** - Cropped mascot (5,864 bytes)
- **`branding/assets/derived/axiom-mascot.png`** - Cropped mascot (59,901 bytes)

##### Screen References (`branding/assets/screens/`)
- **`branding/assets/screens/1a8f995e-ad17-4607-adc5-09c7f560c16b.png`** - Mascot contact sheet (1,536×1024)
- **`branding/assets/screens/about.png`** - About screen reference
- **`branding/assets/screens/control-center-performance.png`** - Control Center reference
- **`branding/assets/screens/desktop-home.png`** - Desktop reference
- **`branding/assets/screens/file-explorer.png`** - File explorer reference
- **`branding/assets/screens/launcher.png`** - Launcher reference
- **`branding/assets/screens/lock-screen.png`** - Lock screen reference
- **`branding/assets/screens/login.png`** - Login reference
- **`branding/assets/screens/notifications.png`** - Notifications reference
- **`branding/assets/screens/session-menu.png`** - Session menu reference
- **`branding/assets/screens/settings.png`** - Settings reference
- **`branding/assets/screens/terminal.png`** - Terminal reference
- **`branding/assets/screens/user-switcher.png`** - User switcher reference

### Documentation
- **`docs/engineering/PHASE3_EVIDENCE.md`** - Phase 3 evidence document (15,861 bytes)
  - Records shell implementation status
  - Documents test environment and findings
  - Contains visual fidelity correction audit
  - Lists screenshots and validation results

### Evidence Screenshots (gitignored)
Under `iso/out/evidence/phase3/`:
- Multiple PNG screenshots documenting shell behavior
- Examples: axiom-shell-first.png, launcher*.png, control-center*.png, notifications*.png, final-*.png, real-desktop-*.png, etc.
- Total: ~20+ screenshot files

---

## 2. Files Modified During Phase 3

### Documentation Updates
- **`docs/PHASES.md`**
  - Updated Phase 3 status from blank to "IN PROGRESS (initial implementation)"
  - Added Phase 3 evidence reference
  - Modified Phase 3 objective and deliverables

- **`docs/engineering/PHASE2_EVIDENCE.md`**
  - Added as part of Phase 3 commit (new file, 142 lines)
  - Records Phase 2 foundation evidence

### Top-Level Files
- **`AGENTS.md`** - Minor updates (2 lines changed)
- **`README.md`** - Minor updates (4 lines changed)

### Scripts
- **`scripts/validate-repo.py`** - Modified (2 lines changed)

---

## 3. Dependencies Added for Phase 3

### Runtime Dependencies
- **Quickshell** v0.3.2.r7 - QML shell toolkit (from Omarchy foundation)
- **Hyprland** v0.56.2 - Wayland compositor (from Omarchy foundation)
- **Qt6** - QML runtime (implicit, from Omarchy)
- **Python 3** - For window-actions.py and test scripts
- **SSH client** - For VM test harness
- **QEMU/KVM** - For VM testing

### Build/Test Dependencies
- **qmllint** - QML linting (from Qt6)
- **hyprctl** - Hyprland control utility

### Note on Dependencies
Most dependencies are inherited from the Omarchy foundation (Phase 2). The Phase 3 shell implementation itself does not introduce new package dependencies beyond what was already pinned in Phase 2. The shell runs as a Quickshell config, which is already part of the foundation.

**Verification needed:** No new package manifests or build files were added specifically for Phase 3. Dependencies are the same as Phase 2.

---

## 4. Config Changes

### Hyprland Configuration
- Added keybinding: SUPER+SPACE → Axiom launcher IPC call
- Binding defined in `shell/hyprland.lua` (intended to be merged into `~/.config/hypr/bindings.lua`)

### Quickshell Configuration
- Shell configuration path: `~/.local/share/axiom/shell`
- IPC socket path: Based on config directory
- Panel and dock configuration via Quickshell plugins

### Theme Configuration
- Axiom theme for Omarchy: `~/.config/omarchy/themes/axiom`
- Contains colors.toml, wallpapers, icons
- Shell-specific configs: shell.bar.toml, shell.lock.toml, foot.ini

---

## 5. Assets Added

### Branding Assets
1. **Mascot assets**: axiom-penguin.svg, axiom-penguin.png, axiom-penguin-64.png
2. **Wordmark assets**: axiom-wordmark.svg, axiom-wordmark.png
3. **Wallpaper**: aurora.svg, aurora.png
4. **Derived assets**: axiom-mascot.png, axiom-mascot-64.png (cropped versions)
5. **Screen references**: 13 reference PNGs for various UI surfaces

### Shell Assets
1. **QML files**: shell.qml, Theme.qml
2. **Lua config**: hyprland.lua
3. **Python scripts**: window-actions.py
4. **Test assets**: test-window-actions.py

---

## 6. Experimental/Prototype Code

### Prototype Status Assessment
The entire Phase 3 implementation is classified as **PROTOTYPE** per user directive. Specific prototype characteristics:

1. **shell.qml**
   - Hardcoded dimensions and positions
   - Placeholder text and labels
   - Simulated status indicators (battery always shows "AC", volume shows 0%)
   - Development state indicators in Control Center
   - No real AI/Shield/Flow backend integration

2. **Window Controls**
   - Custom minimize implementation using Hyprland special workspace
   - Not standard Wayland/CSD behavior
   - Experimental park/restore mechanism

3. **Launcher**
   - Basic app search using desktop entries
   - No category filtering
   - No recent/most-used sorting
   - Keyboard navigation: Up/Down/Enter (basic)

4. **Control Center**
   - Reads real /proc metrics (load, memory, PSI)
   - Placeholder sections for AI/Shield/Flow (labeled "not connected/not active/not measuring")
   - No actual functionality for these sections

5. **Notifications**
   - Basic toast notifications
   - No action buttons
   - No persistence
   - No keyboard dismissal

6. **Dock**
   - Shows installed app icons
   - No app launching from dock
   - Running indicators (dots)
   - Static app list

7. **Panel**
   - Workspace chips
   - Status icons (network, audio, battery, clock)
   - Window title display
   - Window action buttons (close, minimize, maximize)

### Test Infrastructure
- Disposable VM test harness
- Screenshot capture utilities
- IPC validation scripts
- Window action contract tests

---

## 7. Files Shared with Phase 1 or Phase 2 - MUST NOT DELETE

### Phase 1 Files (Must Preserve)
- **`iso/`** directory - Phase 1 archiso profile and build artifacts
  - Legacy evidence retained
  - build-iso.sh and related scripts
  
- **`tests/qemu-boot.sh`** - Phase 1 QEMU boot harness
  - Pre-dates Phase 3
  - Used for Phase 1 validation

- **`scripts/build-iso.sh`** - Phase 1 ISO build script
- **`scripts/check-iso-profile.py`** - Phase 1 profile checker
- **`docs/engineering/PHASE1_EVIDENCE.md`** - Phase 1 evidence
- **`docs/engineering/FOUNDATION_VALIDATION.md`** - Phase 0/1 validation

### Phase 2 Files (Must Preserve)
- **`docs/engineering/OMARCHY_MIGRATION.md`** - Migration report
- **`docs/DECISIONS.md`** - Contains ADR-013 (Omarchy foundation decision)
- **`docs/ARCHITECTURE.md`** - Updated for Omarchy foundation
- **`docs/TECH_STACK.md`** - Updated for Omarchy foundation
- **`.agents/skills/omarchy-upstream/SKILL.md`** - New skill for upstream tracking
- **`.agents/skills/quickshell-ui/SKILL.md`** - New skill for Quickshell UI
- **`THIRD_PARTY_NOTICES.md`** - Third-party license notices

### Core Architecture Files (Must Preserve)
- **`AGENTS.md`** - Agent instructions (modified but must keep)
- **`README.md`** - Project README (modified but must keep)
- **`scripts/validate-repo.py`** - Repository validator (modified, restore pre-Phase-3)
- **`scripts/install-skills.py`** - Skill installation
- **`scripts/readiness-audit.py`** - Readiness audit

### Skills Directory
- **`.agents/skills/`** - All skills except quickshell-ui and omarchy-upstream are pre-Phase-3
- Note: omarchy-upstream and quickshell-ui skills were added in commit 8ec7a77 as part of Phase 2 migration

---

## 8. Recommended Deletion/Revert Plan

### Step 1: Delete Phase 3 Implementation Files

**Complete deletion (not revert):**
```bash
# Shell implementation
rm -rf shell/

# Phase 3 test scripts
rm -f tests/axiom-shell-run.sh
rm -f tests/omarchy-install-axiom-theme.sh
rm -f tests/omarchy-vm-boot.sh
rm -f tests/qmp-screenshot.py
rm -f tests/test-window-actions.py

# Branding assets (all were added in Phase 3)
rm -rf branding/

# Phase 3 evidence
rm -f docs/engineering/PHASE3_EVIDENCE.md
```

### Step 2: Revert Modified Files

**Revert to commit 8ec7a77:**
```bash
# Documentation
git checkout 8ec7a77 -- docs/PHASES.md

# Top-level files
git checkout 8ec7a77 -- AGENTS.md
git checkout 8ec7a77 -- README.md

# Scripts
git checkout 8ec7a77 -- scripts/validate-repo.py

# Phase 2 evidence (added in Phase 3 commit but is Phase 2 related)
# This should be kept as it documents Phase 2, not Phase 3
git checkout 8ec7a77 -- docs/engineering/PHASE2_EVIDENCE.md
```

**Note:** The files `docs/engineering/PHASE2_EVIDENCE.md` and the modified `docs/PHASES.md` need careful handling. The PHASE2_EVIDENCE.md was created in the Phase 3 commit but documents Phase 2. Decision: **KEEP PHASE2_EVIDENCE.md** as it belongs to Phase 2, but update PHASES.md to remove Phase 3 claims.

### Step 3: Clean Untracked Files

```bash
# Untracked Phase 3 files
rm -rf branding/assets/derived/
rm -rf branding/assets/screens/
rm -f shell/Theme.qml
rm -f shell/window-actions.py
rm -f tests/test-window-actions.py

# Pycache cleanup
rm -rf shell/__pycache__
rm -rf tests/__pycache__
```

### Step 4: Clean Evidence Screenshots

```bash
rm -rf iso/out/evidence/phase3/
```

### Step 5: Update Documentation

**Modify PHASES.md:**
- Change Phase 3 status from "IN PROGRESS (initial implementation)" to "RESET — awaiting redesign"
- Update Phase 3 description to reflect reset state
- Add note: "The original Phase 3 desktop shell implementation was removed because the visual and interaction architecture did not meet the intended Axiom desktop quality. Phase 3 will restart from a new shell specification."

**Remove PHASE3_EVIDENCE.md:**
- This file specifically documents the removed implementation
- Should be deleted, not kept

**Note:** `docs/engineering/PHASE2_EVIDENCE.md` should be **KEPT** as it documents Phase 2 foundation, which is still valid.

### Step 6: Verify No Phase 3 References

Search for and remove any remaining references:
- "Phase 3" in documentation (except in PHASES.md status and historical context)
- "axiom.shell" IPC references
- Shell-specific configuration paths

### Step 7: Update Git

```bash
# After deletion, commit the reset
git add -A
git commit -m "RESET Phase 3: Remove prototype shell implementation

Generated by Mistral Vibe.
Co-Authored-By: Mistral Vibe <vibe@mistral.ai>"
```

---

## 9. Protection Checklist

### Files to PROTECT (Do NOT delete)

✅ **Phase 1:**
- [ ] `iso/` directory (archiso profile)
- [ ] `tests/qemu-boot.sh`
- [ ] `scripts/build-iso.sh`
- [ ] `scripts/check-iso-profile.py`
- [ ] `docs/engineering/PHASE1_EVIDENCE.md`
- [ ] `docs/engineering/FOUNDATION_VALIDATION.md`

✅ **Phase 2:**
- [ ] `docs/engineering/OMARCHY_MIGRATION.md`
- [ ] `docs/DECISIONS.md` (with ADR-013)
- [ ] `docs/ARCHITECTURE.md`
- [ ] `docs/TECH_STACK.md`
- [ ] `.agents/skills/omarchy-upstream/SKILL.md`
- [ ] `.agents/skills/quickshell-ui/SKILL.md`
- [ ] `THIRD_PARTY_NOTICES.md`
- [ ] `docs/engineering/PHASE2_EVIDENCE.md` (created in Phase 3 commit but documents Phase 2)

✅ **Core Architecture:**
- [ ] `AGENTS.md` (revert modifications)
- [ ] `README.md` (revert modifications)
- [ ] `scripts/validate-repo.py` (revert modifications)
- [ ] `scripts/install-skills.py`
- [ ] `scripts/readiness-audit.py`
- [ ] All other `.agents/skills/` except omarchy-upstream and quickshell-ui

✅ **Boot/System Configuration:**
- [ ] All Phase 1 and Phase 2 system configs

✅ **Existing Branding:**
- [ ] No pre-Phase-3 branding exists (branding/ was created in Phase 3)

✅ **Existing Official Assets:**
- [ ] No pre-Phase-3 official assets exist

✅ **Documentation Unrelated to Phase 3:**
- [ ] All Phase 0, 1, 2 docs
- [ ] All security docs
- [ ] All AI/agent docs
- [ ] All system docs

---

## 10. File Classification Summary

### DELETE Completely (Phase 3 Only)
| Category | Files/Directories | Count |
|----------|------------------|-------|
| Shell Implementation | shell/ (all files) | 5 |
| Phase 3 Tests | tests/axiom-shell-run.sh, tests/omarchy-*.sh, tests/qmp-screenshot.py, tests/test-window-actions.py | 5 |
| Branding | branding/ (all files and subdirectories) | 25+ |
| Phase 3 Evidence | docs/engineering/PHASE3_EVIDENCE.md | 1 |
| Evidence Screenshots | iso/out/evidence/phase3/ | 20+ |
| **Total** | | **55+** |

### REVERT to Pre-Phase-3 State
| File | Action | Pre-Phase-3 Commit |
|------|--------|-------------------|
| docs/PHASES.md | Revert | 8ec7a77 |
| AGENTS.md | Revert | 8ec7a77 |
| README.md | Revert | 8ec7a77 |
| scripts/validate-repo.py | Revert | 8ec7a77 |

### KEEP (Not Phase 3 Specific)
| File | Reason |
|------|--------|
| docs/engineering/PHASE2_EVIDENCE.md | Documents Phase 2 foundation |
| .agents/skills/omarchy-upstream/SKILL.md | Phase 2 migration skill |
| .agents/skills/quickshell-ui/SKILL.md | Phase 2 migration skill |
| All Phase 0, 1, 2 files | Belong to earlier phases |

---

## 11. Validation Plan

After reset, verify:

1. **Git History**
   - [ ] Commit history shows clean removal
   - [ ] No Phase 3 implementation files remain
   - [ ] Phase 1 and Phase 2 files intact

2. **Build System**
   - [ ] `scripts/validate-repo.py` runs without errors
   - [ ] All validation checks pass

3. **Documentation**
   - [ ] PHASES.md correctly shows Phase 3 as RESET
   - [ ] No broken links to removed Phase 3 files
   - [ ] All Phase 1 and Phase 2 documentation intact

4. **File System**
   - [ ] No references to `shell/` directory
   - [ ] No references to `branding/` directory
   - [ ] No references to removed test scripts
   - [ ] No pycache from removed files

5. **Phase 1 Validation**
   - [ ] Phase 1 archiso profile still valid
   - [ ] Build scripts still functional
   - [ ] QEMU boot harness still valid

6. **Phase 2 Validation**
   - [ ] Omarchy migration docs intact
   - [ ] ADR-013 intact
   - [ ] All Phase 2 skills intact

---

## 12. Risk Assessment

### High Risk Items
- **Branding directory**: Entirely Phase 3, safe to delete
- **Shell directory**: Entirely Phase 3, safe to delete
- **Phase 3 test scripts**: Entirely Phase 3, safe to delete

### Medium Risk Items
- **PHASES.md**: Must be carefully edited, not deleted
- **AGENTS.md, README.md**: Modified in Phase 3, must revert changes
- **scripts/validate-repo.py**: Modified in Phase 3, must revert changes

### Low Risk Items
- **PHASE3_EVIDENCE.md**: Can be safely deleted
- **PHASE2_EVIDENCE.md**: Should be kept (Phase 2 documentation)

### No Risk Items
- All Phase 0, 1 files: Protected
- All Phase 2 core files: Protected
- All skills except omarchy-upstream and quickshell-ui: Protected

---

## 13. Post-Reset State

After completing the reset, the repository will be in state equivalent to commit `8ec7a77` plus:

1. **PHASES.md** will have Phase 3 marked as "RESET — awaiting redesign" with explanatory note
2. **Phase 2 evidence** will remain documented
3. **No Phase 3 implementation** code or assets will exist
4. **All Phase 1 and Phase 2** artifacts will be intact
5. **Git history** will show clean removal via commit

---

## 14. Next Steps

After reset completion:
1. Mark Phase 3 as RESET in documentation
2. Document new Phase 3 direction (macOS-inspired UX research)
3. Do NOT start implementation until design is complete
4. Record ADR for new Phase 3 approach

---

*Report generated: 2026-10-28*  
*Status: Ready for reset execution*
