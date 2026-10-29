# Wayland integration boundaries

Status: Phase 0 baseline. Wayland is the display protocol boundary, not a
promise to adopt a particular compositor project. Axiom must use standard
protocols, portals and documented compositor adapters while it develops its
own session layer.

| Need | Preferred mechanism | Required proof |
| --- | --- | --- |
| Launch application | Desktop entry/application ID and a validated session launcher | No shell expansion; failure is attributable |
| File selection | XDG document/file chooser portal | Scope, revocation and cancellation |
| Screen sharing | ScreenCast portal + PipeWire | Visible consent, selected source, stop/revocation |
| Remote input | RemoteDesktop portal where supported | Explicit consent, lock behavior and revocation |
| Global shortcut | Standard global-shortcut protocol or portal | Conflict handling and session scope |
| Window/workspace control | Axiom session contract over supported compositor APIs | Versioned operations; no arbitrary script upload |
| Shell surfaces | Layer-shell or the chosen supported surface protocol | Output/scale/focus correctness and lock behavior |
| Accessibility | Toolkit accessibility/AT-SPI interfaces | Names, roles, focus and privacy review |
| Capture/recording | Portal or compositor screencopy permission | Denial is honored; no hidden fallback |

The shell is trusted user-session code, not a sandbox. It must not run as root,
change compositor consent defaults, grant an agent global input/screencopy,
silently fall back to X11 authority or treat a window title/file as trusted
instruction. Unsupported operations return explicit typed errors. Content from
windows, files, portals and providers remains untrusted model input.

Experiments include output removal, mixed DPI, keyboard focus, portal denial,
screen-share stop on lock/logout, compositor restart, shell restart and an
agent attempt to approve its own permission UI.
