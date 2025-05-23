#!/bin/bash

set -e
KEY_PATH="$HOME/.ssh/id_ed25519.pub"

if [[ ! -f "$KEY_PATH" ]]; then
  echo "[ERROR] No SSH key found at $KEY_PATH. Run gen_ssh_key.sh first."
  exit 1
fi

SSH_KEY=$(cat "$KEY_PATH")

for FILE in deployment-scripts/vm-setup/controller-cloudinit.yaml deployment-scripts/vm-setup/worker-cloudinit.yaml; do
  echo "[INFO] Injecting SSH key into $FILE"
  yq eval ".users[0].ssh_authorized_keys = [\"$SSH_KEY\"]" -i "$FILE"
done

echo "[SUCCESS] SSH keys injected into cloud-init configs."
