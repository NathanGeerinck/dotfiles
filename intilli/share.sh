#!/bin/bash

# Check if NGROK_AUTHTOKEN_INTILLI is set
if [ -z "$NGROK_AUTHTOKEN_INTILLI" ]; then
    echo -e "$fg_bold[red][✗] Error: NGROK_AUTHTOKEN_INTILLI not found in .env file$reset_color"
    exit 1
fi

echo -e "$fg_bold[cyan]Starting valet share with Intilli ngrok credentials...$reset_color"
NGROK_AUTHTOKEN="$NGROK_AUTHTOKEN_INTILLI" valet share "$@"
