# Export every variable defined in .env. `set -a` marks them for export, so no
# further export lines are needed here. The file is gitignored and generated
# from .env.tpl by `op inject`; see the Secrets section of the readme.
if [ -f "$DOTFILES/.env" ]; then
    set -a
    source "$DOTFILES/.env"
    set +a
fi
