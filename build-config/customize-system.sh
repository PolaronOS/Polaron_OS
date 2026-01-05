#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CHROOT_DIR="/opt/polaron-build/chroot"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""

if [ "$EUID" -ne 0 ]; then 
    exit 1
fi

if [ ! -d "${CHROOT_DIR}" ]; then
    exit 1
fi

mkdir -p "${CHROOT_DIR}/opt/polaron-config"
cp -r "${PROJECT_ROOT}/security-config" "${CHROOT_DIR}/opt/polaron-config/"
cp -r "${PROJECT_ROOT}/privacy-tools" "${CHROOT_DIR}/opt/polaron-config/"
cp -r "${PROJECT_ROOT}/system-packages" "${CHROOT_DIR}/opt/polaron-config/"

cat > "${CHROOT_DIR}/opt/customize-inside-chroot.sh" << 'CHROOT_SCRIPT'
#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


echo "polaron-os" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
127.0.1.1   polaron-os

::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

apt-get upgrade -y -qq

apt-get install -y -qq \
    linux-generic \
    systemd \
    ubuntu-minimal \
    ubuntu-standard \
    casper \
    os-prober

apt-get install -y -qq \
    xfce4 \
    xfce4-goodies \
    lightdm \
    lightdm-gtk-greeter \
    lightdm-gtk-greeter-settings

apt-get install -y -qq \
    network-manager \
    network-manager-gnome

apt-get install -y -qq \
    ufw \
    nftables \
    fail2ban \
    apparmor \
    apparmor-utils \
    apparmor-profiles \
    apparmor-profiles-extra \
    firejail \
    lynis \
    rkhunter

apt-get install -y -qq \
    tor \
    tor-geoipdb \
    torbrowser-launcher \
    obfs4proxy \
    nyx

apt-get install -y -qq \
    macchanger \
    mat2 \
    bleachbit \
    secure-delete

apt-get install -y -qq dnscrypt-proxy

apt-get install -y -qq \
    openvpn \
    wireguard \
    network-manager-openvpn \
    network-manager-openvpn-gnome

apt-get install -y -qq \
    cryptsetup \
    cryptsetup-bin \
    gnupg \
    gnupg2 \
    keepassxc

apt-get install -y -qq firefox

apt-get install -y -qq \
    thunar \
    thunar-archive-plugin \
    thunar-media-tags-plugin \
    xfce4-terminal \
    mousepad \
    evince \
    gpicview

apt-get install -y -qq \
    p7zip-full \
    unrar \
    zip \
    unzip

apt-get install -y -qq \
    vim \
    nano \
    git \
    wget \
    curl \
    htop \
    neofetch \
    inxi

apt-get install -y -qq \
    fonts-liberation \
    fonts-dejavu \
    fonts-noto

apt-get purge -y -qq \
    ubuntu-report \
    popularity-contest \
    apport \
    whoopsie \
    snapd \
    || true  # Don't fail if packages don't exist

apt-get autoremove -y -qq
apt-get autoclean -y -qq

useradd -m -s /bin/bash -G sudo,adm,cdrom,plugdev,netdev polaron || true
echo "polaron:polaron" | chpasswd
echo "polaron ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/polaron
chmod 440 /etc/sudoers.d/polaron

cat > /etc/lightdm/lightdm.conf << EOF
[Seat:*]
autologin-user=polaron
autologin-user-timeout=0
user-session=xfce
EOF

ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw logging on

systemctl enable apparmor

systemctl enable tor

apt-get install -y -qq unattended-upgrades
cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}";
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

echo "APT::Periodic::Update-Package-Lists \"1\";" > /etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::Unattended-Upgrade \"1\";" >> /etc/apt/apt.conf.d/20auto-upgrades

cat > /etc/os-release << EOF
NAME="Polaron OS"
VERSION="1.0 (Dark North)"
ID=polaron
ID_LIKE=ubuntu
PRETTY_NAME="Polaron OS 1.0"
VERSION_ID="1.0"
UBUNTU_CODENAME=noble
EOF

cat > /etc/lsb-release << EOF
DISTRIB_ID=PolaronOS
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=noble
DISTRIB_DESCRIPTION="Polaron OS 1.0"
EOF

systemctl disable bluetooth.service || true
systemctl disable cups.service || true
systemctl disable avahi-daemon.service || true

apt-get clean


CHROOT_SCRIPT

chmod +x "${CHROOT_DIR}/opt/customize-inside-chroot.sh"

chroot "${CHROOT_DIR}" /opt/customize-inside-chroot.sh

echo ""
echo ""
echo ""
