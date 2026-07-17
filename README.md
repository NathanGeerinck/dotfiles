# Nathan's Dotfiles

My personal dotfiles for macOS, built around Laravel/PHP work at [Intilli](https://intilli.be) and [Tallieu & Tallieu](https://www.tnt.be).

Shell config, Homebrew packages, per client commands, and a version controlled Claude Code setup (skills, agents, and settings). Application preferences are handled separately by [Mackup](https://github.com/lra/mackup).

## Install

On a fresh Mac:

```bash
git clone https://github.com/NathanGeerinck/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bin/install
```

The script asks for your password once at the start, then installs the Xcode Command Line Tools, Oh My Zsh, Homebrew, everything in the Brewfile, Laravel Valet, and the [Ploi CLI](#ploi). It prompts before installing Claude Code and before applying the macOS system preferences. It is idempotent, so rerunning it is safe.

It does leave one thing to you: run `mackup restore` to pull your application preferences back from iCloud.

Secrets are handled for you, as long as the 1Password app is installed and unlocked with the CLI integration turned on. See below.

## Structure

```
~/.dotfiles
├── bin/          install, update, install-claude, lib.sh
├── config/       Brewfile, claude/, iterm/, phpstorm/
├── home/         .zshrc and the files it sources
├── macos/        set-defaults.sh, .mackup.cfg
└── work/         intilli/, tallieu/
```

## What gets symlinked

`bin/install` creates these. Anything real that is already in the way gets renamed to `<name>.backup-<timestamp>` rather than deleted.

| Symlink | Points to |
|---|---|
| `~/.zshrc` | `home/.zshrc` |
| `~/.gitconfig` | `home/.gitconfig` |
| `~/.global-gitignore` | `home/.global-gitignore` |
| `~/.mackup.cfg` | `macos/.mackup.cfg` (only if absent, see below) |
| `~/.claude/CLAUDE.md` | `config/claude/CLAUDE.md` |
| `~/.claude/laravel-php-guidelines.md` | `config/claude/laravel-php-guidelines.md` |
| `~/.claude/settings.json` | `config/claude/settings.json` |
| `~/.claude/statusline.sh` | `config/claude/statusline.sh` |
| `~/.claude/skills` | `config/claude/skills/` |
| `~/.claude/agents` | `config/claude/agents/` |

## What this repo owns, and what Mackup owns

This repo owns the shell (`.zshrc` and everything it sources), git (`.gitconfig` and `.global-gitignore`), and the Claude Code config. Mackup is told to ignore `zsh` and `git`, so it stays out of the way of all of it.

Mackup owns application preferences only, synced through iCloud.

`.mackup.cfg` is the awkward case. Mackup syncs its own config file, so once you run `mackup backup`, `~/.mackup.cfg` becomes a symlink into iCloud and this repo's copy is no longer what you are reading. The copy here exists only to bootstrap a fresh Mac, where Mackup needs to know the storage engine before it can restore anything. That is why `bin/install` places it only when nothing is there yet. **If you change `macos/.mackup.cfg`, mirror it into `~/.mackup.cfg`,** or the change only reaches a machine that has never run Mackup.

Git used to be Mackup's. There is a stale `.gitconfig` sitting in the iCloud Mackup folder from before the switch to SSH commit signing, which is why `git` is now in `applications_to_ignore`: without that, `mackup restore` would overwrite the real config with the old one.

## How the shell loads

`~/.zshrc` is the only entry point, and it sources the rest explicitly in this order:

1. `home/env.zsh` exports everything in `.env`.
2. Oh My Zsh loads, which also runs `compinit`.
3. `home/path.zsh` sets up `$PATH`.
4. `home/aliases.zsh` defines the aliases and sources `work/intilli/intilli.zsh` and `work/tallieu/tnt.zsh`.

Order matters in two places. Anything using `compdef` (the `tnt` and `intilli` completions) has to come after Oh My Zsh, and aliases come last so they win over the ones Oh My Zsh plugins define.

## Secrets

Secrets live in 1Password, never in this repo and never in iCloud. `.env` is generated from `.env.tpl`, which is committed and holds [1Password secret references](https://developer.1password.com/docs/cli/secret-references/) instead of values:

```
NGROK_AUTHTOKEN_INTILLI="{{ op://Intilli/Ngrok/authtoken }}"
```

`bin/install` generates `.env` on a new machine. Regenerate it yourself after rotating a token:

```bash
op inject -f -i .env.tpl -o .env
```

This needs the 1Password app unlocked with the CLI integration enabled (Settings, Developer, Integrate with 1Password CLI). `bin/install` skips this step with a warning when `op` is missing or signed out, so the rest of the install still completes.

`.env` itself is gitignored and stays an ordinary file, so `home/env.zsh` sources it with `set -a` and every key is exported automatically. There is no per shell call to `op` and no startup cost. To add a secret, put it in 1Password, add a line to `.env.tpl`, and regenerate.

One quirk worth knowing: the Tallieu & Tallieu vault is referenced by ID rather than name, because `op` rejects the `&` in "Tallieu & Tallieu" as an illegal character in a secret reference.

A missing field is not a soft failure. `op inject` aborts on the whole template rather than skipping the one line it cannot resolve: it exits 1 and writes nothing, leaving any existing `.env` untouched. So a bad reference does not destroy your secrets, but it does mean the file silently stays stale. Add the field in 1Password first, then add the reference here.

## Claude Code

`config/claude/` is version controlled and symlinked into `~/.claude`, so skills, agents, and settings survive a machine rebuild. Install or relink it on its own with:

```bash
bin/install-claude
```

Add a skill with `npx skills add <owner/repo>` (it lands in `config/claude/skills/`), then commit it. Browse more at [skills.sh](https://skills.sh).

### MCP servers

MCP servers are the one part of the Claude Code setup that cannot be symlinked. Claude Code stores them in `~/.claude.json`, which also holds machine specific state (startup counts, project history, per project notes), so the file is no use in a repo. `bin/install-claude` registers them with `claude mcp add` instead, which gets the same reproducibility without version controlling any of that noise.

Registered right now:

| Server | Transport | Notes |
|---|---|---|
| `ploi` | HTTP, `https://ploi.io/api/mcp` | Needs a Ploi Pro plan or higher |

Authenticating is manual and once per machine, because the OAuth flow opens a browser. Start Claude Code, run `/mcp`, select `ploi`, then choose **Authenticate**. The tokens go to the macOS Keychain, so they never touch this repo or `~/.claude.json`.

To add another server, register it with `claude mcp add --scope user ...`, then mirror the command into `bin/install-claude` so a rebuild picks it up.

Be deliberate about which servers you add. Ploi's `get-site-env` tool returns raw `.env` contents, secrets included, to whatever client is connected.

## Ploi

[Ploi](https://ploi.io) hosts the servers, and there are two separate integrations here.

The **CLI** is installed globally by `bin/install` (`composer global require ploi/cli`) and lands on `$PATH` through `~/.composer/vendor/bin`. It needs PHP 8.2 or higher. Useful commands:

```bash
ploi init          # Link the current directory to a Ploi site
ploi deploy        # Deploy, optionally streaming the log
ploi ssh           # SSH into a server
ploi list          # Show every command
```

The **MCP server** gives Claude Code the same reach. See [MCP servers](#mcp-servers) above.

They authenticate separately, and neither one shares the other's credentials.

The CLI takes its token from `PLOI_API_TOKEN`, which `.env` provides from 1Password. This is worth knowing because it is not the documented flow: the docs tell you to run `ploi token`, which writes the token in plaintext to `~/.ploi/config.php`. The CLI checks the environment variable first and prefers it, so the token stays in the vault and a rebuild needs no manual step.

Rotating it, or setting it up on a machine that has never had it:

```bash
# Create a key at https://ploi.io/profile/api-keys, then store it
op item edit ploi.io --vault Intilli api-token=<token>
op inject -f -i .env.tpl -o .env
exec zsh
```

`op inject` fails on the whole template while that field is absent, so create the field before regenerating. Verify with `ploi server:list`.

## Custom commands

### General
- `reload` Reload the ZSH configuration
- `phpstorm` Open the current directory in PhpStorm
- `emptytrash` Empty the trash and clear system logs

### PHP version switching
- `switch-php84`, `switch-php83`, `switch-php82`, `switch-php81`, `switch-php80`, `switch-php74`

### Laravel
- `pa` Shortcut for `php artisan`

### Git
- `pull`, `push`, `commit` Quick git shortcuts

### Docker
- `dcu` Run `docker compose up`
- `dps` Run `docker ps`
- `dssh <service>` Open a bash shell in a running container

### Intilli
```bash
intilli startup     # Start Valet and PHP Monitor
intilli shutdown    # Stop Valet and quit PHP Monitor
intilli share       # Run valet share
intilli help        # Show help message
```

### TNT (Tallieu & Tallieu)
```bash
tnt open <project>           # Open a project in PhpStorm
tnt clone <repo> [-gh]       # Clone repo from Bitbucket (or GitHub with -gh)
tnt pull-notes               # Pull Obsidian notes
tnt sync-notes [message]     # Sync Obsidian notes
tnt share [args]             # Run ngrok with T&T credentials (e.g. tnt share http 80)
tnt startup                  # Start Docker
tnt shutdown                 # Quit Docker Desktop
tnt help                     # Show help message
```

Both commands support tab completion.

## Updating

```bash
bin/update
```

Pulls this repo, then updates Homebrew, reapplies the Brewfile, and updates global Composer packages.

## Packages

Everything lives in `config/Brewfile`. To add a tool:

```bash
echo "brew 'neovim'" >> config/Brewfile
brew bundle --file=config/Brewfile
```

## macOS preferences

`macos/set-defaults.sh` writes a long list of system preferences (originally from [Mathias Bynens](https://mths.be/macos)). `bin/install` offers to run it. It restarts Finder, Dock, and several other apps, so run it when you are not in the middle of something.

## Thanks to

Inspiration from these excellent dotfiles repositories:

- [Dries Vints](https://github.com/driesvints/dotfiles)
- [Freek Van der Herten](https://github.com/freekmurze/dotfiles)
- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [Zach Holman](https://github.com/holman/dotfiles)
