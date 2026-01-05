#!/bin/bash

set -e

CHROOT_DIR="/opt/polaron-build/chroot"


chroot "${CHROOT_DIR}" apt-get install -y secure-delete mat2 udisks2

cat >> "${CHROOT_DIR}/etc/fstab" << EOF
tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
EOF

cat > "${CHROOT_DIR}/etc/systemd/system/ram-wipe.service" << EOF
[Unit]
Description=Wipe RAM on Shutdown
DefaultDependencies=no
Before=final.target shutdown.target poweroff.target
After=umount.target

[Service]
Type=oneshot
ExecStart=/usr/bin/sdmem -ll
TimeoutStartSec=0

[Install]
WantedBy=final.target
EOF
ln -sf /etc/systemd/system/ram-wipe.service "${CHROOT_DIR}/etc/systemd/system/final.target.wants/ram-wipe.service"

mkdir -p "${CHROOT_DIR}/etc/xdg/Thunar"
cat > "${CHROOT_DIR}/etc/xdg/Thunar/uca.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<actions>
  <action>
    <icon>edit-clear</icon>
    <name>Clean Metadata (MAT2)</name>
    <unique-id>mat2-clean</unique-id>
    <command>mat2 --inplace %F</command>
    <description>Remove metadata from files</description>
    <patterns>*</patterns>
    <audio-files/>
    <image-files/>
    <other-files/>
    <text-files/>
    <video-files/>
  </action>
  <action>
    <icon>user-trash</icon>
    <name>Secure Delete (SRM)</name>
    <unique-id>srm-delete</unique-id>
    <command>srm -r -v %F</command>
    <description>Securely wipe file from disk</description>
    <patterns>*</patterns>
    <directories/>
    <audio-files/>
    <image-files/>
    <other-files/>
    <text-files/>
    <video-files/>
  </action>
</actions>
EOF

