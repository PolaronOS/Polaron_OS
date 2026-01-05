#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"

echo "[Privacy] Configuring DNS encryption..."

cat > "${CHROOT_DIR}/etc/dnscrypt-proxy/dnscrypt-proxy.toml" << 'EOF'

server_names = ['cloudflare', 'cloudflare-security', 'quad9-dnscrypt-ip4-filter-pri']

listen_addresses = ['127.0.2.1:53']

max_clients = 250

doh_servers = true

require_dnssec = true

require_nolog = true

require_nofilter = false

ipv6_servers = false
block_ipv6 = true

cache = true
cache_size = 4096
cache_min_ttl = 2400
cache_max_ttl = 86400

[query_log]
  file = '/var/log/dnscrypt-proxy/query.log'
  format = 'tsv'

timeout = 5000

lb_strategy = 'p2'
lb_estimator = true

[anonymized_dns]
  routes = [
    { server_name='cloudflare', via=['anon-cloudflare-*'] }
  ]
  skip_incompatible = true


[blocked_names]
  blocked_names_file = '/etc/dnscrypt-proxy/blocked-names.txt'

[blocked_ips]
  blocked_ips_file = '/etc/dnscrypt-proxy/blocked-ips.txt'

[sources]
  [sources.'public-resolvers']
    urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md']
    cache_file = '/var/cache/dnscrypt-proxy/public-resolvers.md'
    minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
    refresh_delay = 72
    prefix = ''
  
  [sources.'relays']
    urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md', 'https://download.dnscrypt.info/resolvers-list/v3/relays.md']
    cache_file = '/var/cache/dnscrypt-proxy/relays.md'
    minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
    refresh_delay = 72
    prefix = ''
EOF

cat > "${CHROOT_DIR}/etc/dnscrypt-proxy/blocked-names.txt" << 'EOF'

EOF

cat > "${CHROOT_DIR}/etc/dnscrypt-proxy/blocked-ips.txt" << 'EOF'
EOF

cat > "${CHROOT_DIR}/etc/systemd/resolved.conf" << 'EOF'
[Resolve]
DNS=127.0.2.1
DNSStubListener=no
DNSSEC=yes
DNSOverTLS=no
EOF

echo "[Privacy] DNS encryption configured!"
echo "[Privacy] Using Cloudflare and Quad9 encrypted DNS"
