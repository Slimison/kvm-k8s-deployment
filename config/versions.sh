#!/bin/bash

# Requires: curl, jq
set -e

echo "[INFO] Fetching latest Kubernetes versions..."

# Fetch the latest 3 stable versions
curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | sed 's/^/Fetching for: /'

VERSIONS=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases \
  | jq -r '.[].tag_name' \
  | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
  | sort -Vr \
  | uniq \
  | head -n 3)

echo "[INFO] Latest 3 Kubernetes versions:"
echo "$VERSIONS"
