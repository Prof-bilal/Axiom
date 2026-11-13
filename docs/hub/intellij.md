# IntelliJ IDEA Community

- Id: `intellij` · Category: Development · Weight: heavy · Licence (catalog): Apache-2.0
- Catalog sources: flatpak `com.jetbrains.IntelliJ-IDEA-Community`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
IntelliJ IDEA is JetBrains' Java and JVM-focused IDE, offered as a free Community edition and a paid Ultimate edition with broader framework support. It is for professional developers who want deep code analysis, refactoring and framework integration.

## Facts
- Name: IntelliJ IDEA (Community and Ultimate editions)
- Publisher: JetBrains
- Official website: https://www.jetbrains.com/idea/
- Licence: Community edition under Apache 2.0, with proprietary terms for some bundled plugins. Ultimate is commercial with a 30-day trial. Source: https://www.jetbrains.com/help/idea/requirements-for-intellij-idea.html
- Latest version: not found
- Typical install size: not found
- Minimum RAM: 8 GB total RAM, with 3 GB available to the IDE (vendor install guide). Source: https://www.jetbrains.com/help/idea/requirements-for-intellij-idea.html
- CPU: 4-core x86_64 or arm64 CPU (vendor). Source: https://www.jetbrains.com/help/idea/requirements-for-intellij-idea.html
- Disk: 10 GB (vendor). Source: https://www.jetbrains.com/help/idea/requirements-for-intellij-idea.html
- Linux prerequisites: glibc 2.28 or higher on Linux x64 from v2025.1. Source: https://blog.jetbrains.com/idea/2025/01/updated-system-requirements-for-linux-gnu-c-library-glibc/

Flathub data (https://flathub.org/api/v2/appstream/com.jetbrains.IntelliJ-IDEA-Community):
- Flatpak id: `com.jetbrains.IntelliJ-IDEA-Community` · Developer: JetBrains s.r.o. · Licence: Apache-2.0
- Latest version on Flathub: 2026.3 (released 2026-11-04)

## Logo
Bundled icon: `apps/hub/icons/intellij.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.jetbrains.IntelliJ-IDEA-Community.png (verified-200).

## Screenshots
![Java support](https://dl.flathub.org/media/com/jetbrains/IntelliJ-IDEA-Community/8eb46e6b52f6433fd577e7a9c92ed81c/screenshots/image-1_orig.png)
![Kotlin support](https://dl.flathub.org/media/com/jetbrains/IntelliJ-IDEA-Community/8eb46e6b52f6433fd577e7a9c92ed81c/screenshots/image-2_orig.png)
![AI Assistant](https://dl.flathub.org/media/com/jetbrains/IntelliJ-IDEA-Community/8eb46e6b52f6433fd577e7a9c92ed81c/screenshots/image-3_orig.png)
![The Problems tool window](https://dl.flathub.org/media/com/jetbrains/IntelliJ-IDEA-Community/8eb46e6b52f6433fd577e7a9c92ed81c/screenshots/image-4_orig.png)
![Detection of code duplicates](https://dl.flathub.org/media/com/jetbrains/IntelliJ-IDEA-Community/8eb46e6b52f6433fd577e7a9c92ed81c/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/com.jetbrains.IntelliJ-IDEA-Community

Unverified. The JetBrains IDEA page returned four image paths (relative, resolved against https://www.jetbrains.com/): `/_assets/rr/air-configure-DHl43cDn.png`, `/_assets/rr/air-context-CSuiw5KZ.png`, `/_assets/rr/air-session-BYOwWy9v.png`, `/_assets/rr/air-cli-small-DkKty5XR.png`. Their filenames say "air" (which may refer to a different JetBrains product), so they were not confirmed as IntelliJ screenshots. Treat as unconfirmed:
- ![air-configure (unconfirmed as IntelliJ)](https://www.jetbrains.com/_assets/rr/air-configure-DHl43cDn.png) Caption: image on the IDEA page, product not confirmed.
- ![air-context (unconfirmed as IntelliJ)](https://www.jetbrains.com/_assets/rr/air-context-CSuiw5KZ.png) Caption: image on the IDEA page, product not confirmed.
- ![air-session (unconfirmed as IntelliJ)](https://www.jetbrains.com/_assets/rr/air-session-BYOwWy9v.png) Caption: image on the IDEA page, product not confirmed.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| JetBrains Toolbox App (recommended by JetBrains) | `download from https://www.jetbrains.com/toolbox-app/` | no |
| Snap (official docs) | `sudo snap install intellij-idea-community --classic` | yes |
| Flatpak (unofficial per some guides) | `flatpak install flathub com.jetbrains.IntelliJ-IDEA-Community` | no |
| Tarball | `download Linux tar.gz from https://www.jetbrains.com/idea/download/` | no |

- From 2025.3 the Community snap downloads the unified IntelliJ IDEA.
- The Arch/AUR package name was not confirmed.

- Source: https://www.jetbrains.com/help/idea/2024.1/installation-guide.html
- Source: https://snapcraft.io/intellij-idea-community

## Install options (research draft; unverified. Search quota ran out; all methods below come from model knowledge and must be checked.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.jetbrains.IntelliJ-IDEA-Community` | no (`--user`) | yes | ID unverified. Launch: `flatpak run com.jetbrains.IntelliJ-IDEA-Community`. |
| Snap | `sudo snap install intellij-idea-community --classic` | yes | yes | Name unverified. Classic confinement. |
| JetBrains Toolbox | download from https://www.jetbrains.com/toolbox-app/ | no | yes | Recommended for updates. Toolbox is an AppImage/tarball (unverified). |
| Tarball | download `ideaIC-*.tar.gz` from https://www.jetbrains.com/idea/download/ | no (in `~/.local/opt`) | yes | Launch `bin/idea.sh`. |

## Manual install (draft)
1. Download `ideaIC-<version>.tar.gz` from https://www.jetbrains.com/idea/download/#section=linux (unverified URL).
2. `mkdir -p ~/.local/opt && tar -xzf ~/Downloads/ideaIC-*.tar.gz -C ~/.local/opt`.
3. Run `~/.local/opt/idea-IC-*/bin/idea.sh`.
4. Check: the first-run wizard starts.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `Unable to load JDK` or IDE will not start | Bundled JBR issue or missing libs. | Install X11/GTK libs listed in JetBrains docs (unverified). |
| Blank window or font problems on Wayland | Wayland rendering. | Set `-Dsun.java2d.xrender=...` per JetBrains docs; use `JETBRAINS_WAYLAND`-style options only if documented (unverified). |
| Low RAM, slow indexing | Default heap too large. | Edit `Help > Edit Custom VM Options`. |
| Flatpak cannot see project files | Sandbox. | `flatpak override --user --filesystem=xdg-documents com.jetbrains.IntelliJ-IDEA-Community` (unverified). |

## Sources
- https://blog.jetbrains.com/idea/2025/01/updated-system-requirements-for-linux-gnu-c-library-glibc/
- https://flathub.org
- https://www.jetbrains.com/help/idea/installation-guide.html.md
- https://www.jetbrains.com/help/idea/requirements-for-intellij-idea.html
- https://www.jetbrains.com/idea/
- https://www.jetbrains.com/idea/download/
- https://www.jetbrains.com/toolbox-app/
