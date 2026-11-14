# text-generation-webui install guide

Status: Verified: install commands are from the official README and portable instructions. Exact error text was not documented, so the errors above are the documented remedies only.


## Install options

| Method | Command | Needs root | Verified? |
|---|---|---|---|
| One-click start (Linux) | `./start_linux.sh` (choose GPU vendor when prompted) | No | Verified: https://github.com/oobabooga/text-generation-webui |
| Automated one-click | `GPU_CHOICE=A LAUNCH_AFTER_INSTALL=FALSE INSTALL_EXTENSIONS=TRUE ./start_linux.sh` | No | Verified: https://github.com/oobabooga/text-generation-webui |
| Portable venv install | `git clone https://github.com/oobabooga/textgen && cd textgen && python -m venv venv && source venv/bin/activate && pip install -r requirements/portable/requirements.txt --upgrade && python server.py --portable --api --auto-launch` | No | Verified: https://github.com/oobabooga/text-generation-webui |
| Conda full install (NVIDIA PyTorch) | `conda create -n textgen python=3.13`, then `pip3 install torch==2.9.1 --index-url https://download.pytorch.org/whl/cu128` | No (Miniforge install is user-level) | Verified: https://github.com/oobabooga/text-generation-webui |
| Full install requirements (NVIDIA) | `pip install -r requirements/full/requirements.txt` (use `requirements_amd.txt` or `requirements_cpu_only.txt` for other hardware) | No | Verified: https://github.com/oobabooga/text-generation-webui |
| Start the server (conda) | `conda activate textgen && python server.py` | No | Verified: https://github.com/oobabooga/text-generation-webui |

## Possible errors and fixes

- **Error:** tokenizer problems on load.
  - Cause: the tokenizer defaults to fast mode.
  - Fix: start with `--no_use_fast`.
  - Source: https://github.com/oobabooga/text-generation-webui
- **Error:** broken install (the start script fails repeatedly).
  - Cause: the `installer_files` folder is in a bad state.
  - Fix: delete the `installer_files` folder and run the `start_` script again.
  - Source: https://github.com/oobabooga/text-generation-webui
- **Error:** no compatible wheels for a dependency.
  - Cause: no prebuilt wheel matches this system.
  - Fix: use `requirements_nowheels.txt`, compile manually, and install loaders yourself.
  - Source: https://github.com/oobabooga/text-generation-webui
- **Error:** Transformers or EXL3 models will not load on the portable build.
  - Cause: these formats need the full install.
  - Fix: use the full install, and place multi-file models in a subfolder under `user_data/models`.
  - Source: https://github.com/oobabooga/text-generation-webui
- **Error:** conflicting extension dependencies.
  - Fix: use the update wizard's "Install/update extensions requirements" option, which reinstalls the main requirements afterward.
  - Source: https://github.com/oobabooga/text-generation-webui

