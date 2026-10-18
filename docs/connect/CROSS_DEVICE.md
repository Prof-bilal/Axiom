# Workspace continuation and other devices

Status: LATER research; no V1 cross-device continuation. Last researched: 2026-10-18.

Workspace continuation transfers a declarative manifest, not a running process checkpoint. Proposed manifest version 1: repository identity, selected commit/branch, workspace-relative files, application IDs, terminal working directories, container definitions and explicitly approved task context. Browser tabs require separate per-domain opt-in. Secrets, SSH keys, environment variables, terminal scrollback and provider session tokens are excluded.

Receiving devices validate schema, signatures/peer identity, path containment and local availability. A saved manifest is untrusted input: opening it cannot execute hooks, clone arbitrary credentials, run container commands or install packages silently. Show a dry-run diff and missing dependencies; each resulting capability goes through current policy. Dirty Git work and unavailable commits require an explicit conflict path; no silent push or destructive checkout.

Do not transfer provider session IDs as portable AI memory. Export only selected local context with provenance and redaction. Default local activity uses structured events, retention limits and deletion controls; screenshots are absent unless a later opt-in design passes review.

A desktop-to-laptop proof must demonstrate resume with different home paths, absent applications, offline operation, stale manifest, malicious paths and conflicting branches. Data compatibility and revocation need versioned tests before multi-device UX claims.

iOS research is bounded to APIs and applications Apple actually permits; universal notification mirroring, SMS/calls, unrestricted background clipboard and remote control are not promised. Tablet second display and seamless Handoff remain research, including encoding, input, latency, battery and licensing costs.

WebRTC provides a media/peer-connection building block, not discovery, account identity or authorization. QUIC supplies transport mechanisms, not workspace synchronization. Sources: [WebRTC](https://www.w3.org/TR/webrtc/), [QUIC RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000). See [architecture](../ARCHITECTURE.md), [connect](CONNECT.md).
