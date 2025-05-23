#!/bin/bash

set -e
source "$(dirname "$0")/../utils/common.sh"

log_info "Checking for virtualization support..."

if ! grep -E --color 'vmx|svm' /proc/cpuinfo > /dev/null; then
  log_error "Virtualization is not supported on this system (missing vmx or svm flags)."
fi

log_success "CPU virtualization supported."

log_info "Updating package index..."
sudo apt-get update -y

log_info "Installing KVM and dependencies..."
sudo apt-get install -y \
  qemu-kvm \
  libvirt-daemon-system \
  libvirt-clients \
  bridge-utils \
  virtinst \
  libvirt-daemon \
  virt-manager \
  cloud-image-utils \
  genisoimage

log_info "Enabling and starting libvirtd..."
sudo systemctl enable --now libvirtd

log_info "Adding user '$USER' to libvirt and kvm groups..."
sudo usermod -aG libvirt "$USER"
sudo usermod -aG kvm "$USER"

log_success "KVM installation and configuration complete. You may need to reboot for group changes to take effect."
