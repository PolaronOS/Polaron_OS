#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NFTABLES_CONF="${SCRIPT_DIR}/nftables.conf"
TOR_ISOLATION_CONF="${SCRIPT_DIR}/../privacy-tools/tor-stream-isolation.conf"


cp "${NFTABLES_CONF}" "${CHROOT_DIR}/etc/nftables.conf"

chroot "${CHROOT_DIR}" systemctl enable nftables

chroot "${CHROOT_DIR}" systemctl disable polaron-tor-routing.service || true
rm -f "${CHROOT_DIR}/etc/systemd/system/polaron-tor-routing.service" || true

mkdir -p "${CHROOT_DIR}/etc/systemd/system/nftables.service.d"
cat > "${CHROOT_DIR}/etc/systemd/system/nftables.service.d/override.conf" << EOF
[Unit]
Before=network-pre.target
Wants=network-pre.target
DefaultDependencies=no
EOF


if [ -f "${CHROOT_DIR}/etc/tor/torrc" ]; then
    cat "${TOR_ISOLATION_CONF}" >> "${CHROOT_DIR}/etc/tor/torrc"
else
    echo "[WARNING] torrc not found, creating new one with isolation config"
    cp "${TOR_ISOLATION_CONF}" "${CHROOT_DIR}/etc/tor/torrc"
fi

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 /' "${CHROOT_DIR}/etc/default/grub"

cat > "${CHROOT_DIR}/etc/sysctl.d/99-disable-ipv6.conf" << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

mkdir -p "${CHROOT_DIR}/etc/NetworkManager/conf.d"
cat > "${CHROOT_DIR}/etc/NetworkManager/conf.d/20-no-connectivity-check.conf" << EOF
[connectivity]
enabled=false
uri=
interval=0
EOF

