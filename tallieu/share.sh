#!/bin/bash

# Check if NGROK_AUTHTOKEN_TNT is set
if [ -z "$NGROK_AUTHTOKEN_TNT" ]; then
    echo -e "$fg_bold[red][✗] Error: NGROK_AUTHTOKEN_TNT not found in .env file$reset_color"
    exit 1
fi

echo -e "$fg_bold[cyan]Starting ngrok with T&T credentials...$reset_color"
NGROK_AUTHTOKEN="$NGROK_AUTHTOKEN_TNT" ngrok "$@"
