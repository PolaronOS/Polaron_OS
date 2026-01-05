#!/bin/bash

echo "========================================================================"
echo "                   TOR BRIDGE CONFIGURATION"
echo "========================================================================"
echo "If Tor is blocked in your country, you need Bridges."
echo "Get them from: https://bridges.torproject.org/"
echo ""
echo "Example likely bridge line:"
echo "obfs4 1.2.3.4:443 <FINGERPRINT> cert=<CERT> iat-mode=0"
echo ""
echo "------------------------------------------------------------------------"
echo "PASTE your bridge lines below."
echo "When finished pasting, press ENTER, then press Ctrl+D (EOF)."
echo "------------------------------------------------------------------------"

BRIDGES=$(cat)

echo ""
echo "------------------------------------------------------------------------"
echo "[INFO] configuring bridges..."

TORRC="/usr/share/tor/torrc"

if [ "$EUID" -ne 0 ]; then
    echo "[!] Authentication required to modify Tor configuration."
    if command -v pkexec >/dev/null; then
         sudo "$0" <<< "$BRIDGES"
         exit $?
    else
         echo "Error: Need root permissions."
         exit 1
    fi
fi

sed -i '/^UseBridges/d' "$TORRC"
sed -i '/^Bridge/d' "$TORRC"
sed -i '/^ClientTransportPlugin/d' "$TORRC"

if [ -z "$BRIDGES" ]; then
    echo "[INFO] No bridges provided. Resetting to direct connection."
else
    echo "" >> "$TORRC"
    echo "## Bridge Configuration (Added by User)" >> "$TORRC"
    echo "UseBridges 1" >> "$TORRC"
    echo "ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy" >> "$TORRC"
    
    echo "$BRIDGES" | while read -r line; do
        [[ -z "$line" ]] && continue
        
        if [[ "$line" =~ ^obfs4 ]]; then
            echo "Bridge $line" >> "$TORRC"
            echo "Added: Bridge $line"
        elif [[ "$line" =~ ^Bridge ]]; then
            echo "$line" >> "$TORRC"
            echo "Added: $line"
        else
            echo "[WARN] Ignoring invalid line: $line"
        fi
    done
fi

echo "[INFO] Configuration updated."
echo "[INFO] Restarting Tor service..."
systemctl restart tor@default

echo "------------------------------------------------------------------------"
echo "Tor Status:"
systemctl status tor@default --no-pager
echo "------------------------------------------------------------------------"
echo "If status is 'active', you are good to go!"
echo "Press Enter to exit."
read
