#!/bin/bash

CHROOT_DIR="/opt/polaron-build/chroot"


cat > "${CHROOT_DIR}/etc/NetworkManager/conf.d/10-globally-managed-devices.conf" << 'EOF'
[keyfile]
unmanaged-devices=none
EOF

rm -f "${CHROOT_DIR}/etc/NetworkManager/conf.d/10-globally-managed-devices-link.conf" 2>/dev/null
rm -f "${CHROOT_DIR}/usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf" 2>/dev/null

mkdir -p "${CHROOT_DIR}/etc/NetworkManager/system-connections"
cat > "${CHROOT_DIR}/etc/NetworkManager/system-connections/Wired-Auto.nmconnection" << 'EOF'
[connection]
id=Wired Auto
uuid=a1b2c3d4-e5f6-7890-abcd-ef1234567890
type=ethernet
autoconnect=true
autoconnect-priority=100

[ethernet]

[ipv4]
method=auto

[ipv6]
method=auto
addr-gen-mode=stable-privacy

[proxy]
EOF

chmod 600 "${CHROOT_DIR}/etc/NetworkManager/system-connections/Wired-Auto.nmconnection"

ln -sf /lib/systemd/system/NetworkManager.service "${CHROOT_DIR}/etc/systemd/system/multi-user.target.wants/NetworkManager.service" 2>/dev/null || true

mkdir -p "${CHROOT_DIR}/etc/cloud/cloud.cfg.d"
echo "network: {config: disabled}" > "${CHROOT_DIR}/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"

rm -f "${CHROOT_DIR}/etc/netplan/"*.yaml 2>/dev/null

