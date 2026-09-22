#!/bin/bash

score=100

echo "======================================"
echo "       LINUX SECURITY AUDIT TOOL"
echo "======================================"
echo

echo "[1] SYSTEM INFORMATION"
echo "--------------------------------------"
hostnamectl
echo

echo "[2] CURRENT USER"
echo "--------------------------------------"
whoami
id
echo

echo "[3] LISTENING PORTS"
echo "--------------------------------------"
ss -tuln
echo

echo "[4] RUNNING SERVICES"
echo "--------------------------------------"
systemctl --type=service --state=running --no-pager
echo

echo "[5] FIREWALL CHECK"
echo "--------------------------------------"

INPUT_POLICY=$(iptables -L INPUT | head -n 1 | awk '{print $4}' | tr -d ')')
FORWARD_POLICY=$(iptables -L FORWARD | head -n 1 | awk '{print $4}' | tr -d ')')

if [ "$INPUT_POLICY" = "DROP" ] || [ "$INPUT_POLICY" = "REJECT" ]; then
    echo "[PASS] INPUT firewall policy is restrictive: $INPUT_POLICY"
else
    echo "[WARNING] INPUT firewall policy is: $INPUT_POLICY"
    score=$((score-15))
fi

if [ "$FORWARD_POLICY" = "DROP" ] || [ "$FORWARD_POLICY" = "REJECT" ]; then
    echo "[PASS] FORWARD firewall policy is restrictive: $FORWARD_POLICY"
else
    echo "[WARNING] FORWARD firewall policy is: $FORWARD_POLICY"
    score=$((score-10))
fi

echo

echo "[6] IMPORTANT FILE PERMISSIONS"
echo "--------------------------------------"

PASSWD_PERM=$(stat -c "%a" /etc/passwd)
SHADOW_PERM=$(stat -c "%a" /etc/shadow)

if [ "$PASSWD_PERM" = "644" ]; then
    echo "[PASS] /etc/passwd permissions: $PASSWD_PERM"
else
    echo "[WARNING] /etc/passwd permissions: $PASSWD_PERM"
    score=$((score-10))
fi

if [ "$SHADOW_PERM" = "640" ] || [ "$SHADOW_PERM" = "600" ]; then
    echo "[PASS] /etc/shadow permissions: $SHADOW_PERM"
else
    echo "[WARNING] /etc/shadow permissions: $SHADOW_PERM"
    score=$((score-15))
fi

echo

echo "[7] USERS WITH UID 0"
echo "--------------------------------------"

UID_ZERO_USERS=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
UID_ZERO_COUNT=$(echo "$UID_ZERO_USERS" | wc -l)

if [ "$UID_ZERO_COUNT" -eq 1 ] && [ "$UID_ZERO_USERS" = "root" ]; then
    echo "[PASS] Only root has UID 0"
else
    echo "[WARNING] Multiple UID 0 users detected:"
    echo "$UID_ZERO_USERS"
    score=$((score-20))
fi

echo

echo "[8] SSH CONFIGURATION"
echo "--------------------------------------"

if [ -f /etc/ssh/sshd_config ]; then

    ROOT_LOGIN=$(grep -E "^[[:space:]]*PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}' | tail -n 1)

    PASSWORD_AUTH=$(grep -E "^[[:space:]]*PasswordAuthentication" /etc/ssh/sshd_config | awk '{print $2}' | tail -n 1)

    if [ "$ROOT_LOGIN" = "no" ]; then
        echo "[PASS] SSH root login is disabled"
    elif [ -z "$ROOT_LOGIN" ]; then
        echo "[INFO] PermitRootLogin is not explicitly configured"
    else
        echo "[WARNING] SSH PermitRootLogin: $ROOT_LOGIN"
        score=$((score-10))
    fi

    if [ "$PASSWORD_AUTH" = "no" ]; then
        echo "[PASS] SSH password authentication is disabled"
    elif [ -z "$PASSWORD_AUTH" ]; then
        echo "[INFO] PasswordAuthentication is not explicitly configured"
    else
        echo "[WARNING] SSH PasswordAuthentication: $PASSWORD_AUTH"
        score=$((score-10))
    fi

else
    echo "[INFO] SSH server configuration not found"
fi

echo

echo "[9] SYSTEM UPDATE CHECK"
echo "--------------------------------------"

UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l)

if [ "$UPDATES" -eq 0 ]; then
    echo "[PASS] No pending package updates detected"
else
    echo "[WARNING] $UPDATES package update(s) available"
    score=$((score-10))
fi

echo

echo "[10] PASSWORD POLICY CHECK"
echo "--------------------------------------"

MAX_DAYS=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
MIN_DAYS=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')

echo "[INFO] Password maximum age: $MAX_DAYS days"
echo "[INFO] Password minimum age: $MIN_DAYS days"

if [ "$MAX_DAYS" -le 90 ]; then
    echo "[PASS] Password maximum age is 90 days or less"
else
    echo "[WARNING] Password maximum age is greater than 90 days"
    score=$((score-5))
fi

echo

echo "[11] RISKY SERVICES CHECK"
echo "--------------------------------------"

RISKY_FOUND=0

for service in telnet ftp rsh rlogin; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "[WARNING] Potentially risky service running: $service"
        RISKY_FOUND=1
        score=$((score-10))
    fi
done

if [ "$RISKY_FOUND" -eq 0 ]; then
    echo "[PASS] No common risky legacy services detected"
fi

echo

echo "[12] BASIC ROOTKIT INDICATOR CHECK"
echo "--------------------------------------"

SUID_COUNT=$(find /usr/bin /usr/sbin -perm -4000 -type f 2>/dev/null | wc -l)

echo "[INFO] SUID binaries detected: $SUID_COUNT"

if command -v chkrootkit >/dev/null 2>&1; then
    echo "[INFO] chkrootkit is installed"
    echo "[INFO] A dedicated rootkit scan can be performed separately"
else
    echo "[INFO] chkrootkit is not installed"
    echo "[INFO] Current check is limited to basic indicators"
fi

echo

echo "[13] HARDENING RECOMMENDATIONS"
echo "--------------------------------------"

if [ "$INPUT_POLICY" = "ACCEPT" ]; then
    echo "[RECOMMEND] Review INPUT firewall rules and consider a restrictive default policy."
fi

if [ "$FORWARD_POLICY" = "ACCEPT" ]; then
    echo "[RECOMMEND] Review FORWARD firewall rules and disable forwarding if not required."
fi

if [ "$UPDATES" -gt 0 ]; then
    echo "[RECOMMEND] Install pending security and package updates."
fi

if [ "$MAX_DAYS" -gt 90 ]; then
    echo "[RECOMMEND] Reduce PASS_MAX_DAYS in /etc/login.defs to 90 days or less."
fi

if [ "$RISKY_FOUND" -eq 1 ]; then
    echo "[RECOMMEND] Disable unnecessary legacy network services."
fi

echo "[RECOMMEND] Periodically review SUID binaries for unexpected changes."

if ! command -v chkrootkit >/dev/null 2>&1; then
    echo "[RECOMMEND] Consider using a dedicated rootkit detection tool for deeper scans."
fi

echo

echo "[14] SECURITY SCORE"
echo "--------------------------------------"

if [ "$score" -lt 0 ]; then
    score=0
fi

echo "Security Score: $score/100"

if [ "$score" -ge 80 ]; then
    echo "Overall Status: GOOD"
elif [ "$score" -ge 60 ]; then
    echo "Overall Status: NEEDS IMPROVEMENT"
else
    echo "Overall Status: HIGH RISK"
fi

echo
echo "======================================"
echo "           AUDIT COMPLETE"
echo "======================================"
