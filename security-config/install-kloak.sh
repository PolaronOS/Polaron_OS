#!/bin/bash

set -e

CHROOT_DIR="$(dirname "$0")/../../build/chroot"
KLOAK_REPO="https://github.com/vmonaco/kloak.git"

chroot "$CHROOT_DIR" apt-get update
chroot "$CHROOT_DIR" apt-get install -y build-essential git pkg-config libevdev-dev libcanberra-dev libx11-dev libxtst-dev libxi-dev

rm -rf "$CHROOT_DIR/tmp/kloak"
chroot "$CHROOT_DIR" git clone "$KLOAK_REPO" /tmp/kloak

chroot "$CHROOT_DIR" bash -c "cd /tmp/kloak && make"

cp "$CHROOT_DIR/tmp/kloak/kloak" "$CHROOT_DIR/usr/local/sbin/"
chmod +x "$CHROOT_DIR/usr/local/sbin/kloak"

cat > "$CHROOT_DIR/etc/systemd/system/kloak.service" << EOF
[Unit]
Description=kloak - Keystroke Obfuscation
Documentation=https://github.com/vmonaco/kloak
After=syslog.target unit-random-identity.service
Wants=syslog.target

[Service]
ExecStart=/usr/local/sbin/kloak -r /dev/urandom -d 100
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

chroot "$CHROOT_DIR" systemctl enable kloak

rm -rf "$CHROOT_DIR/tmp/kloak"

