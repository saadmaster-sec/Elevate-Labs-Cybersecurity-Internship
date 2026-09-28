# Cowrie Honeypot Project

A defensive cybersecurity project using **Cowrie**, an SSH/Telnet honeypot, to simulate a vulnerable Linux system, capture login activity and commands, and analyze the collected logs with Python.

This project was completed as part of a cybersecurity internship project phase focused on honeypots, monitoring, logging, and SOC-style analysis.

## Objective

The goal of this project is to deploy a honeypot that can:

- Simulate a vulnerable SSH service
- Capture connection attempts
- Record usernames and passwords
- Log attacker commands and session activity
- Store events in structured JSON logs
- Analyze collected activity using Python
- Summarize connections, login attempts, source IPs, credentials, and commands

All testing in this project was performed in a **controlled localhost lab environment** using `127.0.0.1`. No real external attackers were involved.

## Tools Used

- Kali Linux
- Cowrie Honeypot
- Python 3
- Python virtual environment (`venv`)
- OpenSSH client
- JSON logging
- Bash / Linux terminal
- Oracle VirtualBox

## Project Setup

A dedicated Cowrie user was created to avoid running the honeypot as root.

```bash
sudo adduser --disabled-password cowrie
sudo su - cowrie
```

A separate project directory and Python virtual environment were created:

```bash
mkdir ~/honeypot
cd ~/honeypot

python3 -m venv cowrie-env
source cowrie-env/bin/activate
```

Cowrie was then installed inside the virtual environment:

```bash
python -m pip install --upgrade pip
python -m pip install cowrie
```

## Initializing Cowrie

Cowrie was initialized with:

```bash
cowrie init
```

This created the main configuration and runtime directories, including:

```text
etc/
var/
var/log/cowrie/
var/lib/cowrie/
var/run/
```

Cowrie was started using:

```bash
cowrie start
```

Its status was checked using:

```bash
cowrie status
```

The SSH honeypot service was confirmed to be listening on port `2222`:

```bash
ss -tuln | grep 2222
```

## Testing the Honeypot

SSH connections were generated from the same Kali machine using localhost.

Example:

```bash
ssh -p 2222 admin@127.0.0.1
```

Other test usernames included:

```text
test
root
admin
```

Fake lab passwords were used during testing, including:

```text
admin123
password123
hello123
```

After a successful login, Cowrie presented an emulated Linux shell.

Example commands entered inside the honeypot included:

```bash
whoami
ls
uname -a
pwd
cat /etc/passwd
exit
```

The `/etc/passwd` output shown inside the session was part of Cowrie's **emulated filesystem**, not the real Kali system.

## Cowrie Logging

Cowrie recorded activity in both human-readable and structured formats.

Main log files:

```text
var/log/cowrie/cowrie.log
var/log/cowrie/cowrie.json
```

The standard log captured events such as:

- New SSH connections
- Source IP addresses
- SSH client information
- Login attempts
- Successful logins
- Commands entered
- Session closing events

Example:

```text
login attempt [admin/admin123] succeeded
```

The JSON log stored the same activity in structured form, including fields such as:

```text
eventid
src_ip
src_port
dst_ip
dst_port
username
password
input
session
timestamp
```

## Python Log Analyzer

A Python script named:

```text
analyze_logs.py
```

was created to parse `cowrie.json` and summarize honeypot activity.

The script uses:

```python
import json
from collections import Counter
```

It reads each JSON event and counts:

- Total connections
- Successful logins
- Failed logins
- Source IP addresses
- Usernames attempted
- Passwords attempted
- Commands observed

## Analyzer Output

The test environment produced the following results:

```text
Total Connections: 4
Successful Logins: 4
Failed Logins: 0
```

### Top Source IP

```text
127.0.0.1: 4
```

### Usernames Attempted

```text
admin: 2
test: 1
root: 1
```

### Passwords Attempted

```text
admin123: 2
password123: 1
hello123: 1
```

### Commands Observed

```text
exit: 4
whoami: 1
ls: 1
uname -a: 1
pwd: 1
cat /etc/passwd: 1
```

The analyzer was run with:

```bash
python analyze_logs.py
```

The results were saved to a text file using:

```bash
python analyze_logs.py | tee honeypot_analysis.txt
```

A sample of the raw Cowrie JSON log was also saved:

```bash
cp var/log/cowrie/cowrie.json cowrie_sample.json
```

## Project Files

```text
Cowrie-Honeypot/
├── README.md
├── analyze_logs.py
├── honeypot_analysis.txt
├── cowrie_sample.json
├── screenshots/
└── report/
```

### File Description

- `analyze_logs.py` - Python script used to analyze Cowrie JSON logs
- `honeypot_analysis.txt` - Saved analyzer output
- `cowrie_sample.json` - Sample structured Cowrie event log
- `screenshots/` - Setup, honeypot activity, logs, and analysis screenshots
- `report/` - Final project report

## Screenshots

Project screenshots are available in the `screenshots/` directory and document the main stages of the honeypot project.

### Cowrie Setup and Startup

Shows the dedicated Cowrie user, Python virtual environment, Cowrie installation, initialization, and successful startup.

### SSH Test Activity

Shows controlled SSH connections to the honeypot on port `2222` using localhost.

### Captured Cowrie Logs

Shows Cowrie recording login attempts, session activity, and commands.

### Emulated Shell Activity

Shows commands being executed inside Cowrie's fake Linux environment.

### JSON Logging

Shows structured events stored in `cowrie.json`.

### Python Log Analysis

Shows the custom Python analyzer summarizing:

- Total connections
- Successful and failed logins
- Source IP addresses
- Usernames attempted
- Passwords attempted
- Commands observed

## Security and Lab Scope

This project was performed only in a controlled lab environment.

All source activity came from:

```text
127.0.0.1
```

which is the local loopback address.

The captured usernames, passwords, and commands were manually generated for testing purposes and are not real attacker credentials.

The honeypot was not exposed to the public internet.

## Limitations

This project uses locally generated test traffic, so it does not represent real-world attacker behavior.

The Python analyzer currently provides basic counting and summarization only.

It does not currently include:

- Geographic IP enrichment
- Threat intelligence lookups
- Automated blocking
- Real-time dashboards
- Alerting
- Public internet exposure
- Advanced attacker behavior classification

## Future Improvements

Possible future improvements include:

- Detecting repeated brute-force attempts
- Identifying the most common attacker commands
- Adding charts and visualizations
- Integrating AbuseIPDB or VirusTotal
- Adding alerting for repeated suspicious activity
- Using a dashboard to display honeypot events
- Running the honeypot in a properly isolated cloud lab

## Key Learning Outcomes

This project helped demonstrate:

- How honeypots are used in defensive security
- How fake services can capture suspicious activity
- How SSH activity can be monitored and logged
- How Cowrie records credentials and commands
- How structured JSON logs can be analyzed
- How Python can be used to summarize security telemetry
- How honeypot data connects to SOC monitoring and incident analysis

## Conclusion

This project successfully deployed a Cowrie SSH honeypot in a controlled Kali Linux lab and generated realistic test sessions against the emulated service.

Cowrie captured connection details, credentials, commands, and session activity. A custom Python script then parsed the structured JSON logs and converted the raw telemetry into an easy-to-read security summary.

The project demonstrates practical blue-team concepts including honeypot deployment, activity monitoring, log analysis, basic Python automation, and SOC-oriented security investigation.
