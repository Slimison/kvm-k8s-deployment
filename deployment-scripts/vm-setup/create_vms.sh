#!/bin/bash

set -e
source "$(dirname "$0")/../utils/common.sh"

HEADLESS=$1

IMG_PATH="/var/lib/libvirt/images"
UBUNTU_CLOUD_IMAGE="jammy-server-cloudimg-amd64.img"
UBUNTU_IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/$UBUNTU_CLOUD_IMAGE"
CLOUD_IMG_LOCAL="$IMG_PATH/$UBUNTU_CLOUD_IMAGE"

# Check yq installed
if ! command -v yq &> /dev/null; then
  log_error "'yq' is required. Install it with: sudo snap install yq"
fi

if [[ "$HEADLESS" == "true" ]]; then
  log_info "Using headless mode with default values..."
  CPU=$(yq '.vm.cpu' config/default-values.yaml)
  RAM=$(yq '.vm.ram' config/default-values.yaml)
  DISK=$(yq '.vm.disk' config/default-values.yaml)
else
  CPU=2
  RAM=4096
  DISK=20
  read -p "CPU cores per VM [default 2]: " USER_CPU
  read -p "RAM per VM in MB [default 4096]: " USER_RAM
  read -p "Disk size per VM in GB [default 20]: " USER_DISK
  CPU=${USER_CPU:-$CPU}
  RAM=${USER_RAM:-$RAM}
  DISK=${USER_DISK:-$DISK}
fi

# Ensure base image
log_info "Ensuring Ubuntu cloud image is available..."
[[ -f "$CLOUD_IMG_LOCAL" ]] || wget -O "$CLOUD_IMG_LOCAL" "$UBUNTU_IMAGE_URL"

# Common VM creation function
create_vm() {
  local name=$1
  local cloudinit=$2
  local disk_img="$IMG_PATH/$name.qcow2"
  local seed_img="$IMG_PATH/${name}-seed.iso"

  sudo qemu-img create -f qcow2 -b "$CLOUD_IMG_LOCAL" -F qcow2 "$disk_img" "${DISK}G"
  sudo cloud-localds --ssh-key-type ed25519 "$seed_img" "deployment-scripts/vm-setup/${cloudinit}"

  sudo virt-install \
    --name "$name" \
    --ram "$RAM" \
    --vcpus "$CPU" \
    --os-variant ubuntu22.04 \
    --virt-type kvm \
    --disk path="$disk_img",format=qcow2 \
    --disk path="$seed_img",device=cdrom \
    --graphics none \
    --network network=default \
    --noautoconsole \
    --import
}

create_vm "k8s-controller" "controller-cloudinit.yaml"
create_vm "k8s-worker" "worker-cloudinit.yaml"

log_success "Both VMs created successfully."
