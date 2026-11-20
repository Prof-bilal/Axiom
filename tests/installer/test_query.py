"""The unprivileged query modes the desktop installer uses (stdlib unittest, no root).

    python3 -m unittest discover -s tests/installer -v
"""
import io
import json
import os
import sys
import unittest
from unittest import mock

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "installer"))
import axiom_install as ai  # noqa: E402


class QueryModes(unittest.TestCase):
    def run_main(self, mode, stdin=""):
        out = io.StringIO()
        with mock.patch("sys.stdin", io.StringIO(stdin)), mock.patch("sys.stdout", out):
            rc = ai.main(["axiom_install.py", mode])
        return rc, json.loads(out.getvalue())

    def test_validate_reports_a_plain_error_not_a_crash(self):
        rc, res = self.run_main("--validate", json.dumps({"username": "root"}) + "\n")
        self.assertEqual(rc, 0)
        self.assertFalse(res["ok"])
        self.assertIn("username", res["error"])

    def test_validate_survives_garbage(self):
        rc, res = self.run_main("--validate", "not json\n")
        self.assertEqual(rc, 0)
        self.assertFalse(res["ok"])

    def test_list_disks_returns_the_safe_list(self):
        with mock.patch.object(ai, "list_disks", return_value=[{"path": "/dev/vda", "size": 1}]):
            rc, res = self.run_main("--list-disks")
        self.assertEqual(res, {"ok": True, "disks": [{"path": "/dev/vda", "size": 1}]})

    def test_unknown_mode_is_refused(self):
        rc, res = self.run_main("--install-everything")
        self.assertFalse(res["ok"])


if __name__ == "__main__":
    unittest.main()
