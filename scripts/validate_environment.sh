#!/bin/bash

set -e

echo "[INFO] Validating host system..."

# CPU Virtualization
if grep -E -c 'vmx|svm' /proc/cpuinfo > /dev/null; then
  echo "[OK] CPU supports virtualization"
else
  echo "[ERROR] Virtualization not supported (missing vmx/svm)"
  exit 1
fi

# Memory Check
RAM_MB=$(free -m | awk '/Mem:/ { print $2 }')
if (( RAM_MB < 32000 )); then
  echo "[WARNING] Less than 32 GB RAM detected"
else
  echo "[OK] RAM available: ${RAM_MB}MB"
fi

# Disk Check
DISK_FREE=$(df / | awk 'END{print $4}')
if (( DISK_FREE < 300000000 )); then
  echo "[WARNING] Less than 300 GB free on root filesystem"
else
  echo "[OK] Disk space sufficient"
fi

# Required Tools
for cmd in curl jq yq ssh-keygen qemu-img virt-install cloud-localds; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "[ERROR] Missing required tool: $cmd"
    MISSING=true
  fi
done

if [[ "$MISSING" = true ]]; then
  echo "[FAIL] One or more tools are missing. Please install them and retry."
  exit 1
fi

echo "[SUCCESS] Environment validation passed."
