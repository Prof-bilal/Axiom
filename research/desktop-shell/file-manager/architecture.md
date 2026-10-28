# File manager architecture

The Axiom shell owns navigation entry points only. Nautilus (or a later
approved replacement) owns directory enumeration, thumbnails, rename/copy and
mount integration. Portals own application file selection and authorization.
The shell receives plain display values and never interpolates paths into a
shell command. Removable-media and network locations remain user-session
operations with explicit failure reporting; no root file broker is introduced.
