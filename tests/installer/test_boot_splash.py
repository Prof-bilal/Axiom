"""Boot splash setup: hidden boot menu, quiet splash on entries, plymouth hook, soft failure."""
import os
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "installer"))
import axiom_install as ai  # noqa: E402


class BootSplash(unittest.TestCase):
    def setUp(self):
        self.t = tempfile.mkdtemp()
        os.makedirs(os.path.join(self.t, "boot/loader/entries"))
        os.makedirs(os.path.join(self.t, "etc"))
        with open(os.path.join(self.t, "boot/loader/loader.conf"), "w") as fh:
            fh.write("default arch.conf\ntimeout 4\neditor yes\n")
        with open(os.path.join(self.t, "boot/loader/entries/arch.conf"), "w") as fh:
            fh.write("title Axiom\noptions root=UUID=1 rw\n")
        with open(os.path.join(self.t, "etc/mkinitcpio.conf"), "w") as fh:
            fh.write("HOOKS=(base udev autodetect modconf kms keyboard block filesystems fsck)\n")

    def _run(self, side_effect=None):
        with mock.patch.object(ai.subprocess, "run", side_effect=side_effect or (lambda *a, **k: None)) as run:
            ai.boot_splash(self.t)
        return run

    def test_loader_hides_menu_and_keeps_default(self):
        self._run()
        text = open(os.path.join(self.t, "boot/loader/loader.conf")).read()
        self.assertIn("default arch.conf", text)
        self.assertIn("timeout 0", text)
        self.assertIn("editor no", text)
        self.assertNotIn("timeout 4", text)
        self.assertNotIn("editor yes", text)

    def test_entries_get_quiet_splash_once(self):
        self._run()
        self._run()  # running twice must not duplicate the options
        text = open(os.path.join(self.t, "boot/loader/entries/arch.conf")).read()
        self.assertEqual(text.count("quiet splash"), 1)
        self.assertIn("root=UUID=1 rw quiet splash", text)

    def test_plymouth_hook_inserted_after_kms_only_once(self):
        self._run()
        self._run()
        hooks = open(os.path.join(self.t, "etc/mkinitcpio.conf")).read()
        self.assertIn("kms plymouth keyboard", hooks)
        self.assertEqual(hooks.count("plymouth"), 1)

    def test_theme_rebuild_runs_in_chroot(self):
        run = self._run()
        cmd = run.call_args.args[0]
        self.assertEqual(cmd, ["arch-chroot", self.t, "plymouth-set-default-theme", "-R", "axiom"])

    def test_failure_is_soft(self):
        def boom(*a, **k):
            raise subprocess.CalledProcessError(1, a[0])
        with mock.patch.object(ai, "emit") as emit:
            self._run(side_effect=boom)  # must not raise: the system still boots to text
        self.assertTrue(emit.called)
        self.assertEqual(emit.call_args.args[0], "log")


if __name__ == "__main__":
    unittest.main()
