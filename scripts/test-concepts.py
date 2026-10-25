#!/usr/bin/env python3
"""Non-destructive local concept checks. No stress, system writes or network access."""
import argparse
from contextlib import redirect_stdout
from datetime import datetime, timezone
import hashlib
import io
import json
import os
from pathlib import Path
import re
import runpy
import shutil
import socket
import sqlite3
import struct
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def load_script(name):
    return runpy.run_path(str(ROOT / 'scripts' / name), run_name='concept_check_module')


class Foundation(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='axiom-concepts-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def fixture(self):
        for folder in ('docs', 'portable-skills', '.opencode', '.commandcode',
                       'scripts', 'iso', 'tests', '.github'):
            if (ROOT / folder).exists():
                # iso/ holds multi-GB build output; copy only the reviewed profile.
                ignore = shutil.ignore_patterns('work*', 'out', '*.iso') if folder == 'iso' else None
                shutil.copytree(ROOT / folder, self.root / folder, symlinks=True,
                                ignore_dangling_symlinks=True, ignore=ignore)
        for file in ('README.md', 'AGENTS.md'):
            shutil.copyfile(ROOT / file, self.root / file)

    def validate(self, root):
        with redirect_stdout(io.StringIO()):
            return load_script('validate-repo.py')['validate'](root)

    def install(self):
        module = load_script('install-skills.py')
        function = module['main']
        function.__globals__.update(ROOT=self.root,
            SOURCE=self.root / 'portable-skills/skills',
            TARGET=self.root / '.agents/skills')
        with redirect_stdout(io.StringIO()):
            function()

    def test_repository_contract_inventory_and_links(self):
        self.assertEqual(self.validate(ROOT), [])

    def test_validator_rejects_broken_local_link(self):
        self.fixture()
        file = self.root / 'docs/VISION.md'
        file.write_text(file.read_text() + '\n[missing](missing-concept.md)\n')
        self.assertTrue(any('Broken local link' in e for e in self.validate(self.root)))

    def test_validator_rejects_missing_skill_inventory(self):
        self.fixture()
        shutil.rmtree(self.root / 'portable-skills')
        self.assertTrue(any('No portable skill inventory' in e for e in self.validate(self.root)))

    def test_skill_installation_is_complete_and_idempotent(self):
        shutil.copytree(ROOT / 'portable-skills', self.root / 'portable-skills')
        self.install()
        before = {p.relative_to(self.root): p.read_bytes()
                  for p in (self.root / '.agents/skills').glob('*/SKILL.md')}
        self.assertEqual(len(before), 18)
        self.install()
        self.assertEqual(before, {p: (self.root / p).read_bytes() for p in before})

    def test_skill_conflict_rejected_before_other_copies(self):
        shutil.copytree(ROOT / 'portable-skills', self.root / 'portable-skills')
        target = self.root / '.agents/skills/warden-policy/SKILL.md'
        target.parent.mkdir(parents=True)
        target.write_text('operator-owned change\n')
        with self.assertRaises(ValueError):
            self.install()
        self.assertEqual(target.read_text(), 'operator-owned change\n')
        self.assertEqual(len(list((self.root / '.agents').rglob('SKILL.md'))), 1)

    def test_skill_symlink_target_rejected(self):
        shutil.copytree(ROOT / 'portable-skills', self.root / 'portable-skills')
        outside = self.root / 'outside'
        outside.mkdir()
        (self.root / '.agents').symlink_to(outside, target_is_directory=True)
        with self.assertRaises(ValueError):
            self.install()
        self.assertEqual(list(outside.iterdir()), [])


class LocalPrimitives(unittest.TestCase):
    def test_sqlite_fts5_search(self):
        with sqlite3.connect(':memory:') as connection:
            connection.execute('CREATE VIRTUAL TABLE search USING fts5(text)')
            connection.executemany('INSERT INTO search VALUES (?)',
                                   [('synthetic workspace alpha',), ('synthetic app beta',)])
            rows = connection.execute("SELECT text FROM search WHERE search MATCH ?",
                                      ('workspace',)).fetchall()
            self.assertEqual(rows, [('synthetic workspace alpha',)])

    def test_sqlite_transaction_failure_rolls_back(self):
        with tempfile.TemporaryDirectory(prefix='axiom-sqlite-') as temp:
            path = Path(temp) / 'metadata.db'
            with sqlite3.connect(path) as connection:
                connection.execute('PRAGMA journal_mode=WAL')
                connection.execute('CREATE TABLE events (id INTEGER PRIMARY KEY, label TEXT)')
                connection.commit()
                try:
                    with connection:
                        connection.execute('INSERT INTO events VALUES (1, ?)', ('synthetic',))
                        connection.execute('INSERT INTO events VALUES (1, ?)', ('duplicate',))
                except sqlite3.IntegrityError:
                    pass
            with sqlite3.connect(path) as connection:
                self.assertEqual(connection.execute('SELECT count(*) FROM events').fetchone()[0], 0)

    @unittest.skipUnless(sys.platform == 'linux' and hasattr(socket, 'SO_PEERCRED'),
                         'Linux SO_PEERCRED not available')
    def test_unix_socket_peer_identity(self):
        left, right = socket.socketpair(socket.AF_UNIX, socket.SOCK_STREAM)
        with left, right:
            left.settimeout(2)
            right.settimeout(2)
            try:
                credentials = right.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12)
            except PermissionError:
                self.skipTest('Execution environment denies SO_PEERCRED; peer identity remains unvalidated')
            pid, uid, gid = struct.unpack('3i', credentials)
            self.assertEqual((pid, uid, gid), (os.getpid(), os.getuid(), os.getgid()))

    def test_unix_socket_framed_payload(self):
        left, right = socket.socketpair(socket.AF_UNIX, socket.SOCK_STREAM)
        with left, right:
            left.settimeout(2)
            right.settimeout(2)
            payload = b'synthetic capability request'
            try:
                left.sendall(struct.pack('!I', len(payload)) + payload)
            except PermissionError:
                self.skipTest('Execution environment denies socket send; IPC exchange remains unvalidated')
            stream = b''
            while len(stream) < 4 + len(payload):
                block = right.recv(4 + len(payload) - len(stream))
                self.assertTrue(block)
                stream += block
            self.assertEqual(struct.unpack('!I', stream[:4])[0], len(payload))
            self.assertEqual(stream[4:], payload)

    def test_kernel_psi_interface_format(self):
        for resource in ('cpu', 'memory', 'io'):
            path = Path('/proc/pressure') / resource
            if not path.exists():
                self.skipTest(f'PSI {resource} unavailable')
            lines = path.read_text().splitlines()
            self.assertTrue(lines)
            for line in lines:
                fields = line.split()
                self.assertIn(fields[0], ('some', 'full'))
                values = dict(item.split('=', 1) for item in fields[1:])
                self.assertTrue({'avg10', 'avg60', 'avg300', 'total'} <= values.keys())
                for name in ('avg10', 'avg60', 'avg300'):
                    self.assertGreaterEqual(float(values[name]), 0)
                    self.assertLessEqual(float(values[name]), 100)
                self.assertGreaterEqual(int(values['total']), 0)

    def test_cgroup_v2_controller_interface(self):
        path = Path('/sys/fs/cgroup/cgroup.controllers')
        if not path.exists():
            self.skipTest('Unified cgroup controller interface unavailable')
        controllers = path.read_text().split()
        self.assertTrue(all(re.fullmatch(r'[a-z_]+', item) for item in controllers))
        # An empty controller list is legitimate; this test proves format, not delegation.

class Evidence(unittest.TextTestResult):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.checks = []

    def addSuccess(self, test):
        super().addSuccess(test)
        self.checks.append({'check': test.id(), 'status': 'PASS'})

    def addSkip(self, test, reason):
        super().addSkip(test, reason)
        self.checks.append({'check': test.id(), 'status': 'SKIP', 'reason': reason})

    def addFailure(self, test, err):
        super().addFailure(test, err)
        self.checks.append({'check': test.id(), 'status': 'FAIL'})

    def addError(self, test, err):
        super().addError(test, err)
        self.checks.append({'check': test.id(), 'status': 'ERROR'})


def preflight():
    commands = ('qemu-system-x86_64', 'qemu-img', 'mkarchiso', 'btrfs', 'snapper',
                'qmllint', 'dbus-daemon', 'busctl', 'systemctl', 'rustc', 'cargo',
                'codex', 'opencode', 'commandcode', 'freebuff')
    cgroup = Path('/sys/fs/cgroup/cgroup.controllers')
    manager = {'accessible': False}
    if shutil.which('systemctl'):
        try:
            probe = subprocess.run(['systemctl', '--user', 'show', '--property=Version', '--value'],
                                   capture_output=True, text=True, timeout=5)
            manager = {'accessible': probe.returncode == 0,
                       'returncode': probe.returncode}
            # Do not save app identities, bus addresses or unrelated host diagnostics.
        except subprocess.TimeoutExpired:
            manager = {'accessible': False, 'reason': 'timeout'}
    return {
        'commands_found': {cmd: shutil.which(cmd) is not None for cmd in commands},
        'kvm_device_present': Path('/dev/kvm').exists(),
        'cgroup_v2_interface_present': cgroup.exists(),
        'controllers_visible': cgroup.read_text().split() if cgroup.exists() else [],
        'user_manager': manager,
        'canonical_skills_installed': (ROOT / '.agents/skills').is_dir(),
        'kernel_release': os.uname().release,
        'sqlite_version': sqlite3.sqlite_version,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, help='Write local evidence JSON to this explicit path')
    args = parser.parse_args()
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2, resultclass=Evidence).run(suite)
    report = {
        'schema_version': 1,
        'time_utc': datetime.now(timezone.utc).isoformat(),
        'runner_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'scope': 'Local foundation and primitive checks only; no architecture/runtime proof',
        'architecture_validated': False,
        'runtime_experiments_E01_E20': 'NOT RUN',
        'checks': result.checks,
        'preflight': preflight(),
        'limits': ['No stress, freeze, reclaim, swap or host policy changes',
                   'SQLite rollback is not Btrfs/OS rollback',
                   'Peer credentials are not an implemented authorization engine',
                   'Visible controllers do not prove writable delegation or effective policy',
                   'No ISO, desktop, provider, MCP, Warden or hardware integration tested'],
    }
    if args.report:
        # Exclusive creation preserves existing evidence instead of silently replacing it.
        with args.report.open('x') as output:
            json.dump(report, output, indent=2)
            output.write('\n')
    print(f'Local checks: {result.testsRun}; skipped: {len(result.skipped)}; '
          f'failures/errors: {len(result.failures) + len(result.errors)}. '
          'Architecture gate remains incomplete.')
    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(main())
