# Ollama
## When to use
- You want to run open models locally from the command line.
- You need a local REST API for your own apps on a headless machine.
- You want an OpenAI-compatible endpoint on your machine.
- You want to script model calls in CI or on a server.
## How it works
- `ollama pull <model>` downloads a model; `ollama run <model>` downloads if needed and starts a chat.
- `ollama serve` starts the server on Linux if it is not running.
- The local REST API is at `http://localhost:11434` with `/api/chat` and OpenAI-compatible `/v1/chat/completions`.
- Set `"stream": false` to get one response, then read `message.content` or `choices[0].message.content`.
- Cloud models use `OLLAMA_API_KEY` and `https://ollama.com`.
## Not for
- Users who want a GUI for browsing and chatting with models; use LM Studio.
- Machines with little memory; a large model needs roughly 8 GB VRAM or unified memory for comfortable use.

## Sources
https://docs.ollama.com/quickstart
