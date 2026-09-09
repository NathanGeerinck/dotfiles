# Load Composer tools
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Load Node global installed binaries
export PATH="$HOME/.node/bin:$PATH"

# Use project specific binaries before global ones
export PATH="node_modules/.bin:vendor/bin:$PATH"

# Local bin directories before anything else
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Where the Claude Code native installer puts its launcher. It normally appends
# this line to the shell rc itself, which cannot stick here: ~/.zshrc is a
# symlink into this repo, so anything appended to it is lost on the next relink.
export PATH="$HOME/.local/bin:$PATH"