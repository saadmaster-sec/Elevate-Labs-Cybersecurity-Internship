# Task 03: Perform a Basic Vulnerability Scan on Your PC

## Objective
Use free tools to identify common vulnerabilities on your computer.

## Tools Used
- Nessus Essentials 10.12.4 (Windows)

## Methodology
1. Installed Nessus Essentials on Windows and registered a free activation code
2. Let the plugin feed download and compile (first-run setup — CPU/disk intensive one-time step)
3. Ran a **Basic Network Scan** against `127.0.0.1` (localhost) — unauthenticated, no Windows credentials configured
4. Reviewed all 78 findings across 26 vulnerability groups, sorted by severity
5. Selected 4 notable findings spanning SSL, SSH, and SMB for detailed write-up
6. Documented results, real risk context, and remediation for each

## Results
Full breakdown in [`vulnerability-scan-report.md`](./vulnerability-scan-report.md), covering:
- SSL Certificate Cannot Be Trusted (Medium, CVSS 6.5) — Nessus's own self-signed cert on its local admin port
- SSH Password Authentication Accepted (Info) — port 22
- OS Identification & Installed Software Enumeration over SSH (Info)
- Microsoft Windows SMB NativeLanManager Remote System Information Disclosure (Info) — port 139/445

Overall result: 1 Medium, remainder Info — no Critical/High findings, an expected and
healthy outcome for an unauthenticated scan of a personal, patched Windows machine.

## Screenshots
See [`screenshots/`](./screenshots) for the full setup-to-results walkthrough:
setup and scan configuration, the results summary, the full vulnerabilities list, and
detail views for each selected finding.
