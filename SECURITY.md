# Reporting security issues

Please **don't report security vulnerabilities in public issues, pull requests
or discussions.**

Report them privately using GitHub's
[private vulnerability reporting](https://github.com/Prof-bilal/Axiom/security/advisories/new)
for this repository. Include:

- what is affected (file, component, ISO date or commit);
- steps to reproduce, or a proof of concept that is safe to run in a VM;
- what an attacker could achieve;
- any fix you suggest.

You should get an acknowledgement within 7 days. Axiom is maintained by
volunteers, so a fix may take longer. You'll be kept informed, credited in the
advisory if you want to be, and asked before anything is disclosed publicly.

## Supported versions

Axiom is pre-alpha and has **no stable release yet**. Only the latest commit
on `main` gets security fixes. Don't use pre-release images on machines that
hold data you care about.

## In scope

Problems in Axiom's own code and configuration, in particular:

- privilege escalation from the desktop user or an app to root;
- bypassing a polkit rule, PAM configuration, the lock screen or the login screen;
- the installer leaking passwords or LUKS passphrases into logs, evidence or the
  installed system;
- the installer writing to a disk the user didn't choose;
- weakening Wayland or portal consent;
- anything that lets future AI or agent components act outside their granted
  scope.

Bugs in upstream packages (the kernel, systemd, labwc, Quickshell and others)
should go to those projects. Tell us as well if Axiom's configuration makes
the bug worse.

The design that these reports are checked against is in the
[security contract](docs/SECURITY.md) and the
[threat model](docs/security/THREAT_MODEL.md).
