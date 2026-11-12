#!/usr/bin/env python3
"""Phase 6 acceptance: install Axiom onto a blank QEMU disk through the real TUI, boot it, log in.

    tests/phase6-install.py ISO OUTDIR [--stage install|installed|provision|all] [--luks]

Each stage runs in a disposable guest (OVMF, retained serial/transcript/screen evidence):
  install    live ISO in installer mode: validation errors, cancel leaves the disk blank, a killed
             install is retryable, full install through the TUI (real key events, no shortcuts)
  installed  boot the installed disk offline: greeter, wrong/right login, session, Settings
             persistence across reboot, lock screen, no autologin, root locked, secrets absent,
             provisioning deferred
  provision  boot with network: first-boot job converges, re-run is idempotent, loopback only

The installer is driven with key events and read back from the screen-text file the pixel renderer writes (/dev/vcs1 as a fallback); nothing is stubbed.
"""
import argparse
import base64
import gzip
import os
import re
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qemu_lib import Guest, QS  # noqa: E402

PW = "correct-horse-9"
LUKS_PW = "luks-passphrase-77"
USER = "dev"
GIT_NAME, GIT_EMAIL = "Dev User", "dev@example.com"
DISK_GB = 24
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HUB_SELECT = ["git", "neovim"]  # git is a default; neovim is ticked in the UI
CONSOLE = "console=ttyS0,115200"
# The pixel renderer bypasses /dev/vcs1, so the guest also writes the screen's characters to this file.
FB_TEXT = "/run/axiom-screen.txt"
LIVE_CMDLINE = f"{CONSOLE} systemd.setenv=AXIOM_FB_TEXT={FB_TEXT}"
NO_REFRESH = False


def mk_disk(out, name="disk.qcow2", gb=DISK_GB):
    path = os.path.join(out, name)
    subprocess.run(["rm", "-f", path])
    subprocess.run(["qemu-img", "create", "-f", "qcow2", path, f"{gb}G"], check=True, stdout=subprocess.DEVNULL)
    return path


def disk_args(path):
    return ["-drive", f"file={path},if=virtio,format=qcow2,cache=unsafe"]


def live_kernel(iso, out):
    k, i = os.path.join(out, "vmlinuz"), os.path.join(out, "initramfs.img")
    for src, dst in (("axiom/boot/x86_64/vmlinuz-linux", k), ("axiom/boot/x86_64/initramfs-linux.img", i)):
        with open(dst, "wb") as fh:
            subprocess.run(["bsdtar", "-xOf", iso, src], check=True, stdout=fh)
    return k, i


def halt(g):
    try:
        g.sh("sync; poweroff -f", 10)
    except OSError:
        pass
    time.sleep(4)


def push(g, path, data, mode="644"):
    b = base64.b64encode(gzip.compress(data)).decode()
    g.sh(f"rm -f /tmp/p.b64; mkdir -p $(dirname {path})", 15)
    for i in range(0, len(b), 1500):
        g.sh(f"printf %s '{b[i:i + 1500]}' >> /tmp/p.b64", 40)
    g.sh(f"base64 -d /tmp/p.b64 | gunzip > {path}; chmod {mode} {path}", 20)


def screen_colours(g, name, targets, tol=40, step=4):
    """Screendump the guest and count (sampled) pixels near each target colour: the pixel-drawn login has no
    text in /dev/vcs, so its state is read from colours. Returns {name: count}."""
    ppm = g.p(name + ".ppm")
    if os.path.exists(ppm):
        os.unlink(ppm)
    g.monitor(f"screendump {ppm}", settle=1.2)
    if not os.path.exists(ppm) or os.path.getsize(ppm) == 0:
        return {k: 0 for k in targets}
    data = open(ppm, "rb").read()
    os.unlink(ppm)
    head = data.split(b"\n", 3)
    w, h = (int(v) for v in head[1].split())
    px = head[3]
    counts = {k: 0 for k in targets}
    for i in range(0, w * h * 3, 3 * step):
        r, gr, b = px[i], px[i + 1], px[i + 2]
        for k, (tr, tg, tb) in targets.items():
            if abs(r - tr) < tol and abs(gr - tg) < tol and abs(b - tb) < tol:
                counts[k] += 1
    return counts


LOGIN_COLOURS = {"wordmark": (0x7C, 0xF0, 0xBE), "box": (0x20, 0xD6, 0xD2), "error": (0xFF, 0x8A, 0x8A)}


def wait_login_screen(g, timeout=120, want="wordmark", at_least=300):
    """True once the pixel login is on screen (its mint wordmark or, with want='error', its red message)."""
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        if screen_colours(g, "login-probe", LOGIN_COLOURS)[want] >= at_least:
            return True
        time.sleep(4)
    return False


def refresh_installer(g):
    """Overlay the working-tree installer files onto the live medium and restart the TUI."""
    files = (("installer/axiom_install.py", "/usr/local/lib/axiom-installer/axiom_install.py", "755"),
             ("installer/axiom-installer", "/usr/local/lib/axiom-installer/axiom-installer", "755"),
             ("catalog/developer-hub.json", "/usr/local/lib/axiom-installer/catalog/developer-hub.json", "644"),
             ("catalog/developer-hub.json", "/usr/local/share/axiom/catalog/developer-hub.json", "644"),
             ("provision/axiom-provision", "/usr/local/lib/axiom-provision/axiom-provision", "755"),
             ("provision/axiom-provision.service", "/usr/local/lib/axiom-provision/axiom-provision.service", "644"),
             ("tui/axiom_tui.py", "/usr/local/lib/axiom-tui/axiom_tui.py", "644"),
             ("tui/fbdraw.py", "/usr/local/lib/axiom-tui/fbdraw.py", "644"),
             ("tui/penguin_art.py", "/usr/local/lib/axiom-tui/penguin_art.py", "644"),
             ("tui/penguin_image.bin", "/usr/local/lib/axiom-tui/penguin_image.bin", "644"),
             ("greeter/axiom-greeter", "/usr/local/lib/axiom-greeter/axiom-greeter", "755"))
    for rel, dst, mode in files:
        push(g, dst, open(os.path.join(REPO, rel), "rb").read(), mode)
    g.sh("ln -sf /usr/local/lib/axiom-installer/axiom-installer /usr/local/bin/axiom-installer; "
         "ln -sf /usr/local/lib/axiom-provision/axiom-provision /usr/local/bin/axiom-provision; "
         f"systemctl set-environment AXIOM_FB_TEXT={FB_TEXT}; "
         "systemctl reset-failed axiom-installer; systemctl restart axiom-installer", 20)


class Tui:
    """Drive the installer on tty1 with key events; read it from /dev/vcs1."""

    def __init__(self, g):
        self.g, self.last = g, ""

    def screen(self):
        rc, out = self.g.sh(f"cat {FB_TEXT} 2>/dev/null || "
                            "{ c=$(stty -F /dev/tty1 size | cut -d' ' -f2); fold -w $c /dev/vcs1 2>&1; }", 20)
        self.last = "\n".join(l.rstrip() for l in (out or "").splitlines() if l.strip())
        return self.last

    def wait(self, text, timeout=60):
        end = time.monotonic() + timeout
        while time.monotonic() < end:
            if text in self.screen():
                return True
            time.sleep(1.5)
        return False

    def enter(self, n=1):
        for _ in range(n):
            self.g.key("ret", 0.8)

    def wipe(self, n=34):
        for _ in range(n):
            self.g.key("backspace", 0.08)

    def say(self, text):
        self.g.type(text, 0.3)


def fill_form(g, t, luks=False):
    """Walk steps 1-5 with real keys up to (not including) the ERASE confirmation."""
    t.enter()  # Install Axiom
    g.check(t.wait("Language and time"), "step 1 (language and time) shown")
    scr = t.last
    g.check("<  English (United States)" in scr and "<  English (US)" in scr and scr.count("<  UTC") == 2,
            "step 1 opens on the old defaults (en_US, us, UTC)")
    t.say("x")
    g.check("<  English (United States)" in t.screen(), "typing a letter is ignored on Language")
    g.key("right", 0.6)
    g.check("<  English (United Kingdom)" in t.screen(), "Left/Right changes Language")
    g.key("left", 0.6)
    g.key("down", 0.6)
    t.say("x")
    g.check("<  English (US)" in t.screen(), "typing a letter is ignored on Keyboard")
    g.key("right", 0.6)
    g.check("<  English (UK)" in t.screen(), "Left/Right changes Keyboard")
    g.key("left", 0.6)
    g.key("down", 0.6)
    g.key("right", 0.8)
    g.check("<  UTC" not in t.screen(), "Left/Right changes Region and rebuilds the City list")
    g.key("left", 0.8)
    g.check(t.screen().count("<  UTC") == 2, "Region cycles back to UTC and City follows")
    t.enter(2)  # city, then continue with the defaults
    g.check(t.wait("Choose a disk", 20), "step 2 (disk) shown")
    scr = t.last
    g.check("/dev/vda" in scr, "installer offers the blank virtio disk")
    g.check("/dev/sr0" not in scr and "loop0" not in scr, "live medium and loop devices are not offered")
    if luks:
        g.key("down", 0.4); g.key("spc", 0.5); g.key("down", 0.4)
        t.say(LUKS_PW)
    t.enter(2 if not luks else 1)
    g.check(t.wait("Create your account", 20), "step 3 (account) shown")
    t.say("Dev User"); t.enter()
    t.say("root"); t.enter()  # reserved username
    t.enter()                 # hostname stays "axiom"
    t.say("short"); t.enter()
    t.say("short"); t.enter()
    g.check(t.wait("can't be used", 15), "reserved username 'root' is rejected with a plain explanation")
    t.enter()                 # field 0 -> username
    t.wipe(); t.say(USER); t.enter()
    t.wipe(); t.say("axiom-test"); t.enter()
    t.wipe(); t.say(PW); t.enter()
    t.wipe(); t.say(PW + "x"); t.enter()
    g.check(t.wait("two passwords are different", 15), "mismatched passwords are rejected")
    t.enter(3)
    t.wipe(); t.say(PW); t.enter()
    t.wipe(); t.say(PW); t.enter()
    g.check(t.wait("Git identity", 30), "valid account accepted")
    t.say(GIT_NAME); t.enter()
    t.say(GIT_EMAIL); t.enter()
    g.check(t.wait("Choose your tools", 20), "step 5 (tools) shown")
    scr = t.last
    g.check("Git + GitHub CLI" in scr and "Neovim" in scr, "Hub lists catalogue items")
    g.key("down", 0.4)
    g.key("spc", 0.5)  # Neovim (second editor)
    t.enter()
    g.check(t.wait("Check and install", 20), "review screen shown")
    scr = t.last
    g.check("will be erased" in scr and "/dev/vda" in scr, "review shows the destructive plan with the target")
    g.check(PW not in scr and LUKS_PW not in scr, "review does not echo secrets")
    g.check("neovim" in scr and "git" in scr, "review lists the selected Hub items")


def inspect_target(g, out, luks):
    """Mount the written disk read-only and check layout, subvolumes, boot entries and the profile."""
    unlock = ("printf %%s '%s' | cryptsetup open /dev/vda2 chk --key-file=- && R=/dev/mapper/chk; " % LUKS_PW) if luks else "R=/dev/vda2; "
    rc, o = g.sh("sfdisk -d /dev/vda; blkid -o value -s TYPE /dev/vda2; mkdir -p /m && " + unlock +
                 "mount -o ro,subvol=@ $R /m && mount -o ro /dev/vda1 /m/boot && "
                 "ls /m/boot/loader/entries; cat /m/boot/loader/entries/*.conf | head -20; "
                 "btrfs subvolume list /m | cut -d' ' -f9; ls -la /m/var/lib/axiom; "
                 "umount /m/boot /m; " + ("cryptsetup close chk" if luks else "true"), 90)
    open(os.path.join(out, "target-inspection.txt"), "w").write(o)
    g.check("label: gpt" in o, "GPT layout written")
    g.check("@snapshots" in o and "@home" in o, "btrfs subvolumes created (@, @home, @snapshots, ...)")
    g.check("console=ttyS0" in o, "boot entries carry the console option")
    g.check("profile.json" in o, "Developer Hub profile recorded in /var/lib/axiom")
    g.check(luks == ("crypto_LUKS" in o), "LUKS state matches the request")


def stage_inspect(iso, out, luks=False):
    """Re-inspect an installed disk from a live boot (used when the install stage's own inspection needs a rerun)."""
    g = Guest(iso, out, mem=2048)
    inst = os.path.join(os.path.dirname(out), "install")
    g.vars_src = os.path.join(inst, "OVMF_VARS.fd")
    g.extra = [*disk_args(os.path.join(inst, "disk.qcow2")), "-kernel", os.path.join(inst, "vmlinuz"),
               "-initrd", os.path.join(inst, "initramfs.img"), "-append",
               f"archisobasedir=axiom archisodevice=/dev/sr0 {LIVE_CMDLINE}"]
    g.start()
    g.check(g.wait_login(), "live medium booted for inspection")
    time.sleep(20)
    g.login_root()
    inspect_target(g, out, luks)
    halt(g)
    return g


def stage_install(iso, out, luks=False):
    g = Guest(iso, out, mem=2560, smp=2)
    disk = mk_disk(out)
    kern, initrd = live_kernel(iso, out)
    g.extra = ["-nic", "user,model=virtio-net-pci", *disk_args(disk), "-kernel", kern, "-initrd", initrd,
               "-append", f"archisobasedir=axiom archisodevice=/dev/sr0 axiom.installer=1 {LIVE_CMDLINE}"]
    g.start()
    try:
        if not g.check(g.wait_login(), "live medium booted in installer mode"):
            return g
        time.sleep(15)
        g.check(g.login_root(), "root serial shell available")
        if not NO_REFRESH:
            refresh_installer(g)  # iterate on the working tree without an ISO rebuild
        else:
            g.check(g.sh("test -x /usr/local/bin/axiom-installer && test -x /usr/local/lib/axiom-greeter/axiom-greeter", 10)[0] == 0, "installer and greeter ship executable in the ISO")
        t = Tui(g)
        g.check(t.wait("Welcome to Axiom!", 60), "welcome screen shown on tty1")
        scr = t.last
        g.check("Install Axiom" in scr and "Advanced options" in scr, "welcome menu entries present")
        g.check("pixel renderer: drm" in g.sh("cat /run/axiom-ui.log 2>&1", 10)[1], "installer draws through DRM (pixel renderer), not the text-console fallback")
        g.check(g.sh("systemctl is-active axiom-installer", 15)[1].strip() == "active", "installer service owns tty1")
        g.check(80 <= int(g.sh("stty -F /dev/tty1 size", 10)[1].split()[-1]) <= 130, "large console font is active (about 120 columns at 1920x1080; the default font gives 240)")
        g.check(g.sh("! pgrep -x axiom-session && ! pgrep -x quickshell", 10)[0] == 0,
                "no desktop session in installer mode")

        # 1) validation + cancel path
        fill_form(g, t, luks)
        t.say("erase"); t.enter()
        g.check(t.wait("capital letters", 10), "lowercase confirmation is rejected")
        for _ in range(8):
            g.key("esc", 0.7)
        g.check(t.wait("Welcome to Axiom!", 20), "Esc walks back to the welcome menu")
        rc, o = g.sh("sfdisk -d /dev/vda 2>&1; echo; lsblk -no NAME /dev/vda | wc -l", 15)
        g.check("label" not in o and o.strip().splitlines()[-1] == "1", "cancel wrote nothing: disk still blank")

        # 2) interrupted install: kill archinstall mid-run, expect a clear failure and a retryable machine
        fill_form(g, t, luks)
        t.say("ERASE"); t.enter()
        g.check(t.wait("Installing Axiom", 30), "install started")
        ok = False
        for _ in range(60):
            if g.sh("pgrep -f '[b]in/archinstall' >/dev/null", 10)[0] == 0:
                ok = True
                break
            time.sleep(2)
        g.check(ok, "archinstall is running")
        time.sleep(40)
        g.sh("pkill -9 -f '[b]in/archinstall'; true", 10)
        g.check(t.wait("did not finish", 60), "killed install is reported as failed")
        g.sh("cp /var/log/axiom-installer.log /root/axiom-installer.interrupted.log", 10)
        t.enter()
        g.check(t.wait("Welcome to Axiom!", 20), "installer returns to the menu after failure")
        g.check(g.sh("findmnt -R /mnt >/dev/null 2>&1; test $? -ne 0", 15)[0] == 0, "failed install left nothing mounted")

        # 3) retry: full install onto the half-written disk
        fill_form(g, t, luks)
        t.say("ERASE"); t.enter()
        g.check(t.wait("Installing Axiom", 30), "retry install started")
        t0 = time.monotonic()
        done, seen, shots = False, [], []
        while time.monotonic() - t0 < 2400:
            scr = t.screen()
            seen.append(scr)
            m = re.findall(r"(?m)^\s*(\d{1,3})%\s*$", scr)
            if m and 30 <= int(m[-1]) <= 70 and not shots:
                g.shot("installing-penguin")
                shots.append(1)
            if "Axiom is ready" in scr or "did not finish" in scr:
                g.shot("install-finished")
                done = "Axiom is ready" in scr
                break
            time.sleep(20)
        g.check(done, f"install completed through the TUI ({int(time.monotonic() - t0)} s)")
        pcts = []
        for scr in seen:
            m = re.findall(r"(?m)^\s*(\d{1,3})%\s*$", scr)
            if m:
                pcts.append(int(m[-1]))
        g.check(len(set(pcts)) >= 6 and pcts == sorted(pcts), f"progress moved smoothly and never went backwards ({sorted(set(pcts))[:12]}...)")
        text = "\n".join(seen)
        g.check("Downloading Axiom" in text and "Installing the system" in text, "progress screen names the real stages (download, install)")
        g.check(bool(re.search(r"Package \d+ of \d+", text)) and bool(re.search(r"MiB downloaded", text)), "progress shows package counts and download size")
        g.sh("cp /var/log/axiom-installer.log /root/axiom-installer.final.log", 10)
        if not done:  # keep the evidence of why it failed (progress bars filtered out)
            open(os.path.join(out, "installer-failure.log"), "w").write(
                g.sh("tr '\\r' '\\n' < /var/log/axiom-installer.log | grep -v -E '^ *[a-z0-9._+-]+ +[0-9.]+ [KMG]iB|Total \\(|^\\([ 0-9]+/[0-9]+\\)' | tail -80", 30)[1])
        inspect_target(g, out, luks)
        # secrets: the installer logs must not contain either secret
        rc, o = g.sh("grep -c -e '%s' -e '%s' /var/log/axiom-installer.log /root/axiom-installer.*.log || true" % (PW, LUKS_PW), 20)
        g.check(all(l.endswith(":0") for l in o.strip().splitlines() if ":" in l), "no password or passphrase in installer logs")
        halt(g)
        return g
    except Exception:
        g.failures.append("exception during install stage")
        raise


class Installed:
    """Boot the installed disk (no ISO). Root is locked, so a serial root shell is reached through sudo."""

    def __init__(self, out, disk, vars_src, net=False):
        self.g = Guest(None, out, mem=2560, smp=2)
        self.g.vars_src = vars_src
        self.g.duser = USER
        self.g.extra = (["-nic", "user,model=virtio-net-pci"] if net else []) + disk_args(disk)
        self.t = Tui(self.g)

    def serial_login(self, luks=False):
        g = self.g
        if luks:
            g.check(g.wait_for("Enter passphrase", 300) or g.wait_for("passphrase", 60), "LUKS passphrase prompt appears at boot")
            time.sleep(2)
            g._write(LUKS_PW + "\n")
        if not g.wait_for("login:", 420):
            return False
        time.sleep(3)
        g._write(USER + "\n")
        time.sleep(2)
        g._write(PW + "\n")
        time.sleep(5)
        g._write("sudo -S -p '' -i\n")
        time.sleep(2)
        g._write(PW + "\n")
        time.sleep(3)
        g._write("exec sh\n")
        time.sleep(2)
        g._write("stty -echo; PS1=; PS2=\n")
        time.sleep(1.5)
        return g.sh("id -u", 15)[1].strip() == "0"

    def wait_ready(self, start, timeout=240):
        return self.g.wait_for("AXIOM_SHELL_READY", timeout, start)


def relogin(g, mark, luks):
    """After a reboot: unlock LUKS if needed, then get a root shell through the user's sudo."""
    if luks:
        g.check(g.wait_for("passphrase", 300, mark), "LUKS passphrase prompt appears again after reboot")
        time.sleep(2)
        g._write(LUKS_PW + "\n")
    ok = g.wait_for("login:", 420, mark)
    time.sleep(3)
    g._write(USER + "\n"); time.sleep(2); g._write(PW + "\n"); time.sleep(5)
    g._write("sudo -S -p '' -i\n"); time.sleep(2); g._write(PW + "\n"); time.sleep(3)
    g._write("exec sh\n"); time.sleep(2); g._write("stty -echo; PS1=; PS2=\n"); time.sleep(1.5)
    return ok


def greeter_login(g, t, password):
    g.check(wait_login_screen(g), "greeter is on screen")
    time.sleep(1)
    t.say(password)
    t.enter()


def stage_installed(out, disk, vars_src, luks=False):
    inst = Installed(out, disk, vars_src)
    g, t = inst.g, inst.t
    g.start()
    try:
        g.check(inst.serial_login(luks), "installed system boots; the created user can sudo to a root shell (password via sudo)")
        g.check(g.sh("systemctl is-active greetd", 15)[1].strip() == "active", "greetd is the login manager")
        g.check(g.sh("grep -rIl autologin /etc/systemd /etc/greetd /etc/sddm* 2>/dev/null | wc -l", 15)[1].strip() == "0",
                "no autologin configured on the installed system")
        g.check(g.sh("passwd -S root | cut -d' ' -f2", 15)[1].strip() == "L", "root account is locked")
        g.check(g.sh("findmnt -no FSTYPE /; findmnt -no FSTYPE /boot", 15)[1].split() == ["btrfs", "vfat"], "root is btrfs, /boot is the ESP")
        g.check(g.sh("grep -c . /var/lib/axiom/profile.json && grep -q neovim /var/lib/axiom/profile.json && "
                     "! grep -q -i -e password -e passphrase /var/lib/axiom/profile.json", 15)[0] == 0,
                "profile.json lists the selection and holds no secrets")
        g.check(g.sh(f"stat -c '%a %U' /home/{USER}/.config/axiom/dev-profile.json", 15)[1].strip() == f"600 {USER}",
                "user copy of the profile is private (0600)")
        g.check(g.sh(f"git config --file /home/{USER}/.gitconfig user.name; git config --file /home/{USER}/.gitconfig user.email", 15)[1].split("\n")
                == [GIT_NAME, GIT_EMAIL], "git identity from the installer is set")
        g.check(g.sh("test -x /usr/local/bin/axiom-session && test -f /usr/local/share/axiom/shell/shell.qml && "
                     "test -f /etc/polkit-1/rules.d/51-axiom-system-settings.rules", 15)[0] == 0, "Axiom session, shell and polkit rules were installed")
        g.check(g.sh("ls /boot/loader/entries | grep -c -e linux.conf -e lts", 15)[1].strip() == "2", "two boot entries: linux and the linux-lts fallback")
        g.check(g.sh("systemctl is-enabled NetworkManager bluetooth power-profiles-daemon axiom-provision | sort -u", 15)[1].strip() == "enabled",
                "services enabled: NetworkManager, bluetooth, power-profiles-daemon, axiom-provision")
        # greeter: wrong password, then right password
        g.check(wait_login_screen(g), "greeter drawn: the AXIOM wordmark is on screen")
        cols = screen_colours(g, "login-check", LOGIN_COLOURS)
        g.check(cols["wordmark"] >= 300 and cols["box"] >= 100, f"greeter shows the wordmark and the password box ({cols})")
        g.check(g.sh("journalctl -u greetd --no-pager | grep -c 'pixel renderer: drm'", 20)[1].strip() not in ("", "0"),
                "the greeter draws through DRM (pixel renderer), not the text-console fallback")
        g.check(80 <= int(g.sh("stty -F /dev/tty1 size", 10)[1].split()[-1]) <= 130, "installed system uses the large console font (vconsole.conf)")
        g.shot("greeter-login")
        start = len(g.raw)
        t.say("wrong-password-1"); t.enter()
        g.check(wait_login_screen(g, 30, want="error"), "wrong password is rejected with a plain message")
        t.say(PW); t.enter()
        g.check(inst.wait_ready(start, 240), "graphical session started from the greeter (AXIOM_SHELL_READY)")
        g.check(g.sh(f"loginctl list-sessions --no-legend | grep -c ' {USER} '", 15)[1].strip() != "0", "logind session exists for the user")
        g.prepare_env()
        # Settings persistence
        g.user("mkdir -p ~/.config/axiom && printf '{\"version\":1,\"textScale\":1.2,\"idleBlankMinutes\":7}' > ~/.config/axiom/settings.json", 15)
        g.check(g.user("grep -q '\"idleBlankMinutes\":7' ~/.config/axiom/settings.json", 15)[0] == 0, "setting written")
        # lock screen
        g.check(g.user(f"{QS} call axiom isLocked", 20)[1].strip() == "false", "screen starts unlocked")
        g.user(f"{QS} call axiom lock", 20)
        time.sleep(3)
        g.check(g.user(f"{QS} call axiom isLocked", 20)[1].strip() == "true", "lock request locks the screen")
        t.say("not-the-password"); t.enter()
        time.sleep(3)
        g.check(g.user(f"{QS} call axiom isLocked", 20)[1].strip() == "true", "wrong password keeps the screen locked")
        t.say(PW); t.enter()
        time.sleep(4)
        g.check(g.user(f"{QS} call axiom isLocked", 20)[1].strip() == "false", "correct password unlocks the screen")
        g.shot("installed-session")
        # secrets must not be in the journal or world-readable state
        g.check(g.sh("journalctl -b --no-pager | grep -c -e '%s' -e 'wrong-password-1' -e 'not-the-password' || true" % PW, 30)[1].strip().splitlines()[-1] == "0",
                "no password in the journal")
        g.sh("sync", 20)
        mark = len(g.raw)
        g.sh("systemctl reboot", 15)
        g.check(relogin(g, mark, luks), "installed system reboots")
        g.check(g.sh("id -u", 15)[1].strip() == "0", "root shell after reboot")
        g.check(g.sh(f"grep -q '\"idleBlankMinutes\":7' /home/{USER}/.config/axiom/settings.json", 15)[0] == 0,
                "Settings survived the reboot")
        g.check(g.sh("pgrep -x quickshell >/dev/null; test $? -ne 0", 15)[0] == 0, "no session without login: no autologin after reboot")
        start = len(g.raw)
        greeter_login(g, t, PW)
        g.check(inst.wait_ready(start, 240), "session starts again after reboot")
        g.sh("systemctl is-active axiom-provision; /usr/local/bin/axiom-provision --status", 20)
        deferred = False
        for _ in range(30):
            o = g.sh("/usr/local/bin/axiom-provision --status", 20)[1]
            if "deferred" in o:
                deferred = True
                break
            time.sleep(10)
        g.check(deferred, "offline first boot defers provisioning and keeps the selection (status: deferred)")
        # fallback kernel: one-shot boot into the linux-lts entry
        entry = g.sh("bootctl list --no-pager | sed -n 's/^ *id: *//p' | grep lts | head -1", 20)[1].strip()
        g.check(bool(entry), "bootctl lists a linux-lts entry")
        mark = len(g.raw)
        g.sh(f"bootctl set-oneshot {entry}; systemctl reboot", 20)
        g.check(relogin(g, mark, luks), "system reboots into the fallback entry")
        g.check("lts" in g.sh("uname -r", 15)[1], "fallback boot runs the linux-lts kernel")
        halt(g)
        return g
    except Exception:
        g.failures.append("exception during installed stage")
        raise


def stage_provision(out, disk, vars_src, luks=False):
    inst = Installed(out, disk, vars_src, net=True)
    g = inst.g
    g.start()
    try:
        g.check(inst.serial_login(luks), "installed system boots with network")
        done = False
        for _ in range(60):
            o = g.sh("/usr/local/bin/axiom-provision --status", 20)[1]
            if "Developer Hub: done" in o:
                done = True
                break
            if "Developer Hub: partial" in o:
                break
            time.sleep(10)
        g.check(done, "first-boot job applied the selected items (status: done)")
        open(os.path.join(out, "provision-status.txt"), "w").write(g.sh("/usr/local/bin/axiom-provision --status", 20)[1])
        g.check(g.sh("pacman -Q git github-cli neovim >/dev/null 2>&1", 30)[0] == 0, "git, github-cli and neovim are installed")
        g.check("ok" in g.sh("/usr/local/bin/axiom-provision --status | grep neovim", 20)[1], "status reports neovim ok")
        t0 = time.monotonic()
        g.sh("systemctl restart axiom-provision", 120)
        g.check(time.monotonic() - t0 < 60 and "Developer Hub: done" in g.sh("/usr/local/bin/axiom-provision --status", 20)[1],
                "re-running the job is idempotent and quick")
        rc, o = g.sh("ss -ltnH | awk '{print $4}'", 20)
        bad = [l for l in o.split() if not (l.startswith("127.") or l.startswith("[::1]") or l.startswith("::1"))]
        g.check(not bad, f"no listeners outside loopback ({bad})")
        halt(g)
        return g
    except Exception:
        g.failures.append("exception during provision stage")
        raise


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("iso")
    ap.add_argument("out")
    ap.add_argument("--stage", default="all")
    ap.add_argument("--luks", action="store_true")
    ap.add_argument("--no-refresh", action="store_true", help="test the ISO exactly as built")
    a = ap.parse_args()
    NO_REFRESH = a.no_refresh
    os.makedirs(a.out, exist_ok=True)
    fails = []
    if a.stage in ("install", "all"):
        g = stage_install(a.iso, os.path.join(a.out, "install"), a.luks)
        fails += g.failures
        g.kill()
    if a.stage == "inspect":
        g = stage_inspect(a.iso, os.path.join(a.out, "inspect"), a.luks)
        fails += g.failures
        g.kill()
    if a.stage in ("installed", "all") and not fails:
        g = stage_installed(os.path.join(a.out, "installed"), os.path.join(a.out, "install", "disk.qcow2"),
                            os.path.join(a.out, "install", "OVMF_VARS.fd"), a.luks)
        fails += g.failures
        g.kill()
    if a.stage in ("provision", "all") and not fails:
        g = stage_provision(os.path.join(a.out, "provision"), os.path.join(a.out, "install", "disk.qcow2"),
                            os.path.join(a.out, "installed", "OVMF_VARS.fd" if os.path.exists(os.path.join(a.out, "installed", "OVMF_VARS.fd")) else "../install/OVMF_VARS.fd"), a.luks)
        fails += g.failures
        g.kill()
    print("FAILURES:" if fails else "ALL PASSED", fails)
    sys.exit(1 if fails else 0)
