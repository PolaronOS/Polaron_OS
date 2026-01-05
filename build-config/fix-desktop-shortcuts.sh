#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"


cat > "${CHROOT_DIR}/usr/local/bin/ensure-desktop-icons" << 'EOF'
#!/bin/bash
sleep 5

mkdir -p "$HOME/Desktop"

if [ ! -f "$HOME/Desktop/tor-browser.desktop" ]; then
    if [ -f "/usr/share/applications/tor-browser.desktop" ]; then
        cp "/usr/share/applications/tor-browser.desktop" "$HOME/Desktop/"
        chmod +x "$HOME/Desktop/tor-browser.desktop"
        
        gio set "$HOME/Desktop/tor-browser.desktop" metadata::trusted true || true
    fi
fi
EOF
chmod +x "${CHROOT_DIR}/usr/local/bin/ensure-desktop-icons"

mkdir -p "${CHROOT_DIR}/etc/xdg/autostart"
cat > "${CHROOT_DIR}/etc/xdg/autostart/polaron-desktop-icons.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Ensure Desktop Icons
Exec=/usr/local/bin/ensure-desktop-icons
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF

