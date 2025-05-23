# Makefile for KVM + Kubernetes deployment project

.PHONY: all key inject validate deploy headless run clean

all: run

key:
	@echo "🔐 Generating SSH key..."
	bash scripts/gen_ssh_key.sh

inject:
	@echo "🛠️ Injecting SSH key into cloud-init configs..."
	bash scripts/inject_ssh_key.sh

validate:
	@echo "🔍 Validating environment..."
	bash scripts/validate_environment.sh

deploy:
	@echo "🚀 Starting interactive deployment..."
	bash scripts/deploy.sh --debug

headless:
	@echo "🤖 Starting headless deployment..."
	bash scripts/deploy.sh --headless --debug

run:
	@echo "🏁 Running full setup workflow..."
	bash scripts/run_all.sh --debug

clean:
	@echo "🧹 Cleaning up generated VMs and images..."
	sudo virsh destroy k8s-controller || true
	sudo virsh destroy k8s-worker || true
	sudo virsh undefine k8s-controller --remove-all-storage || true
	sudo virsh undefine k8s-worker --remove-all-storage || true
	sudo rm -f /var/lib/libvirt/images/k8s-*.qcow2 /var/lib/libvirt/images/k8s-*-seed.iso

