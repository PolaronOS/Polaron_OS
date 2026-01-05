#!/bin/bash

echo "[PANIC] Emergency shutdown sequence initiated!" | wall

if command -v xsel >/dev/null; then
    xsel -bc  # Clear clipboard
    xsel -pc  # Clear primary selection
    xsel -sc  # Clear secondary selection
fi

if command -v veracrypt >/dev/null; then
    veracrypt -d -f &
fi

umount -f /media/* 2>/dev/null

systemctl poweroff -i
