# Zoom

## When to use
- You need to join or host Zoom meetings and webinars from a Linux desktop.
- Your school, employer or client requires Zoom and you cannot use a browser join.
- You want the native Linux client for audio and video in Zoom meetings.
- You are on a supported distribution (Ubuntu 20.04+, Debian 11+, Fedora 32+, RHEL-family 9+, openSUSE, Arch).

## How it works
- The Linux desktop client (called Zoom Workplace in Zoom's support docs) installs from a DEB, RPM or Arch package.
- Installed with the system package manager (`apt`, `zypper`, `yum`, `pacman`), which needs sudo.
- Minimum 4 GB RAM (16 GB recommended) and OpenGL 2.0 or higher, per Zoom's Linux system requirements.
- Proprietary software under Zoom's terms; the client is closed-source.

## Not for
- Machines with less than 4 GB RAM or without OpenGL 2.0.
- Users who only need to join meetings occasionally and prefer not to install software (use the browser join link instead).

## Sources
- https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458
- https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0060748
- https://zoom.us/download?os=linux
