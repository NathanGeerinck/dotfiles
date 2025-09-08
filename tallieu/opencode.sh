#!/bin/bash

# Load environment variables from .env file
if [ -f ~/.dotfiles/.env ]; then
    source ~/.dotfiles/.env
fi

# Check if ANTHROPIC_KEY_TNT is set
if [ -z "$ANTHROPIC_KEY_TNT" ]; then
    echo "Error: ANTHROPIC_KEY_TNT not found in .env file"
    exit 1
fi

# Set the Anthropic API key and run opencode
export ANTHROPIC_API_KEY="$ANTHROPIC_KEY_TNT"
opencode "$@"