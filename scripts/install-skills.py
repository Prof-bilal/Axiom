#!/usr/bin/env python3
"""Install reviewed staged skills into the canonical repository location."""
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'portable-skills' / 'skills'
TARGET = ROOT / '.agents' / 'skills'

def main():
    sources = sorted(SOURCE.glob('*/SKILL.md'))
    if len(sources) != 18:
        raise ValueError('Expected 18 reviewed staged skills; validate source before installation')
    # Preflight all conflicts before changing anything. Never overwrite local edits.
    for source in sources:
        dest = TARGET / source.parent.name / 'SKILL.md'
        if dest.is_symlink() or any(p.is_symlink() for p in (TARGET.parent, TARGET, dest.parent)):
            raise ValueError(f'Refusing symlink destination: {dest}')
        if dest.exists() and dest.read_bytes() != source.read_bytes():
            raise ValueError(f'Existing skill differs; reconcile manually: {dest}')
    TARGET.mkdir(parents=True, exist_ok=True)
    for source in sources:
        dest = TARGET / source.parent.name / 'SKILL.md'
        dest.parent.mkdir(exist_ok=True)
        if not dest.exists():
            with dest.open('xb') as output:
                output.write(source.read_bytes())
    print(f'Installed/verified {len(sources)} skills in {TARGET}')

if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError) as exc:
        print(f'Skill installation incomplete: {exc}. Staged sources preserved.', file=sys.stderr)
        sys.exit(1)
