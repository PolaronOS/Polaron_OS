#!/bin/bash

set -e


rm -f /etc/apt/sources.list.d/dangerzone.list
rm -f /etc/apt/sources.list.d/oxen.list

if ! grep -q "^deb.*universe" /etc/apt/sources.list; then
    echo "deb http://archive.ubuntu.com/ubuntu noble universe" >> /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu noble-updates universe" >> /etc/apt/sources.list
    echo "deb http://security.ubuntu.com/ubuntu noble-security universe" >> /etc/apt/sources.list
fi

apt-get update
apt-get install -y curl gpg apt-transport-https lsb-release

rm -f /etc/apt/sources.list.d/oxen.list
curl -so /usr/share/keyrings/oxen.gpg https://deb.oxen.io/pub.gpg
echo "deb [signed-by=/usr/share/keyrings/oxen.gpg] https://deb.oxen.io noble main" > /etc/apt/sources.list.d/oxen.list


apt-get update

dpkg-divert --local --rename --add /usr/sbin/apparmor_parser
ln -sf /bin/true /usr/sbin/apparmor_parser

dpkg --remove --force-remove-reinstreq session-desktop 2>/dev/null || true

apt-get install -f -y

apt-get install -y \
    dino-im \
    onionshare \
    session-desktop

rm /usr/sbin/apparmor_parser
dpkg-divert --local --rename --remove /usr/sbin/apparmor_parser

