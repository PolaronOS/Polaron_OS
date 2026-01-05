#!/bin/bash

set -e


if [ -f /etc/default/apport ]; then
    sed -i 's/enabled=1/enabled=0/g' /etc/default/apport
else
    echo "enabled=0" > /etc/default/apport
fi
systemctl mask apport.service || true
systemctl mask apport-autoreport.service || true
systemctl mask apport-forward.socket || true

if dpkg -l | grep -q whoopsie; then
    systemctl disable whoopsie 2>/dev/null || true
    systemctl mask whoopsie 2>/dev/null || true
fi

if [ -f /etc/default/motd-news ]; then
    sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
fi
systemctl mask motd-news.timer || true
systemctl mask motd-news.service || true

cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

mkdir -p /usr/lib/NetworkManager/conf.d
cat > /usr/lib/NetworkManager/conf.d/20-connectivity-disable.conf <<EOF
[connectivity]
uri=
interval=0
EOF

if command -v ubuntu-report >/dev/null; then
    ubuntu-report -f send no || true
    chmod 000 $(which ubuntu-report) || true
fi

if dpkg -l | grep -q pollinate; then
    systemctl disable pollinate || true
    systemctl mask pollinate || true
fi

cat >> /etc/hosts <<EOF

127.0.0.1 metrics.ubuntu.com
127.0.0.1 popcon.ubuntu.com
127.0.0.1 daisy.ubuntu.com
127.0.0.1 errors.ubuntu.com
EOF

