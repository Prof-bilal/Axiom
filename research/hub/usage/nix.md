# Nix

## When to use
- You want reproducible, isolated builds and installs of packages on Linux, macOS or WSL.
- You want several users on one machine to share a single package store (multi-user daemon install).
- You want to pin or roll back a set of tools so a project builds the same way on every machine.
- You are a developer or sysadmin who wants declarative environments (Nixpkgs, or NixOS as a full distro).

## How it works
- A purely functional package manager: each package lives under `/nix/store` at a path derived from its inputs.
- The recommended Linux install is the multi-user daemon: `curl ... | sh -s -- --daemon`, which needs systemd and SELinux disabled.
- The single-user install (`--no-daemon`) runs under your own account and creates `/nix` with sudo if needed.
- Packages come from Nixpkgs; NixOS is a Linux distribution configured from Nix files.

## Not for
- Quick one-off installs where you do not want a new package model or a `/nix` directory.
- Systems where you cannot run systemd or disable SELinux, unless you use the single-user install.

## Sources
- https://nixos.org/download/
- https://nix.dev/manual/nix/2.31/installation/installing-binary.html
- https://github.com/NixOS/nix
