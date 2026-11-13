# Wireshark

## When to use
- You need to see exactly what packets a host, app or device sends and receives.
- You are debugging a network protocol, a slow connection or a failed handshake.
- You want to follow a TCP or other protocol stream from start to end.
- You need to open, inspect or share an existing capture file.

## How it works
- Capture sets up a live capture on a network interface, optionally with a capture filter.
- Packets appear in a list; you select one to see its decoded protocol fields and raw bytes.
- Display filters narrow the view to matching packets using field expressions.
- Follow Stream and expert information group related packets and flag problems.
- Statistics windows and protocol-specific tools (such as VoIP/RTP) summarize traffic.

## Not for
- Blocking or changing traffic; use a firewall tool such as nftables.
- Quick bandwidth monitoring without packet detail; use a simpler traffic monitor.

## Sources
- https://www.wireshark.org/docs/wsug_html_chunked/
