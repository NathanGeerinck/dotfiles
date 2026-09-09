#!/bin/bash
#
# Publishes the MCP credentials into the launchd GUI session, so Claude Code can
# read them when it is started by an app rather than from a terminal. Loaded at
# login by be.intilli.mcp-env.plist in this directory. Safe to run repeatedly.

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES
source "$DOTFILES/bin/lib.sh"

CLAUDE_JSON="$HOME/.claude.json"

[ -f "$DOTFILES/.env" ] || abort ".env not found, run 'op inject -f -i .env.tpl -o .env' first"
[ -f "$CLAUDE_JSON" ] || abort "$CLAUDE_JSON not found, start Claude Code once first"

# Same file ~/.zshrc sources, so the two paths into the environment cannot drift.
source "$DOTFILES/home/env.zsh"

# Which variables to publish is read out of the MCP config rather than listed
# here, so registering a server that references a new ${VAR} needs no change to
# this script. The only ${...} references ~/.claude.json ever holds are these
# credential placeholders; everything else in it is machine state.
vars="$(grep -o '\${[A-Za-z_][A-Za-z0-9_]*}' "$CLAUDE_JSON" | tr -d '${}' | sort -u)"

if [ -z "$vars" ]; then
  ok "no \${VAR} references in .claude.json, nothing to publish"
  exit 0
fi

for var in $vars; do
  value="${!var:-}"

  if [ -z "$value" ]; then
    warn "$var is referenced by an MCP server but is not set in .env"
    continue
  fi

  launchctl setenv "$var" "$value"
  ok "published $var (${#value} chars)"
done
