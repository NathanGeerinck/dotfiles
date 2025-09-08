tnt() {
  case "$1" in
    help)
      echo -e "$fg_bold[magenta]TNT (Tallieu & Tallieu) Commands:$reset_color"
      echo -e "  tnt open <project>           Open a project in PHPStorm$reset_color"
      echo -e "  tnt clone <repo> [-gh]       Clone a repository from Bitbucket (default) or Github with -gh flag$reset_color"
      echo -e "  tnt pull-notes               Pull Obsidian notes$reset_color"
      echo -e "  tnt sync-notes [message]     Sync Obsidian notes with optional commit message$reset_color"
      echo -e "  tnt opencode [args]          Run opencode with T&T credentials, passes all args to opencode$reset_color"
      echo -e "  tnt help                     Show this help message$reset_color"
      ;;
    open)
      shift
      source ~/.dotfiles/tallieu/open.sh "$@"
      ;;
    clone)
      shift
      source ~/.dotfiles/tallieu/clone.sh "$@"
      ;;
    pull-notes)
      shift
      source ~/.dotfiles/tallieu/pull-notes.sh "$@"
      ;;
    sync-notes)
      shift
      source ~/.dotfiles/tallieu/sync-notes.sh "$@"
      ;;
    opencode)
      shift
      source ~/.dotfiles/tallieu/opencode.sh "$@"
      ;;
    *)
      echo -e "$fg_bold[red][✗] Error: Unknown command '$1'$reset_color"
      echo -e "Usage: tnt <command> [args]"
      echo -e "Run 'tnt help' for available commands"
      ;;
  esac
}