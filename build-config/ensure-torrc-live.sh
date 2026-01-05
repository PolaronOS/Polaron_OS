#!/bin/bash

CHROOT_DIR="/opt/polaron-build/chroot"


CASPER_SCRIPT="${CHROOT_DIR}/usr/share/initramfs-tools/scripts/casper-bottom/99-fix-torrc"

cat > "${CASPER_SCRIPT}" << 'EOF'
#!/bin/sh
PREREQ=""
DESCRIPTION="Restoring Tor Configuration..."

prereqs()
{
       echo "$PREREQ"
}

case $1 in
prereqs)
       prereqs
       exit 0
       ;;
esac


if [ -z "$1" ]; then
    TARGET="/root"
else
    TARGET="$1"
fi

log_success_msg "Fixing Tor configuration in $TARGET/etc/tor/torrc"

mkdir -p "$TARGET/etc/tor"

cat > "$TARGET/etc/tor/torrc" << 'TORRC'
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

chown 113:113 "$TARGET/var/lib/tor" 2>/dev/null || true
chmod 700 "$TARGET/var/lib/tor" 2>/dev/null || true
chmod 644 "$TARGET/etc/tor/torrc"


exit 0
EOF

chmod +x "${CASPER_SCRIPT}"

