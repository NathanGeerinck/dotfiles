tnt() {
  case "$1" in
    help)
      echo -e "$fg_bold[cyan]TNT (Tallieu & Tallieu) Commands:$reset_color"
      echo -e "  open <project>           Open a project in PHPStorm$reset_color"
      echo -e "  clone <repo> [-gh]       Clone a repository from Bitbucket (default) or Github with -gh flag$reset_color"
      echo -e "  pull-notes               Pull Obsidian notes$reset_color"
      echo -e "  sync-notes [message]     Sync Obsidian notes with optional commit message$reset_color"
      echo -e "  opencode [args]          Run opencode with T&T credentials, passes all args to opencode$reset_color"
      echo -e "  startup                  Stop Valet, quit PHP Monitor, and start Docker Desktop$reset_color"
      echo -e "  shutdown                 Quit Docker Desktop$reset_color"
      echo -e "  help                     Show this help message$reset_color"
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
    startup)
      shift
      source ~/.dotfiles/tallieu/startup.sh "$@"
      ;;
    shutdown)
      shift
      source ~/.dotfiles/tallieu/shutdown.sh "$@"
      ;;
    *)
      echo -e "$fg_bold[red][✗] Error: Unknown command '$1'$reset_color"
      echo -e "Usage: tnt <command> [args]"
      echo -e "Run 'tnt help' for available commands"
      ;;
  esac
}

# Autocompletion for tnt command
_tnt_completion() {
  local -a commands
  commands=(
    'help:Show help message'
    'open:Open a project in PHPStorm'
    'clone:Clone a repository from Bitbucket or Github'
    'pull-notes:Pull Obsidian notes'
    'sync-notes:Sync Obsidian notes'
    'opencode:Run opencode with T&T credentials'
    'startup:Stop Valet, quit PHP Monitor, and start Docker Desktop'
    'shutdown:Quit Docker Desktop'
  )

  if (( CURRENT == 2 )); then
    _describe 'tnt commands' commands
  elif (( CURRENT == 3 )) && [[ ${words[2]} == "open" ]]; then
    # For 'tnt open', complete with directory names in ~/Development/tnt
    if [[ -d ~/Development/tnt ]]; then
      local -a projects
      projects=($(ls ~/Development/tnt 2>/dev/null))
      _describe 'projects' projects
    fi
  fi
}

compdef _tnt_completion tnt