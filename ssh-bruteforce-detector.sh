#!/bin/bash
# ---------------------------------------------
# SSH Brute Force Detector
# Reads auth logs and shows failed SSH attempts
# ---------------------------------------------

LOG_FILE="/var/log/auth.log"
THRESHOLD=5   # block IP if attempts are more than this number

echo "=========================================="
echo "   🚨 SSH Brute Force Detector"
echo "=========================================="

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
  echo "[WARN] Log file not found: $LOG_FILE"
  echo "[INFO] On some systems, logs may be in: /var/log/secure"
  exit 1
fi

echo "[INFO] Reading log file: $LOG_FILE"
echo

# Extract failed password attempts and count per IP
echo "📌 Top IPs with failed SSH login attempts:"
echo "------------------------------------------"

FAILED_IPS=$(grep "Failed password" "$LOG_FILE" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr)

if [ -z "$FAILED_IPS" ]; then
  echo "[OK] No failed SSH password attempts found 🎉"
  exit 0
fi

echo "$FAILED_IPS"
echo

# Show suspicious IPs above threshold
echo "⚠️ IPs above threshold ($THRESHOLD attempts):"
echo "------------------------------------------"

SUSPICIOUS=$(grep "Failed password" "$LOG_FILE" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | awk -v t=$THRESHOLD '$1 > t {print $2}')

if [ -z "$SUSPICIOUS" ]; then
  echo "[OK] No IP crossed the threshold."
else
  echo "$SUSPICIOUS"
fi

echo
echo "=========================================="
echo "   ✅ Scan completed"
echo "=========================================="
