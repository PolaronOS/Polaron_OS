#!/bin/bash

TB_USER_DIR="$HOME/tor-browser"
TB_OPT_DIR="/opt/tor-browser"
LAUNCHER="start-tor-browser.desktop"

if [ -f "$TB_USER_DIR/$LAUNCHER" ]; then
    TARGET="$TB_USER_DIR/$LAUNCHER"
    WORKING_DIR="$TB_USER_DIR"
elif [ -f "$TB_OPT_DIR/$LAUNCHER" ]; then
    TARGET="$TB_OPT_DIR/$LAUNCHER"
    WORKING_DIR="$TB_OPT_DIR"
else
    ls -la "$HOME"
    if command -v zenity >/dev/null; then
        zenity --error --text="Tor Browser not found in $TB_USER_DIR or $TB_OPT_DIR"
    fi
    exit 1
fi

export TOR_SKIP_LAUNCH=1
export TOR_SOCKS_PORT=9150
export TOR_TRANSPROXY=1

cd "$WORKING_DIR"
./$LAUNCHER --detach &

