#!/bin/bash

# Check if ANTHROPIC_KEY_TNT is set
if [ -z "$ANTHROPIC_KEY_TNT" ]; then
    echo -e "$fg_bold[red][✗] Error: ANTHROPIC_KEY_TNT not found in .env file$reset_color"
    exit 1
fi

ANTHROPIC_API_KEY="$ANTHROPIC_KEY_TNT" opencode "$@"