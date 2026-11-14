# ProtonUp-Qt

## When to use
- A Steam game needs a newer GE-Proton build than the one Steam ships.
- You want to install Luxtorpeda for Steam titles that support it.
- A Lutris game needs a Wine-GE build.
- You want a graphical way to add and remove these compatibility tools without downloading archives by hand.

## How it works
- The app is a Qt graphical front end for installing and managing compatibility tools.
- For Steam it installs GE-Proton and Luxtorpeda; for Lutris it installs Wine-GE.
- It is distributed as a Flatpak on Flathub and as an AppImage on the project's releases page.
- Newer releases also list Heroic Games Launcher and Boxtron support in their notes.

## Not for
- Installing Proton itself or Steam updates; Steam manages its own Proton.
- Managing Wine prefixes for individual Windows apps; use Bottles.

## Sources
- https://github.com/DavidoTek/ProtonUp-Qt/blob/main/README.md
