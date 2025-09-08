# ZSH
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

# PHPStorm
alias phpstorm='open -a /Applications/PhpStorm.app "`pwd`"'

# PHP
alias switch-php84="brew unlink php && brew link --overwrite --force php@8.4"
alias switch-php83="brew unlink php && brew link --overwrite --force php@8.3"
alias switch-php82="brew unlink php && brew link --overwrite --force php@8.2"
alias switch-php81="brew unlink php && brew link --overwrite --force php@8.1"
alias switch-php80="brew unlink php && brew link --overwrite --force php@8.0"
alias switch-php74="brew unlink php && brew link --overwrite --force php@7.4"

# Laravel
alias pa='php artisan'

# Git
alias pull="git pull"
alias push="git push"
alias commit="git add . && git commit -m 'wip'"

# Docker
dssh() {
  docker compose exec -it $1 bash
}

alias dcu="docker compose up"
alias dps="docker ps"

# Tallieu & Tallieu
tnt-help() {
  echo -e "$fg_bold[magenta]TNT (Tallieu & Tallieu) Commands:$reset_color"
  echo -e "  tnt-open        Open a project in PHPStorm$reset_color"
  echo -e "  tnt-clone       Clone a repository from Bitbucket or Github$reset_color"
  echo -e "  tnt-pull-notes  Pull Obsidian notes$reset_color"
  echo -e "  tnt-sync-notes  Sync Obsidian notes$reset_color"
  echo -e "  tnt-opencode    Run opencode with T&T credentials$reset_color"
  echo -e "  tnt-help        Show this help message$reset_color"
}

tnt-opencode() {
  source ~/.dotfiles/tallieu/opencode.sh "$@"
}

tnt-open() {
  source ~/.dotfiles/tallieu/open.sh "$@"
}

alias tnt-clone="source ~/.dotfiles/tallieu/clone.sh"
alias tnt-pull-notes="source ~/.dotfiles/tallieu/pull-notes.sh"
alias tnt-sync-notes="source ~/.dotfiles/tallieu/sync-notes.sh"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"
