# Nathan's Dotfiles

My personal dotfiles for macOS.

Contains custom aliases, functions, and environment setup. Application settings backups are managed via [Mackup](https://github.com/lra/mackup).

You can install them by cloning the repository as `.dotfiles` in your home directory and running the installation script:

```bash
git clone https://github.com/NathanGeerinck/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Custom Commands

### General Aliases
- `reload` - Reload ZSH configuration
- `phpstorm` - Open current directory in PHPStorm
- `emptytrash` - Empty trash and clear system logs

### PHP Version Switching
- `switch-php84`, `switch-php83`, `switch-php82`, `switch-php81`, `switch-php80`, `switch-php74` - Switch PHP versions

### Laravel
- `pa` - Shortcut for `php artisan`

### Git
- `pull`, `push`, `commit` - Quick git shortcuts

### Docker
- `dcu` - Run `docker compose up`
- `dps` - Run `docker ps`
- `dssh <service>` - SSH into a Docker container

### Intilli Commands
```bash
intilli startup     # Stop Docker, start Valet and PHP Monitor
intilli shutdown    # Stop Valet and quit PHP Monitor
intilli help        # Show help message
```

### TNT (Tallieu & Tallieu) Commands
```bash
tnt open <project>           # Open a project in PHPStorm
tnt clone <repo> [-gh]       # Clone repo from Bitbucket (or GitHub with -gh)
tnt pull-notes               # Pull Obsidian notes
tnt sync-notes [message]     # Sync Obsidian notes
tnt opencode [args]          # Run OpenCode with T&T credentials
tnt startup                  # Stop Valet, quit PHP Monitor, start Docker
tnt shutdown                 # Quit Docker Desktop
tnt help                     # Show help message
```

## Thanks To...

Inspiration from these excellent dotfiles repositories:

- [Dries Vints](https://github.com/driesvints/dotfiles)
- [Freek Van der Herten](https://github.com/freekmurze/dotfiles)
- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [Zach Holman](https://github.com/holman/dotfiles)