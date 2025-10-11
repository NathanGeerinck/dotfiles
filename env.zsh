if [ -f "$DOTFILES/.env" ]; then
    set -a
    source "$DOTFILES/.env"
    set +a
fi

export ANTHROPIC_KEY_TNT="$ANTHROPIC_KEY_TNT"
export SHORTCUT_KEY_TNT="$SHORTCUT_KEY_TNT"