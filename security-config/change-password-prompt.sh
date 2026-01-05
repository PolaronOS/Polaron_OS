#!/bin/bash

clear

echo "========================================================================"
echo "                   POLARON OS - SECURITY WARNING"
echo "========================================================================"
echo ""
echo "WARNING: The default password for user 'polaron' is 'polaron'."
echo "This is public knowledge and highly insecure."
echo ""
echo "You MUST change your password now to secure 'sudo' access."
echo "If you do not change it, your system is vulnerable to local attacks."
echo ""
echo "------------------------------------------------------------------------"
echo "Press ENTER to change password now (or Ctrl+C to ignore risk)..."
read

passwd

if [ $? -eq 0 ]; then
    echo ""
    echo "[SUCCESS] Password changed successfully."
else
    echo ""
    echo "[!] Password change failed. You are at risk."
fi

echo ""
echo "------------------------------------------------------------------------"
echo "SETUP DURESS PASSWORD (OPTIONAL)"
echo "------------------------------------------------------------------------"
echo "A 'Duress Password' works like a panic button."
echo "If you enter it instead of your real password in sudo/login,"
echo "the system will IMMEDIATELY self-destruct (RAM wipe + shutdown)."
echo ""
echo "Enter a Duress Password (or leave empty to skip):"
read -s DURESS_PASS
echo ""

if [ -n "$DURESS_PASS" ]; then
    echo "Repeat Duress Password:"
    read -s DURESS_PASS2
    echo ""
    
    if [ "$DURESS_PASS" = "$DURESS_PASS2" ]; then
        echo "Saving Duress Password... (Please enter your NEW password if asked)"
        echo -n "$DURESS_PASS" | sha256sum | awk '{print $1}' | sudo tee /etc/security/duress_password.sha256 > /dev/null
        sudo chmod 644 /etc/security/duress_password.sha256
        echo "[SUCCESS] Duress password set."
    else
        echo "[ERROR] Passwords do not match. Duress NOT set."
    fi
else
    echo "Skipping Duress setup."
fi

echo "Configuration complete. This prompt will disappear in 5 seconds."
sleep 5

