#!/bin/bash

set -e

CHROOT_DIR="$(dirname "$0")/../build/chroot"
PANIC_SCRIPT="/usr/local/bin/panic-button.sh"

cp "$(dirname "$0")/../security-config/panic-button.sh" "${CHROOT_DIR}${PANIC_SCRIPT}"
chmod +x "${CHROOT_DIR}${PANIC_SCRIPT}"


SHORTCUTS_XML="${CHROOT_DIR}/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"

mkdir -p "$(dirname "$SHORTCUTS_XML")"

if [ ! -f "$SHORTCUTS_XML" ]; then
    echo '<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="custom" type="empty">
      <property name="&lt;Primary&gt;&lt;Alt&gt;r" type="string" value="/usr/local/bin/panic-button.sh"/>
    </property>
  </property>
</channel>' > "$SHORTCUTS_XML"
else
    
    
    if grep -q "panic-button.sh" "$SHORTCUTS_XML"; then
        echo "Shortcut already present."
    else
        true
    fi
fi

cat > "${CHROOT_DIR}/usr/local/bin/apply-panic-shortcut.sh" << 'EOF'
#!/bin/bash
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>r" -n -t string -s "/usr/local/bin/panic-button.sh"
EOF
chmod +x "${CHROOT_DIR}/usr/local/bin/apply-panic-shortcut.sh"

cat > "${CHROOT_DIR}/etc/xdg/autostart/apply-panic-shortcut.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Apply Panic Shortcut
Exec=/usr/local/bin/apply-panic-shortcut.sh
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF

