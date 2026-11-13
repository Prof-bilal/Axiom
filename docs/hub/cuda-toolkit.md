# NVIDIA CUDA Toolkit

- Id: `cuda-toolkit` · Category: Development · Weight: heavy · Licence (catalog): NVIDIA proprietary
- Catalog sources: pacman `cuda`
- Install verified: no · Screenshots: 0 of 3 · Logo: yes

## Overview
GPU compute toolkit for NVIDIA cards.

## Facts
Not researched yet.

## Logo
Bundled icon: `apps/hub/icons/cuda-toolkit.png`.

## Screenshots
Not found.

## Install (verified against a source)
Not verified yet. Use the draft below only after checking it.

## Install options (research draft; Partially verified: the apt, dnf and runfile commands are from the official Linux installation guide, but they were not run here and the Ubuntu keyring package URL was not copied.)
| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Ubuntu (network repo) | Install `cuda-keyring` from the downloads page, then `sudo apt update` and `sudo apt install cuda-toolkit` (run separately) | Yes | Verified: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html (keyring URL not copied; the guide points to developer.nvidia.com/cuda-downloads) |
| Debian | `sudo add-apt-repository contrib`, then keyring, `sudo apt update`, `sudo apt install cuda-toolkit`, reboot | Yes | Verified: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html |
| Fedora / RHEL, Alma, Rocky, Oracle | `sudo dnf install cuda-toolkit` (enable optional repos first on RHEL family) | Yes | Verified: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html |
| Runfile | `sudo sh cuda_<version>_linux.run`, then reboot | Yes | Verified: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html |
| pip (runtime only) | `python3 -m pip install nvidia-cuda-runtime` | No | Verified: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html (not the developer toolkit) |
| GPU driver | Not in the toolkit since CUDA 13.4; install a compatible driver separately | Yes | Verified as a note: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html (driver steps not copied) |

## Possible errors and fixes (draft)
**Error: `nvcc: No such file or directory`**
- Cause: `PATH` does not include the CUDA bin directory.
- Fix: `export PATH=/usr/local/cuda-13.5/bin${PATH:+:${PATH}}`
- Source: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

**Error: `cannot open shared object file` at runtime**
- Cause: `LD_LIBRARY_PATH` does not include the CUDA lib64 directory.
- Fix: `export LD_LIBRARY_PATH=/usr/local/cuda-13.5/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}`
- Source: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

**Symptom: deviceQuery reports no CUDA devices**
- Cause: `/dev/nvidia*` files missing or wrong permissions; on SELinux systems the guide mentions SELinux.
- Fix: check the device files. The guide suggests temporarily running `setenforce 0` as superuser on SELinux systems (a temporary test step, not a permanent fix).
- Source: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

**Error: `E: Failed to fetch file:/var/cuda-repo File not found`**
- Cause: stale apt package lists.
- Fix: `sudo rm -v /var/lib/apt/lists/*cuda* /var/lib/apt/lists/*nvidia*`, then reinstall.
- Source: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

**Error: `Errors were encountered while processing: glx-diversions`**
- Cause: conflicting `nvidia-alternative` packages.
- Fix: `sudo apt install glx-diversions --reinstall`, then `sudo apt remove nvidia-alternative`, then retry.
- Source: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

**Symptom: runfile fails to extract (limited /tmp space)**
- Fix: use `--tmpdir=<path>` with a directory that has more space.
- Source: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

**Driver version mismatch, `nvidia-smi` errors**
- Cause: Not covered by the install guide.
- Fix: Not found on this page.

## Sources
