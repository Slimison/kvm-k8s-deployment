#!/bin/bash

KEY_PATH="$HOME/.ssh/id_ed25519"

# Check if key already exists
if [[ -f "$KEY_PATH" ]]; then
  echo "[INFO] SSH key already exists at $KEY_PATH"
else
  echo "[INFO] Generating new ED25519 SSH key..."
  ssh-keygen -t ed25519 -C "kvm-k8s" -f "$KEY_PATH" -N ""
fi

echo "[SUCCESS] Public key:"
echo "--------------------------------------"
cat "$KEY_PATH.pub"
echo "--------------------------------------"
