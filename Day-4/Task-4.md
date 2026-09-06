# Task 04: Firewall Configuration Report

## Objective
Configure and test basic firewall rules to allow or block traffic, using Windows
Defender Firewall with Advanced Security.

## Environment
Windows Defender Firewall was confirmed on and active across all three profiles
(Domain, Private, Public) before making any changes — inbound connections that
don't match a rule are blocked by default on each, outbound allowed by default.

## Steps Performed

### 1. Blocked inbound Telnet (port 23)
Created a rule via the GUI wizard (Inbound Rules → New Rule → Port):
- Protocol: TCP, Specific local port: 23
- Action: Block the connection
- Profiles: Domain, Private, Public
- Name: `Block-Telnet-23`

*(Screenshots: `rule-type.png` → `name.png` show the full wizard;
`inbound-rule-list.png` shows the rule live in the list)*

### 2. Tested the block
```
Test-NetConnection -ComputerName localhost -Port 23
```
Result: `TcpTestSucceeded: False` — connection attempts on both IPv6 (`::1`) and
IPv4 (`127.0.0.1`) loopback failed, confirming the block rule works as intended.

*(Screenshot: `test-port-23.png`)*

### 3. Allowed inbound SSH (port 22)
```
netsh advfirewall firewall add rule name="Allow-SSH-22" dir=in action=allow protocol=TCP localport=22
```
This reflects a real, intentional state — Task 3's vulnerability scan had already
confirmed an SSH service listening on this machine, so explicitly allowing it
(rather than leaving it to a default/implicit rule) makes the firewall's intent
around that service explicit and auditable.

### 4. Tested the allow rule
```
Test-NetConnection -ComputerName localhost -Port 22
```
Result: `TcpTestSucceeded: True` — SSH is reachable, as intended.

*(Screenshot: `allow-ssh.png`)*

### 5. Removed the test block rule
```
netsh advfirewall firewall delete rule name="Block-Telnet-23"
```
Result: `Deleted 1 rule(s).` Confirmed absent from the full rule dump afterward —
restoring original state for anything unrelated to this task, while keeping the
SSH allow rule as a deliberate, permanent change.

*(Screenshot: `delete-block.png`)*

## How the Firewall Filters Traffic
Windows Defender Firewall evaluates inbound and outbound traffic against an
ordered rule set matched by protocol, port, direction, and profile (network
type). By default here, inbound traffic that matches no rule is dropped —
a "default deny" posture — while outbound traffic that matches no rule is
allowed. Adding an explicit **Block** rule for port 23 meant any inbound TCP
traffic to that port is dropped regardless of the default policy, while the
explicit **Allow** rule for port 22 guarantees SSH traffic gets through even
if broader policy changed later — explicit rules take precedence over defaults.

## Deliverables
- [`firewall-rules-after.txt`](./firewall-rules-after.txt) — the relevant custom
  rule (Allow-SSH-22), extracted and annotated
- [`firewall-rules-full-dump.txt`](./firewall-rules-full-dump.txt) — full raw
  `netsh advfirewall firewall show rule name=all` output, for verification
- `screenshots/`[./Day-4/screenshots] — full walkthrough from rule creation to cleanup
