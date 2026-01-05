#!/bin/bash

CHROOT_DIR="/opt/polaron-build/chroot"


cat > "${CHROOT_DIR}/usr/local/bin/restore-torrc.sh" << 'EOF'
#!/bin/bash

CONFIG_FILE="/etc/tor/torrc"

if [ ! -f "$CONFIG_FILE" ] || [ ! -s "$CONFIG_FILE" ]; then
    mkdir -p /etc/tor
    
    cat > "$CONFIG_FILE" << 'TORRC'
User debian-tor
DataDirectory /var/lib/tor
Log notice syslog
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
AutomapHostsSuffixes .exit .onion
TransPort 127.0.0.1:9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
DNSPort 127.0.0.1:5353
SocksPort 127.0.0.1:9050 IsolateDestAddr IsolateDestPort
SocksPort 127.0.0.1:9150 IsolateDestAddr IsolateDestPort
ControlPort 9051
CookieAuthentication 1
LearnCircuitBuildTimeout 1
CircuitBuildTimeout 30
NumEntryGuards 8
IsolateDestPort 1
IsolateDestAddr 1
AllowSingleHopExits 0
ClientOnly 1
SocksPolicy accept 127.0.0.1
SocksPolicy reject *
TORRC

    chown root:root "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
    
    mkdir -p /var/lib/tor
    chown debian-tor:debian-tor /var/lib/tor
    chmod 700 /var/lib/tor
    
else
fi
EOF

chmod +x "${CHROOT_DIR}/usr/local/bin/restore-torrc.sh"

cat > "${CHROOT_DIR}/etc/systemd/system/restore-torrc.service" << 'EOF'
[Unit]
Description=Ensure Tor Configuration Exists
DefaultDependencies=no
After=local-fs.target
Before=tor.service tor@default.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/restore-torrc.sh
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target multi-user.target
EOF

ln -sf /etc/systemd/system/restore-torrc.service "${CHROOT_DIR}/etc/systemd/system/multi-user.target.wants/restore-torrc.service"
ln -sf /etc/systemd/system/restore-torrc.service "${CHROOT_DIR}/etc/systemd/system/sysinit.target.wants/restore-torrc.service"

