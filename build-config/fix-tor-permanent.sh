#!/bin/bash

CHROOT_DIR="/opt/polaron-build/chroot"
TORRC_SOURCE="$(dirname "$0")/../privacy-tools/torrc-clean"


mkdir -p "${CHROOT_DIR}/usr/share/tor"
cat "${TORRC_SOURCE}" > "${CHROOT_DIR}/usr/share/tor/torrc"
chmod 644 "${CHROOT_DIR}/usr/share/tor/torrc"

mkdir -p "${CHROOT_DIR}/etc/systemd/system/tor@default.service.d"
cat > "${CHROOT_DIR}/etc/systemd/system/tor@default.service.d/override.conf" << 'EOF'
[Service]
ExecStart=
ExecStartPre=
ExecStartPre=/usr/bin/install -Z -m 02755 -o debian-tor -g debian-tor -d /run/tor
ExecStartPre=/usr/bin/tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc -f /usr/share/tor/torrc --RunAsDaemon 0 --verify-config
ExecStart=/usr/bin/tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc -f /usr/share/tor/torrc --RunAsDaemon 0
LogsDirectory=tor
LogsDirectoryMode=0700
EOF

ln -sf /lib/systemd/system/tor@default.service "${CHROOT_DIR}/etc/systemd/system/multi-user.target.wants/tor@default.service"

