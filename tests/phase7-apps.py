#!/usr/bin/env python3
"""Axiom Phase 7 acceptance driver (QEMU/KVM): Hub, click-to-install and the app-file handlers.

    tests/phase7-apps.py <iso> [outdir] [--res 1920x1080] [--only hub,quickinstall,handlers]

Boots the image and checks results on disk, in the serial log and in process state.
Screenshots are retained as evidence and are never the pass/fail signal.

Sections:
  hub           the Hub starts with no QML errors and lists the catalogue
  quickinstall  a downloaded AppImage installs through the click-to-install window: the file lands in
                ~/Applications, its menu entry exists, the window closes itself, nothing errors
  handlers      the file-type associations point at the click-to-install window
Not covered yet: the .deb path (needs distrobox, podman and network inside the guest) and
installing a Hub app (needs network). Those stay open until a networked run.

Exit codes: 0 pass, 1 failures, 2 usage, 3 firmware-stage stall (retry the run).
No networking, no host shares.
"""
import json
import os
import re
import shlex
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qemu_lib import Guest  # noqa: E402

args = sys.argv[1:]
if not args or not os.path.isfile(args[0]):
    print(__doc__)
    sys.exit(2)
ISO = args[0]
OUT = args[1] if len(args) > 1 and not args[1].startswith("--") else "iso/out-phase7/evidence"
RES = "1920x1080"
ONLY = None
for i, a in enumerate(args):
    if a == "--res" and i + 1 < len(args):
        RES = args[i + 1]
    if a == "--only" and i + 1 < len(args):
        ONLY = set(args[i + 1].split(","))
OUT = os.path.join(OUT, RES)
os.makedirs(OUT, exist_ok=True)


def want(section):
    return ONLY is None or section in ONLY


results = {"resolution": RES, "iso": os.path.basename(ISO)}
HOME = "/home/axiom"
APPIMAGE = "Axiom-Phase7-Test-1.0-x86_64.AppImage"

# A tiny executable stand-in for an AppImage: it is only copied, never run.
FIXTURE = r"""#!/bin/sh
set -e
mkdir -p "$HOME/Downloads" "$HOME/Applications" "$HOME/.local/share/applications"
# The fixture runs as root; hand the folders to the desktop user so the installer can write there.
chown -R axiom "$HOME/Downloads" "$HOME/Applications" "$HOME/.local" 2>/dev/null || true
rm -f "$HOME/Applications/Axiom-Phase7-Test-1.0-x86_64.AppImage"
rm -f "$HOME/.local/share/applications/axiom-Axiom-Phase7-Test-1.0-x86_64.AppImage.desktop"
printf '#!/bin/sh\necho phase7\n' > "$HOME/Downloads/Axiom-Phase7-Test-1.0-x86_64.AppImage"
chmod 644 "$HOME/Downloads/Axiom-Phase7-Test-1.0-x86_64.AppImage"
echo FIXTURE_OK
"""

# --- boot -------------------------------------------------------------------------------------
# A firmware-stage stall (UEFI never hands off, so no guest output) is host flakiness:
# retry it, as tests/qemu-boot.sh does. Every attempt's evidence is kept.
ATTEMPTS = int(os.environ.get("QEMU_BOOT_ATTEMPTS", "3"))
for attempt in range(1, ATTEMPTS + 1):
    g = Guest(ISO, OUT, RES)
    g.start()
    if g.wait_login():
        print(f"phase7: guest reached a login prompt on attempt {attempt}")
        break
    g.shot(f"00-firmware-stall-{attempt}")
    print(f"phase7: attempt {attempt}/{ATTEMPTS} stalled in firmware; retrying")
    g.kill()
else:
    print("STALL: firmware stage produced no kernel/systemd output on every attempt")
    sys.exit(3)
if not g.login_root():
    g.bad("could not get a root shell on the serial console")
    g.kill()
    sys.exit(1)
if not g.shell_ready():
    g.shot("00-failure")
    g.bad("session did not become ready")
    g.kill()
    sys.exit(1)
g.ok(f"session ready at {RES}")
g.prepare_env()
time.sleep(3)


# --- helpers ----------------------------------------------------------------------------------
def eventually(cmd, timeout=20):
    """Poll a root-shell condition until it succeeds."""
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        rc, _ = g.sh(cmd, 20)
        if rc == 0:
            return True
        time.sleep(1.0)
    return False


def kill_apps():
    # Bracketed patterns so pkill never matches this command's own shell.
    g.sh("pkill -f '[a]xiom-app (hub|quickinstall)'; pkill -f '[s]hell/hub.qml'; "
         "pkill -f '[s]hell/quickinstall.qml'; true", 20)
    time.sleep(1.5)


def qml_errors(log):
    """Count QML TypeError/ReferenceError lines in a Quickshell log (ignores portal noise)."""
    rc, out = g.sh(f"grep -c -E 'TypeError|ReferenceError|is not a type|Cannot assign' {log} 2>/dev/null || true", 10)
    m = re.search(r"\d+", out or "")
    return int(m.group(0)) if m else 0


# =========================================================================================
if want("hub"):
    kill_apps()
    g.user(f"nohup axiom-app hub > /tmp/phase7-hub.out 2>&1 &", 20)
    loaded = eventually("grep -q 'Configuration Loaded' /tmp/phase7-hub.out", 60)
    time.sleep(7)
    g.check(loaded, "hub: the Hub's Quickshell config loaded")
    errs = qml_errors("/tmp/phase7-hub.out")
    results["hub_qml_errors"] = errs
    g.check(errs == 0, f"hub: no QML errors at startup ({errs})")
    rc, out = g.sh(
        "python3 -c \"import json,re;"
        "s=open('/usr/local/share/axiom/shell/apps/hub/catalog.js').read();"
        "print(len(re.findall(r'\\\"id\\\":', s)))\"", 20)
    m = re.search(r"\d+", out or "")
    count = int(m.group(0)) if m else 0
    results["hub_catalog_entries"] = count
    g.check(count >= 97, f"hub: catalogue on the image lists {count} entries (expected 97)")
    g.shot("hub-01-started")
    kill_apps()

# =========================================================================================
if want("quickinstall"):
    kill_apps()
    g.sh(f"HOME={HOME} sh -c {shlex.quote(FIXTURE)}", 30)
    g.user(f"nohup env AXIOM_APP_ARG={shlex.quote(HOME + '/Downloads/' + APPIMAGE)} "
           f"axiom-app quickinstall > /tmp/phase7-quick.out 2>&1 &", 20)
    installed = eventually(f"test -x {HOME}/Applications/{APPIMAGE}", 60)
    g.check(installed, "quickinstall: the AppImage was copied to ~/Applications and is executable")
    entry = f"{HOME}/.local/share/applications/axiom-{APPIMAGE}.desktop"
    entry_ok = eventually(f"grep -q '^Exec=' {entry}", 30)
    g.check(entry_ok, "quickinstall: a menu entry was written to ~/.local/share/applications")
    if entry_ok:
        rc, out = g.sh(f"cat {entry}", 10)
        g.check("Name=Axiom Phase7 Test" in (out or "") or "Name=Axiom-Phase7-Test" in (out or ""),
                "quickinstall: the menu entry names the app")
    time.sleep(4)
    closed = eventually("! pgrep -f '[s]hell/quickinstall.qml' >/dev/null", 30)
    g.check(closed, "quickinstall: the window closed itself after success")
    errs = qml_errors("/tmp/phase7-quick.out")
    results["quickinstall_qml_errors"] = errs
    g.check(errs == 0, f"quickinstall: no QML errors ({errs})")
    g.shot("quickinstall-01-done")
    g.sh(f"rm -f {HOME}/Applications/{APPIMAGE} {entry}", 10)

# =========================================================================================
if want("handlers"):
    rc, out = g.sh("cat /etc/xdg/mimeapps.list 2>/dev/null; cat /usr/local/share/applications/axiom-quickinstall.desktop 2>/dev/null", 10)
    text = out or ""
    for mime in ("application/vnd.appimage", "application/vnd.debian.binary-package"):
        g.check(f"{mime}=axiom-quickinstall.desktop" in text, f"handlers: {mime} opens the click-to-install window")
    g.check("Exec=axiom-app quickinstall %f" in text, "handlers: the handler runs axiom-app quickinstall with the file")

# --- finish --------------------------------------------------------------------------------------
kill_apps()
if g.power_off():
    g.ok("guest powered off cleanly")
else:
    g.bad("guest did not power off within 120s")
    g.kill()

with open(os.path.join(OUT, "results.json"), "w") as f:
    json.dump(results, f, indent=2)
print(json.dumps(results, indent=2))
print("RESULT:", "PASS" if not g.failures else f"FAIL ({len(g.failures)})")
sys.exit(0 if not g.failures else 1)
