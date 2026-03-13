#!/bin/bash

# This script modifies an RHCOS LiveISO to add userdata support in QEMU
# environments, add additional files, and create a QCOW2 image for use by a VM.

workdir="$(mktemp -d)"
echo "${workdir}"

libvirt_dir="/home/libvirt-ocp"
mbr_template="${workdir}/isohdpfx.bin"
orig_iso="${libvirt_dir}/rhcos-4.17.0-x86_64-live.x86_64.iso"
new_files="${workdir}/rhcos"
new_iso="${workdir}/rhcos-4.17.0-x86_64-live-qemu.x86_64.iso"
qcow2_img="${workdir}/rhcos-4.17.0-x86_64-qemu-live.x86_64.qcow2"
vm_disk="${libvirt_dir}/rhcos-ostree-1.qcow2"

# Extract RHCOS ISO image to tmp directory
xorriso -osirrox on -indev "${orig_iso}" -extract / "${new_files}"

# Replace ignition.platform.id from metal to qemu to use the userdata
sed -i 's/ignition.platform.id=metal/ignition.platform.id=qemu console=tty0 console=ttyS0,115200n8/' "${new_files}/isolinux/isolinux.cfg"

# Extract MBR template file to disk
dd if="$orig_iso" bs=1 count=432 of="${mbr_template}"

# Create the new ISO image
xorriso -as mkisofs \
   -r -V 'rhcos-417.94.202408270355-0' \
   -o "${new_iso}" \
   -J -J -joliet-long -cache-inodes \
   -isohybrid-mbr "${mbr_template}" \
   -b isolinux/isolinux.bin \
   -c isolinux/boot.cat \
   -boot-load-size 4 -boot-info-table -no-emul-boot \
   -eltorito-alt-boot \
   -e images/efiboot.img \
   -no-emul-boot -isohybrid-gpt-basdat \
   "$new_files"

echo "========"

# Used to compare boot data with the orig_iso
# xorriso -indev "$new_iso" -report_system_area plain

# Convert iso image to qcow2
qemu-img convert -O qcow2 "${new_iso}" "${qcow2_img}"
# Replace the VM disk with the new image
cp "${qcow2_img}" "${vm_disk}"
# Increase the size for the installation
qemu-img resize "${vm_disk}" +120G

