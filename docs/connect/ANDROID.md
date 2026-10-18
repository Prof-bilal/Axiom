# Android feasibility matrix

Status: LATER research, device/API-version dependent. Last researched: 2026-10-18.

| Feature | Candidate | Limits / required experiment |
|---|---|---|
| Battery / file share | KDE Connect reuse | Inspect protocol, authenticate peer, recipient approval |
| Notifications / replies | Companion with Android notification access | Per-app visibility and reply actions vary; deny by default |
| SMS / calls | Companion/system integrations | Android roles, permissions and distribution restrictions; no universal promise |
| Clipboard | Companion/KDE Connect | Background clipboard restrictions vary; explicit directional sharing |
| Screen mirroring | scrcpy / ADB | Developer-mode/ADB authorization risk; not invisible consumer pairing |
| Webcam | scrcpy V4L2 output experiment or companion media stream | Camera/OS support and virtual-device setup need validation |
| Hotspot | NetworkManager + Android companion | Android control permissions vary; never assume remote toggling |
| Keyboard/mouse | Consent-scoped portal + companion | Screen lock, revocation, latency and injection boundaries |
| BLE discovery | BlueZ + companion | Discovery only; pairing identity remains separate |

scrcpy supports Android display/control and has documented USB debugging requirements; camera/mirroring modes have their own version/device limits. ADB grants broad developer authority beyond a narrow file-share feature. It must be an explicit advanced flow, with clear authorization/revocation instructions and no globally exposed debugging port. Prefer the smallest companion permission set for ordinary user features.

Test minimum and current Android API levels on at least two vendors plus permission denial, background restrictions, revoked notification access, screen lock, USB reconnect and network loss. Record exact OS/device, scrcpy/ADB versions, feature and failure behavior. No blanket Android compatibility claim.

Sources: [scrcpy upstream and feature documentation](https://github.com/Genymobile/scrcpy), [Android ADB documentation](https://developer.android.com/tools/adb), [KDE Connect source—inspection pending](https://invent.kde.org/network/kdeconnect-kde). See [connect threat boundaries](CONNECT.md).
