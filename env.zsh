if [ -f "$DOTFILES/.env" ]; then
    set -a
    source "$DOTFILES/.env"
    set +a
fi

export SHORTCUT_KEY_TNT="$SHORTCUT_KEY_TNT"