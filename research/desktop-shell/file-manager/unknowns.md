# File manager unknowns

1. Whether Nautilus is shipped in the foundation image is unknown; resolve by
   checking the staged package manifest before release. 2. Portal availability
   in a locked or minimal session is unproven; test absent and denied portal
   responses. 3. Removable/network mount latency and thumbnail resource cost
   need guest measurements. 4. A future replacement would require a separate
   ADR, license review and recovery tests rather than a UI-only swap.
