"""Unit tests for provision/axiom-provision with a fake command runner (no root, no network)."""
import importlib.machinery
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
loader = importlib.machinery.SourceFileLoader("axiom_provision", os.path.join(ROOT, "provision", "axiom-provision"))
spec = importlib.util.spec_from_loader("axiom_provision", loader)
ap = importlib.util.module_from_spec(spec)
loader.exec_module(ap)
CAT = json.load(open(os.path.join(ROOT, "catalog", "developer-hub.json")))


class Fake:
    """Records commands; installed packages are tracked so verify() sees them."""
    def __init__(self, fail=()):
        self.calls, self.installed, self.fail = [], set(), set(fail)

    def __call__(self, cmd, **kw):
        self.calls.append(cmd)
        out = subprocess.CompletedProcess(cmd, 0, "", "")
        if cmd[:2] == ["pacman", "-S"]:
            pk = [c for c in cmd if not c.startswith("-") and c != "pacman" and c != "S"]
            if self.fail & set(pk):
                return subprocess.CompletedProcess(cmd, 1, "", "target not found")
            self.installed |= set(pk)
        elif cmd[:2] == ["pacman", "-Qi"]:
            out.returncode = 0 if cmd[2] in self.installed else 1
        return out


class Resolve(unittest.TestCase):
    def test_requirements_first_and_unknown_reported(self):
        items, unknown = ap.resolve({"hub": ["postgres", "bogus", "x; rm -rf /"]}, CAT)
        self.assertEqual([i["id"] for i in items], ["podman", "postgres"])
        self.assertEqual(set(unknown), {"bogus", "x; rm -rf /"})

    def test_profile_cannot_inject_packages(self):
        items, _ = ap.resolve({"hub": ["git"], "packages": ["evil"]}, CAT)
        self.assertEqual(items[0]["packages"], ["git", "github-cli"])

    def test_catalogue_is_valid(self):
        ids = {i["id"] for i in CAT["items"]}
        self.assertEqual(len(ids), len(CAT["items"]))
        for i in CAT["items"]:
            self.assertIn(i["method"], ("pacman", "podman"))
            for p in i.get("packages", []):
                self.assertRegex(p, ap.PKG_RE)
            if i["method"] == "podman":
                self.assertRegex(i["image"], ap.IMG_RE)
        for preset in CAT["presets"].values():
            self.assertTrue(set(preset) <= ids)


class Run(unittest.TestCase):
    def setUp(self):
        self.d = tempfile.mkdtemp()
        self.state = os.path.join(self.d, "state.json")

    def test_offline_defers_and_keeps_selection(self):
        rc = ap.provision({"user": "root", "hub": ["git"]}, CAT, self.state, Fake(), lambda: False)
        self.assertEqual(rc, ap.EXIT_DEFER)
        self.assertEqual(json.load(open(self.state))["state"], "deferred")

    def test_failure_is_isolated_and_rerun_converges(self):
        fake = Fake(fail={"neovim"})
        prof = {"user": "root", "hub": ["git", "neovim", "go"]}
        self.assertEqual(ap.provision(prof, CAT, self.state, fake, lambda: True), 1)
        st = json.load(open(self.state))
        self.assertEqual(st["state"], "partial")
        self.assertEqual({k: v["status"] for k, v in st["items"].items()}, {"git": "ok", "neovim": "failed", "go": "ok"})
        fake.fail.clear()
        n = len(fake.calls)
        self.assertEqual(ap.provision(prof, CAT, self.state, fake, lambda: True), 0)
        again = [c for c in fake.calls[n:] if c[:2] == ["pacman", "-S"]]
        self.assertEqual(len(again), 1)  # only neovim is retried
        self.assertEqual(json.load(open(self.state))["state"], "done")

    def test_commands_are_argv_lists(self):
        fake = Fake()
        ap.provision({"user": "root", "hub": ["kubectl"]}, CAT, self.state, fake, lambda: True)
        self.assertTrue(all(isinstance(c, list) for c in fake.calls))
        self.assertIn(["pacman", "-S", "--needed", "--noconfirm", "kubectl", "helm"], fake.calls)


if __name__ == "__main__":
    unittest.main()
