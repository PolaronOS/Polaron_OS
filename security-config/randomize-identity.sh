#!/bin/bash

set -e

RAND_SUFFIX=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 8)
NEW_HOSTNAME="polaron-$RAND_SUFFIX"


hostnamectl set-hostname "$NEW_HOSTNAME" 2>/dev/null || hostname "$NEW_HOSTNAME"
echo "$NEW_HOSTNAME" > /etc/hostname
sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts

mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/00-mac-randomization.conf
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
connection.stable-id=\${CONNECTION}/\${BOOT}
EOF

if [ -f /var/lib/dbus/machine-id ]; then
    rm -f /var/lib/dbus/machine-id
fi

