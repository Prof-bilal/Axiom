#!/usr/bin/env python3
"""Dependency-free foundation checks; does not claim runtime/ISO validation."""
from pathlib import Path
import re
import runpy
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = '''VISION PRD MVP ARCHITECTURE TECH_STACK ROADMAP PHASES SUBAGENTS AGENT_WORKFLOW DECISIONS RESEARCH'''.split()
GROUPS = {
    'desktop': 'DESKTOP_UX DESIGN_SYSTEM WAYLAND',
    'ai': 'AI_ARCHITECTURE AGENT_SYSTEM SYSTEM_AGENT_API MODEL_ROUTER ECOSYSTEM ROUTINES MCP',
    'security': 'SECURITY THREAT_MODEL PERMISSIONS SANDBOXING WARDEN_INTEGRATION',
    'system': 'PERFORMANCE FLOW BTRFS_ROLLBACK SYSTEMD PACKAGING',
    'connect': 'CONNECT ANDROID CROSS_DEVICE',
    'engineering': 'TESTING BENCHMARKS ISO_BUILD INSTALLER RELEASE ECOSYSTEM_PLAN OMARCHY_MIGRATION FOUNDATION_VALIDATION PHASE1_EVIDENCE DEV_ENVIRONMENTS INSTALL_CHECKLIST',
}
SKILLS = set('archiso-build arch-pkgbuild quickshell-ui wayland-integration rust-daemon dbus-service systemd-service agent-system-api threat-model security-review warden-policy btrfs-transaction performance-benchmark qemu-integration-test mcp-tool provider-adapter android-connect release-check omarchy-upstream'.split())

def validate(root):
    errors = []
    required = ['README.md', 'AGENTS.md', 'THIRD_PARTY_NOTICES.md'] + [f'docs/{name}.md' for name in REQUIRED]
    required += [f'docs/{group}/{name}.md' for group, names in GROUPS.items() for name in names.split()]
    for item in required:
        path = root / item
        if not path.is_file() or len(path.read_text().strip()) < 200:
            errors.append(f'Missing or insubstantial required document: {item}')
    paths = list((root / 'docs').rglob('*.md')) + [root / 'README.md', root / 'AGENTS.md']
    for base in ('portable-skills/skills', '.agents/skills', '.opencode/agents', '.commandcode/agents'):
        folder = root / base
        if folder.exists():
            paths += list(folder.rglob('*.md'))
    for path in paths:
        text = path.read_text()
        for target in re.findall(r'(?<!!)\[[^\]]+\]\(([^)]+)\)', text):
            target = target.strip('<>').split('#', 1)[0]
            if not target or re.match(r'^[a-zA-Z][a-zA-Z0-9+.-]*:', target):
                continue
            if not (path.parent / target).exists():
                errors.append(f'Broken local link: {path.relative_to(root)} -> {target}')
        if re.search(r'^\s*(?:TODO|TBD)\s*$', text, re.M):
            errors.append(f'Unfinished scaffold: {path.relative_to(root)}')
    if not any((root / base).is_dir() for base in ('portable-skills/skills', '.agents/skills')):
        errors.append('No portable skill inventory exists in staging or canonical location')
    for base in ('portable-skills/skills', '.agents/skills'):
        folder = root / base
        if not folder.exists():
            if base == '.agents/skills':
                print('NOTICE: canonical skills not installed; read-only mount constraint documented.')
            continue
        found = {p.parent.name for p in folder.glob('*/SKILL.md')}
        if found != SKILLS:
            errors.append(f'Skill inventory mismatch: {base}: {found ^ SKILLS}')
        for path in folder.glob('*/SKILL.md'):
            text = path.read_text()
            match = re.match(r'^---\n(.*?)\n---\n', text, re.S)
            if not match:
                errors.append(f'Missing frontmatter: {path}')
                continue
            fields = dict(re.findall(r'^(name|description):\s*(.+)$', match[1], re.M))
            if fields.get('name') != path.parent.name or not fields.get('description'):
                errors.append(f'Invalid skill name/description: {path}')
            if len(fields.get('name','')) > 64 or len(fields.get('description','')) > 1024:
                errors.append(f'Skill metadata too long: {path}')
    for folder, expected in (('.opencode/agents',11),('.commandcode/agents',6)):
        adapters = list((root / folder).glob('*.md'))
        if len(adapters) != expected:
            errors.append(f'Adapter inventory mismatch: {folder}')
        for path in adapters:
            if 'docs/SUBAGENTS.md' not in path.read_text():
                errors.append(f'Adapter lacks canonical role reference: {path}')
    phase1 = ('iso/profile/profiledef.sh', 'scripts/build-iso.sh',
              'scripts/check-iso-profile.py', 'tests/qemu-boot.sh',
              '.github/workflows/validate.yml',
              'docs/engineering/PHASE0_EVIDENCE.json',
              'docs/engineering/PHASE1_EVIDENCE.md')
    for item in phase1:
        if not (root / item).is_file():
            errors.append(f'Missing Phase 1 artifact: {item}')
    if (root / 'iso/profile').is_dir():
        module = runpy.run_path(str(root / 'scripts' / 'check-iso-profile.py'),
                                run_name='iso_profile_check')
        errors += module['validate'](root)
    return errors

if __name__ == '__main__':
    errors = validate(ROOT)
    for error in errors:
        print(f'ERROR: {error}', file=sys.stderr)
    print(f'Foundation validation: {len(errors)} error(s). Runtime/tool discovery/OS tests not performed.')
    sys.exit(bool(errors))
