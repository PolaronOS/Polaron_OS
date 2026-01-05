#!/bin/bash

RAND_SUFFIX=$(openssl rand -hex 4)
NEW_HOSTNAME="polaron-${RAND_SUFFIX}"

echo "Randomizing identity: ${NEW_HOSTNAME}"

hostnamectl set-hostname "${NEW_HOSTNAME}" 2>/dev/null || hostname "${NEW_HOSTNAME}"

sed -i "s/127.0.1.1.*/127.0.1.1\t${NEW_HOSTNAME}/" /etc/hosts

echo "${NEW_HOSTNAME}" > /etc/hostname

rm -f /var/lib/dbus/machine-id
rm -f /etc/machine-id
systemd-machine-id-setup

echo "Identity randomized."
