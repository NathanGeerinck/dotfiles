#!/bin/bash
#
# Installs Claude Code and symlinks the config in this repo into ~/.claude.
# Safe to run repeatedly. Can be run standalone or from ../../install.sh

set -e

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
CLAUDE_SRC="$DOTFILES/misc/claude"
CLAUDE_DIR="$HOME/.claude"

echo "Setting up Claude Code..."

if [ ! -d "$CLAUDE_SRC" ]; then
  echo "  ✗ $CLAUDE_SRC not found, aborting"
  exit 1
fi

# Install the CLI if it isn't there yet
if command -v claude >/dev/null 2>&1; then
  echo "  ✓ Claude Code already installed"
elif command -v brew >/dev/null 2>&1; then
  brew install --cask claude-code
else
  curl -fsSL https://claude.ai/install.sh | bash
fi

mkdir -p "$CLAUDE_DIR"

# Replace $2 with a symlink to $1, moving any real file/dir out of the way first.
link() {
  src="$1"
  dest="$2"

  if [ ! -e "$src" ]; then
    echo "  ⚠ skipping $(basename "$dest"): $src does not exist"
    return
  fi

  # Already pointing where we want it
  if [ "$(readlink "$dest" 2>/dev/null)" = "$src" ]; then
    echo "  ✓ $(basename "$dest") already linked"
    return
  fi

  # A real file or directory lives here: keep a copy rather than clobbering it
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    backup="$dest.backup-$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "  ⚠ moved existing $(basename "$dest") to $(basename "$backup")"
  fi

  rm -rf "$dest"
  ln -s "$src" "$dest"
  echo "  ✓ linked $(basename "$dest")"
}

link "$CLAUDE_SRC/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
link "$CLAUDE_SRC/laravel-php-guidelines.md" "$CLAUDE_DIR/laravel-php-guidelines.md"
link "$CLAUDE_SRC/settings.json" "$CLAUDE_DIR/settings.json"
link "$CLAUDE_SRC/skills" "$CLAUDE_DIR/skills"
link "$CLAUDE_SRC/agents" "$CLAUDE_DIR/agents"

echo "Claude Code setup complete. Restart Claude Code to pick up the changes."
