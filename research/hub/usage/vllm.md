# vLLM

## When to use
- You serve an LLM to many users or apps and need high throughput from a GPU.
- You want an OpenAI-compatible API server for an open-weight model.
- You need memory-efficient inference (PagedAttention) and continuous batching.
- You run on NVIDIA, AMD or Intel GPUs, or on supported CPUs.

## How it works
- A Python library and server (Apache-2.0) from the vLLM project.
- Installed into a user-level Python environment with uv or pip.
- Serves models over an OpenAI-compatible API; Docker images are also published.
- Supports quantization, distributed inference, structured output and multi-LoRA.

## Not for
- Single-user desktop chat on a laptop; a lighter local runner is simpler there.
- Native Windows, which the docs do not support (use WSL).

## Sources
- https://github.com/vllm-project/vllm
- https://vllm.ai
- https://docs.vllm.ai/en/latest/getting_started/installation/gpu/
