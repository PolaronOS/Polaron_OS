#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"


chroot "${CHROOT_DIR}" apt-get install -y usbguard usbguard-notifier

cat > "${CHROOT_DIR}/usr/local/bin/randomize-identity" << 'EOF'
#!/bin/bash
NEW_HOSTNAME="polaron-$(tr -dc 'a-z0-9' < /dev/urandom | head -c 8)"
hostnamectl set-hostname "$NEW_HOSTNAME"
sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
echo "Hostname randomized to: $NEW_HOSTNAME"

rm -f /etc/machine-id
dbus-uuidgen --ensure=/etc/machine-id
echo "Machine-ID rotated."
EOF
chmod +x "${CHROOT_DIR}/usr/local/bin/randomize-identity"

cat > "${CHROOT_DIR}/etc/systemd/system/polaron-identity.service" << EOF
[Unit]
Description=Polaron OS Identity Randomizer
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/randomize-identity
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF

ln -sf /etc/systemd/system/polaron-identity.service "${CHROOT_DIR}/etc/systemd/system/sysinit.target.wants/polaron-identity.service"



cat > "${CHROOT_DIR}/etc/usbguard/rules.conf" << EOF
allow-device with-interface one-of { 03:*:* }

allow-device with-interface one-of { 08:*:* }

allow-device with-interface one-of { 09:*:* }
EOF

sed -i 's/ImplicitPolicyTarget=allow/ImplicitPolicyTarget=block/' "${CHROOT_DIR}/etc/usbguard/usbguard-daemon.conf"
sed -i 's/PresentDevicePolicy=apply-policy/PresentDevicePolicy=apply-policy/' "${CHROOT_DIR}/etc/usbguard/usbguard-daemon.conf"

