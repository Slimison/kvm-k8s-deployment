#!/bin/bash

set -e

# Load common functions
source deployment-scripts/utils/common.sh

# Flags
HEADLESS=false
DEBUG=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --headless)
      HEADLESS=true
      shift
      ;;
    --debug)
      DEBUG=true
      set -x
      shift
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

log_info "Starting Kubernetes KVM deployment..."

# Clone GitHub repo
log_info "Authenticating and cloning configuration repo..."
read -p "Enter your GitHub username: " GH_USER
read -p "Enter repo URL (or press Enter for default): " GH_REPO
GH_REPO=${GH_REPO:-"https://github.com/$GH_USER/kvm-k8s-deployment.git"}

git clone "$GH_REPO" /tmp/kvm-k8s-deployment
cd /tmp/kvm-k8s-deployment || exit 1

# Install KVM
log_info "Installing KVM and dependencies..."
bash deployment-scripts/kvm-install/install_kvm.sh

# Create VMs
log_info "Creating virtual machines..."
bash deployment-scripts/vm-setup/create_vms.sh "$HEADLESS"

# Install Kubernetes with kubeadm
log_info "Setting up Kubernetes with kubeadm..."
bash deployment-scripts/kubernetes-setup/install_kubeadm.sh "$HEADLESS"

log_success "Deployment complete!"
