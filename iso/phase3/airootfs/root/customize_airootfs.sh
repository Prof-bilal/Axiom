#!/bin/bash
# Axiom Phase 3 live-session customization (runs inside the airootfs chroot).
set -euo pipefail

# Unprivileged desktop user. The Axiom UI must never run as root.
if ! id axiom >/dev/null 2>&1; then
  useradd -m -u 1000 -s /usr/bin/zsh axiom
  passwd -d axiom
fi
# `tty` is required so the session can write its readiness marker to the serial
# console (used only for QEMU evidence, never a product dependency).
usermod -aG wheel,video,input,audio,rfkill,tty axiom

# Session entry points are executable.
chmod 0755 /usr/local/bin/axiom-session /usr/local/bin/axiom-shell /usr/local/bin/axiom-greeting /usr/local/bin/axiom-terminal

# OS identity. /etc/os-release takes precedence over /usr/lib/os-release
# (os-release(5)); Axiom keeps ID_LIKE=arch so Arch-aware tools still work.
# Written here, not shipped in airootfs/etc, because the `filesystem` package
# owns the /etc/os-release symlink.
rm -f /etc/os-release
install -m 0644 /etc/axiom/os-release /etc/os-release

# Shell tree is readable by the user, owned by root.
if [ -d /usr/local/share/axiom ]; then
  chown -R root:root /usr/local/share/axiom
  chmod -R a+rX /usr/local/share/axiom
fi

# Axiom interactive shell config (greeting + prompt). Not shipped through
# /etc/skel because grml-zsh-config owns /etc/skel/.zshrc.
install -m 0644 /etc/axiom/zshrc /home/axiom/.zshrc

# Home ownership (useradd -m copies /etc/skel, including .zprofile).
chown -R 1000:1000 /home/axiom

# Services used by the session.
systemctl enable NetworkManager.service
systemctl enable systemd-timesyncd.service || true

# The build injects a build-host GPGDir into the profile pacman.conf; the guest
# must not carry a build-time path. Drop it so pacman uses the packaged keyring.
if [ -f /etc/pacman.conf ]; then
  sed -i '/^GPGDir = /d' /etc/pacman.conf
fi
