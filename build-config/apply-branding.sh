#!/bin/bash

set -e


CHROOT_DIR="/opt/polaron-build/chroot"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOGO_FILE="${SCRIPT_DIR}/../polaron_boot_logo.png"
WALLPAPER_FILE="${SCRIPT_DIR}/../polaron.jpg"



cat > "${CHROOT_DIR}/etc/os-release" << EOF
PRETTY_NAME="Polaron OS 1.0"
NAME="Polaron OS"
VERSION_ID="1.0"
VERSION="1.0 (Dark North)"
ID=polaron
ID_LIKE=ubuntu
UBUNTU_CODENAME=noble
EOF

cat > "${CHROOT_DIR}/etc/issue" << EOF
Polaron OS 1.0 \n \l
EOF

cat > "${CHROOT_DIR}/etc/issue.net" << EOF
Polaron OS 1.0
EOF

cat > "${CHROOT_DIR}/etc/lsb-release" << EOF
DISTRIB_ID=PolaronOS
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=noble
DISTRIB_DESCRIPTION="Polaron OS 1.0"
EOF


sed -i 's/GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="Polaron OS"/' "${CHROOT_DIR}/etc/default/grub"

sed -i 's/#GRUB_DISABLE_RECOVERY="true"/GRUB_DISABLE_RECOVERY="true"/' "${CHROOT_DIR}/etc/default/grub"




rm -rf "${CHROOT_DIR}/usr/share/xfce4/backdrops"/*
rm -rf "${CHROOT_DIR}/usr/share/backgrounds"/*


mkdir -p "${CHROOT_DIR}/usr/share/xfce4/backdrops"
mkdir -p "${CHROOT_DIR}/usr/share/backgrounds/polaron"


cp "${WALLPAPER_FILE}" "${CHROOT_DIR}/usr/share/backgrounds/polaron/default-wallpaper.jpg"


TARGET="/usr/share/backgrounds/polaron/default-wallpaper.jpg"


ln -sf "$TARGET" "${CHROOT_DIR}/usr/share/xfce4/backdrops/xubuntu-wallpaper.png"
ln -sf "$TARGET" "${CHROOT_DIR}/usr/share/xfce4/backdrops/xfce-stripes.png"
ln -sf "$TARGET" "${CHROOT_DIR}/usr/share/xfce4/backdrops/xfce-blue.jpg"
ln -sf "$TARGET" "${CHROOT_DIR}/usr/share/xfce4/backdrops/greybird.svg" # The "Mouse" killer


ln -sf "$TARGET" "${CHROOT_DIR}/usr/share/backgrounds/warty-final-ubuntu.png"
ln -sf "$TARGET" "${CHROOT_DIR}/usr/share/backgrounds/ubuntu-default-greyscale-wallpaper.png"

sed -i 's/#GRUB_GFXMODE=.*/GRUB_GFXMODE=1024x768/' "${CHROOT_DIR}/etc/default/grub"

if ! grep -q "GRUB_GFXPAYLOAD_LINUX" "${CHROOT_DIR}/etc/default/grub"; then
    echo 'GRUB_GFXPAYLOAD_LINUX="keep"' >> "${CHROOT_DIR}/etc/default/grub"
fi




chroot "${CHROOT_DIR}" apt-get install -y plymouth-themes || true


mkdir -p "${CHROOT_DIR}/etc/lightdm"
cat > "${CHROOT_DIR}/etc/lightdm/lightdm-gtk-greeter.conf" << EOF
[greeter]
background=/usr/share/backgrounds/polaron/default-wallpaper.jpg
theme-name=Adwaita-dark
icon-theme-name=Adwaita
font-name=Sans 10
EOF


cat > "${CHROOT_DIR}/usr/local/bin/polaron-force-wallpaper" << EOF
#!/bin/bash
# Wait for XFCE to start and monitors to be detected
sleep 5

# Set wallpaper for ALL detected monitors and workspaces
# We search for any property ending in 'last-image' or 'image-path'
# This handles Virtual-1, HDMI-1, etc.
for PROP in \$(xfconf-query -c xfce4-desktop -l | grep -E 'last-image|image-path'); do
    xfconf-query -c xfce4-desktop -p "\$PROP" -n -t string -s /usr/share/backgrounds/polaron/default-wallpaper.jpg
done

# Set image style to 'Zoom' (5) for all
for PROP in \$(xfconf-query -c xfce4-desktop -l | grep 'image-style'); do
    xfconf-query -c xfce4-desktop -p "\$PROP" -n -t int -s 5
done
EOF
chmod +x "${CHROOT_DIR}/usr/local/bin/polaron-force-wallpaper"

mkdir -p "${CHROOT_DIR}/etc/xdg/autostart"
cat > "${CHROOT_DIR}/etc/xdg/autostart/polaron-wallpaper.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Force Wallpaper
Exec=/usr/local/bin/polaron-force-wallpaper
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF


chroot "${CHROOT_DIR}" apt-get install -y plymouth-themes plymouth-x11 || true

PLYMOUTH_DIR="${CHROOT_DIR}/usr/share/plymouth/themes/polaron"
mkdir -p "${PLYMOUTH_DIR}"


cp "${LOGO_FILE}" "${PLYMOUTH_DIR}/logo.png"
cp "${WALLPAPER_FILE}" "${PLYMOUTH_DIR}/background.png"
cp "${LOGO_FILE}" "${PLYMOUTH_DIR}/watermark.png"
cp "${LOGO_FILE}" "${PLYMOUTH_DIR}/progress_bar.png"


cat > "${PLYMOUTH_DIR}/polaron.plymouth" << EOF
[Plymouth Theme]
Name=Polaron
Description=Polaron OS Boot Theme
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/polaron
ScriptFile=/usr/share/plymouth/themes/polaron/polaron.script
EOF

cat > "${PLYMOUTH_DIR}/polaron.script" << 'EOF'
Window.SetBackgroundTopColor(0.0, 0.0, 0.0);
Window.SetBackgroundBottomColor(0.0, 0.0, 0.0);

logo.image = Image("logo.png");
logo.sprite = Sprite(logo.image);

# Center the logo
logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2);
logo.sprite.SetZ(100);
EOF


mkdir -p "${CHROOT_DIR}/etc/alternatives"
rm -f "${CHROOT_DIR}/etc/alternatives/default.plymouth"
ln -sf /usr/share/plymouth/themes/polaron/polaron.plymouth "${CHROOT_DIR}/etc/alternatives/default.plymouth"

rm -f "${CHROOT_DIR}/usr/share/plymouth/themes/default.plymouth"
ln -sf /usr/share/plymouth/themes/polaron/polaron.plymouth "${CHROOT_DIR}/usr/share/plymouth/themes/default.plymouth"


echo "FRAMEBUFFER=y" >> "${CHROOT_DIR}/etc/initramfs-tools/conf.d/splash"


cat > "${CHROOT_DIR}/etc/plymouth/plymouthd.conf" << EOF
[Daemon]
Theme=polaron
ShowDelay=0
EOF

