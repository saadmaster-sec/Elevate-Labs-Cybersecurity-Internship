# Task 05: Network Traffic Capture & Protocol Analysis

## Objective
Capture live network packets and identify basic protocols and traffic types using Wireshark.

## Capture Overview
| | |
|---|---|
| **Tool** | Wireshark (Kali Linux) |
| **Interface** | eth0 |
| **Traffic generated** | Browsing (Apple Store, Google), `ping -c 10 google.com` |
| **Total packets captured** | 21,271 |
| **Protocol breakdown** | TCP: 19,465 · UDP: 1,712 (incl. DNS: 1,082) · ICMP: 25 |
| **File** | [`network-capture.pcapng`](./network-capture.pcapng) |

## Protocols Identified

### 1. DNS — 1,082 packets
*(Screenshot: [`dns-filtered.png`](./screenshots/dns-filtered.png))*

Filtering on `dns` showed queries and responses resolving domains for every
site visited — not just the sites themselves, but everything they load in the
background: `normandy.cdn.mozilla.net`, `services.addons.mozilla.org`,
`www.google.com`, `fonts.gstatic.com`, and several ad-tech/tracking domains
(`mediarithmics.com`, `pubmatic.com`, `kargo.com`) triggered just by loading
ordinary pages. This is a good illustration of how much DNS traffic a single
"visit two websites" session actually generates — most of it invisible to the
user, driven by embedded trackers, fonts, and CDN lookups.

### 2. TLS — the majority of traffic (19,056 packets on port 443)
*(Screenshot: [`tls-filtered.png`](./screenshots/tls-filtered.png))*

Filtering on `tls` showed full handshakes in progress — **Client Hello**,
**Server Hello, Change Cipher Spec**, and encrypted **Application Data**
afterward, across both TLS 1.2 and TLS 1.3. Even though the actual page
content is encrypted and unreadable, the **Client Hello's SNI (Server Name
Indication)** field reveals which domain is being connected to in plaintext
— e.g. `SNI=normandy.cdn.mozilla.net`, `SNI=services.addons.mozilla.org` were
visible directly in the packet list. This is a good practical answer to "can
Wireshark decrypt encrypted traffic" — it can't read the payload, but it can
still reveal *who you're talking to* via SNI, which is itself useful for
network monitoring or troubleshooting.

### 3. HTTP (OCSP over port 80) — 74 packets
*(Screenshot: [`http-ocsp-filtered.png`](./screenshots/http-ocsp-filtered.png))*

Filtering on `http` surfaced **OCSP (Online Certificate Status Protocol)**
traffic — requests checking whether a website's TLS certificate has been
revoked. The notable detail: OCSP requests/responses travel over **plain
HTTP (port 80)**, not HTTPS, even though they're part of validating an HTTPS
connection's certificate. One request went to an Amazon Trust Services OCSP
responder (`ocsp.r2m04.amazontrust.com`, visible in the packet's hex payload).

### 4. ICMP — 25 packets
*(Screenshot: [`icmp-filtered.png`](./screenshots/icmp-filtered.png))*

Two distinct things showed up here, worth reporting honestly:
- The `ping -c 10 google.com` command itself **failed** — 100% packet loss,
  likely due to an IPv6 routing issue in the VM's network setup (the resolved
  address was IPv6, `2404:6800:4000:101d::71`).
- Despite that, the capture still recorded a **successful Echo
  request/reply pair** with the local gateway (`192.168.29.1`) — an automatic
  connectivity check, not something manually triggered.
- The remaining ICMP packets were mostly **"Destination Unreachable (Port
  Unreachable)"** messages from various IPs — a common side effect of modern
  browsers attempting **QUIC/HTTP3 over UDP** first, then falling back to
  TCP/TLS when the UDP port is closed on the server side. This is a
  legitimate, everyday protocol negotiation behavior, not an error.

## Summary
This capture demonstrates a realistic mix of everyday browsing traffic:
DNS resolving far more domains than the sites visited directly imply, TLS
dominating volume while still leaking destination hostnames via SNI, OCSP
quietly running over plaintext HTTP as part of certificate validation, and
ICMP revealing both a failed manual ping and normal QUIC-fallback behavior.
Together these four protocols cover the full range the task asked for —
name resolution, encrypted application traffic, plaintext protocol
occurring within an otherwise "secure" flow, and network-layer diagnostics.
