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

echo "[9] SECURITY SCORE"
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
