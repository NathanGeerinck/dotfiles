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

The script asks for your password once at the start, then installs the Xcode Command Line Tools, Oh My Zsh, Homebrew, everything in the Brewfile, and Laravel Valet. It prompts before installing Claude Code and before applying the macOS system preferences. It is idempotent, so rerunning it is safe.

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
| `~/.mackup.cfg` | `macos/.mackup.cfg` (only if absent, see below) |
| `~/.claude/CLAUDE.md` | `config/claude/CLAUDE.md` |
| `~/.claude/laravel-php-guidelines.md` | `config/claude/laravel-php-guidelines.md` |
| `~/.claude/settings.json` | `config/claude/settings.json` |
| `~/.claude/skills` | `config/claude/skills/` |
| `~/.claude/agents` | `config/claude/agents/` |

## What this repo owns, and what Mackup owns

These two overlap in a way that is worth spelling out, because it is easy to go looking for a file in the wrong place.

This repo owns the shell (`.zshrc` and everything it sources) and the Claude Code config. Mackup is configured to ignore `zsh`, so it stays out of the way.

Mackup owns application preferences and, per `macos/.mackup.cfg`, **your `.gitconfig`**. It syncs them through iCloud. There is no `.gitconfig` in this repo, and that is deliberate.

`.mackup.cfg` is the awkward case. Mackup syncs its own config file, so once you run `mackup backup`, `~/.mackup.cfg` becomes a symlink into iCloud and this repo's copy is no longer what you are reading. The copy here exists only to bootstrap a fresh Mac, where Mackup needs to know the storage engine before it can restore anything. That is why `bin/install` places it only when nothing is there yet.

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

## Claude Code

`config/claude/` is version controlled and symlinked into `~/.claude`, so skills, agents, and settings survive a machine rebuild. Install or relink it on its own with:

```bash
bin/install-claude
```

Add a skill with `npx skills add <owner/repo>` (it lands in `config/claude/skills/`), then commit it. Browse more at [skills.sh](https://skills.sh).

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
