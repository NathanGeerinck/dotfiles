#!/bin/bash

# Read JSON input once
input=$(cat)

# Extract everything in a single jq pass (one value per line).
# Rate limit fields are absent for non-subscribers and before the first
# API response of a session, in which case they come back empty.
IFS=$'\n' read -r -d '' cwd ctx_pct csl_pct wl_pct < <(
  echo "$input" | jq -r '
    .workspace.current_dir,
    (.context_window.used_percentage // 0 | floor),
    (.rate_limits.five_hour.used_percentage // "" | if . == "" then "" else floor end),
    (.rate_limits.seven_day.used_percentage // "" | if . == "" then "" else floor end)
  '
  printf '\0'
)

# Green under 40%, yellow under 60%, red above
color_for_pct() {
  if [ "$1" -ge 60 ]; then
    printf '\033[01;31m'
  elif [ "$1" -ge 40 ]; then
    printf '\033[01;33m'
  else
    printf '\033[01;32m'
  fi
}

# Renders " | <label>: <pct>%" in colour, or nothing when the value is missing
usage_segment() {
  [ -n "$2" ] || return 0
  printf ' | %s: %b%s%%\033[00m' "$1" "$(color_for_pct "$2")" "$2"
}

if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  repo_name=$(basename "$cwd")
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

  printf '\033[01;36m%s\033[00m \033[00;37m(%s)\033[00m' "$repo_name" "$git_branch"
else
  printf '\033[01;36m%s\033[00m' "$cwd"
fi

usage_segment "ctx" "$ctx_pct"
usage_segment "csl" "$csl_pct"
usage_segment "wl" "$wl_pct"
