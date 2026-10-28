#!/usr/bin/env python3
"""Verify REA's MCP transport/catalog and a bounded read-only artifact probe.

No installation/configuration, engine startup, attach, capture or target execution.
"""
import json
import os
from pathlib import Path
import selectors
import subprocess
import tempfile
import time

EXPECTED_VERSION = "6.8.0"
TARGET = "/usr/lib/qt6/qml/Quickshell/Hyprland"


def verify():
    with tempfile.TemporaryFile() as log:
        server = subprocess.Popen(
            ["rea", "mcp"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=log, bufsize=0)
        selector = selectors.DefaultSelector()
        selector.register(server.stdout, selectors.EVENT_READ)
        buffered = bytearray()

        def send(message):
            server.stdin.write(json.dumps(message).encode() + b"\n")
            server.stdin.flush()

        def request(number, method, params):
            send(dict(jsonrpc="2.0", id=number, method=method, params=params))
            deadline = time.monotonic() + 45
            while time.monotonic() < deadline:
                while b"\n" in buffered:
                    line, _, rest = buffered.partition(b"\n")
                    buffered[:] = rest
                    message = json.loads(line)
                    if message.get("id") == number:
                        if "error" in message:
                            raise RuntimeError(message["error"])
                        return message["result"]
                if not selector.select(max(0, deadline - time.monotonic())):
                    break
                chunk = os.read(server.stdout.fileno(), 65536)
                if not chunk:
                    raise RuntimeError("REA closed MCP stdout")
                buffered.extend(chunk)
                if len(buffered) > 16 * 1024 * 1024:
                    raise RuntimeError("MCP response exceeded verification bound")
            raise TimeoutError(method)

        try:
            initialized = request(1, "initialize", {
                "protocolVersion": "2024-11-05", "capabilities": {},
                "clientInfo": {"name": "axiom-research-verifier", "version": "1"}})
            assert initialized["serverInfo"]["version"] == EXPECTED_VERSION
            send({"jsonrpc": "2.0", "method": "notifications/initialized"})
            catalog = request(2, "tools/list", {})
            tools = catalog["tools"]
            assert not catalog.get("nextCursor"), "Verifier needs explicit catalog paging"
            names = {tool["name"] for tool in tools}
            assert {"binary_session", "inspect_desktop_application"} <= names
            session = request(3, "tools/call", {
                "name": "binary_session", "arguments": {
                    "expected_package_version": EXPECTED_VERSION}})
            assert not session.get("isError"), session
            assert Path(TARGET).is_dir(), "Installed Quickshell target missing"
            inspected = request(4, "tools/call", {
                "name": "inspect_desktop_application", "arguments": {
                    "path": TARGET, "max_entries": 40, "max_probe_bytes": 4096}})
            assert not inspected.get("isError"), inspected
            evidence = inspected["structuredContent"]
            return {
                "server": initialized["serverInfo"], "toolCount": len(tools),
                "sessionCall": "PASS", "inspectionCall": "PASS",
                "target": TARGET, "evidenceId": evidence["evidence_id"],
                "scope": evidence["normalized_result"],
                "limitations": evidence["limitations"]}
        finally:
            selector.close()
            server.stdin.close()
            try:
                server.wait(timeout=8)
            except subprocess.TimeoutExpired:
                server.terminate()
                try:
                    server.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    server.kill()
                    server.wait(timeout=5)


if __name__ == "__main__":
    print(json.dumps(verify(), indent=2))
