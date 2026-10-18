---
name: provider-adapter
description: "Implement replaceable AI provider adapters with consistent streaming and errors."
---

# provider-adapter

## When to use

Use for OpenAI, Anthropic, Gemini, OpenRouter or Ollama integration. Do not use for spreading provider-specific types across OS services.

## Required inputs

Provider docs/version, endpoint, credentials, model requirements and normalized contract.

## Procedure

1. Verify current official provider API; keep wire schemas inside one adapter and explicitly map capability differences.
2. Normalize messages/tool requests, streaming, cancellation, token/usage data and retryable versus terminal errors.
3. Define context/output bounds, timeouts and redaction; disclose remote destinations and retain offline operation for core OS functions.
4. Keep model planning incapable of bypassing capability authorization; local inference receives no automatic trust.
5. Use deterministic fixtures/mocks for rate limits, malformed streams, tool calls, cancellation and provider replacement.

## Validation

Contract tests pass without live credentials; optional live smoke tests disclose cost/data use and never assert unsupported model features.

## Failure handling

Fail with actionable normalized errors; bound retries and require explicit policy before falling back to another provider/data destination.

## Project references

- [ai/MODEL_ROUTER.md](../../../docs/ai/MODEL_ROUTER.md)
- [ai/AI_ARCHITECTURE.md](../../../docs/ai/AI_ARCHITECTURE.md)
