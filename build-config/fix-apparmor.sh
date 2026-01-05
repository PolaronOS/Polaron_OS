#!/bin/bash

CHROOT_DIR="/opt/polaron-build/chroot"


PROFILE="${CHROOT_DIR}/etc/apparmor.d/system_tor"

if [ -f "${PROFILE}" ]; then
    
    if ! grep -q "/usr/share/tor/\*\* r," "${PROFILE}"; then
        sed -i '/}/i \  /usr/share/tor/** r,' "${PROFILE}"
    else
    fi
else
    echo "[WARNING] AppArmor profile not found at ${PROFILE}. Creating a local override..."
    mkdir -p "${CHROOT_DIR}/etc/apparmor.d/local"
    echo "/usr/share/tor/** r," >> "${CHROOT_DIR}/etc/apparmor.d/local/system_tor"
fi


