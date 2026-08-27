# Task 01: Scan Your Local Network for Open Ports

## Objective
Discover open ports on devices within a local network to understand overall network exposure and identify potential security risks.

## Tools Used
- **Nmap** — network scanning
- **Wireshark** *(optional)* — packet capture analysis
- **Kali Linux** (VirtualBox, bridged network adapter)

## Methodology
1. Identified local IP range using `ip a` → `192.168.29.146/24`
2. Ran a TCP SYN scan:
   ```
   sudo nmap -sS 192.168.29.146/24
   ```
3. Recorded live hosts, open ports, and the services running on them
4. Cross-referenced each open port against its default/common service
5. Saved output to `scan-results.txt`
6. *(Optional)* Captured traffic during the scan in Wireshark to observe the SYN scan behavior at the packet level

## Results

| Host IP | Open Port(s) | Service | Notes |
|---------|-------------|---------|-------|
| 192.168.29.1 (router) | 53, 80, 443, 1900, 7443, 8080, 8443 | domain, http, https, upnp, oracleas-https, http-proxy, https-alt | Closed: 2869, 8002, 8200. 7 open ports is a broad surface for a gateway device |
| 192.168.29.21 | none | — | All 1000 ports filtered (no response) |
| 192.168.29.254 | 445 | microsoft-ds (SMB) | Windows/Intel NIC host |

*(Full raw output in [`scan-results.txt`](./scan-results.txt))*

## Key Findings / Risk Assessment
- **Router (.1) exposes 7 open ports**, including UPnP (1900), UPnP allows LAN devices to request port forwards without authentication, which is a common home-router hardening target. Worth disabling if not actively needed.
- **SMB open on .254 (port 445)** is the highest-risk finding, SMB is a classic lateral-movement/ransomware vector (e.g., EternalBlue). Worth confirming the SMB version and whether file sharing is actually required on that host.
- **.21 (D-Link device) returned zero open ports**, a useful contrast showing not every device on the LAN is equally exposed.

## Wireshark Packet Analysis
Went beyond the base task requirement by capturing and analyzing the scan traffic in Wireshark.

**Setup:**
1. Started a Wireshark capture on the active interface (`eth0`/`wlan0`), filtered to the target subnet: `net 192.168.X.0/24`
2. Ran the Nmap SYN scan while the capture was active
3. Stopped the capture once the scan completed, saved as `wireshark-capture.pcapng`

**Filters used to isolate scan behavior:**
- `tcp.flags.syn==1 && tcp.flags.ack==0` — SYN packets Nmap sent
- `tcp.flags.syn==1 && tcp.flags.ack==1` — SYN-ACK replies (confirms open ports)
- `tcp.flags.reset==1` — RSTs from closed ports

**Observations:**
Filtering on `tcp.flags.syn==1 && tcp.flags.ack==1` returned 20 packets out of 6,959 captured (0.3%), confirming 8 unique open ports — 53, 80, 443, 1900, 7443, 8080, 8443 on .1, and 445 on .254 — an exact match to Nmap's results. The repeated SYN-ACKs seen for .254:445 (5 occurrences across different ephemeral source ports) are retransmissions from Nmap re-probing the same port, not additional open ports. In every case, no final ACK follows the SYN-ACK — confirming the "half-open" nature of a SYN scan, since Kali never completes the three-way handshake.

*(Capture file: [`wireshark-capture.pcapng`](./wireshark-capture.pcapng))*

## Screenshots
Screenshots for terminal output of the Nmap scan and the Wireshark capture.

### ip address
![ip](/Day-1/ip-a.png)

### nmap scan
![namp](/Day-1/nmap-scan.png)

### wireshark capture
![wireshark](/Day-1/wireshark-capture.png)
