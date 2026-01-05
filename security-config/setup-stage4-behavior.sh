#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"



chroot "${CHROOT_DIR}" apt-get install -y build-essential libev-dev git libsodium-dev

cat > "${CHROOT_DIR}/tmp/build_kloak.sh" << 'EOF'
#!/bin/bash
cd /tmp
git clone https://github.com/vmonaco/kloak.git
cd kloak
make
make install
if [ -f "kloak.service" ]; then
    cp kloak.service /etc/systemd/system/
else
    cat > /etc/systemd/system/kloak.service << SERVICE
[Unit]
Description=Keystroke Anonymization Tool
After=syslog.target

[Service]
ExecStart=/usr/local/sbin/kloak -r /dev/input/event* -d 100
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE
fi
EOF

chmod +x "${CHROOT_DIR}/tmp/build_kloak.sh"
chroot "${CHROOT_DIR}" /tmp/build_kloak.sh
rm "${CHROOT_DIR}/tmp/build_kloak.sh"

ln -sf /etc/systemd/system/kloak.service "${CHROOT_DIR}/etc/systemd/system/multi-user.target.wants/kloak.service"


cat > "${CHROOT_DIR}/usr/local/bin/panic-button" << 'EOF'
#!/bin/bash
echo 1 > /proc/sys/kernel/sysrq
echo o > /proc/sysrq-trigger
poweroff -f
EOF
chmod +x "${CHROOT_DIR}/usr/local/bin/panic-button"


mkdir -p "${CHROOT_DIR}/usr/local/bin"
cat > "${CHROOT_DIR}/usr/local/bin/setup-panic-shortcut" << 'EOF'
#!/bin/bash
sleep 5
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/F12" -n -t string -s "/usr/local/bin/panic-button"
EOF
chmod +x "${CHROOT_DIR}/usr/local/bin/setup-panic-shortcut"

cat > "${CHROOT_DIR}/etc/xdg/autostart/panic-shortcut.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Panic Shortcut Setup
Exec=/usr/local/bin/setup-panic-shortcut
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF


PREF_DIR="${CHROOT_DIR}/usr/lib/firefox/browser/defaults/preferences"
mkdir -p "${PREF_DIR}"
cat > "${PREF_DIR}/polaron-privacy.js" << EOF
// Polaron OS - Deep Freeze Privacy
pref("privacy.resistFingerprinting", true); // Enables Letterboxing & Spoofing
pref("privacy.resistFingerprinting.letterboxing", true);
pref("webgl.disabled", true);
pref("media.peerconnection.enabled", false); // Disable WebRTC
pref("geo.enabled", false);
EOF

