# ZSH
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

# PHPStorm
alias phpstorm='open -a /Applications/PhpStorm.app "`pwd`"'

# VSCode
alias code='open -a "/Applications/Visual Studio Code.app" "`pwd`"'

# PHP
alias switch-php83="brew unlink php@8.3 && brew link --overwrite --force php"
alias switch-php82="brew unlink php@8.2 && brew link --overwrite --force php"
alias switch-php81="brew unlink php@8.1 && brew link --overwrite --force php"
alias switch-php80="brew unlink php@8.0 && brew link --overwrite --force php"
alias switch-php74="brew unlink php@7.4 && brew link --overwrite --force php"

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

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Tallieu & Tallieu
## Clone a repository from Bitbucket or Github
alias tnt-clone="source ~/.dotfiles/tallieu/clone.sh"

## Pull Obsidian notes
alias tnt-pull-notes="source ~/.dotfiles/tallieu/pull-notes.sh"

## Sync Obsidian notes
alias tnt-sync-notes="source ~/.dotfiles/tallieu/sync-notes.sh"
