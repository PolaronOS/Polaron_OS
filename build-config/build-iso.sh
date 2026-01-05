#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""

if [ "$EUID" -ne 0 ]; then 
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
WORK_DIR="${PROJECT_DIR}/build"
CHROOT_DIR="${WORK_DIR}/chroot"
ISO_DIR="${WORK_DIR}/iso"
OUTPUT_DIR="${PROJECT_DIR}/output"
ISO_NAME="polaron-os-1.0-amd64.iso"

if [ ! -d "${CHROOT_DIR}" ]; then
    exit 1
fi

rm -rf "${ISO_DIR}"
mkdir -p "${ISO_DIR}"
mkdir -p "${OUTPUT_DIR}"


chroot "${CHROOT_DIR}" apt-get clean
chroot "${CHROOT_DIR}" rm -rf /tmp/* /var/tmp/* /var/cache/apt/*.deb

rm -f "${CHROOT_DIR}/etc/machine-id"
rm -f "${CHROOT_DIR}/var/lib/dbus/machine-id"


mount --bind /dev "${CHROOT_DIR}/dev" || true
mount --bind /dev/pts "${CHROOT_DIR}/dev/pts" || true
mount -t proc proc "${CHROOT_DIR}/proc" || true
mount -t sysfs sysfs "${CHROOT_DIR}/sys" || true

chroot "${CHROOT_DIR}" update-initramfs -u -k all

umount -lf "${CHROOT_DIR}/proc" || true
umount -lf "${CHROOT_DIR}/sys" || true
umount -lf "${CHROOT_DIR}/dev/pts" || true
umount -lf "${CHROOT_DIR}/dev" || true

chroot "${CHROOT_DIR}" dpkg-query -W --showformat='${Package} ${Version}\n' > "${ISO_DIR}/filesystem.manifest"

mkdir -p "${ISO_DIR}/casper"

rm -f "${ISO_DIR}/casper/filesystem.squashfs" # Ensure we delete the old one
mksquashfs "${CHROOT_DIR}" "${ISO_DIR}/casper/filesystem.squashfs" \
    -comp xz \
    -e boot \
    -noappend

printf $(du -sx --block-size=1 "${CHROOT_DIR}" | cut -f1) > "${ISO_DIR}/casper/filesystem.size"

cp "${CHROOT_DIR}"/boot/vmlinuz-* "${ISO_DIR}/casper/vmlinuz"
cp "${CHROOT_DIR}"/boot/initrd.img-* "${ISO_DIR}/casper/initrd"

mkdir -p "${ISO_DIR}/boot/grub"

cat > "${ISO_DIR}/boot/grub/grub.cfg" << 'EOF'
set default="0"
set timeout=10

menuentry "Polaron OS - Live Session" {
    linux /casper/vmlinuz boot=casper quiet splash ipv6.disable=1 ---
    initrd /casper/initrd
}

menuentry "Polaron OS - Live Session (Safe Graphics)" {
    linux /casper/vmlinuz boot=casper nomodeset quiet splash ipv6.disable=1 ---
    initrd /casper/initrd
}

menuentry "Polaron OS - Live Session (Debug Mode)" {
    linux /casper/vmlinuz boot=casper debug ---
    initrd /casper/initrd
}

menuentry "Check Disk for Defects" {
    linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
    initrd /casper/initrd
}

menuentry "Boot from First Hard Disk" {
    set root=(hd0)
    chainloader +1
}
EOF


cat > "${ISO_DIR}/README.diskdefines" << EOF
EOF


grub-mkrescue \
    --output="${OUTPUT_DIR}/${ISO_NAME}" \
    "${ISO_DIR}" \
    2>&1 | grep -v "warning" || true


cd "${OUTPUT_DIR}"
sha256sum "${ISO_NAME}" > "${ISO_NAME}.sha256"
md5sum "${ISO_NAME}" > "${ISO_NAME}.md5"

ISO_SIZE=$(du -h "${OUTPUT_DIR}/${ISO_NAME}" | cut -f1)

echo ""
echo ""
echo -e "${YELLOW}[OUTPUT]${NC}"
echo "  ISO File: ${OUTPUT_DIR}/${ISO_NAME}"
echo "  Size: ${ISO_SIZE}"
echo "  SHA256: ${OUTPUT_DIR}/${ISO_NAME}.sha256"
echo "  MD5: ${OUTPUT_DIR}/${ISO_NAME}.md5"
echo ""
echo -e "${YELLOW}[TESTING]${NC}"
echo "  Test in VM: qemu-system-x86_64 -m 4G -cdrom ${OUTPUT_DIR}/${ISO_NAME}"
echo "  Or use VirtualBox/VMware"
echo ""
echo -e "${YELLOW}[INSTALLATION]${NC}"
echo "  Write to USB: sudo dd if=${OUTPUT_DIR}/${ISO_NAME} of=/dev/sdX bs=4M status=progress"
echo "  (Replace /dev/sdX with your USB device)"
echo ""
