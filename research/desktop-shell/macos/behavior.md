# Observable behavior model

DOCUMENTED behavior is summarized in [evidence](evidence.md). The model to study
is app identity → one or more windows → particular window state. Persisted Dock
membership is independent of current windows. Removing membership must not
uninstall the application. Closing a window and ending a process are different
operations; Linux app lifetime ultimately belongs to each application.

For Axiom, preserve these distinctions while deriving transitions from Linux
runtime evidence. No inference about Apple private window storage, animation
engines or IPC follows from the behavior model.
