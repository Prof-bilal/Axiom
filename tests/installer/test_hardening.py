"""Fixes from the pre-release scan: stale-log progress, mapper cleanup, root-run test hooks, greeter group."""
import importlib.machinery
import importlib.util
import os
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
sys.path.insert(0, os.path.join(ROOT, "installer"))
sys.path.insert(0, os.path.join(ROOT, "tui"))
import axiom_install as ai  # noqa: E402

loader = importlib.machinery.SourceFileLoader("axiom_installer_ui", os.path.join(ROOT, "installer", "axiom-installer"))
spec = importlib.util.spec_from_loader("axiom_installer_ui", loader)
ui_mod = importlib.util.module_from_spec(spec)
loader.exec_module(ui_mod)

OLD_RUN = ("Retrieving packages\nTotal ( 3/ 3) 300 MiB 3.0 MiB/s 00:00 [###] 100%\n"
           "( 5/ 5) installing foo\nRetrieving packages\nTotal ( 3/ 3) 300 MiB 3.0 MiB/s 00:00 [###] 100%\n")


class StaleLog(unittest.TestCase):
    def test_a_retry_does_not_replay_the_earlier_runs_progress(self):
        with tempfile.TemporaryDirectory() as d:
            log = os.path.join(d, "install.log")
            with open(log, "w") as fh:
                fh.write(OLD_RUN)  # the first attempt, already in the log the retry appends to
            seen = []
            with mock.patch.object(ai, "progress", lambda pct, *a, **k: seen.append(pct)):
                ai.run_archinstall([sys.executable, "-c", "print('formatting the disk')"], log, 0.0)
            self.assertTrue(seen)
            self.assertLess(max(seen), 15, seen)  # replaying the old text used to jump the bar to ~48%


class Mappers(unittest.TestCase):
    def test_only_the_target_disks_mappers_are_closed(self):
        status = {"root": "  device:  /dev/vda2\n", "backup": "  device:  /dev/sdb1\n"}

        def fake_run(cmd, **kw):
            return subprocess.CompletedProcess(cmd, 0, stdout=status[cmd[2]], stderr="")

        with mock.patch("os.path.isdir", return_value=True), \
                mock.patch("os.listdir", return_value=["control", "root", "backup"]), \
                mock.patch.object(ai.subprocess, "run", fake_run):
            self.assertEqual(ai.mappers_on("/dev/vda"), ["root"])
            self.assertEqual(ai.mappers_on(None), [])  # unknown disk: close nothing

    def test_cleanup_never_closes_a_foreign_mapper(self):
        closed = []

        def fake_run(cmd, **kw):
            if cmd[:2] == ["cryptsetup", "close"]:
                closed.append(cmd[2])
            return subprocess.CompletedProcess(cmd, 1, stdout="", stderr="")

        with mock.patch.object(ai, "kill_users"), mock.patch.object(ai.subprocess, "run", fake_run), \
                mock.patch.object(ai, "mappers_on", return_value=["root"]):
            ai.cleanup("/mnt-test", "/dev/vda")
        self.assertEqual(closed, ["root"])


class RootHooks(unittest.TestCase):
    def test_the_real_install_ignores_the_fake_backend_variable(self):
        captured = []

        def fake_popen(cmd, **kw):
            captured.append(cmd)
            raise RuntimeError("stop here")

        with mock.patch.dict(os.environ, {"AXIOM_BACKEND_CMD": "touch /tmp/pwned"}), \
                mock.patch.object(ui_mod.subprocess, "Popen", fake_popen):
            with self.assertRaises(RuntimeError):
                ui_mod.run_install(None, {}, {"path": "/dev/null", "size": 0})
        self.assertEqual(captured[0][0], sys.executable)
        self.assertNotIn("touch", captured[0])

    def test_the_demo_path_still_uses_the_fake_backend(self):
        captured = []

        def fake_popen(cmd, **kw):
            captured.append(cmd)
            raise RuntimeError("stop here")

        with mock.patch.object(ui_mod.subprocess, "Popen", fake_popen):
            with self.assertRaises(RuntimeError):
                ui_mod.run_install(None, {}, {"path": "/dev/null", "size": 0}, backend="python3 fake.py")
        self.assertEqual(captured[0], ["python3", "fake.py"])

    def test_a_preview_run_cannot_install(self):
        with mock.patch.dict(os.environ, {"AXIOM_FB_PNG": "/tmp/x"}), mock.patch("os.geteuid", return_value=1000):
            with self.assertRaises(SystemExit):
                ui_mod.run_install(None, {}, {"path": "/dev/vda", "size": 1})

    def test_the_login_user_is_in_the_video_group(self):
        src = open(os.path.join(ROOT, "installer", "axiom_install.py")).read()
        self.assertIn('["usermod", "-aG", "video", "greeter"]', src)


if __name__ == "__main__":
    unittest.main()
