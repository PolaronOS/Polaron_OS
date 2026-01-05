#!/bin/bash

CHROOT_DIR="/opt/polaron-build/chroot"


mkdir -p "${CHROOT_DIR}/etc/apparmor.d/disable"

if [ -f "${CHROOT_DIR}/etc/apparmor.d/system_tor" ]; then
    ln -sf /etc/apparmor.d/system_tor "${CHROOT_DIR}/etc/apparmor.d/disable/system_tor"
    
    ls -l "${CHROOT_DIR}/etc/apparmor.d/disable/system_tor"
else
    echo "[WARNING] Tor AppArmor profile not found in expected location. Configuring generic disable just in case."
    ln -sf /etc/apparmor.d/system_tor "${CHROOT_DIR}/etc/apparmor.d/disable/system_tor"
fi

mkdir -p "${CHROOT_DIR}/var/lib/tor"
chown -R 113:113 "${CHROOT_DIR}/var/lib/tor" # UID 113 IS DEBIAN
chmod 700 "${CHROOT_DIR}/var/lib/tor"

