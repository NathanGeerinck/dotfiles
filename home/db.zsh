db() {
  case "$1" in
    help)
      echo -e "$fg_bold[cyan]Database Commands:$reset_color"
      echo -e "  list                     List all databases$reset_color"
      echo -e "  create <name>            Create a database$reset_color"
      echo -e "  drop <name>              Drop a database$reset_color"
      echo -e "  refresh <name>           Drop and recreate a database$reset_color"
      echo -e "  help                     Show this help message$reset_color"
      ;;
    list)
      mysql -uroot -e "show databases" | sed 's/[|[:space:]]//g'
      ;;
    create)
      if [ -z "$2" ]; then
        echo -e "$fg_bold[red][✗] Error: a database name is required$reset_color"
        return 1
      fi
      mysql -uroot -e "create database \`$2\`" &&
        echo -e "$fg_bold[cyan]Created $2$reset_color"
      ;;
    drop)
      if [ -z "$2" ]; then
        echo -e "$fg_bold[red][✗] Error: a database name is required$reset_color"
        return 1
      fi
      mysql -uroot -e "drop database \`$2\`" &&
        echo -e "$fg_bold[cyan]Dropped $2$reset_color"
      ;;
    refresh)
      if [ -z "$2" ]; then
        echo -e "$fg_bold[red][✗] Error: a database name is required$reset_color"
        return 1
      fi
      mysql -uroot -e "drop database if exists \`$2\`; create database \`$2\`" &&
        echo -e "$fg_bold[cyan]Refreshed $2$reset_color"
      ;;
    *)
      echo -e "$fg_bold[red][✗] Error: Unknown command '$1'$reset_color"
      echo -e "Usage: db <command> [args]"
      echo -e "Run 'db help' for available commands"
      ;;
  esac
}

# Autocompletion for db command
_db_completion() {
  local -a commands
  commands=(
    'help:Show help message'
    'list:List all databases'
    'create:Create a database'
    'drop:Drop a database'
    'refresh:Drop and recreate a database'
  )

  if (( CURRENT == 2 )); then
    _describe 'db commands' commands
  elif (( CURRENT == 3 )) && [[ ${words[2]} == (drop|refresh) ]]; then
    # Complete with the databases that actually exist
    local -a databases
    databases=($(mysql -uroot -e "show databases" 2>/dev/null | sed 's/[|[:space:]]//g' | grep -v '^Database$'))
    _describe 'databases' databases
  fi
}

compdef _db_completion db
