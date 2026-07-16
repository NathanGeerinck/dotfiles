#!/bin/bash
#
# Shared helpers for the scripts in this directory. Source it, don't run it.

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

info() { echo "  $1"; }
ok() { echo "  ✓ $1"; }
warn() { echo "  ⚠ $1"; }
step() { echo ""; echo "$1"; }
abort() { echo "  ✗ $1"; exit 1; }

# Ask a yes/no question. Returns 0 for yes.
confirm() {
  printf "%s (y/n) " "$1"
  read -r reply
  [[ "$reply" =~ ^[Yy] ]]
}

# Replace $2 with a symlink to $1, moving any real file or directory out of the
# way first so nothing is silently destroyed.
link() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    warn "skipping $(basename "$dest"): $src does not exist"
    return
  fi

  if [ "$(readlink "$dest" 2>/dev/null)" = "$src" ]; then
    ok "$(basename "$dest") already linked"
    return
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local backup="$dest.backup-$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    warn "moved existing $(basename "$dest") to $(basename "$backup")"
  fi

  rm -rf "$dest"
  ln -s "$src" "$dest"
  ok "linked $(basename "$dest")"
}
