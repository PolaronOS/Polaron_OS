#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"



cat > "${CHROOT_DIR}/etc/usbguard/rules.conf" << EOF
allow with-interface one-of { 03:*:* }

allow with-interface one-of { 08:*:* }

allow with-interface one-of { 09:*:* }
EOF

sed -i 's/ImplicitPolicyTarget=block/ImplicitPolicyTarget=allow/' "${CHROOT_DIR}/etc/usbguard/usbguard-daemon.conf"


chroot "${CHROOT_DIR}" systemctl disable systemd-resolved
chroot "${CHROOT_DIR}" systemctl stop systemd-resolved || true

rm -f "${CHROOT_DIR}/etc/resolv.conf"

cat > "${CHROOT_DIR}/etc/resolv.conf" << EOF
nameserver 127.0.0.1
options edns0 trust-ad
EOF

if ! grep -q "DNSPort" "${CHROOT_DIR}/etc/tor/torrc"; then
    cat >> "${CHROOT_DIR}/etc/tor/torrc" << EOF
DNSPort 5353
AutomapHostsOnResolve 1
EOF
fi


cat > "${CHROOT_DIR}/etc/nftables.conf" << 'NFT'
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        ct state established,related accept
        ct state invalid drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy drop;
        oifname "lo" accept
        meta skuid "debian-tor" accept
        ct state established,related accept
    }
}

table ip nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        udp dport 53 redirect to :5353
    }

    chain output {
        type nat hook output priority -100; policy accept;

        meta skuid "debian-tor" return

        udp dport 53 redirect to :5353
        tcp dport 53 redirect to :5353

        oifname "lo" return

        tcp dport 1-65535 redirect to :9040
    }
}
NFT

chroot "${CHROOT_DIR}" systemctl enable nftables || true

