# GPT4All (gpt4all)

Status: unverified. Search not run.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Installer from vendor | download `gpt4all-installer-linux.run` from https://gpt4all.io and run it | no | yes | Unverified filename. |
| Flatpak | unverified | no | yes | Check Flathub. |
| AUR | `yay -S gpt4all-bin` | no | yes | Unverified. |

## Manual install
1. Download the Linux installer from https://gpt4all.io (unverified).
2. `chmod +x gpt4all-installer-linux.run` and run it.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Installer won't run | Not executable. | `chmod +x` on the file. |
| Model download fails | Network or disk full. | Check network and free space; retry. |
| Slow inference | No GPU acceleration. | Use a smaller model. |

## Sources
- https://gpt4all.io (unverified this session)
