#!/bin/bash
mkdir -p "$HOME/Desktop"

cp /usr/share/applications/start-tor.sh "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/start-tor.sh"

cp /usr/local/bin/setup-bridges.sh "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/setup-bridges.sh"

cp /usr/share/applications/tor-browser.desktop "$HOME/Desktop/" 2>/dev/null || true

cp /usr/share/applications/tor-browser.desktop "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/tor-browser.desktop"
gio set "$HOME/Desktop/tor-browser.desktop" metadata::trusted true 2>/dev/null || true

cp /etc/skel/Desktop/anonymity-dashboard.desktop "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/anonymity-dashboard.desktop"
gio set "$HOME/Desktop/anonymity-dashboard.desktop" metadata::trusted true 2>/dev/null || true



cp /usr/share/applications/window-lock.desktop "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/window-lock.desktop"
gio set "$HOME/Desktop/window-lock.desktop" metadata::trusted true 2>/dev/null || true

