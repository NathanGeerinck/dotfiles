# Completion for bb, the Bitbucket client in bin/bb. The command itself reaches
# $PATH through the ~/.local/bin symlink bin/install creates, so there is no
# function to define here, only the subcommands to teach zsh.
_bb_completion() {
  local -a commands pr_commands repo_commands

  commands=(
    'whoami:Show the authenticated user and the account used'
    'repo:Show the current repository'
    'pr:Work with pull requests'
    'api:Call any Bitbucket API endpoint'
    'help:Show help message'
  )

  pr_commands=(
    'list:List pull requests'
    'view:Show one pull request'
    'diff:Show the diff of a pull request'
    'create:Open a pull request from the current branch'
    'comment:Comment on a pull request'
    'approve:Approve a pull request'
    'merge:Merge a pull request'
  )

  repo_commands=('view:Show the current repository')

  if (( CURRENT == 2 )); then
    _describe 'bb commands' commands
  elif (( CURRENT == 3 )) && [[ ${words[2]} == "pr" ]]; then
    _describe 'pr commands' pr_commands
  elif (( CURRENT == 3 )) && [[ ${words[2]} == "repo" ]]; then
    _describe 'repo commands' repo_commands
  fi
}

compdef _bb_completion bb
