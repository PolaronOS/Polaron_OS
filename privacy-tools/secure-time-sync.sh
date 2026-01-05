#!/bin/bash

SOCKS_PORT="127.0.0.1:9050"
TARGET_URL="https://www.google.com"

log() {
    echo "[$(date)] $1"
}

wait_for_tor() {
    log "Waiting for Tor..."
    until curl --socks5-hostname "$SOCKS_PORT" --head "$TARGET_URL" --connect-timeout 5 -o /dev/null -s; do
        sleep 5
    done
    log "Tor is ready."
}

sync_time() {
    log "Fetching secure time via Tor..."
    HTTP_DATE=$(curl --socks5-hostname "$SOCKS_PORT" --head "$TARGET_URL" --connect-timeout 10 -s | grep -i "^Date:" | cut -d' ' -f2-)
    
    if [ -n "$HTTP_DATE" ]; then
        log "Remote time: $HTTP_DATE"
        if date -s "$HTTP_DATE"; then
            log "Time synchronized successfully."
            hwclock --systohc
        else
            log "Error: Failed to set time."
        fi
    else
        log "Error: Could not fetch time."
    fi
}

wait_for_tor

while true; do
    sync_time
    
    INTERVAL=$((1800 + RANDOM % 1800))
    log "Sleeping for $INTERVAL seconds..."
    sleep "$INTERVAL"
done
