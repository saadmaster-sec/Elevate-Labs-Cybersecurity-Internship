# Task 05: Capture and Analyze Network Traffic Using Wireshark

## Objective
Capture live network packets and identify basic protocols and traffic types.

## Tools Used
- Wireshark (Kali Linux)

## Methodology
1. Started a capture on `eth0`
2. Generated traffic by browsing (Apple Store, Google search) and running `ping -c 10 google.com`
3. Stopped the capture after roughly a minute
4. Filtered by protocol (`dns`, `tls`, `http`, `icmp`) to identify and analyze distinct traffic types
5. Exported the full capture as `.pcapng`
6. Wrote up findings per protocol, including two unplanned but genuinely useful observations: a failed ping (IPv6 routing issue) and OCSP certificate-check traffic running in plaintext over HTTP

## Results
Full breakdown in [`protocol-analysis-report.md`](./protocol-analysis-report.md), covering:
- **DNS** (1,082 packets) — name resolution for visited sites plus embedded trackers/CDNs
- **TLS** (19,056 packets) — full handshakes visible, SNI reveals destination hostnames even though payloads are encrypted
- **HTTP/OCSP** (74 packets) — certificate revocation checks traveling over plaintext HTTP
- **ICMP** (25 packets) — a failed manual ping alongside normal QUIC-fallback "port unreachable" traffic

Total capture: 21,271 packets (TCP: 19,465 · UDP: 1,712 · ICMP: 25).

## Deliverables
- [`network-capture.pcapng`](./network-capture.pcapng) — full raw capture
- [`protocol-analysis-report.md`](./protocol-analysis-report.md) — protocol-by-protocol findings

## Screenshots
See [`screenshots`](./screenshots) for the traffic-generation source, and each filtered protocol view (DNS, TLS, HTTP/OCSP, ICMP).
