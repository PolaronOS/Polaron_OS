#!/bin/bash

set -e  # Exit on error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""

if [ "$EUID" -ne 0 ]; then 
    exit 1
fi


UBUNTU_VERSION="24.04"
UBUNTU_CODENAME="noble"
UBUNTU_ISO_URL="https://releases.ubuntu.com/${UBUNTU_VERSION}/ubuntu-${UBUNTU_VERSION}-desktop-amd64.iso"
WORK_DIR="/opt/polaron-build"
CHROOT_DIR="${WORK_DIR}/chroot"
ISO_DIR="${WORK_DIR}/iso"
OUTPUT_DIR="${WORK_DIR}/output"

echo "    Ubuntu Version: ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"
echo "    Working Directory: ${WORK_DIR}"
echo ""

apt-get update -qq
apt-get install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    isolinux \
    syslinux-utils \
    wget \
    curl \
    rsync \
    git \
    > /dev/null


mkdir -p "${WORK_DIR}"
mkdir -p "${CHROOT_DIR}"
mkdir -p "${ISO_DIR}"
mkdir -p "${OUTPUT_DIR}"


if [ ! -d "${CHROOT_DIR}/bin" ]; then
    debootstrap --arch=amd64 --variant=minbase ${UBUNTU_CODENAME} "${CHROOT_DIR}" http://archive.ubuntu.com/ubuntu/
else
    echo -e "${YELLOW}[SKIP]${NC} Base system already exists"
fi

cp /etc/resolv.conf "${CHROOT_DIR}/etc/resolv.conf"

cat > "${CHROOT_DIR}/etc/apt/sources.list" << EOF
deb http://archive.ubuntu.com/ubuntu ${UBUNTU_CODENAME} main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu ${UBUNTU_CODENAME}-security main restricted universe multiverse
EOF

mount --bind /dev "${CHROOT_DIR}/dev"
mount --bind /dev/pts "${CHROOT_DIR}/dev/pts"
mount -t proc proc "${CHROOT_DIR}/proc"
mount -t sysfs sysfs "${CHROOT_DIR}/sys"
mount -t tmpfs tmpfs "${CHROOT_DIR}/tmp"

cat > "${WORK_DIR}/enter-chroot.sh" << 'EOF'
#!/bin/bash
CHROOT_DIR="/opt/polaron-build/chroot"
chroot "${CHROOT_DIR}" /bin/bash
EOF
chmod +x "${WORK_DIR}/enter-chroot.sh"

echo ""
echo ""
echo -e "${YELLOW}[NEXT STEPS]${NC}"
echo "  1. Run: sudo ./customize-system.sh"
echo "  2. Then: sudo ./build-iso.sh"
echo ""
echo -e "${YELLOW}[UTILITIES]${NC}"
echo "  Enter chroot: sudo ${WORK_DIR}/enter-chroot.sh"
echo "  Clean build: sudo rm -rf ${WORK_DIR}"
echo ""
