# PHPStorm
alias phpstorm='open -a /Applications/PhpStorm.app "`pwd`"'

# VSCode
alias code='open -a "/Applications/Visual Studio Code.app" "`pwd`"'


# PHP
alias switch-php80="brew unlink php@7.4 && brew link --overwrite --force php"
alias switch-php74="brew unlink php && brew link --overwrite --force php@7.4"

# Laravel
alias pa='php artisan'

# Git
alias pull="git pull"
alias push="git push"
alias commit="git add . && git commit -m 'wip'"
tntclone() {
  git clone https://nathangeerincktnt@bitbucket.org/tallieu/$1.git
}

# Restart touch bar
alias touchbar="killall ControlStrip"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

