# ZSH
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

# PHPStorm
alias phpstorm='open -a /Applications/PhpStorm.app "`pwd`"'
alias phpstorm-aep='open -a /Applications/PhpStorm\ 2022.3\ EAP.app "`pwd`"'

# VSCode
alias code='open -a "/Applications/Visual Studio Code.app" "`pwd`"'

# PHP
alias switch-php81="brew unlink php@8.1 && brew link --overwrite --force php"
alias switch-php80="brew unlink php@8.0 && brew link --overwrite --force php"
alias switch-php74="brew unlink php@7.4 && brew link --overwrite --force php"

# Laravel
alias pa='php artisan'

# Git
alias pull="git pull"
alias push="git push"
alias commit="git add . && git commit -m 'wip'"

# Restart touch bar
alias touchbar="killall ControlStrip"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

## Tallieu & Tallieu

# Clone a repository from Bitbucket
tntclone() {
  git clone https://nathangeerincktnt@bitbucket.org/tallieu/$1.git
}

# Start a DRY application
dry-boot() {
  vagrant up
  vagrant ssh
}
