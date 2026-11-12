"""Axiom installer backend (Phase 6, ADR-020/021). Python stdlib only.

Validates the form, builds archinstall's config/credentials, runs archinstall
with an argv list (never a shell string), applies the Axiom overlay in the target
and records the Developer Hub profile. Progress is JSON lines on stdout.

Secrets: the password is hashed with `openssl passwd -6 -stdin`; hash and LUKS
passphrase live only in 0600 files on tmpfs that are removed after the run.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import uuid

TARGET = "/mnt"
USER_RE = re.compile(r"^[a-z_][a-z0-9_-]{0,31}$")
HOST_RE = re.compile(r"^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$")
EMAIL_RE = re.compile(r"^[^@\s]{1,64}@[^@\s]{1,190}\.[^@\s]{2,}$")
LAYOUT_RE = re.compile(r"^[a-z0-9_]{2,12}$")
LOCALE_RE = re.compile(r"^[a-z]{2,3}_[A-Z]{2}$")
RESERVED = {"root", "daemon", "bin", "sys", "sync", "games", "man", "lp", "mail", "news", "uucp", "proxy",
            "www-data", "backup", "list", "irc", "nobody", "systemd-network", "polkitd", "git", "axiom", "admin"}
COMMON_PW = {"password", "password1", "12345678", "123456789", "1234567890", "qwertyuiop", "iloveyou1",
             "letmein123", "welcome123", "administrator", "axiom12345", "install", "changeme123"}
ESP_MIB = 1024
ENV = {"PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin", "LC_ALL": "C.UTF-8"}

# Desktop set mirrors the Phase 3/5 package list (iso/phase3/packages.x86_64).
BASE_PACKAGES = [
    "base-devel", "git", "nano", "vim", "openssh", "sudo", "zsh", "btrfs-progs", "cryptsetup",
    "networkmanager", "wpa_supplicant", "polkit", "dbus", "pipewire", "pipewire-pulse", "pipewire-alsa",
    "wireplumber", "alsa-utils", "mesa", "libglvnd", "wayland", "wayland-protocols", "labwc",
    "xdg-desktop-portal", "xdg-desktop-portal-wlr", "xdg-desktop-portal-gtk", "gvfs", "quickshell",
    "qt6-declarative", "qt6-wayland", "qt6-svg", "qt6-5compat", "noto-fonts", "ttf-dejavu", "inter-font",
    "ttf-jetbrains-mono", "adwaita-icon-theme", "hicolor-icon-theme", "foot", "mousepad", "firefox",
    "libnotify", "xdg-utils", "glib2", "bluez", "bluez-utils", "power-profiles-daemon", "upower",
    "wlr-randr", "brightnessctl", "xkeyboard-config", "greetd", "python", "linux-firmware",
    "qemu-guest-agent", "mkinitcpio", "intel-ucode", "amd-ucode", "kbd", "plymouth",
]
SERVICES = ["NetworkManager", "bluetooth", "power-profiles-daemon", "systemd-timesyncd", "qemu-guest-agent"]
# Axiom-owned files copied from the live medium into the target (nothing else).
OVERLAY = [
    "/etc/axiom", "/etc/polkit-1/rules.d/50-axiom-session-power.rules",
    "/etc/polkit-1/rules.d/51-axiom-system-settings.rules", "/etc/xdg/foot", "/etc/xdg/gtk-3.0",
    "/etc/xdg/gtk-4.0", "/etc/xdg/mimeapps.list", "/etc/pam.d/axiom-lock", "/usr/local/lib/axiom-greeter", "/usr/local/lib/axiom-tui", "/usr/local/lib/axiom-provision",
    "/usr/local/bin/axiom-provision", "/usr/share/plymouth/themes/axiom",
    "/etc/systemd/system/power-profiles-daemon.service.d",
    "/usr/local/bin/axiom-app", "/usr/local/bin/axiom-greeting", "/usr/local/bin/axiom-session",
    "/usr/local/bin/axiom-shell", "/usr/local/bin/axiom-terminal", "/usr/local/share/axiom",
    "/usr/local/share/applications", "/usr/local/share/icons",
]


class FormError(ValueError):
    pass


def emit(event, **kw):
    print(json.dumps({"event": event, **kw}), flush=True)


# ---- validation ----------------------------------------------------------------
def check_password(pw, username=""):
    if len(pw) < 10:
        raise FormError("Use at least 10 characters.")
    if pw.lower() in COMMON_PW or (username and pw.lower() == username.lower()):
        raise FormError("That password is too easy to guess. Try a longer one.")
    if len(set(pw)) < 4:
        raise FormError("Use a few different characters, not just repeats.")
    if "\n" in pw or "\x00" in pw:
        raise FormError("The password has a character that is not allowed.")


def validate_form(f, zoneinfo="/usr/share/zoneinfo"):
    """Return a cleaned copy of form f or raise FormError. Everything is data, never shell."""
    out = {}
    user = f.get("username", "")
    if not USER_RE.match(user) or user in RESERVED:
        raise FormError("That username can't be used. Use lowercase letters, numbers, - or _, starting with a letter.")
    out["username"] = user
    name = f.get("fullname", "").strip()
    if not name or len(name) > 64 or re.search(r"[\x00-\x1f:,=]", name):
        raise FormError("Please enter your name (without : or , characters).")
    out["fullname"] = name
    host = f.get("hostname", "")
    if not HOST_RE.match(host):
        raise FormError("The computer name can only use lowercase letters, numbers and -.")
    out["hostname"] = host
    check_password(f.get("password", ""), user)
    out["password"] = f["password"]
    tz = f.get("timezone", "")
    if not re.match(r"^[A-Za-z0-9_+-]+(/[A-Za-z0-9_+-]+){0,2}$", tz) or not os.path.isfile(os.path.join(zoneinfo, tz)):
        raise FormError("Unknown time zone. Example: Asia/Karachi or Europe/London.")
    out["timezone"] = tz
    if not LAYOUT_RE.match(f.get("keyboard", "us")):
        raise FormError("Use a keyboard code like us, uk or de.")
    out["keyboard"] = f.get("keyboard", "us")
    if not LOCALE_RE.match(f.get("locale", "en_US")):
        raise FormError("Use a language code like en_US.")
    out["locale"] = f.get("locale", "en_US")
    gname, gmail = f.get("git_name", "").strip(), f.get("git_email", "").strip()
    if gname or gmail:
        if not gname or re.search(r"[\x00-\x1f<>]", gname) or len(gname) > 100:
            raise FormError("Enter both a name and an email for Git, or leave both empty.")
        if not EMAIL_RE.match(gmail):
            raise FormError("That email address does not look right.")
    out["git_name"], out["git_email"] = gname, gmail
    out["luks"] = bool(f.get("luks"))
    if out["luks"]:
        check_password(f.get("luks_passphrase", ""))
        out["luks_passphrase"] = f["luks_passphrase"]
    out["hub"] = [str(i) for i in f.get("hub", [])]
    if any(not re.match(r"^[a-z0-9][a-z0-9._-]{0,63}$", i) for i in out["hub"]):
        raise FormError("invalid hub item id")
    return out


# ---- disks ----------------------------------------------------------------------
def list_disks(lsblk_json=None):
    """Whole disks that are safe targets: not removable/optical, nothing mounted, not the live medium."""
    if lsblk_json is None:
        lsblk_json = subprocess.run(
            ["lsblk", "-J", "-b", "-o", "NAME,PATH,SIZE,MODEL,SERIAL,TYPE,RM,RO,MOUNTPOINTS"],
            capture_output=True, text=True, check=True, env=ENV).stdout
    disks = []
    for d in json.loads(lsblk_json).get("blockdevices", []):
        if d.get("type") != "disk" or d.get("ro") or d.get("rm"):
            continue
        mounts = [m for m in (d.get("mountpoints") or []) if m]
        for c in d.get("children") or []:
            mounts += [m for m in (c.get("mountpoints") or []) if m]
            for cc in c.get("children") or []:
                mounts += [m for m in (cc.get("mountpoints") or []) if m]
        if mounts:
            continue
        disks.append({"path": d["path"], "size": int(d["size"]), "model": (d.get("model") or "").strip(),
                      "serial": (d.get("serial") or "").strip()})
    return disks


def check_target(path, size, disks=None):
    """Re-validate right before writing: must still be a listed safe disk of the same size."""
    for d in (disks if disks is not None else list_disks()):
        if d["path"] == path and d["size"] == size:
            return d
    raise FormError("That disk is not available any more. Go back and choose again.")


# ---- archinstall config -----------------------------------------------------------
def _size(unit, value):
    return {"sector_size": {"unit": "B", "value": 512}, "unit": unit, "value": value}


def build_config(f, disk_path, disk_bytes):
    root_mib = disk_bytes // (1024 * 1024) - ESP_MIB - 2
    if root_mib < 8 * 1024:
        raise FormError("This disk is too small. Axiom needs at least 10 GB.")
    root_id, esp_id = str(uuid.uuid4()), str(uuid.uuid4())
    subvols = [("@", "/"), ("@home", "/home"), ("@log", "/var/log"), ("@pkg", "/var/cache/pacman/pkg"),
               ("@snapshots", "/.snapshots")]
    cfg = {
        "archinstall-language": "English",
        "bootloader_config": {"bootloader": "Systemd-boot", "uki": False, "removable": False},
        "disk_config": {"config_type": "default_layout", "device_modifications": [{
            "device": disk_path, "wipe": True, "partitions": [
                {"btrfs": [], "dev_path": None, "flags": ["boot", "esp"], "fs_type": "fat32",
                 "size": _size("MiB", ESP_MIB), "mount_options": [], "mountpoint": "/boot", "obj_id": esp_id,
                 "start": _size("MiB", 1), "status": "create", "type": "primary"},
                {"btrfs": [{"name": n, "mountpoint": m} for n, m in subvols], "dev_path": None, "flags": [],
                 "fs_type": "btrfs", "size": _size("MiB", root_mib), "mount_options": ["compress=zstd"],
                 "mountpoint": None, "obj_id": root_id, "start": _size("MiB", ESP_MIB + 1),
                 "status": "create", "type": "primary"}]}]},
        "hostname": f["hostname"], "kernels": ["linux", "linux-lts"],
        "locale_config": {"kb_layout": f["keyboard"], "sys_enc": "UTF-8", "sys_lang": f["locale"]},
        "network_config": {"type": "nm"}, "ntp": True, "offline": False,
        "packages": BASE_PACKAGES, "services": SERVICES,
        "swap": {"enabled": True, "algorithm": "zstd"}, "timezone": f["timezone"], "script": "guided",
    }
    if f["luks"]:
        cfg["disk_encryption"] = {"encryption_type": "luks", "partitions": [root_id], "lvm_volumes": []}
    return cfg


def hash_password(pw):
    """sha512-crypt hash; the password goes to openssl on stdin, never argv."""
    return subprocess.run(["openssl", "passwd", "-6", "-stdin"], input=pw + "\n", capture_output=True,
                          text=True, check=True, env=ENV).stdout.strip()


def build_creds(f):
    creds = {"users": [{"username": f["username"], "enc_password": hash_password(f["password"]),
                        "sudo": True, "groups": ["wheel", "video", "input", "audio", "rfkill", "tty"]}]}
    if f["luks"]:
        creds["encryption_password"] = f["luks_passphrase"]
    return creds


# ---- profile --------------------------------------------------------------------------
def build_profile(f):
    """Developer Hub profile: selection only, no secrets (ADR-021)."""
    return {"schema": 1, "user": f["username"], "git": {"name": f["git_name"], "email": f["git_email"]},
            "hub": f["hub"], "applied": {}}


class ProgressTracker:
    """Turns archinstall/pacman output into (percent, stage, detail). Percent never goes backwards.

    archinstall runs pacstrap in two rounds (base system, then the Axiom packages); each round has
    a download phase ("Total (a/b) ... NN%") and an install phase ("(n/N) installing pkg"). Fixed
    windows per phase keep the bar moving smoothly without knowing the totals in advance.
    """
    DL = {1: (8, 28), 2: (48, 66)}
    INST = {1: (28, 48), 2: (66, 84)}
    RE_TOTAL = re.compile(r"Total \(\s*(\d+)/(\d+)\)\s+([\d.]+)\s+([KMGT]?i?B)\s+([\d.]+)\s+([KMGT]?i?B)/s\s.*?(\d+)%")
    RE_INST = re.compile(r"\(\s*(\d+)/(\d+)\)\s+installing\s+(\S+)")
    # Markers of the real boot-setup step only; package names such as mkinitcpio or systemd-boot also
    # appear in pacman's package list and must not move the bar.
    BOOT = ("==> Building image", "==> Starting build", "Installed systemd-boot", "bootctl --esp-path",
            "Created /boot/loader")
    DISK = ("formatting", "mkfs", "luks2", "partition")

    def __init__(self):
        self.round = 0
        self.pct = 2.0
        self.stage = "Preparing the disk"
        self.detail = ""

    def _set(self, pct, stage, detail=""):
        self.pct = max(self.pct, min(pct, 99.0))
        self.stage, self.detail = stage, detail

    def feed(self, text):
        """Consume a chunk of output; returns True if the visible state changed."""
        before = (round(self.pct), self.stage, self.detail)
        for line in re.split(r"[\r\n]+", text):
            if "Retrieving packages" in line:
                self.round += 1
                self._set(self.DL[min(self.round, 2)][0], "Downloading Axiom")
                continue
            m = self.RE_INST.search(line)
            if m:
                n, total = int(m.group(1)), max(1, int(m.group(2)))
                lo, hi = self.INST[min(max(self.round, 1), 2)]
                self._set(lo + (hi - lo) * n / total, "Installing the system", f"Package {n} of {total}: {m.group(3)}")
                continue
            m = self.RE_TOTAL.search(line)
            if m:
                lo, hi = self.DL[min(max(self.round, 1), 2)]
                self._set(lo + (hi - lo) * int(m.group(7)) / 100, "Downloading Axiom",
                          f"{m.group(3)} {m.group(4)} downloaded at {m.group(5)} {m.group(6)}/s")
                continue
            if self.round >= 1 and any(k in line for k in self.BOOT):
                self._set(max(self.pct, 85), "Setting up startup")
            elif self.round == 0 and any(k in line for k in self.DISK):
                self._set(min(self.pct + 1, 7), "Preparing the disk")
        return (round(self.pct), self.stage, self.detail) != before


def eta_minutes(pct, elapsed_s):
    """Rough minutes left from the average pace so far; None until there is enough data."""
    if pct < 12 or elapsed_s < 30:
        return None
    return max(1, round(elapsed_s * (100 - pct) / pct / 60))


def progress(pct, stage, detail="", started=None):
    ev = {"pct": int(pct), "stage": stage, "detail": detail}
    if started is not None:
        eta = eta_minutes(pct, time.monotonic() - started)
        if eta is not None:
            ev["eta_min"] = eta
    emit("progress", **ev)


def run_archinstall(cmd, log_path, started):
    """Run archinstall with its output in log_path while reporting progress from that log."""
    tracker = ProgressTracker()
    pos = os.path.getsize(log_path) if os.path.exists(log_path) else 0  # a retry appends: skip the earlier run's text
    progress(tracker.pct, tracker.stage, "", started)
    with open(log_path, "ab") as log:
        proc = subprocess.Popen(cmd, env=ENV, stdout=log, stderr=subprocess.STDOUT)
        last = 0.0
        while True:
            done = proc.poll() is not None
            with open(log_path, "rb") as rd:
                rd.seek(pos)
                chunk = rd.read()
                pos += len(chunk)
            if chunk and tracker.feed(chunk.decode("utf-8", "replace")) and time.monotonic() - last > 0.25:
                progress(tracker.pct, tracker.stage, tracker.detail, started)
                last = time.monotonic()
            if done:
                break
            time.sleep(0.4)
    if proc.returncode != 0:
        raise subprocess.CalledProcessError(proc.returncode, cmd)


# ---- install --------------------------------------------------------------------------------
def run(cmd, **kw):
    return subprocess.run(cmd, check=True, env=ENV, **kw)


def apply_overlay(target=TARGET, paths=OVERLAY):
    for p in paths:
        if not os.path.exists(p):
            raise FileNotFoundError(f"overlay source missing: {p}")
        dst = os.path.join(target, p.lstrip("/"))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.isdir(p):
            shutil.copytree(p, dst, symlinks=True, dirs_exist_ok=True)
        else:
            shutil.copy2(p, dst)


def boot_splash(target=TARGET):
    """Axiom splash: hide the boot menu, quiet kernel log, Plymouth theme in the initramfs.

    Soft failure by design: if Plymouth cannot be set up, the system still boots to the text console
    (the splash is cosmetic; the LUKS prompt falls back to the plain prompt).
    """
    loader = os.path.join(target, "boot/loader/loader.conf")
    keep = [l for l in (open(loader).read().splitlines() if os.path.exists(loader) else [])
            if l.split()[:1] not in (["timeout"], ["editor"])]
    os.makedirs(os.path.dirname(loader), exist_ok=True)
    open(loader, "w").write("\n".join(keep + ["timeout 0", "editor no"]) + "\n")
    entries = os.path.join(target, "boot/loader/entries")
    if os.path.isdir(entries):
        for name in os.listdir(entries):
            path = os.path.join(entries, name)
            lines = open(path).read().splitlines()
            out = [(l.rstrip() + " quiet splash") if l.startswith("options") and "splash" not in l else l
                   for l in lines]
            open(path, "w").write("\n".join(out) + "\n")
    mkinit = os.path.join(target, "etc/mkinitcpio.conf")
    if os.path.exists(mkinit):
        text = open(mkinit).read()
        if "plymouth" not in text:  # shortcut: naive HOOKS edit; upgrade to a parsed edit if the default layout changes
            text = re.sub(r"^HOOKS=\((.*?)\bkms\b", r"HOOKS=(\1kms plymouth", text, count=1, flags=re.M)
            open(mkinit, "w").write(text)
    try:
        subprocess.run(["arch-chroot", target, "plymouth-set-default-theme", "-R", "axiom"],
                       check=True, env=ENV, capture_output=True)
    except (OSError, subprocess.CalledProcessError) as e:
        emit("log", message=f"Plymouth splash not set up; text boot used: {e}")


def propagate_console(target=TARGET, cmdline="/proc/cmdline"):
    """Copy the live medium's console= options to the installed boot entries (serial testing/recovery)."""
    try:
        opts = [t for t in open(cmdline).read().split() if re.match(r"^console=[a-zA-Z0-9,]+$", t)]
    except OSError:
        return
    entries = os.path.join(target, "boot/loader/entries")
    if not opts or not os.path.isdir(entries):
        return
    for name in os.listdir(entries):
        path = os.path.join(entries, name)
        lines = open(path).read().splitlines()
        lines = [(l.rstrip() + " " + " ".join(o for o in opts if o not in l)).rstrip() if l.startswith("options") else l
                 for l in lines]
        open(path, "w").write("\n".join(lines) + "\n")


def post_install(f, target=TARGET, started=None):
    progress(88, "Adding the Axiom desktop", "", started)
    apply_overlay(target)
    shutil.copy2("/etc/axiom/os-release", os.path.join(target, "etc/os-release")) if os.path.exists(
        "/etc/axiom/os-release") else None
    progress(93, "Creating your account", "", started)
    home = os.path.join(target, "home", f["username"])
    chroot = ["arch-chroot", target]
    run(chroot + ["usermod", "-c", f["fullname"], "-s", "/usr/bin/zsh", f["username"]])
    run(chroot + ["passwd", "-l", "root"])
    # Axiom interactive shell config; without a .zshrc zsh starts its first-run wizard.
    shutil.copy2("/etc/axiom/zshrc", os.path.join(home, ".zshrc"))
    run(chroot + ["chown", f"{f['username']}:{f['username']}", f"/home/{f['username']}/.zshrc"])
    run(chroot + ["install", "-d", "-m", "0700", "-o", f["username"], "-g", f["username"],
                  f"/home/{f['username']}/.config/axiom"])
    prof = json.dumps(build_profile(f), indent=2) + "\n"
    run(chroot + ["install", "-d", "-m", "0755", "/var/lib/axiom"])
    for dst in ("/var/lib/axiom/profile.json", f"/home/{f['username']}/.config/axiom/dev-profile.json"):
        with open(os.path.join(target, dst.lstrip("/")), "w") as fh:
            fh.write(prof)
        os.chmod(os.path.join(target, dst.lstrip("/")), 0o644 if dst.startswith("/var") else 0o600)
    run(chroot + ["chown", f"{f['username']}:{f['username']}", f"/home/{f['username']}/.config/axiom/dev-profile.json"])
    if f["git_name"]:
        gc = f"/home/{f['username']}/.gitconfig"
        for key, val in (("user.name", f["git_name"]), ("user.email", f["git_email"])):
            run(chroot + ["git", "config", "--file", gc, key, val])
        run(chroot + ["chown", f"{f['username']}:{f['username']}", gc])
    # Login manager: greetd + the Axiom greeter; installed systems never autologin.
    os.makedirs(os.path.join(target, "etc/greetd"), exist_ok=True)
    with open(os.path.join(target, "etc/greetd/config.toml"), "w") as fh:
        fh.write('[terminal]\nvt = 1\n\n[default_session]\ncommand = "/usr/local/lib/axiom-greeter/axiom-greeter"\nuser = "greeter"\n')
    # The login screen draws through /dev/dri (group video); without it the greeter falls back to the text console.
    soft = subprocess.run(chroot + ["usermod", "-aG", "video", "greeter"], env=ENV, capture_output=True, text=True)
    if soft.returncode != 0:
        print(f"warning: could not add greeter to the video group: {soft.stderr.strip()}", file=sys.stderr)
    # Large console font for the login screen and early boot text (the font ships in kbd). archinstall
    # already wrote FONT=default8x16, so replace the line rather than only adding one.
    vc = os.path.join(target, "etc/vconsole.conf")
    lines = [l for l in (open(vc).read().splitlines() if os.path.exists(vc) else []) if not l.startswith("FONT=")]
    open(vc, "w").write("\n".join(lines + ["FONT=latarcyrheb-sun32"]) + "\n")
    # The login screen runs as an unprivileged user and cannot change the console font itself, and the
    # framebuffer console resets the font when it takes over at boot: set it as root, right after greetd has
    # started (the greeter redraws when the console resizes).
    dropin = os.path.join(target, "etc/systemd/system/greetd.service.d")
    os.makedirs(dropin, exist_ok=True)
    with open(os.path.join(dropin, "axiom-font.conf"), "w") as fh:
        fh.write("[Service]\nExecStartPost=-/usr/local/lib/axiom-tui/axiom-setfont\n")
    run(chroot + ["systemctl", "enable", "greetd.service"])
    shutil.copy2("/usr/local/lib/axiom-provision/axiom-provision.service", os.path.join(target, "etc/systemd/system/axiom-provision.service"))
    run(chroot + ["systemctl", "enable", "axiom-provision.service"])
    # sudo for wheel (password required)
    with open(os.path.join(target, "etc/sudoers.d/10-wheel"), "w") as fh:
        fh.write("%wheel ALL=(ALL:ALL) ALL\n")
    os.chmod(os.path.join(target, "etc/sudoers.d/10-wheel"), 0o440)
    propagate_console(target)
    boot_splash(target)
    progress(97, "Finishing up", "", started)


def kill_users(target=TARGET, proc="/proc", kill=os.kill):
    """SIGKILL every process whose root or cwd is under target (pacstrap/pacman left behind by a killed run)."""
    killed = []
    for pid in os.listdir(proc):
        if not pid.isdigit() or int(pid) == os.getpid():
            continue
        for link in ("root", "cwd"):
            try:
                dest = os.readlink(os.path.join(proc, pid, link))
            except OSError:
                continue
            if dest == target or dest.startswith(target.rstrip("/") + "/"):
                kill(int(pid), 9)
                killed.append(int(pid))
                break
    return killed


def mappers_on(disk):
    """Names under /dev/mapper whose LUKS device is a partition of `disk` (cryptsetup status shows `device:`)."""
    names = []
    if disk and os.path.isdir("/dev/mapper"):
        for name in os.listdir("/dev/mapper"):
            if name == "control":
                continue
            out = subprocess.run(["cryptsetup", "status", name], env=ENV, capture_output=True, text=True).stdout
            dev = next((l.split(":", 1)[1].strip() for l in out.splitlines() if l.strip().startswith("device:")), "")
            if dev.startswith(disk):
                names.append(name)
    return names


def cleanup(target=TARGET, disk=None):
    """Leave the machine retryable after a failed run: no stragglers, nothing mounted, the target's LUKS closed."""
    import time
    kill_users(target)
    for _ in range(5):
        subprocess.run(["umount", "-R", target], env=ENV, capture_output=True)
        if subprocess.run(["findmnt", target], env=ENV, capture_output=True).returncode != 0:
            break
        kill_users(target)
        time.sleep(1)
    for name in mappers_on(disk):  # only the installer's own mapper, never another encrypted disk's
        subprocess.run(["cryptsetup", "close", name], env=ENV, capture_output=True)


def check_installed(target=TARGET):
    """archinstall can exit 0 without installing anything (for example with no network). Say so clearly."""
    if not os.path.ismount(target) or not os.path.exists(os.path.join(target, "etc/os-release")):
        raise FormError("Axiom could not download its packages. Check the internet connection and try again.")


def install(f, disk_path, disk_bytes, target=TARGET):
    check_target(disk_path, disk_bytes)
    cfg = build_config(f, disk_path, disk_bytes)
    with tempfile.TemporaryDirectory(dir="/run", prefix="axiom-inst-") as tmp:
        os.chmod(tmp, 0o700)
        cp, kp = os.path.join(tmp, "config.json"), os.path.join(tmp, "creds.json")
        for path, data in ((cp, cfg), (kp, build_creds(f))):
            fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(fd, "w") as fh:
                json.dump(data, fh)
        started = time.monotonic()
        try:
            run_archinstall(["archinstall", "--config", cp, "--creds", kp, "--silent", "--skip-version-check",
                             "--skip-wkd", "--skip-wifi-check", "--mountpoint", target], "/var/log/axiom-installer.log", started)
            check_installed(target)  # archinstall 4.x exits 0 without installing when offline
            post_install(f, target, started)
            subprocess.run(["sync"], env=ENV)
            cleanup(target, disk_path)  # flushed and unmounted: safe to remove the medium and reboot
        except BaseException:
            cleanup(target, disk_path)  # leave the machine retryable: nothing mounted, LUKS closed
            raise
    emit("done", pct=100)


def main(argv):
    form = json.load(sys.stdin)
    try:
        f = validate_form(form)
        install(f, form["disk"], int(form["disk_bytes"]))
    except FormError as e:
        emit("error", message=str(e))
        return 2
    except subprocess.CalledProcessError as e:
        emit("error", message=f"The installation stopped before it was finished (error {e.returncode}).")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
