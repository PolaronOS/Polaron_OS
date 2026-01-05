#!/bin/bash
echo "Starting Tor manually..."
echo "You will see logs below. Press Ctrl+C to stop. If Tor connection fails, use sudo systemctl status tor@default to check connection status (should be enabled) "
echo "------------------------------------------------"
sudo /usr/bin/tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc -f /usr/share/tor/torrc
