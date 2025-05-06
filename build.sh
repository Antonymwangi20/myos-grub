#!/bin/bash
set -e

# Create required directories
mkdir -p iso/boot/grub

# Build kernel
nasm -f elf64 src/boot.S -o src/boot.o
gcc -c src/kernel.c -o src/kernel.o -ffreestanding -nostdlib -mno-red-zone -fno-exceptions
ld -nostdlib -T linker.ld src/boot.o src/kernel.o -o iso/boot/kernel.elf

# Add these compiler flags:
CFLAGS="-ffreestanding -nostdlib -fno-stack-protector -mno-red-zone -fno-pie -mcmodel=kernel"

# Add these linker flags:
LDFLAGS="-nostdlib -z noexecstack -T linker.ld"

# Copy GRUB configuration
cp boot/grub/grub.cfg iso/boot/grub/

# Create GRUB image
grub-mkrescue -o myos.iso iso

echo "ISO built: myos.iso"
