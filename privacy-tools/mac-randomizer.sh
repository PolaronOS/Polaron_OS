#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"

echo "[Privacy] Configuring MAC address randomization..."

cat > "${CHROOT_DIR}/etc/NetworkManager/conf.d/00-polaron-mac-randomize.conf" << 'EOF'

[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random

connection.stable-id=${CONNECTION}/${BOOT}
EOF

cat > "${CHROOT_DIR}/usr/local/bin/polaron-randomize-mac" << 'EOF'
#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

echo "Randomizing MAC addresses for all network interfaces..."

INTERFACES=$(ip link show | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/:$//' | grep -v '^lo$')

for IFACE in $INTERFACES; do
    ip link set dev $IFACE down
    
    macchanger -r $IFACE
    
    ip link set dev $IFACE up
    
    echo "[✓] Randomized MAC for $IFACE"
done

echo ""
echo "All MAC addresses randomized!"
echo "Note: Restart NetworkManager for changes to take effect"
echo "      sudo systemctl restart NetworkManager"
EOF

chmod +x "${CHROOT_DIR}/usr/local/bin/polaron-randomize-mac"

cat > "${CHROOT_DIR}/etc/systemd/system/polaron-mac-randomize.service" << 'EOF'
[Unit]
Description=Polaron OS - MAC Address Randomization on Boot
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/usr/bin/macchanger -e eth0
ExecStart=/usr/bin/macchanger -e wlan0
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "[Privacy] MAC randomization configured!"
