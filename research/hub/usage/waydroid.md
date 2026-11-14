# Waydroid

## When to use
- You want Android apps to run on a Linux desktop without a virtual machine.
- You are on a Wayland session (the official docs ask for a Wayland session on Ubuntu 22.04+).
- You need to install a specific APK on a Linux machine, for example with `waydroid app install`.
- You want Android apps in the normal Linux application menu, in windowed or full-screen mode.

## How it works
- Runs a full Android system (LineageOS-based image, Android 13 per the project site) in a container that uses Linux namespaces.
- Needs an initial setup with `waydroid init`, then a container service, then a user session.
- Uses the Linux kernel's binder support for Android hardware access.
- Apps installed with `waydroid app install file.apk`. APKs that are ARM-only will not run on x86_64.

## Not for
- Systems that cannot provide a Wayland session or the kernel features Waydroid relies on.

## Sources
- https://github.com/waydroid/waydroid
- https://waydro.id
- https://docs.waydro.id/usage/install-on-desktops.md
- https://docs.waydro.id/usage/install-and-run-android-applications.md
- https://docs.waydro.id/usage/waydroid-command-line-options.md
- https://docs.waydro.id/debugging/known-issues.md
