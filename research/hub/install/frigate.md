# Frigate install guide

Status: Partly verified: the official Docker image name and Home Assistant app steps are confirmed. The full `docker run` line was only partly read, and no verified `docker compose up` command exists on the page. Root or docker-group requirement is not stated.


## Install options

| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Docker Compose (recommended) | Compose file with `image: ghcr.io/blakeblackshear/frigate:stable` and `shm_size: "512mb"`; the page shows no `docker compose up` command | Docker daemon access (root or docker group; not stated by the page) | Partly verified: https://docs.frigate.video/frigate/installation |
| Docker CLI | `docker run -d --name frigate --restart=unless-stopped --shm-size=64m ... ghcr.io/blakeblackshear/frigate:stable` (full flags are on the page; only key lines were read) | Docker daemon access (not stated) | Partly verified: https://docs.frigate.video/frigate/installation |
| Home Assistant app | Add repository `https://github.com/blakeblackshear/frigate-hass-addons` in Settings > Apps > App Store > Repositories, then install a Frigate variant | No shell command | Verified (UI steps): https://docs.frigate.video/frigate/installation |
| Kubernetes | Helm chart (no command given in the fetched page) | Not stated | Not verified |

## Possible errors and fixes

- **Error:** `Bus error` on exit.
  - Cause: shared memory is too small (Docker default 64 MB).
  - Fix: raise shm size with `--shm-size` or `service.shm_size`.
  - Source: https://docs.frigate.video/frigate/installation
- **Error:** `RuntimeError: can't start new thread`.
  - Cause: the container hit its PID limit.
  - Fix: raise it with `--pids-limit` or `service.pids_limit`.
  - Source: https://docs.frigate.video/frigate/installation
- **Error:** `OSError: [Errno 24] Too many open files`.
  - Cause: the open-file limit is too low.
  - Fix: raise `nofile` under `ulimits` in Docker Compose.
  - Source: https://docs.frigate.video/frigate/installation
- **Error:** `[HailoRT] [error] CHECK failed - max_desc_page_size given 16384...`.
  - Cause: Hailo accelerator descriptor page size mismatch.
  - Fix: create `/etc/modprobe.d/hailo_pci.conf` containing `force_desc_page_size=4096`, then reboot.
  - Source: https://docs.frigate.video/frigate/installation
- **Error:** WebUI and API on port 5000 unreachable on macOS.
  - Cause: macOS AirPlay Receiver uses port 5000.
  - Fix: remap the host port, for example `"5001:5000"`.
  - Source: https://docs.frigate.video/frigate/installation

