# Path to the dotfiles repo. Everything below loads relative to this.
export DOTFILES=$HOME/.dotfiles

# Secrets from $DOTFILES/.env, loaded first so everything else can use them.
source "$DOTFILES/home/env.zsh"

# Oh My Zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="af-magic"
HIST_STAMPS="dd/mm/yyyy"
plugins=(docker laravel git)

# 1Password SSH agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# This runs compinit, so anything calling compdef must be sourced after it.
source $ZSH/oh-my-zsh.sh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PHP_CS_FIXER_IGNORE_ENV=1
export GPG_TTY=$(tty)

source "$DOTFILES/home/path.zsh"
source "$DOTFILES/home/aliases.zsh"
source "$DOTFILES/home/functions.zsh"
source "$DOTFILES/home/db.zsh"

# Modern CLI tools, each guarded so a machine without them still gets a shell.
# zoxide tracks the directories you visit: `z tnt` jumps to the best match, `zi`
# picks interactively.
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# fzf: ctrl+r fuzzy history, ctrl+t file search, alt+c cd
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] &&
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# NVM
export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Only present on machines where certificates are managed with acme.sh.
[ -s "$HOME/.acme.sh/acme.sh.env" ] && \. "$HOME/.acme.sh/acme.sh.env"
