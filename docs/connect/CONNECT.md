# Device connectivity architecture

Status: LATER, Phase 11 proof of concept; no connectivity promise in V1. Last researched: 2026-10-18.

Start with Android and evaluate reusing KDE Connect rather than maintaining a competing pairing/protocol stack. First demonstrate authenticated pairing, battery status and one explicit file transfer. Inspect upstream implementations and protocol compatibility before deciding whether to integrate the application, its interfaces or selected protocol behavior. A new connectd requires a documented lifecycle and dependency justification.

Transport is not identity. Discovery advertisements are untrusted; mDNS/Avahi is an optional LAN discovery candidate and BLE an optional proximity signal. Neither proves ownership. Pairing must display/verifiably compare identity, require confirmation on both devices, store keys in reviewed secret storage and support revocation. Encryption must authenticate the selected peer; certificate errors never silently downgrade.

Clipboard, notifications, files and remote control each need separate opt-in scopes with clear direction and disable controls. Locking either device should suspend sensitive flows. Set rate/size/time limits; reject unsolicited file writes and traversal/symlink tricks. Sanitize notification markup and filenames. Audit external actions without persisting notification/clipboard secrets by default.

Prefer an existing authenticated LAN transport for initial evidence. QUIC is RESEARCH if reconnection or multiplexing requirements justify complexity. WebRTC is RESEARCH for real-time media, with signaling/authentication and TURN privacy/cost explicitly designed. PipeWire is the desktop media integration candidate. No cloud relay is enabled by default.

Required tests: spoofed discovery, first-contact MITM, replay, revoked/stolen device, network change, notification injection, transfer interruption and consent withdrawal. Performance includes idle wakeups, transfer throughput, battery and media latency.

Evidence limitation: direct KDE Connect project/wiki fetching was blocked on verification date; integration/security details remain unverified until source inspection. Sources: [KDE Connect upstream](https://invent.kde.org/network/kdeconnect-kde), [BlueZ Device API](https://github.com/bluez/bluez/blob/master/doc/org.bluez.Device.rst), [QUIC RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000), [WebRTC specification](https://www.w3.org/TR/webrtc/). See [Android matrix](ANDROID.md).
