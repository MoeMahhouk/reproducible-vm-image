# Image names
BUILDER_IMAGE = ubuntu-minimal-builder
EXTRACTOR_IMAGE = ubuntu-minimal-extractor
QCOW2_IMAGE = ubuntu-minimal.qcow2
QCOW2_CHECKSUM = ubuntu-minimal.qcow2.sha256
OUTPUT_DIR = $(shell pwd)/output
OVMF_PATH = /usr/share/ovmf/OVMF.fd

# Get the kernel and initrd paths
KERNEL_PATH := $(OUTPUT_DIR)/vmlinuz
INITRD_PATH := $(OUTPUT_DIR)/initrd.img

# Dockerfile names
BUILDER_DOCKERFILE = Dockerfile.builder
EXTRACTOR_DOCKERFILE = Dockerfile.extractor

# Whether to use --no-cache option or not
USE_CACHE ?= true

# Build the builder image
build-builder:
	docker build $(if $(filter $(USE_CACHE),true),,--no-cache) -f $(BUILDER_DOCKERFILE) -t $(BUILDER_IMAGE) .

# Build the extractor image
build-extractor: build-builder
	docker build $(if $(filter $(USE_CACHE),true),,--no-cache) --output=./output -f $(EXTRACTOR_DOCKERFILE) -t $(EXTRACTOR_IMAGE) .

# Calculate the SHA256 checksum of the qcow2 image
verify-image: build-extractor
	sha256sum $(OUTPUT_DIR)/$(QCOW2_IMAGE) > $(QCOW2_CHECKSUM)
	sha256sum -c $(QCOW2_CHECKSUM)

# Clean up generated files and Docker images
clean:
	rm -f $(QCOW2_CHECKSUM)
	rm -rf $(OUTPUT_DIR)/$(QCOW2_IMAGE)
	docker rmi $(EXTRACTOR_IMAGE) $(BUILDER_IMAGE)	

# Run the qcow2 image with QEMU
run-qemu: verify-image
	sudo qemu-system-x86_64 -hda $(OUTPUT_DIR)/$(QCOW2_IMAGE) -m 1024 -nographic -kernel $(KERNEL_PATH) -append "root=/dev/sda rw console=ttyS0" -initrd $(INITRD_PATH)

# Default target
all: verify-image run-qemu
