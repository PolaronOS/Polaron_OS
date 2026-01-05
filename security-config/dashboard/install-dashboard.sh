#!/bin/bash

set -e

apt-get install -y python3-tk curl

mkdir -p /usr/local/bin
cp /tmp/anonymity_dashboard.py /usr/local/bin/anonymity_dashboard.py
chmod +x /usr/local/bin/anonymity_dashboard.py

mkdir -p /etc/skel/Desktop
mkdir -p /usr/share/applications

cat <<EOF > /tmp/anonymity-dashboard.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Anonymity Dashboard
Comment=Check Tor status, Killswitch, and System Stats
Exec=/usr/local/bin/anonymity_dashboard.py
Icon=security-high
Terminal=false
StartupNotify=true
Categories=System;Security;
EOF

cp /tmp/anonymity-dashboard.desktop /usr/share/applications/
cp /tmp/anonymity-dashboard.desktop /etc/skel/Desktop/

chmod +x /usr/share/applications/anonymity-dashboard.desktop
chmod +x /etc/skel/Desktop/anonymity-dashboard.desktop

