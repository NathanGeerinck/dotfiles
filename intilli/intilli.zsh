intilli() {
  case "$1" in
    help)
      echo -e "$fg_bold[cyan]Intilli Commands:$reset_color"
      echo -e "  startup                  Stop Docker, start Valet and PHP Monitor$reset_color"
      echo -e "  shutdown                 Stop Valet and quit PHP Monitor$reset_color"
      echo -e "  help                     Show this help message$reset_color"
      ;;
    startup)
      shift
      source ~/.dotfiles/intilli/startup.sh "$@"
      ;;
    shutdown)
      shift
      source ~/.dotfiles/intilli/shutdown.sh "$@"
      ;;
    *)
      echo -e "$fg_bold[red][✗] Error: Unknown command '$1'$reset_color"
      echo -e "Usage: intilli <command> [args]"
      echo -e "Run 'intilli help' for available commands"
      ;;
  esac
}

_intilli_completion() {
  local -a commands
  commands=(
    'help:Show help message'
    'startup:Stop Docker, start Valet and PHP Monitor'
    'shutdown:Stop Valet and quit PHP Monitor'
  )

  if (( CURRENT == 2 )); then
    _describe 'intilli commands' commands
  fi
}

compdef _intilli_completion intilli
