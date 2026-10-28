#!/usr/bin/env python3
"""Relay real compositor IPC, then drop only owned relay connections.

No synthetic compositor state and no changes to the real compositor sockets.
The separate Wayland connection remains live while IPC failure is tested.
"""
import json
import argparse
import os
from pathlib import Path
import runpy
import select
import socket
import socketserver
import tempfile
import threading


class Relay(socketserver.BaseRequestHandler):
    def handle(self):
        upstream = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        upstream.settimeout(2)
        self.request.settimeout(2)
        owner = self.server.owner
        try:
            upstream.connect(str(self.server.upstream))
            with owner.lock:
                owner.streams.update([self.request, upstream])
                self.server.streams.update([self.request, upstream])
            while not owner.stopped.is_set():
                readable, _, _ = select.select([self.request, upstream], [], [], 0.2)
                for source in readable:
                    data = source.recv(65536)
                    if not data:
                        return
                    (upstream if source is self.request else self.request).sendall(data)
        except OSError:
            # Expected when this test deliberately closes its own transport.
            pass
        finally:
            with owner.lock:
                owner.streams.discard(self.request)
                owner.streams.discard(upstream)
                self.server.streams.discard(self.request)
                self.server.streams.discard(upstream)
            upstream.close()


class Server(socketserver.ThreadingUnixStreamServer):
    daemon_threads = True
    block_on_close = False


class SessionRelay:
    def __init__(self):
        runtime = Path(os.environ["XDG_RUNTIME_DIR"]) / "hypr"
        upstream = runtime / os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
        self.upstream = upstream
        assert (upstream / ".socket.sock").is_socket()
        assert (upstream / ".socket2.sock").is_socket()
        self.folder = tempfile.TemporaryDirectory(prefix="axiom-ipc-test-", dir=runtime)
        self.stopped = threading.Event()
        self.lock = threading.Lock()
        self.streams = set()
        self.servers = []
        self.threads = []
        self.signature = Path(self.folder.name).name
        try:
            for name in [".socket.sock", ".socket2.sock"]:
                server = Server(str(Path(self.folder.name) / name), Relay)
                server.owner = self
                server.upstream = upstream / name
                server.streams = set()
                thread = threading.Thread(target=server.serve_forever, daemon=True)
                try:
                    thread.start()
                except Exception:
                    server.server_close()
                    raise
                self.servers.append(server)
                self.threads.append(thread)
        except Exception:
            self.close()
            self.folder.cleanup()
            raise

    def drop_requests(self):
        for server in self.servers:
            if server.upstream.name != ".socket.sock":
                continue
            server.shutdown()
            with self.lock:
                for stream in server.streams:
                    try:
                        stream.shutdown(socket.SHUT_RDWR)
                    except OSError:
                        pass
            server.server_close()
            (Path(self.folder.name) / ".socket.sock").unlink(missing_ok=True)

    def restore_requests(self):
        server = Server(str(Path(self.folder.name) / ".socket.sock"), Relay)
        server.owner = self
        server.upstream = self.upstream / ".socket.sock"
        server.streams = set()
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        try:
            thread.start()
        except Exception:
            server.server_close()
            raise
        self.servers.append(server)
        self.threads.append(thread)

    def close(self):
        if self.stopped.is_set():
            return
        self.stopped.set()
        for server in self.servers:
            server.shutdown()
        with self.lock:
            for stream in self.streams:
                try:
                    stream.shutdown(socket.SHUT_RDWR)
                except OSError:
                    pass
        for server in self.servers:
            server.server_close()
        for thread in self.threads:
            thread.join(timeout=3)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--request-only", action="store_true")
    args = parser.parse_args()
    check = runpy.run_path(str(Path(__file__).with_name("window-state-smoke.py")))["check"]
    relay = SessionRelay()
    try:
        result = check(False, session_env={"HYPRLAND_INSTANCE_SIGNATURE": relay.signature},
                       disconnect=relay.drop_requests if args.request_only else relay.close,
                       recover=relay.restore_requests if args.request_only else None)
        assert result["disconnect"]["eventConnected"] == args.request_only
        print(json.dumps({"loss": result, "reinitialized": check(False)}, indent=2))
    finally:
        relay.close()
        relay.folder.cleanup()
