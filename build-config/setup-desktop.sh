#!/bin/bash

DESKTOP_DIR="/home/polaron/Desktop"

mkdir -p "${DESKTOP_DIR}"

cp /usr/share/applications/start-tor.desktop "${DESKTOP_DIR}/" 2>/dev/null || true
cp /usr/share/applications/tor-browser.desktop "${DESKTOP_DIR}/" 2>/dev/null || true

chmod +x "${DESKTOP_DIR}"/*.desktop 2>/dev/null || true

chown -R polaron:polaron "${DESKTOP_DIR}" 2>/dev/null || true

for f in "${DESKTOP_DIR}"/*.desktop; do
    [ -f "$f" ] && gio set "$f" metadata::trusted true 2>/dev/null || true
done
