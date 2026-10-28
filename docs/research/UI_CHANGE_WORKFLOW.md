# How a future Axiom UI change should be made

Status: **RESEARCH/DOCUMENTATION ONLY**. No implementation is being added by
this workflow.

## Ownership model

```text
Hyprland / Wayland protocols
        │ authoritative window, focus, workspace, monitor and input state
        ▼
Quickshell native models and bounded adapters
        │ normalized identity, availability, pending/failed/stale state
        ▼
Axiom QML surfaces
        │ render, accept user intent, show result and cancellation
        ▼
Narrow user-session APIs (only when required)
        │ independently authorize one operation and one target
        ▼
Linux primitive / service response
```

The QML surface is never the source of truth. It must not infer a window's
identity from a title, turn a visible button into authority, or execute
arbitrary shell text. A privileged operation remains denied when its caller,
operation, target or freshness proof is missing.

## Research-before-code checklist

For every surface or interaction, write the following before touching QML:

- **Behavior:** trigger, visible states, focus order, cancellation, timeout,
  success and failure.
- **Evidence:** public reference, Linux source path/revision, runtime trace or
  REA Evidence ID; distinguish documented, source-inspected, observed,
  proposed and unknown.
- **Authority:** exact owner of the state and exact API that may request a
  mutation; record why no broader executor is needed.
- **Data contract:** typed values, untrusted fields, identity normalization,
  unavailable/denied/stale representation and error text policy.
- **Visual contract:** Axiom tokens, original assets, reduced-motion behavior,
  keyboard/focus/accessibility rules and responsive/mixed-DPI layout.
- **License/provenance:** every copied source, icon, font, sound, screenshot,
  text fragment and trademark reference.
- **Validation:** disposable guest or explicitly scoped session, failure and
  security cases, artifact paths, environment versions and measurable latency.

The eight records required by the [desktop-shell workflow](../../research/desktop-shell/README.md)
are the minimum durable form of this checklist.

## Safe implementation shape when coding resumes

1. Add or update a small adapter/service contract first; do not duplicate
   compositor state in a decorative model.
2. Keep visual components pure where possible: properties in, signals out,
   no raw socket parsing, no `eval`, no string-built shell commands.
3. Make lifecycle explicit: connect, observe, unavailable, reconnect,
   disconnect, stale and shutdown. Bound timers and buffers.
4. Make identity explicit: use compositor/window object identity or a
   validated canonical address; never use title text as a selector.
5. Render real state only. If a backend is absent, show an honest unavailable
   state or keep the surface closed; do not populate sample windows or fake
   battery/network/audio values.
6. Keep mutations narrow and reversible where the Linux contract supports it.
   Each button must map to one reviewed operation, one validated target and a
   verifiable result.
7. Test with normal, terminal, browser/Electron, multiple same-app windows,
   fullscreen, multi-monitor/mixed-DPI, lock/unlock, disconnect and keyboard-
   only cases before calling the feature integrated.
8. Measure the actual interaction boundary (for example, request accepted to
   compositor-confirmed state), not a screenshot render time.

## Feature-specific direction

| Surface | Research question before code | Implementation boundary to preserve |
| --- | --- | --- |
| Window controls | Which Hyprland/Wayland operation is real for close, maximize, minimize and restore, and how is each confirmed? | One target identity; no title-based dispatch; explicit unsupported/minimized policy |
| Dock | How are desktop entries, launched processes, grouping and pins represented by the actual session? | Icons/entries are data; launch path is validated; no invented running state |
| Top bar | Which services own network, Bluetooth, audio, battery, power, time and notifications? | Each module shows unavailable/denied/failed states and uses the narrow existing API |
| Launcher | What is indexed locally, when is it stale, and how are commands separated from search text? | Search text is data; command execution is a separate authorized action |
| Control Center | Which toggles have a stable system API and what confirmation proves success? | No generic shell passthrough; privileged paths stay outside the UI |
| Notifications | What service owns history, grouping, action buttons and DND? | Notification content is untrusted; actions are typed and scoped |
| Workspace overview | Which windows/workspaces are real, and are thumbnails technically proven? | No fake thumbnails or duplicate authority; drag/drop only after protocol evidence |
| File manager | Which mature file manager and portal contracts already solve the problem? | Specification first; no full replacement without a separate architecture decision |

## “Looks right” is not the exit criterion

The implementation may not advance solely because a QML window renders, an
animation resembles a reference, or an IPC command appears to work once. The
feature is ready for completion only when the dossier, license record, actual
session evidence, failure behavior, security review and measured limitations
all agree.
