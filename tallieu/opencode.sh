#!/bin/bash

# Load environment variables from .env file
if [ -f ~/.dotfiles/.env ]; then
    source ~/.dotfiles/.env
fi

# Check if ANTHROPIC_KEY_TNT is set
if [ -z "$ANTHROPIC_KEY_TNT" ]; then
    echo -e "$fg_bold[red][✗] Error: ANTHROPIC_KEY_TNT not found in .env file$reset_color"
    exit 1
fi

# Set the Anthropic API key and run opencode
export ANTHROPIC_API_KEY="$ANTHROPIC_KEY_TNT"
opencode "$@"