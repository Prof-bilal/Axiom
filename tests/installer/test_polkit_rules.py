"""Polkit rules authorize a group, not a user name, and the installer puts the user in it (audit H2, S5, S6)."""
import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
RULES = os.path.join(REPO, "iso/phase3/airootfs/etc/polkit-1/rules.d")
sys.path.insert(0, os.path.join(REPO, "installer"))
import axiom_install as ai  # noqa: E402


def read(*p):
    return open(os.path.join(REPO, *p)).read()


class PolkitGroup(unittest.TestCase):
    def test_installed_rules_match_the_group_not_a_user_name(self):
        for name in ("50-axiom-session-power.rules", "51-axiom-system-settings.rules"):
            text = read("iso/phase3/airootfs/etc/polkit-1/rules.d", name)
            self.assertIn('subject.isInGroup("axiom-users")', text, name)
            self.assertNotRegex(text, r'subject\.user\s*[!=]=\s*"axiom"', name)

    def test_the_rules_installed_by_the_overlay_are_the_group_ones(self):
        shipped = [p for p in ai.OVERLAY if "/polkit-1/rules.d/" in p]
        self.assertTrue(shipped)
        self.assertFalse([p for p in shipped if "52-axiom-live-installer" in p], "live-only rule must not be installed")

    def test_installer_adds_the_user_to_the_group(self):
        src = open(os.path.join(REPO, "installer/axiom_install.py")).read()
        self.assertIn('"groupadd", "-f", "axiom-users"', src)
        self.assertRegex(src, r'"usermod", "-aG", "axiom-users"')

    def test_live_user_is_in_the_group_and_sshd_is_off(self):
        self.assertRegex(read("iso/phase3/airootfs/root/customize_airootfs.sh"), r"usermod -aG [^\n]*axiom-users")
        self.assertFalse(os.path.exists(os.path.join(
            REPO, "iso/phase3/airootfs/etc/systemd/system/multi-user.target.wants/sshd.service")))
        conf = read("iso/phase3/airootfs/etc/ssh/sshd_config.d/10-archiso.conf")
        self.assertRegex(conf, r"(?m)^PermitRootLogin no$")
        self.assertRegex(conf, r"(?m)^PasswordAuthentication no$")

    def test_sudoers_file_is_created_0440(self):
        src = open(os.path.join(REPO, "installer/axiom_install.py")).read()
        self.assertRegex(src, r"os\.open\([^\n]*10-wheel[^\n]*0o440")


if __name__ == "__main__":
    unittest.main()


class LocalSignatures(unittest.TestCase):
    def _conf(self, body):
        import tempfile
        d = tempfile.mkdtemp()
        os.makedirs(os.path.join(d, "etc"))
        open(os.path.join(d, "etc/pacman.conf"), "w").write(body)
        ai.require_local_signatures(d)
        return open(os.path.join(d, "etc/pacman.conf")).read()

    def test_commented_default_gets_an_explicit_required(self):
        out = self._conf("[options]\nSigLevel = Required DatabaseOptional\n#LocalFileSigLevel = Optional\n")
        self.assertIn("\nLocalFileSigLevel = Required\n", out)

    def test_optional_is_replaced(self):
        out = self._conf("[options]\nSigLevel = Required DatabaseOptional\nLocalFileSigLevel = Optional\n")
        self.assertNotIn("Optional\n", out.split("SigLevel = Required DatabaseOptional")[1])
        self.assertEqual(out.count("LocalFileSigLevel"), 1)
