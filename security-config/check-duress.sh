#!/bin/bash

HASH_FILE="/etc/security/duress_password.sha256"
PANIC_SCRIPT="/usr/local/bin/panic-button.sh"

read -r PASSWORD

if [ ! -f "$HASH_FILE" ]; then
    exit 0
fi

LOG_FILE="/tmp/duress.log"

echo "$(date): check-duress.sh STARTED (User: $(whoami))" >> "$LOG_FILE"

chmod 666 "$LOG_FILE" 2>/dev/null

read -r PASSWORD

if [ ! -f "$HASH_FILE" ]; then
    echo "$(date): DEBUG: No hash file found at $HASH_FILE" >> "$LOG_FILE"
    exit 0
fi

INPUT_HASH=$(echo -n "$PASSWORD" | sha256sum | awk '{print $1}')
STORED_HASH=$(cat "$HASH_FILE" | awk '{print $1}')

echo "$(date): DEBUG: Input Hash:  $INPUT_HASH" >> "$LOG_FILE"
echo "$(date): DEBUG: Stored Hash: $STORED_HASH" >> "$LOG_FILE"

if [ "$INPUT_HASH" = "$STORED_HASH" ]; then
    echo "$(date): !!! DURESS CODE DETECTED !!! - ACTIVATING PANIC SEQUENCE" >> "$LOG_FILE"
    
    ( setsid "$PANIC_SCRIPT" & ) >/dev/null 2>&1
    
    sleep 2
    
    exit 0
fi

echo "$(date): DEBUG: No match" >> "$LOG_FILE"
exit 0
