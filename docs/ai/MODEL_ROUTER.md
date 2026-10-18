# Provider router

Status: V1 provider-neutral contract; exact SDK/model versions remain unselected. Last verified: 2026-10-18.

Consider OpenAI, Anthropic, Gemini, OpenRouter and Ollama when designing the boundary. First implementation gate requires one cloud adapter and Ollama, plus fake-provider tests; the remaining adapters are incremental, not release prerequisites. Providers do not receive OS authority. A provider reporting a tool call only produces an untrusted capability proposal.

## Internal contract

Input: request ID; bounded messages with provenance and sensitivity; model selection; supported tool schemas; output/token/time limits; cancellation; explicit upload consent and allowed destination. Output: normalized text deltas, typed tool proposals, finish reason, usage when available and stable errors. Advertise features per model: streaming, tool calls, schema constraints, context size, vision and local availability. Unsupported features return UnsupportedFeature rather than silently emulating weaker security. Keep wire formats, model IDs and provider-specific SDKs inside adapters.

Validate emitted tool arguments against project schemas regardless of provider schema guarantees. Never accept tool names dynamically supplied by model output. Streamed partial arguments cannot execute. Preserve tool-call IDs internally without relying on provider identifiers for authorization. Normalize errors into Auth, RateLimited, Timeout, Offline, UnsupportedFeature, InvalidResponse, Cancelled and ProviderFailure; preserve only redacted diagnostic metadata.

## Privacy, reliability and configuration

Cloud use is opt-in with destination, selected provider/model and categories of outgoing data visible. No silent fallback from local to cloud or between cloud vendors. Context minimization excludes secrets, process environments and unrelated files. Obtain user keys from a user secret store, not source/config files; services evaluate systemd credential delivery when appropriate. Do not put API keys in routine definitions or logs. Local Ollama is local only when its configured endpoint is local: custom remote endpoints need the same disclosure and transport policy as cloud providers.

Enforce request deadlines, response size, bounded backoff and cost/concurrency budgets. Retry only safe provider inference requests where duplicate billing is understood; never retry tool side effects automatically. Endpoint overrides require explicit trust review, TLS validation and SSRF restrictions. No provider credential forwarding to MCP servers. Record model/provider/version selection without full prompt logging.

## Adapter acceptance

Use recorded synthetic fixtures and a fake HTTP server for streaming fragmentation, malformed JSON, unknown tool, duplicate tool ID, rate limits, timeout, cancellation, TLS/endpoint failure and secret redaction. Optional live tests require explicit configured credentials and cost bounds, never CI secrets from untrusted forks. Verify actual installed model capability; do not assume all nominally compatible APIs behave alike.

Official API entry points reviewed: [OpenAI](https://developers.openai.com/api/reference/overview), [Anthropic](https://platform.claude.com/docs/en/api/overview), [Gemini](https://ai.google.dev/gemini-api/docs), [OpenRouter](https://openrouter.ai/docs/api_reference/overview), [Ollama](https://docs.ollama.com/api/introduction). Compatibility beyond these documented interfaces requires contract experiments.
