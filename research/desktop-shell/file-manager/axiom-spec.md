# Axiom file-manager specification

V1 is a file-manager entry point, not a Finder replacement. The launcher and
dock may open the configured mature file manager with a user-selected location;
open/save actions use the XDG FileChooser portal. Sidebar, grid/list, tabs,
preview, search, removable media and network locations remain Nautilus-owned.
The Axiom surface must show unavailable/denied/failed states and must not add a
privileged filesystem service. A separate ADR is required for replacement.
