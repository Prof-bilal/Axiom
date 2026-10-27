#!/usr/bin/env python3
"""Capture a QEMU screen through QMP and save it as PNG (stdlib only)."""
from __future__ import annotations

import json
import socket
import struct
import sys
import zlib
from pathlib import Path


def qmp(sock_path: str, command: str, arguments: dict | None = None) -> dict:
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(15)
    sock.connect(sock_path)
    stream = sock.makefile("rwb", buffering=0)
    stream.readline()  # greeting
    for payload in (
        {"execute": "qmp_capabilities"},
        {"execute": command, "arguments": arguments or {}},
    ):
        stream.write(json.dumps(payload).encode() + b"\n")
        while True:
            line = stream.readline()
            if not line:
                raise RuntimeError("QMP closed the connection")
            msg = json.loads(line)
            if "error" in msg:
                raise RuntimeError(msg["error"].get("desc", "QMP error"))
            if "return" in msg:
                break
    sock.close()
    return {"ok": True}


def read_ppm(path: Path) -> tuple[int, int, bytes]:
    data = path.read_bytes()
    if not data.startswith(b"P6"):
        raise ValueError("screendump did not produce a P6 PPM")
    fields: list[bytes] = []
    index = 2
    while len(fields) < 3:
        while index < len(data) and data[index : index + 1].isspace():
            index += 1
        if index < len(data) and data[index : index + 1] == b"#":
            index = data.index(b"\n", index) + 1
            continue
        start = index
        while index < len(data) and not data[index : index + 1].isspace():
            index += 1
        fields.append(data[start:index])
    width, height, max_value = map(int, fields)
    if max_value != 255:
        raise ValueError("unsupported PPM max value")
    if index >= len(data) or not data[index : index + 1].isspace():
        raise ValueError("missing PPM pixel separator")
    index += 1
    pixels = data[index : index + width * height * 3]
    if len(pixels) != width * height * 3:
        raise ValueError("truncated PPM")
    return width, height, pixels


def write_png(width: int, height: int, rgb: bytes, path: Path) -> None:
    raw = bytearray()
    stride = width * 3
    for y in range(height):
        raw.append(0)
        raw.extend(rgb[y * stride : (y + 1) * stride])

    def chunk(tag: bytes, payload: bytes) -> bytes:
        return (
            struct.pack(">I", len(payload))
            + tag
            + payload
            + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF)
        )

    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b"")
    )


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: qmp-screenshot.py <qmp-socket> <out.png>", file=sys.stderr)
        return 2
    sock_path, out_path = sys.argv[1:]
    out = Path(out_path).resolve()
    ppm = out.with_suffix(".ppm")
    qmp(sock_path, "screendump", {"filename": str(ppm)})
    width, height, rgb = read_ppm(ppm)
    write_png(width, height, rgb, out)
    ppm.unlink(missing_ok=True)
    print(f"{out} ({width}x{height})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
