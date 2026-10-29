#!/usr/bin/env python3
"""Static checks for the legacy Phase 1 reviewed archiso profile; does not run mkarchiso.

After the architecture reset this profile is historical Phase 1 evidence. It is still validated
so the retained artifact remains reproducible and its checks do not silently rot.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_KEYS = (
    'iso_name', 'iso_label', 'iso_publisher', 'iso_application',
    'install_dir', 'bootmodes', 'airootfs_image_type',
)
REQUIRED_FILES = (
    'profiledef.sh', 'packages.x86_64', 'pacman.conf',
    'efiboot/loader/loader.conf',
)


def validate(root=ROOT):
    errors = []
    profile = root / 'iso' / 'profile'
    if not profile.is_dir():
        return [f'Missing iso profile directory: iso/profile']

    profiledef = profile / 'profiledef.sh'
    if not profiledef.is_file():
        errors.append('Missing iso/profile/profiledef.sh')
    else:
        text = profiledef.read_text()
        for key in REQUIRED_KEYS:
            if not re.search(rf'^\s*{key}=', text, re.M):
                errors.append(f'profiledef.sh missing key: {key}')
        # archiso derives the target architecture from packages.<arch>; a
        # profiledef 'arch' key is optional but must not contradict x86-64.
        arch_line = re.search(r'^\s*arch=.*$', text, re.M)
        if arch_line and 'x86_64' not in arch_line.group(0):
            errors.append('profiledef.sh declares an arch other than x86_64')
        if 'squashfs' not in text:
            errors.append('profiledef.sh must use a squashfs airootfs image')

    for rel in REQUIRED_FILES:
        if not (profile / rel).is_file():
            errors.append(f'Missing profile file: iso/profile/{rel}')

    packages = profile / 'packages.x86_64'
    if packages.is_file():
        lines = packages.read_text().splitlines()
        entries = [l.strip() for l in lines if l.strip() and not l.strip().startswith('#')]
        if not entries:
            errors.append('packages.x86_64 is empty')
        malformed = [e for e in entries if not re.fullmatch(r'[A-Za-z0-9@._+-]+', e)]
        if malformed:
            errors.append('packages.x86_64 has malformed entries: ' + ', '.join(malformed))

    pacman_conf = profile / 'pacman.conf'
    if pacman_conf.is_file():
        text = pacman_conf.read_text()
        if re.search(r'^\s*SigLevel\s*=\s*Never', text, re.M):
            errors.append('pacman.conf must not disable signature checks (SigLevel = Never)')
        elif not re.search(r'^\s*SigLevel\s*=\s*Required', text, re.M):
            errors.append('pacman.conf must require signatures (SigLevel = Required ...)')
        if not re.search(r'^\s*(?:Server|Include)\s*=', text, re.M):
            errors.append('pacman.conf has no active mirror (Server/Include) lines')

    entries_dir = profile / 'efiboot' / 'loader' / 'entries'
    if entries_dir.is_dir():
        for entry in sorted(entries_dir.glob('*.conf')):
            text = entry.read_text()
            # Kernel boot entries (those loading the ISO) must expose the serial
            # console so the headless QEMU harness can assert boot. Non-kernel
            # entries (e.g. memtest) are exempt.
            if 'archisobasedir' in text and 'console=ttyS0' not in text:
                errors.append(
                    f'{entry.relative_to(root)} kernel entry missing console=ttyS0 for headless test boot')

    for path in sorted(profile.rglob('*')):
        if not path.is_file() or path.stat().st_size > 20000:
            continue
        try:
            text = path.read_text(errors='ignore')
        except OSError:
            continue
        if re.search(r'^\s*(?:TODO|TBD)\s*$', text, re.M):
            errors.append(f'Unfinished scaffold: {path.relative_to(root)}')

    return errors


def main():
    errors = validate()
    for error in errors:
        print(f'ERROR: {error}', file=sys.stderr)
    print(f'ISO profile validation: {len(errors)} error(s). mkarchiso build not performed.')
    return bool(errors)


if __name__ == '__main__':
    sys.exit(main())
