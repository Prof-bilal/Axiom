"""axiom-installd: the root installer socket. Refusals are the security tests (ADR 026)."""
import importlib.util
import json
import os
import sys
import threading
import unittest
from unittest import mock

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "installer"))
import axiom_install as ai  # noqa: E402
import axiom_installd as d  # noqa: E402

MEMBER_GID = 4242
FORM = {"locale": "en_US", "keyboard": "us", "timezone": "UTC", "hostname": "axiom", "username": "abullah"}


def member_gids(uid):
    return [MEMBER_GID]


class Peer(unittest.TestCase):
    def test_root_is_allowed(self):
        self.assertTrue(d.allowed_peer(0, gids_of=lambda u: []))

    def test_non_member_is_refused(self):
        with mock.patch.object(d.grp, "getgrnam", return_value=mock.Mock(gr_gid=MEMBER_GID)):
            self.assertFalse(d.allowed_peer(1234, gids_of=lambda u: [1000]))

    def test_member_is_allowed(self):
        with mock.patch.object(d.grp, "getgrnam", return_value=mock.Mock(gr_gid=MEMBER_GID)):
            self.assertTrue(d.allowed_peer(1000, gids_of=member_gids))

    def test_missing_group_refuses_everyone_but_root(self):
        with mock.patch.object(d.grp, "getgrnam", side_effect=KeyError):
            self.assertFalse(d.allowed_peer(1000, gids_of=member_gids))


class Requests(unittest.TestCase):
    def setUp(self):
        self.inst = d.Installer(runner=lambda *a: 0)
        self.member = mock.patch.object(d, "allowed_peer", return_value=True)
        self.member.start()

    def tearDown(self):
        self.member.stop()

    def test_oversized_request_refused_before_parsing(self):
        r = d.handle("x" * (d.MAX_LINE + 1), 0, self.inst)
        self.assertFalse(r["ok"])

    def test_malformed_json_refused(self):
        self.assertEqual(d.handle("{not json", 0, self.inst)["error"], "Malformed request.")

    def test_unknown_op_refused(self):
        self.assertEqual(d.handle(json.dumps({"op": "shell", "cmd": "id"}), 0, self.inst)["error"],
                         "Unknown operation.")

    def test_non_dict_refused(self):
        self.assertFalse(d.handle("[1,2]", 0, self.inst)["ok"])

    def test_refused_peer_gets_nothing(self):
        self.member.stop()
        with mock.patch.object(d, "allowed_peer", return_value=False):
            self.assertEqual(d.handle(json.dumps({"op": "list_disks"}), 1234, self.inst)["error"], "Not allowed.")
        self.member.start()

    def test_list_disks_uses_injected_source(self):
        r = d.handle(json.dumps({"op": "list_disks"}), 0, self.inst, disks=lambda: [{"path": "/dev/vda"}])
        self.assertEqual(r, {"ok": True, "disks": [{"path": "/dev/vda"}]})

    def test_validate_reports_form_error(self):
        with mock.patch.object(ai, "validate_form", side_effect=ai.FormError("Pick a username.")):
            r = d.handle(json.dumps({"op": "validate", "form": {}}), 0, self.inst)
        self.assertEqual(r, {"ok": False, "error": "Pick a username."})


class Install(unittest.TestCase):
    def test_bad_form_never_reaches_the_runner(self):
        ran = []
        inst = d.Installer(runner=lambda *a: ran.append(a) or 0)
        with mock.patch.object(ai, "validate_form", side_effect=ai.FormError("Bad name.")):
            with self.assertRaises(ai.FormError):
                inst.start({}, "/dev/vda", 20 * 1024**3)
        self.assertEqual(ran, [])
        self.assertFalse(inst.running)

    def test_second_install_refused_while_running(self):
        gate = threading.Event()

        def slow(form, disk, nbytes, emit):
            gate.wait(5)
            return 0
        inst = d.Installer(runner=slow)
        with mock.patch.object(ai, "validate_form", return_value=None), \
                mock.patch.object(ai, "check_target", return_value=None):
            inst.start(FORM, "/dev/vda", 20 * 1024**3)
            r = d.handle(json.dumps({"op": "start_install", "form": FORM, "disk": "/dev/vda",
                                     "disk_bytes": 20 * 1024**3}), 0, inst)
        gate.set()
        self.assertFalse(r["ok"])
        self.assertIn("already running", r["error"])

    def test_events_are_kept_for_status_polling(self):
        def fake(form, disk, nbytes, emit):
            emit({"event": "progress", "pct": 10})
            emit({"event": "done", "pct": 100})
            return 0
        inst = d.Installer(runner=fake)
        with mock.patch.object(ai, "validate_form", return_value=None), \
                mock.patch.object(ai, "check_target", return_value=None):
            inst.start(FORM, "/dev/vda", 20 * 1024**3)
        for _ in range(100):
            if not inst.status()["running"]:
                break
            threading.Event().wait(0.02)
        s = inst.status(since=1)
        self.assertEqual(s["events"], [{"event": "done", "pct": 100}])

    def test_runner_crash_reports_generic_error_only(self):
        def boom(form, disk, nbytes, emit):
            raise RuntimeError("secret-password-in-traceback")
        inst = d.Installer(runner=boom)
        with mock.patch.object(ai, "validate_form", return_value=None), \
                mock.patch.object(ai, "check_target", return_value=None):
            inst.start(FORM, "/dev/vda", 20 * 1024**3)
        for _ in range(100):
            if not inst.status()["running"]:
                break
            threading.Event().wait(0.02)
        msgs = json.dumps(inst.status()["events"])
        self.assertIn("stopped unexpectedly", msgs)
        self.assertNotIn("secret-password", msgs)


class NewOps(unittest.TestCase):
    def setUp(self):
        self.inst = d.Installer(runner=lambda *a: 0)
        self.member = mock.patch.object(d, "allowed_peer", return_value=True)
        self.member.start()

    def tearDown(self):
        self.member.stop()

    def test_catalog_returns_items(self):
        r = d.handle(json.dumps({"op": "catalog"}), 0, self.inst)
        self.assertTrue(r["ok"])
        self.assertIn("items", r["catalog"])

    def test_reboot_is_replied_before_the_reboot_runs(self):
        with mock.patch.object(d.threading, "Timer") as timer:
            r = d.handle(json.dumps({"op": "reboot"}), 0, self.inst)
        self.assertEqual(r, {"ok": True})
        timer.assert_called_once()

    def test_reboot_refused_for_non_member(self):
        self.member.stop()
        with mock.patch.object(d, "allowed_peer", return_value=False), mock.patch.object(d.threading, "Timer") as timer:
            r = d.handle(json.dumps({"op": "reboot"}), 1234, self.inst)
        self.member.start()
        self.assertEqual(r["error"], "Not allowed.")
        timer.assert_not_called()


class SilentCrash(unittest.TestCase):
    def test_backend_crash_without_json_error_reports_stop(self):
        """A backend that dies with no JSON error must not leave the UI on its first progress line."""
        class FakeProc:
            def __init__(self, *a, **k):
                self.stdin = mock.Mock()
                self.stdout = iter([])
            def wait(self):
                return 1
        emitted = []
        with mock.patch.object(d.subprocess, "Popen", FakeProc), mock.patch.object(d, "LOG", os.devnull):
            rc = d.Installer()._run_backend(FORM, "/dev/vda", 20 * 1024**3, emitted.append)
        self.assertEqual(rc, 1)
        self.assertEqual(emitted[-1]["event"], "error")
        self.assertIn("stopped", emitted[-1]["message"])

    def test_backend_json_error_is_not_duplicated(self):
        class FakeProc:
            def __init__(self, *a, **k):
                self.stdin = mock.Mock()
                self.stdout = iter(['{"event": "error", "message": "Bad disk."}\n'])
            def wait(self):
                return 2
        emitted = []
        with mock.patch.object(d.subprocess, "Popen", FakeProc), mock.patch.object(d, "LOG", os.devnull):
            d.Installer()._run_backend(FORM, "/dev/vda", 20 * 1024**3, emitted.append)
        self.assertEqual([e["message"] for e in emitted], ["Bad disk."])

if __name__ == "__main__":
    unittest.main()
