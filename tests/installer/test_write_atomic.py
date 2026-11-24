"""write_atomic replaces a file whole and keeps its mode (audit R4)."""
import os
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(HERE)), "installer"))
import axiom_install as ai  # noqa: E402


class WriteAtomic(unittest.TestCase):
    def test_replaces_and_keeps_mode_and_leaves_no_temp(self):
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "x.conf")
            open(p, "w").write("old")
            os.chmod(p, 0o600)
            ai.write_atomic(p, "new\n")
            self.assertEqual(open(p).read(), "new\n")
            self.assertEqual(os.stat(p).st_mode & 0o777, 0o600)
            self.assertEqual(os.listdir(d), ["x.conf"])


if __name__ == "__main__":
    unittest.main()
