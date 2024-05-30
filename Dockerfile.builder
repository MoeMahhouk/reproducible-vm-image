# Use a specific version of the Ubuntu image
FROM ubuntu:noble AS builder

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary tools with specific versions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    debootstrap=1.0.134ubuntu1 \
    e2fsprogs=1.47.0-2.4~exp1ubuntu4 \
    xz-utils=5.6.1+really5.4.5-1 \
    qemu-utils=1:8.2.2+ds-0ubuntu1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the minimal Ubuntu system using debootstrap with a specific suite
RUN mkdir /ubuntu-minimal && \
    debootstrap --variant=minbase noble /ubuntu-minimal http://archive.ubuntu.com/ubuntu/

# Configure the minimal system
RUN chroot /ubuntu-minimal /bin/bash -c "\
    echo 'ubuntu-minimal' > /etc/hostname && \
    echo '127.0.0.1 localhost' > /etc/hosts && \
    apt-get update && \
    apt-get install -y --no-install-recommends linux-image-generic=6.8.0-31.31 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*"

# Copy binaries from the host to the /bin directory in the minimal system
COPY binaries/* /ubuntu-minimal/bin/

# Create a tarball of the minimal system
RUN tar --mtime='1970-01-01' --sort=name --owner=root:0 --group=root:0 --numeric-owner -C /ubuntu-minimal -cf /ubuntu-minimal.tar .

# Create a raw disk image and format it
RUN dd if=/dev/zero of=/ubuntu-minimal.raw bs=1M count=1024 && \
    mkfs.ext4 /ubuntu-minimal.raw

# Convert the raw disk image to qcow2 format
RUN qemu-img convert -f raw /ubuntu-minimal.raw -O qcow2 /ubuntu-minimal.qcow2