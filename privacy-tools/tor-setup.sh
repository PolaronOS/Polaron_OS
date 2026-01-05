#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"

echo "[Tor] Configuring Tor for maximum anonymity..."

cat > "${CHROOT_DIR}/etc/tor/torrc" << 'EOF'

User debian-tor
DataDirectory /var/lib/tor

Log notice file /var/log/tor/notices.log

VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 127.0.0.1:9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
DNSPort 127.0.0.1:5353

SocksPort 127.0.0.1:9050 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
SocksPort 127.0.0.1:9150 # For Tor Browser compatibility

ControlPort 9051
CookieAuthentication 1

LearnCircuitBuildTimeout 1
CircuitBuildTimeout 20

NumEntryGuards 8

IsolateDestPort 1
IsolateDestAddr 1

AllowSingleHopExits 0

ClientOnly 1

MaxCircuitDirtiness 600


EOF

cat > "${CHROOT_DIR}/usr/local/bin/polaron-tor-routing.sh" << 'EOF'
#!/bin/bash

TRANS_PORT="9040"

DNS_PORT="5353"

TOR_USER="debian-tor"

NON_TOR="127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

iptables -F
iptables -t nat -F

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A OUTPUT -m owner --uid-owner $TOR_USER -j ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $DNS_PORT
iptables -t nat -A OUTPUT -p tcp --dport 53 -j REDIRECT --to-ports $DNS_PORT

for NET in $NON_TOR; do
    iptables -t nat -A OUTPUT -d $NET -j RETURN
done

iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT

iptables -A OUTPUT -j REJECT

echo "[Tor Routing] All traffic is now routed through Tor"
EOF

chmod +x "${CHROOT_DIR}/usr/local/bin/polaron-tor-routing.sh"

cat > "${CHROOT_DIR}/etc/systemd/system/polaron-tor-routing.service" << 'EOF'
[Unit]
Description=Polaron OS - Transparent Tor Routing
After=network.target tor.service
Requires=tor.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/polaron-tor-routing.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

cat > "${CHROOT_DIR}/usr/local/bin/polaron-check-tor" << 'EOF'
#!/bin/bash

echo "Checking Tor connection..."
echo ""

if systemctl is-active --quiet tor; then
    echo "[✓] Tor service is running"
else
    echo "[✗] Tor service is NOT running!"
    exit 1
fi

TOR_CHECK=$(curl -s --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip)

if echo "$TOR_CHECK" | grep -q "true"; then
    echo "[✓] Connected to Tor network"
    TOR_IP=$(echo "$TOR_CHECK" | grep -oP '(?<="IP":")[^"]*')
    echo "[✓] Your Tor IP: $TOR_IP"
else
    echo "[✗] NOT connected to Tor network!"
    exit 1
fi

echo ""
echo "Your connection is anonymous through Tor!"
EOF

chmod +x "${CHROOT_DIR}/usr/local/bin/polaron-check-tor"

cat > "${CHROOT_DIR}/usr/share/applications/polaron-tor-status.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Tor Status
Comment=Check Tor connection status
Exec=xfce4-terminal -e polaron-check-tor
Icon=tor
Categories=Network;Security;
Terminal=false
EOF

echo "[Tor] Configuration complete!"
echo "[Tor] Tor will route ALL traffic transparently on boot"
