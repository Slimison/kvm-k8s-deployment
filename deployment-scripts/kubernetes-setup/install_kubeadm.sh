#!/bin/bash

set -e
source "$(dirname "$0")/../utils/common.sh"

HEADLESS=$1

# Check yq installed
if ! command -v yq &> /dev/null; then
  log_error "'yq' is required. Install it with: sudo snap install yq"
fi

log_info "Waiting for VMs to boot..."
sleep 30

CONTROLLER_IP=$(virsh domifaddr k8s-controller | grep -oP '(\d+\.){3}\d+' | head -n 1)
WORKER_IP=$(virsh domifaddr k8s-worker | grep -oP '(\d+\.){3}\d+' | head -n 1)

log_info "Controller IP: $CONTROLLER_IP"
log_info "Worker IP: $WORKER_IP"

SSH_OPTS="-o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519"
VERSION=""

if [[ "$HEADLESS" == "true" ]]; then
  VERSION=$(yq '.kubernetes.version' config/default-values.yaml)
else
  echo "Available Kubernetes versions:"
  curl -s https://dl.k8s.io/release/stable.txt | sed -e 's/$/-0/' | xargs -I {} curl -s https://dl.k8s.io/release/{}/release-notes.json | jq -r '.name' | head -n 3
  read -p "Enter version to install (e.g., 1.29.0): " VERSION
fi

log_info "Initializing Kubernetes on controller with kubeadm..."
ssh $SSH_OPTS ubuntu@$CONTROLLER_IP "sudo kubeadm init --kubernetes-version=$VERSION --pod-network-cidr=10.244.0.0/16" | tee /tmp/kube-init.log

JOIN_CMD=$(grep -A2 "kubeadm join" /tmp/kube-init.log | grep "kubeadm join")

log_info "Joining worker node to the cluster..."
ssh $SSH_OPTS ubuntu@$WORKER_IP "sudo $JOIN_CMD"

log_success "Kubernetes cluster setup complete."
