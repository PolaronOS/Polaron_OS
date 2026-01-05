#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"
TB_VERSION="15.0.3"
TB_FILENAME="tor-browser-linux-x86_64-${TB_VERSION}.tar.xz"
DOWNLOAD_URL="https://www.torproject.org/dist/torbrowser/${TB_VERSION}/${TB_FILENAME}"
WORK_DIR="/opt/polaron-build"
CACHE_DIR="${WORK_DIR}/cache"


mkdir -p "${CACHE_DIR}"
if [ ! -f "${CACHE_DIR}/${TB_FILENAME}" ]; then
    wget -O "${CACHE_DIR}/${TB_FILENAME}" "${DOWNLOAD_URL}"
else
fi


mkdir -p "${CHROOT_DIR}/opt"

tar -xJf "${CACHE_DIR}/${TB_FILENAME}" -C "${CHROOT_DIR}/opt"

if [ -d "${CHROOT_DIR}/opt/tor-browser" ]; then
else
    ls -l "${CHROOT_DIR}/opt"
fi

mkdir -p "${CHROOT_DIR}/usr/share/applications"

cat > "${CHROOT_DIR}/usr/share/applications/tor-browser.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Tor Browser
GenericName=Web Browser
Comment=Privacy-focused web browser
Exec=/opt/tor-browser/start-tor-browser.desktop --detach
Icon=/opt/tor-browser/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;
EOF

chmod -R 777 "${CHROOT_DIR}/opt/tor-browser"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${SCRIPT_DIR}/polaron-tor-launcher.sh" ]; then
    install -m 755 "${SCRIPT_DIR}/polaron-tor-launcher.sh" "${CHROOT_DIR}/usr/local/bin/polaron-tor"
else
    exit 1
fi

sed -i 's|Exec=.*|Exec=/usr/local/bin/polaron-tor|' "${CHROOT_DIR}/usr/share/applications/tor-browser.desktop"

if [ -f "${CHROOT_DIR}/opt/tor-browser/browser/chrome/icons/default/default128.png" ]; then
    cp "${CHROOT_DIR}/opt/tor-browser/browser/chrome/icons/default/default128.png" "${CHROOT_DIR}/usr/share/pixmaps/tor-browser.png"
    sed -i 's|Icon=.*|Icon=tor-browser|' "${CHROOT_DIR}/usr/share/applications/tor-browser.desktop"
fi

mkdir -p "${CHROOT_DIR}/etc/skel/Desktop/"
cp "${CHROOT_DIR}/usr/share/applications/tor-browser.desktop" "${CHROOT_DIR}/etc/skel/Desktop/"
chmod +x "${CHROOT_DIR}/etc/skel/Desktop/tor-browser.desktop"

chroot "${CHROOT_DIR}" chown -R debian-tor:debian-tor /var/lib/tor || true
chroot "${CHROOT_DIR}" chmod 700 /var/lib/tor || true

