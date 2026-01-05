#!/bin/bash

CHROOT_DIR="/opt/polaron-build/chroot"



mkdir -p "${CHROOT_DIR}/etc/systemd/system/tor@default.service.d"
cat > "${CHROOT_DIR}/etc/systemd/system/tor@default.service.d/volatile-logs.conf" << EOF
[Service]
LogsDirectory=tor
LogsDirectoryMode=0700
User=debian-tor
Group=debian-tor
EOF

rm -f "${CHROOT_DIR}/etc/systemd/system/tor.service.d/volatile-logs.conf"
rmdir "${CHROOT_DIR}/etc/systemd/system/tor.service.d" 2>/dev/null || true

