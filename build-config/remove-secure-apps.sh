#!/bin/bash

set -e


apt-get purge -y session-desktop onionshare dino-im dino-im-common || true

rm -f /etc/apt/sources.list.d/oxen.list
rm -f /usr/share/keyrings/oxen.gpg
rm -f /etc/apt/sources.list.d/dangerzone.list
rm -f /etc/apt/keyrings/dangerzone.gpg

apt-get autoremove -y

