# LM Studio
## When to use
- You want to run language models locally with a graphical app.
- You want to search and download models from Hugging Face inside the app.
- You want a local OpenAI-compatible server for your own scripts or tools.
- You want to chat with a local model and attach documents offline.
## How it works
- Discover tab (Ctrl/Cmd+2) searches models by keyword, `user/model`, or a Hugging Face URL.
- Pick a quantized version; lower Q numbers are smaller with some quality loss.
- Chat screen runs a loaded model; My Models sets where models are stored.
- The local server exposes OpenAI-style endpoints at `http://localhost:1234/v1`, including chat completions and embeddings.
- Loading a model and starting the server steps: Not found on the pages I could read.
## Not for
- Headless servers or CI pipelines; use Ollama, which is CLI-first.
- Users who need hosted frontier models; use a cloud provider directly.

## Sources
https://lmstudio.ai/docs/app
https://lmstudio.ai/docs/app/basics/download-model
https://lmstudio.ai/docs/developer/openai-compat
