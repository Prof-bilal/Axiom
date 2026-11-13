# Steam

## When to use
- You want to buy, install and launch games from the Steam library on Linux.
- You want Windows games to run on Linux through Steam Play (Proton) without a separate Wine setup.
- You want to check whether a game is supported on Linux before installing it.

## How it works
- The Steam client holds your library; each game installs and updates from there.
- Steam Play is turned on in the Steam settings, with separate options for supported titles and for all other titles.
- When Steam Play is on, Windows games run through Proton, a compatibility layer based on Wine.
- Native Linux games run without a compatibility layer.
- Some games may not run well when Steam Play is set to cover all other titles.

## Not for
- Running a Windows game with fine-grained Wine prefix control; use Bottles or Lutris.
- Managing non-Steam games and emulators in one place; use Lutris.

## Sources
- https://itsfoss.com/steam-play-proton.md
