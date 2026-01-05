#!/bin/bash
set -e

apt-get update
apt-get install -y wmctrl

cp /tmp/window-lock.desktop /usr/share/applications/window-lock.desktop
cp /tmp/window-lock.desktop /etc/skel/Desktop/window-lock.desktop
chmod +x /usr/share/applications/window-lock.desktop
chmod +x /etc/skel/Desktop/window-lock.desktop

