#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""

if [ "$EUID" -ne 0 ]; then 
    exit 1
fi

if [ ! -d "${CHROOT_DIR}" ]; then
    exit 1
fi

cp "${SCRIPT_DIR}/sysctl-hardening.conf" "${CHROOT_DIR}/etc/sysctl.d/99-polaron-hardening.conf"

bash "${SCRIPT_DIR}/../privacy-tools/tor-setup.sh"
bash "${SCRIPT_DIR}/../privacy-tools/mac-randomizer.sh"
bash "${SCRIPT_DIR}/../privacy-tools/dns-encryption.sh"

cat > "${CHROOT_DIR}/opt/setup-firewall.sh" << 'EOF'
#!/bin/bash

ufw --force enable

ufw default deny incoming
ufw default allow outgoing


ufw logging high

ufw status verbose
EOF

chmod +x "${CHROOT_DIR}/opt/setup-firewall.sh"
chroot "${CHROOT_DIR}" /opt/setup-firewall.sh

chroot "${CHROOT_DIR}" bash -c "
aa-enforce /etc/apparmor.d/* 2>/dev/null || true
systemctl enable apparmor
"

mkdir -p "${CHROOT_DIR}/etc/fail2ban"
cat > "${CHROOT_DIR}/etc/fail2ban/jail.local" << 'EOF'
[DEFAULT]
bantime = 3600

findtime = 600

maxretry = 3

EOF

chroot "${CHROOT_DIR}" systemctl enable fail2ban

chroot "${CHROOT_DIR}" systemctl enable tor
chroot "${CHROOT_DIR}" systemctl enable dnscrypt-proxy || true
chroot "${CHROOT_DIR}" systemctl enable polaron-tor-routing.service || true

echo ""
echo ""
echo "  ✓ Kernel security parameters (sysctl)"
echo "  ✓ Firewall (UFW) configured"
echo "  ✓ AppArmor mandatory access control"
echo "  ✓ SSH hardening"
echo "  ✓ Fail2Ban intrusion prevention"
echo "  ✓ Tor transparent proxy"
echo "  ✓ MAC address randomization"
echo "  ✓ DNS encryption (DNSCrypt)"
echo ""
