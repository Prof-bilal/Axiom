"""The installed system must carry the packages the shipped apps exec (audit H1).

The ISO has them; an installed system only has installer/axiom_install.py BASE_PACKAGES.
"""
import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "installer"))
import axiom_install as ai  # noqa: E402

# command -> package that provides it. Extend when an app starts executing a new tool.
COMMANDS = {
    "grim": "grim", "wf-recorder": "wf-recorder", "wl-copy": "wl-clipboard", "minisign": "minisign",
    "bwrap": "bubblewrap", "flatpak": "flatpak", "distrobox": "distrobox", "podman": "podman",
    "rsync": "rsync",
}
SCAN = ["shell", "apps", "provision", "system"]


def sources():
    for top in SCAN:
        for root, _, files in os.walk(os.path.join(REPO, top)):
            for f in files:
                if f.endswith((".qml", ".js")) or "." not in f:
                    p = os.path.join(root, f)
                    try:
                        yield p, open(p, errors="ignore").read()
                    except OSError:
                        pass


class PackageParity(unittest.TestCase):
    def test_every_exec_d_tool_is_installed(self):
        used = {}
        for path, text in sources():
            for cmd in COMMANDS:
                if re.search(r'["\'\s]' + re.escape(cmd) + r'["\'\s]', text):
                    used.setdefault(cmd, path)
        missing = sorted({COMMANDS[c] for c in used} - set(ai.BASE_PACKAGES))
        self.assertEqual(missing, [], f"used by {used} but not in BASE_PACKAGES")


if __name__ == "__main__":
    unittest.main()
