"""Greeter protocol tests against a fake greetd on a unix socket (no root, no terminal)."""
import importlib.machinery
import importlib.util
import json
import os
import socket
import struct
import sys
import tempfile
import threading
import unittest

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
sys.path.insert(0, os.path.join(ROOT, "tui"))
loader = importlib.machinery.SourceFileLoader("axiom_greeter", os.path.join(ROOT, "greeter", "axiom-greeter"))
spec = importlib.util.spec_from_loader("axiom_greeter", loader)
g = importlib.util.module_from_spec(spec)
loader.exec_module(g)


def recv(c):
    n = struct.unpack("=I", c.recv(4))[0]
    return json.loads(c.recv(n))


def send(c, obj):
    d = json.dumps(obj).encode()
    c.sendall(struct.pack("=I", len(d)) + d)


class FakeGreetd(threading.Thread):
    """create_session -> secret prompt -> success only for the right password -> start_session."""
    def __init__(self, path, good="right-password-1", info=None):
        super().__init__(daemon=True)
        self.path, self.good, self.info, self.started, self.cancelled = path, good, info, None, False
        self.srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.srv.bind(path)
        self.srv.listen(1)

    def run(self):
        c, _ = self.srv.accept()
        req = recv(c)
        assert req["type"] == "create_session"
        send(c, {"type": "auth_message", "auth_message_type": "secret", "auth_message": "Password: "})
        resp = recv(c)
        if resp["type"] == "cancel_session":
            self.cancelled = True
            send(c, {"type": "success"})
            return
        if self.info:
            send(c, {"type": "error", "error_type": "auth_error", "description": self.info})
            recv(c)
            send(c, {"type": "success"})
            return
        if resp["response"] != self.good:
            send(c, {"type": "error", "error_type": "auth_error", "description": "Authentication failed"})
            recv(c)  # cancel_session
            send(c, {"type": "success"})
            return
        send(c, {"type": "success"})
        self.started = recv(c)
        send(c, {"type": "success"})


class Protocol(unittest.TestCase):
    def run_auth(self, answer, **kw):
        path = os.path.join(tempfile.mkdtemp(), "greetd.sock")
        srv = FakeGreetd(path, **kw)
        srv.start()
        os.environ["GREETD_SOCK"] = path
        shown = []
        res = g.authenticate("dev", lambda p, s: answer, shown.append)
        srv.join(3)
        return res, srv

    def test_right_password_starts_the_axiom_session(self):
        res, srv = self.run_auth("right-password-1")
        self.assertIsNone(res)
        self.assertEqual(srv.started["cmd"], ["/usr/local/bin/axiom-session"])
        self.assertIn("XDG_SESSION_TYPE=wayland", srv.started["env"])

    def test_wrong_password_gets_plain_wording_and_no_session(self):
        res, srv = self.run_auth("nope")
        self.assertEqual(res, g.WRONG)
        self.assertIsNone(srv.started)

    def test_lockout_message_is_friendly(self):
        res, _ = self.run_auth("x", info="Account locked due to 3 failed logins")
        self.assertIn("Too many wrong tries", res)

    def test_escape_cancels_the_session(self):
        res, srv = self.run_auth(None)
        self.assertEqual(res, "cancelled")
        self.assertTrue(srv.cancelled)

    def test_friendly_mapping(self):
        self.assertEqual(g.friendly(""), g.WRONG)
        self.assertEqual(g.friendly("Authentication failure"), g.WRONG)
        self.assertIn("Too many", g.friendly("pam_faillock: user is temporarily locked"))


class Accounts(unittest.TestCase):
    def test_display_name_prefers_full_name(self):
        class P:
            pw_name, pw_gecos = "dev", "Dev User,,,"
        self.assertEqual(g.display_name(P), "Dev User")
        P.pw_gecos = ""
        self.assertEqual(g.display_name(P), "dev")
        self.assertEqual(g.display_name(None), "")


if __name__ == "__main__":
    unittest.main()
