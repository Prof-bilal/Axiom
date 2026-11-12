"""archinstall 4.x exits 0 without installing when offline; the installer must say so instead of failing later."""
import os
import sys
import tempfile
import unittest
from unittest import mock

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(HERE)), "installer"))
import axiom_install as ai  # noqa: E402


class InstalledCheck(unittest.TestCase):
    def test_empty_target_is_reported_as_missing_network(self):
        with tempfile.TemporaryDirectory() as t:
            with mock.patch.object(ai.os.path, "ismount", return_value=True):
                with self.assertRaises(ai.FormError) as cm:
                    ai.check_installed(t)
        self.assertIn("internet connection", str(cm.exception))

    def test_target_that_is_not_a_mount_is_reported(self):
        with tempfile.TemporaryDirectory() as t:
            os.makedirs(os.path.join(t, "etc"))
            open(os.path.join(t, "etc/os-release"), "w").close()
            with mock.patch.object(ai.os.path, "ismount", return_value=False):
                with self.assertRaises(ai.FormError):
                    ai.check_installed(t)

    def test_real_install_passes(self):
        with tempfile.TemporaryDirectory() as t:
            os.makedirs(os.path.join(t, "etc"))
            open(os.path.join(t, "etc/os-release"), "w").close()
            with mock.patch.object(ai.os.path, "ismount", return_value=True):
                ai.check_installed(t)

    def test_archinstall_gets_the_wifi_check_flag(self):
        src = open(os.path.join(os.path.dirname(os.path.dirname(HERE)), "installer", "axiom_install.py")).read()
        self.assertIn('"--skip-wifi-check"', src)


if __name__ == "__main__":
    unittest.main()
