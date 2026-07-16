# Run the test suite, preferring Pest and falling back to PHPUnit. Both are in
# use across the projects here, so this keeps one command for either.
p() {
  if [ -f vendor/bin/pest ]; then
    vendor/bin/pest "$@"
  elif [ -f vendor/bin/phpunit ]; then
    vendor/bin/phpunit "$@"
  else
    echo -e "$fg_bold[red][✗] Error: no vendor/bin/pest or vendor/bin/phpunit here$reset_color"
    return 1
  fi
}

# Same, filtered to a single test.
pf() {
  if [ -z "$1" ]; then
    echo -e "$fg_bold[red][✗] Error: a filter is required$reset_color"
    echo -e "Usage: pf <filter>"
    return 1
  fi

  p --filter "$@"
}

# Create a directory and cd into it.
mkd() {
  if [ -z "$1" ]; then
    echo -e "$fg_bold[red][✗] Error: a directory is required$reset_color"
    return 1
  fi

  mkdir -p "$1" && cd "$1"
}

# Delete local branches whose remote branch is gone.
git-prune-local() {
  git fetch -p

  local branches
  branches=$(git branch -vv | grep ': gone]' | awk '{print $1}')

  if [ -z "$branches" ]; then
    echo -e "$fg_bold[cyan]No local branches to prune$reset_color"
    return
  fi

  echo "$branches" | xargs git branch -D
}
