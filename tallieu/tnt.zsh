# Tallieu & Tallieu Commands
tnt-help() {
  echo -e "$fg_bold[magenta]TNT (Tallieu & Tallieu) Commands:$reset_color"
  echo -e "  tnt-open <project>           Open a project in PHPStorm$reset_color"
  echo -e "  tnt-clone <repo> [-gh]       Clone a repository from Bitbucket (default) or Github with -gh flag$reset_color"
  echo -e "  tnt-pull-notes               Pull Obsidian notes$reset_color"
  echo -e "  tnt-sync-notes [message]     Sync Obsidian notes with optional commit message$reset_color"
  echo -e "  tnt-opencode [args]          Run opencode with T&T credentials, passes all args to opencode$reset_color"
  echo -e "  tnt-help                     Show this help message$reset_color"
}

tnt-opencode() {
  source ~/.dotfiles/tallieu/opencode.sh "$@"
}

tnt-open() {
  source ~/.dotfiles/tallieu/open.sh "$@"
}

tnt-clone() {
  source ~/.dotfiles/tallieu/clone.sh "$@"
}

tnt-pull-notes() {
  source ~/.dotfiles/tallieu/pull-notes.sh "$@"
}

tnt-sync-notes() {
  source ~/.dotfiles/tallieu/sync-notes.sh "$@"
}