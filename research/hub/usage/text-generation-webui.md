# text-generation-webui

## When to use
- You want to run LLMs locally on your own hardware, offline and without telemetry.
- You want a Gradio web UI for chat, file attachments and tool-calling.
- You need a local OpenAI- or Anthropic-compatible API for other tools.
- You want to try GGUF, Transformers or ExLlamaV3 models, with optional LoRA training.

## How it works
- Runs as a local web server (default `http://127.0.0.1:7860`).
- Loads GGUF models through llama.cpp, and Transformers or ExLlamaV3 models with the full install.
- Linux one-click start with `./start_linux.sh`; you pick a GPU vendor when prompted.
- Portable builds (CUDA, Vulkan, ROCm, CPU) run without the full Python stack.

## Not for
- Hosted, multi-user production serving; use a serving stack such as vLLM for that.
- Machines without enough disk space; the full install needs about 10 GB plus PyTorch.

## Sources
- https://github.com/oobabooga/text-generation-webui
- https://github.com/oobabooga/textgen
