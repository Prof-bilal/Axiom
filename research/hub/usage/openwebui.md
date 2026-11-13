# Open WebUI

## When to use
- You want one shared, self-hosted chat interface for a team or household rather than a single-user desktop app.
- You run Ollama or other OpenAI-compatible model servers and want a browser front end for them.
- You need document-grounded answers (knowledge/RAG) over your own files.
- You want one interface that can switch between local models and cloud providers.

## How it works
- You install it on a server or workstation (Python package, Docker, or desktop app) and open its local web address.
- You connect a provider (for example Ollama, OpenAI, or vLLM) and its models appear in the interface.
- Optional features include tool calling, web search, and knowledge collections for retrieval.
- Open Terminal gives an agent a shell and filesystem to run multi-step tasks and produce files in chat.

## Not for
- A single-user, zero-setup offline chat; Jan or GPT4All are simpler.
- Managing the container host or Docker itself; use Docker or Portainer for that.

## Sources
- https://docs.openwebui.com/
