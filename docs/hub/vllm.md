# vLLM

- Id: `vllm` · Category: Development · Weight: heavy · Licence (catalog): Apache-2.0
- Catalog sources: pip `vllm`
- Install verified: no · Screenshots: 0 of 3 · Logo: yes

## Overview
High-throughput LLM inference server.

## Facts
Not researched yet.

## Logo
Bundled icon: `apps/hub/icons/vllm.png`.

## Screenshots
Not found.

## Install (verified against a source)
Not verified yet. Use the draft below only after checking it.

## Install options (research draft; Verified: install commands are from the official GPU installation page. The page gives no sudo or root requirement, and no minimum driver version for the pip path.)
| Method | Command | Needs root | Verified? |
|---|---|---|---|
| uv environment | `uv venv --python 3.12 --seed --managed-python && source .venv/bin/activate` | No | Verified: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/ |
| uv install (CUDA 12.9 default) | `uv pip install vllm --torch-backend=auto` then `vllm download-kernels` | No | Verified: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/ |
| pip install (CUDA 12.9) | `pip install vllm --extra-index-url https://download.pytorch.org/whl/cu129` then `vllm download-kernels` | No | Verified: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/ |
| Docker (NVIDIA) | `docker run --runtime nvidia --gpus all -v ~/.cache/huggingface:/root/.cache/huggingface -p 8000:8000 --ipc=host vllm/vllm-openai:latest --model Qwen/Qwen3-0.6B` | Docker daemon access (not stated) | Verified: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/ |
| Source build (editable) | `uv pip install -e . --torch-backend=auto` | No | Verified (from the errors section): https://docs.vllm.ai/en/latest/getting_started/installation/gpu/ |

The page gives no bare `vllm serve` example for NVIDIA. Its NVIDIA example is the Docker command above.

## Possible errors and fixes (draft)
- **Error:** NCCL problems when PyTorch came from conda.
  - Cause: conda-installed PyTorch conflicts with the vLLM build.
  - Fix: create a fresh environment with uv or venv instead of conda.
  - Source: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/
- **Error:** slow startup or a "kernels" warning; FlashInfer refuses to import after an upgrade.
  - Cause: kernels are missing or stale after install or upgrade.
  - Fix: run `vllm download-kernels` in the same environment.
  - Source: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/
- **Error:** binary incompatibility with a different CUDA or PyTorch version.
  - Cause: mismatched CUDA or PyTorch build.
  - Fix: install into a fresh environment, or build from source with `uv pip install -e . --torch-backend=auto`.
  - Source: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/
- **Error:** source build runs out of memory.
  - Fix: `export MAX_JOBS=6` (lower it on constrained machines).
  - Source: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/
- **Error:** `nvcc` not found during source build.
  - Fix: set `CUDA_HOME` (for example `/usr/local/cuda`), add `${CUDA_HOME}/bin` to `PATH`, and check with `nvcc --version`.
  - Source: https://docs.vllm.ai/en/latest/getting_started/installation/gpu/

## Sources
