#!/bin/bash

set -e


PACKAGES_TO_PURGE=(
    "python3-apport"
    "apport-symptoms"
    "libsnapd-glib-2-1" 
    "update-manager-core"
    "ubuntu-report"
    "popularity-contest"
    "whoopsie"
)

export DEBIAN_FRONTEND=noninteractive
for pkg in "${PACKAGES_TO_PURGE[@]}"; do
    if dpkg -l | grep -q "$pkg"; then
    else
    fi
done

cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

if [ -f /etc/update-manager/release-upgrades ]; then
    sed -i 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades
fi

mkdir -p /usr/lib/NetworkManager/conf.d
cat > /usr/lib/NetworkManager/conf.d/20-connectivity-disable.conf <<EOF
[connectivity]
uri=
interval=0
EOF

systemctl disable systemd-timesyncd || true
systemctl mask systemd-timesyncd || true

apt-get autoremove -y
apt-get clean

