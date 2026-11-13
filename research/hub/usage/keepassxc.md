# KeePassXC

## When to use
- You want a password manager with no cloud service, ads, or subscription.
- You want your credentials in one offline, encrypted database file that you control.
- You need to fill logins into desktop apps through Auto-Type, including on Wayland in version 2.8.0.
- You want to store passwords, URLs, attachments, and notes together in one place.

## How it works
- All data lives in an encrypted database file that you can place anywhere, including a synced folder; the project says no data is stored on remote servers.
- Browser integration asks for confirmation before a browser can access the database, and passkey support is included from version 2.7.12.
- Auto-Type fills credentials into other applications, with configurable shortcuts.
- Quick unlock is available on macOS with a password and on Linux via Polkit (version 2.8.0).

## Not for
- Syncing across devices automatically: the project has no cloud service, so you must move or sync the file yourself.
- Browser-first setups where tight browser autofill is the main need: the official page covers browser integration only briefly (Not found for setup details).

## Sources
- https://keepassxc.org/
