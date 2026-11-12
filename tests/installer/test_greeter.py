"""Greeter protocol tests against a fake greetd on a unix socket (no root, no terminal)."""
import importlib.machinery
import importlib.util
import json
import os
import socket
import stat
import struct
import sys
import tempfile
import threading
import types
import unittest
from unittest import mock

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
    """create_session -> prompt -> success only for the right password -> start_session."""
    def __init__(self, path, good="right-password-1", info=None, prompt_type="secret"):
        super().__init__(daemon=True)
        self.path, self.good, self.info, self.prompt_type = path, good, info, prompt_type
        self.started, self.cancelled = None, False
        self.srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.srv.bind(path)
        self.srv.listen(1)

    def run(self):
        c, _ = self.srv.accept()
        req = recv(c)
        assert req["type"] == "create_session"
        send(c, {"type": "auth_message", "auth_message_type": self.prompt_type, "auth_message": "Password: "})
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
        prompts = []

        def ask(prompt, secret):
            prompts.append((prompt, secret))
            return answer

        res = g.authenticate("dev", ask, shown.append)
        srv.join(3)
        self.prompts = prompts
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

    def test_a_visible_prompt_is_not_treated_as_a_secret(self):
        self.run_auth("right-password-1", prompt_type="visible")
        self.assertEqual(self.prompts, [("Password: ", False)])

    def test_the_password_prompt_is_secret(self):
        self.run_auth("right-password-1")
        self.assertEqual(self.prompts, [("Password: ", True)])


class Accounts(unittest.TestCase):
    def entry(self, name, uid, shell="/bin/bash", gecos=""):
        return types.SimpleNamespace(pw_name=name, pw_uid=uid, pw_shell=shell, pw_gecos=gecos)

    def test_display_name_prefers_full_name(self):
        class P:
            pw_name, pw_gecos = "dev", "Dev User,,,"
        self.assertEqual(g.display_name(P), "Dev User")
        P.pw_gecos = ""
        self.assertEqual(g.display_name(P), "dev")
        self.assertEqual(g.display_name(None), "")

    def test_only_local_human_accounts_are_listed(self):
        entries = [self.entry("dev", 1000, "/usr/bin/zsh", "Dev User,,,"),
                   self.entry("service", 999),
                   self.entry("nologin", 1500, "/usr/bin/nologin"),
                   self.entry("disabled", 1501, "/usr/bin/false"),
                   self.entry("first", 1000),
                   self.entry("last", 59999, "/bin/bash", "Last,,,"),
                   self.entry("system", 60000)]
        listed = [p.pw_name for p in g.human_users(entries)]
        self.assertEqual(listed, ["dev", "first", "last"])
        self.assertNotIn("root", listed)

    def test_the_qml_snapshot_has_only_public_identity_fields(self):
        payload = g.users_payload([self.entry("dev", 1000, gecos="Dev User,,,")])
        self.assertEqual(payload, [{"name": "dev", "display": "Dev User"}])
        self.assertEqual(set(payload[0]), {"name", "display"})

    def test_the_snapshot_file_is_private_and_parses_as_json(self):
        with tempfile.TemporaryDirectory() as d:
            path = g.write_users_file([self.entry("dev", 1000, gecos="Dev User,,,")], d)
            self.assertEqual(stat.S_IMODE(os.stat(path).st_mode), 0o600)
            with open(path) as fh:
                self.assertEqual(json.load(fh), [{"name": "dev", "display": "Dev User"}])


class Fallback(unittest.TestCase):
    def test_curses_is_the_default_login_and_skips_the_graphical_greeter(self):
        calls = []
        with mock.patch.dict(os.environ, {}, clear=False):
            os.environ.pop("AXIOM_GREETER_GRAPHICAL", None)
            rc = g.run(graphical=lambda users: calls.append("graphical") or 0,
                       setup=lambda: calls.append("setup"), wrap=lambda fn: calls.append(fn))
        self.assertEqual((rc, calls), (0, ["setup", g.main]))

    def test_graphical_greeter_runs_only_when_opted_in(self):
        calls = []
        with mock.patch.dict(os.environ, {"AXIOM_GREETER_GRAPHICAL": "1"}):
            rc = g.run(graphical=lambda users: 0, setup=lambda: calls.append("setup"),
                       wrap=lambda fn: calls.append(fn))
        self.assertEqual((rc, calls), (0, []))

    def test_curses_draws_when_the_opted_in_graphical_greeter_cannot_start(self):
        calls = []
        with mock.patch.dict(os.environ, {"AXIOM_GREETER_GRAPHICAL": "1"}):
            rc = g.run(graphical=lambda users: 1, setup=lambda: calls.append("setup"),
                       wrap=lambda fn: calls.append(fn))
        self.assertEqual((rc, calls), (0, ["setup", g.main]))

    def test_login_screen_is_big_axiom_banner_and_input_only(self):
        drawn = []

        class Screen:
            def __init__(self):
                self.h, self.w = 40, 100
                self.s = self
            def getmaxyx(self):
                return self.h, self.w
            def erase(self): drawn.clear()
            def refresh(self): pass
            def keypad(self, _): pass
            def addnstr(self, y, x, text, n, attr=0): drawn.append(text)
            def addstr(self, y, x, text, attr=0): drawn.append(text)
            def addch(self, y, x, ch, attr=0): pass

        app = g.Login.__new__(g.Login)
        app.ui = g.tui.UI.__new__(g.tui.UI)
        app.ui.s, app.ui._pairs, app.ui.fb = Screen(), {}, False
        app.msg, app.msg_color, app.dx = "", 0, 0
        app.ui.pair = lambda fg, bg=0: 0
        acs = {k: 0 for k in ("ACS_HLINE", "ACS_VLINE", "ACS_ULCORNER", "ACS_URCORNER", "ACS_LLCORNER", "ACS_LRCORNER")}
        with mock.patch.multiple(g.curses, create=True, **acs):
            app.draw(None, "")
        text = "\n".join(drawn)
        self.assertIn(g.tui.big_rows("AXIOM", 1)[0].rstrip(), text)
        self.assertIn("Password", text)  # placeholder inside the input box while empty
        for word in ("Welcome", "Sign in", "F2", "F10", "Caps", "@"):
            self.assertNotIn(word, text)


class QmlGreeter(unittest.TestCase):
    """The QML shell is not executable here, so keep its contract in step with the curses path."""

    def setUp(self):
        with open(os.path.join(ROOT, "greeter", "qml", "shell.qml")) as fh:
            self.qml = fh.read()

    def test_uses_real_greetd_and_the_axiom_session(self):
        for call in ("Greetd.createSession", "Greetd.respond", "Greetd.launch"):
            self.assertIn(call, self.qml)
        self.assertIn("/usr/local/bin/axiom-session", self.qml)
        for var in ("XDG_SESSION_TYPE=wayland", "XDG_SESSION_DESKTOP=axiom", "XDG_CURRENT_DESKTOP=Axiom"):
            self.assertIn(var, self.qml)

    def test_handles_every_greetd_signal_it_depends_on(self):
        for signal in ("authMessage", "authFailure", "readyToLaunch", "error"):
            self.assertIn("function on" + signal[0].upper() + signal[1:] + "(", self.qml)

    def test_wrong_password_wording_matches_the_curses_screen(self):
        self.assertIn(g.WRONG, self.qml)
        self.assertNotIn("console.log", self.qml)

    def test_an_error_during_authentication_reads_as_a_failed_sign_in(self):
        # greetd can end a bad-password attempt with `error` instead of (or after)
        # `authFailure`; the generic service wording must not replace the specific one.
        self.assertIn("const duringAuth", self.qml)
        self.assertIn("root.authFailed", self.qml)
        self.assertIn("root.friendly(error)", self.qml)
        self.assertNotIn("GreetdState", self.qml)  # not exported by the Quickshell we ship

    def test_launcher_is_executable(self):
        self.assertTrue(os.access(os.path.join(ROOT, "greeter", "axiom-greeter-graphical"), os.X_OK))


if __name__ == "__main__":
    unittest.main()
