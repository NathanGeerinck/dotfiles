# Export every variable defined in .env. `set -a` marks them for export, so no
# further export lines are needed here. The file is gitignored; .env.example
# lists the keys that are expected.
if [ -f "$DOTFILES/.env" ]; then
    set -a
    source "$DOTFILES/.env"
    set +a
fi
