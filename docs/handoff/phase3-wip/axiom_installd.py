#!/usr/bin/env python3
"""axiom-installd: root installer backend for the QML installer (ADR 026).

The unprivileged UI talks to this service over a Unix socket with one JSON request per line:

    {"op": "list_disks"}
    {"op": "validate", "form": {...}}
    {"op": "start_install", "form": {...}, "disk": "/dev/vda", "disk_bytes": N}
    {"op": "status", "since": 0}

Every reply is one JSON line. Only these four operations exist; there is no shell and no passthrough.
Peers are checked with SO_PEERCRED: root and members of the `axiom-install` group only (the live user).
Passwords are never logged; only operation names and outcomes are.
"""
import grp
import json
import os
import socket
import subprocess
import sys
import threading

HERE = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, HERE)
import axiom_install as ai  # noqa: E402

SOCKET = "/run/axiom/installd.sock"
GROUP = "axiom-install"
LOG = "/var/log/axiom-installer.log"
MAX_LINE = 64 * 1024  # a whole install form is a few KB; anything bigger is refused
OPS = {"list_disks", "validate", "start_install", "status", "catalog", "reboot"}
CATALOG_PATHS = ("/usr/local/lib/axiom-installer/catalog/developer-hub.json",
                 os.path.join(HERE, "..", "catalog", "developer-hub.json"),
                 os.path.join(HERE, "catalog", "developer-hub.json"))


class Refused(Exception):
    pass


def allowed_peer(uid, gids_of=None):
    """Root, or a member of axiom-install (the live user). Anything else is refused."""
    if uid == 0:
        return True
    try:
        gid = grp.getgrnam(GROUP).gr_gid
    except KeyError:
        return False
    gids = gids_of(uid) if gids_of else []
    return gid in gids


class Installer:
    """One install at a time; events from the backend are kept for status polling."""

    def __init__(self, runner=None):
        self.lock = threading.Lock()
        self.events = []
        self.running = False
        self.runner = runner or self._run_backend

    def _run_backend(self, form, disk, disk_bytes, emit):
        payload = json.dumps({**form, "disk": disk, "disk_bytes": disk_bytes})
        # The backend's stderr (tracebacks) goes to the installer log, never to the UI.
        with open(LOG, "a") as log:
            proc = subprocess.Popen([sys.executable, os.path.join(HERE, "axiom_install.py")], stdin=subprocess.PIPE,
                                    stdout=subprocess.PIPE, stderr=log, text=True, env=ai.ENV)
            proc.stdin.write(payload)
            proc.stdin.close()
            seen_error = False
            for line in proc.stdout:
                try:
                    ev = json.loads(line)
                except ValueError:
                    continue
                seen_error = seen_error or ev.get("event") == "error"
                emit(ev)
            rc = proc.wait()
        if rc != 0 and not seen_error:
            # A crash with no JSON error would leave the UI stuck on its first line; say so.
            emit({"event": "error", "message": f"The installation stopped before it was finished (code {rc}). "
                                               f"Details: {LOG}"})
        return rc

    def start(self, form, disk, disk_bytes):
        with self.lock:
            if self.running:
                raise Refused("An installation is already running.")
            # Validate before anything touches a disk; the backend validates again (defence in depth).
            ai.validate_form(dict(form, disk=disk, disk_bytes=disk_bytes))
            ai.check_target(disk, disk_bytes)
            self.running = True
            self.events = []
        threading.Thread(target=self._worker, args=(form, disk, disk_bytes), daemon=True).start()
        return {"ok": True}

    def _worker(self, form, disk, disk_bytes):
        try:
            rc = self.runner(form, disk, disk_bytes, self._record)
        except Exception as e:  # never leak details; the UI gets a generic line
            rc = -1
            self._record({"event": "error", "message": "The installation stopped unexpectedly."})
            print(f"axiom-installd: install failed: {type(e).__name__}", file=sys.stderr)
        finally:
            with self.lock:
                self.running = False
        print(f"axiom-installd: install finished rc={rc}", file=sys.stderr)

    def _record(self, event):
        with self.lock:
            self.events.append(event)

    def status(self, since=0):
        with self.lock:
            return {"running": self.running, "events": self.events[max(0, int(since)):]}


def load_catalog():
    """The Developer Hub catalog (same file the curses installer reads); empty if missing."""
    for p in CATALOG_PATHS:
        try:
            with open(p) as fh:
                return json.load(fh)
        except (OSError, ValueError):
            continue
    return {"items": [], "categories": {}, "presets": {}}


def handle(line, uid, installer, gids_of=None, disks=None):
    """Turn one request line into one reply dict. Pure enough to test without a socket."""
    if len(line) > MAX_LINE:
        return {"ok": False, "error": "Request too large."}
    if not allowed_peer(uid, gids_of):
        return {"ok": False, "error": "Not allowed."}
    try:
        req = json.loads(line)
    except ValueError:
        return {"ok": False, "error": "Malformed request."}
    if not isinstance(req, dict) or req.get("op") not in OPS:
        return {"ok": False, "error": "Unknown operation."}
    op = req["op"]
    try:
        if op == "list_disks":
            return {"ok": True, "disks": (disks or ai.list_disks)()}
        if op == "validate":
            ai.validate_form(req.get("form") or {})
            return {"ok": True}
        if op == "catalog":
            return {"ok": True, "catalog": load_catalog()}
        if op == "reboot":
            # Reply first, then reboot: the UI needs the answer before the machine goes down.
            threading.Timer(1.0, lambda: subprocess.run(["systemctl", "reboot"], env=ai.ENV)).start()
            return {"ok": True}
        if op == "start_install":
            return installer.start(req.get("form") or {}, req.get("disk"), int(req.get("disk_bytes") or 0))
        return {"ok": True, **installer.status(req.get("since", 0))}
    except ai.FormError as e:
        return {"ok": False, "error": str(e)}
    except Refused as e:
        return {"ok": False, "error": str(e)}


def serve(path=SOCKET):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if os.path.exists(path):
        os.remove(path)
    srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    srv.bind(path)
    os.chmod(path, 0o660)
    try:
        os.chown(path, 0, grp.getgrnam(GROUP).gr_gid)
    except KeyError:
        pass
    srv.listen(4)
    installer = Installer()
    while True:
        conn, _ = srv.accept()
        threading.Thread(target=_client, args=(conn, installer), daemon=True).start()


def _client(conn, installer):
    try:
        uid = _peer_uid(conn)
        buf = b""
        while b"\n" not in buf and len(buf) <= MAX_LINE:
            chunk = conn.recv(4096)
            if not chunk:
                break
            buf += chunk
        line = buf.split(b"\n", 1)[0].decode("utf-8", "replace")
        print(f"axiom-installd: uid={uid} op={_op_name(line)}", file=sys.stderr)  # never the form body
        reply = handle(line, uid, installer, gids_of=_gids_of)
        conn.sendall((json.dumps(reply) + "\n").encode())
    except OSError:
        pass
    finally:
        conn.close()


def _peer_uid(conn):
    import struct
    cred = conn.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, struct.calcsize("3i"))
    return struct.unpack("3i", cred)[1]


def _gids_of(uid):
    import pwd
    try:
        name = pwd.getpwuid(uid).pw_name
    except KeyError:
        return []
    return [g.gr_gid for g in grp.getgrall() if name in g.gr_mem] + [pwd.getpwuid(uid).pw_gid]


def _op_name(line):
    try:
        return json.loads(line).get("op", "?")
    except (ValueError, AttributeError):
        return "?"


if __name__ == "__main__":
    serve(os.environ.get("AXIOM_INSTALLD_SOCKET", SOCKET))
