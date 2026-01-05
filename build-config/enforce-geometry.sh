#!/bin/bash

INTERVAL=0.5

echo "========================================"
echo "   Polaron OS - Window Guard Active     "
echo "   Target Geometry: 1000x800            "
echo "   Monitoring: Tor Browser / Firefox    "
echo "========================================"

while true; do
    wmctrl -lx | grep -i "Navigator" | awk '{print $1}' | while read -r WID; do
        if [ -n "$WID" ]; then
            wmctrl -i -r "$WID" -b remove,maximized_vert,maximized_horz,fullscreen 2>/dev/null
            
            wmctrl -i -r "$WID" -e 0,-1,-1,1000,800 2>/dev/null
        fi
    done
    sleep "$INTERVAL"
done
