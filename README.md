# Rico's Development Environment

Cross-platform Nix flake configuration with Home Manager integration, following best practices for maintainability and security.

## Features

- **Cross-platform**: Works seamlessly on macOS (aarch64) and Linux (x86_64)
- **Declarative**: All configuration in code, fully reproducible
- **Automated**: Update scripts, CI/CD integration, format checking
- **Secure**: Built-in secret management guidelines
- **Fast**: Optimized with Nix caches and direnv integration

## Quick Start

### Prerequisites
- Nix installed (with flakes enabled)
- Git installed

### Initial Setup on a New Machine

```bash
# 1. Clone this repository
git clone https://github.com/ricoledan/nix-config.git
cd nix-config

# 2. Run initial setup (installs Homebrew on macOS)
./setup.sh

# 3. Apply the configuration (works for any user)
./switch.sh

# The switch.sh script automatically:
# - Detects your username ($USER)
# - Detects your home directory ($HOME)
# - Detects your system architecture
# - Applies the configuration

# For manual runs, use:
# nix run home-manager/master -- switch --flake .#user@$(nix eval --impure --expr 'builtins.currentSystem' --raw) --impure

# 4. Enter development shell (optional, for development work)
nix develop

# 5. Allow direnv for automatic environment loading
direnv allow
```

### What This Does
1. **setup.sh**: Installs Homebrew (macOS only) and ensures Nix flakes are enabled
2. **Home Manager activation**:
   - Installs all packages defined in `home/modules/packages.nix`
   - Configures Zsh with Oh My Zsh and Powerlevel10k (with instant prompt)
   - Sets up Neovim with LazyVim
   - Applies all dotfiles and configurations
   - Enables direnv for automatic environment loading
3. **nix develop**: Provides a minimal shell (git, nixpkgs-fmt) before Home Manager activation

## Components Overview

### Core Technologies
- **Nix Flakes**: Reproducible, declarative package management
- **Home Manager**: User environment and dotfile management
- **Homebrew** (macOS): GUI applications and system packages
- **Oh My Zsh + Powerlevel10k**: Enhanced terminal experience
- **Direnv**: Automatic environment loading

### Development Tools (via Nix)
- **Editors**: VSCode, Neovim
- **Version Control**: Git, GitHub CLI (gh)
- **Containers**: Docker, Docker Compose
- **Languages**: Node.js 22, Python 3
- **CLI Tools**:
  - Text processing: jq, ripgrep, bat, fd
  - System utilities: curl, tree, openssh
  - Media: yt-dlp
  - AI: claude-code

### Shell Configuration
- **Zsh** with:
  - Oh My Zsh (git, docker plugins)
  - Powerlevel10k theme
  - Syntax highlighting
  - Auto-suggestions
  - Custom aliases (ll, gs, gc, gp)
  - 10k line history
  - Fastfetch on startup

### Editor Configuration
- **Neovim** with:
  - LazyVim distribution (full IDE experience)
  - LSP support for multiple languages
  - Auto-installed plugins via Nix
  - Custom plugin support in `~/.config/nvim/lua/plugins/`

### macOS Applications (via Homebrew)
- **Development**: Ghostty (terminal), JetBrains Toolbox
- **Productivity**: Alfred, Todoist, Fantastical, Notion, Bear, Obsidian
- **Utilities**: 1Password, Magnet, CleanMyMac, Caffeine
- **Media**: Plex, VLC
- **Communication**: Discord
- **Creative**: Adobe Creative Cloud
- **Research**: Zotero
- **Browser**: Zen Browser

## Automation & Maintenance

### Update Dependencies
```bash
# Run the update script to update all flake inputs
./update.sh
```

This script will:
- Update nixpkgs and home-manager to latest versions
- Show you what changed
- Optionally commit the updates with detailed messages
- Run flake checks to ensure everything works

### Code Formatting
```bash
# Format all Nix files
nix fmt

# Check formatting without changes
nix fmt -- --check
```

### Run Checks
```bash
# Run all flake checks
nix flake check

# Show flake metadata
nix flake metadata
```

## Common Workflows

### Daily Development
```bash
# Start your day - enter the development environment
nix develop

# Your shell will have all tools available
# Fastfetch runs automatically on first shell
```

### Making Configuration Changes
```bash
# Edit configuration files
vim home/home.nix              # Home Manager config
vim home/modules/packages.nix  # Nix packages
vim home/modules/zsh.nix       # Shell config
vim Brewfile                   # macOS apps

# Apply changes
./switch.sh

# For Brewfile changes
brew bundle
```

### Updating Packages
```bash
# Update all Nix packages (recommended method)
./update.sh

# Or manually:
nix flake update
./switch.sh

# Update Homebrew packages
brew update && brew upgrade
brew bundle  # Ensure Brewfile apps are installed
```

### Adding New Tools
```bash
# For CLI tools (cross-platform)
# Edit flake.nix or home/modules/packages.nix
# Add package name to the list

# For macOS GUI apps
# Edit Brewfile
# Add: cask "app-name"
# Run: brew bundle
```

## File Structure

```
.
├── flake.nix                 # Main Nix configuration with formatter & checks
├── flake.lock               # Locked dependencies
├── home/
│   ├── home.nix            # Home Manager entry point
│   ├── modules/
│   │   ├── packages.nix    # Nix packages for home
│   │   ├── zsh.nix        # Shell configuration with P10k
│   │   └── neovim.nix     # Neovim config with LazyVim
│   └── systems/
│       └── default.nix    # System-specific configurations
├── dotfiles/
│   └── .p10k.zsh          # Powerlevel10k config
├── .github/
│   └── workflows/
│       └── check.yml      # CI/CD checks
├── Brewfile               # macOS applications
├── setup.sh              # Initial setup script
├── switch.sh             # Apply configuration script
├── update.sh             # Update automation script
├── .envrc                # Direnv configuration
├── .gitignore            # Includes .env for secrets
└── README.md            # This file
```

## Troubleshooting

### Home Manager Not Found
```bash
# Run the switch script:
./switch.sh
```

### LazyVim Not Working
```bash
# Clear Neovim cache and plugins
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
rm -rf ~/.config/nvim/lazy-lock.json

# Rebuild Home Manager configuration
./switch.sh

# Launch Neovim - LazyVim will auto-install
nvim
```

### Zsh/P10k Issues
```bash
# To modify p10k configuration:
# Edit dotfiles/.p10k.zsh directly
# Then rebuild: ./switch.sh
```

### Nix Build Failures
```bash
# Clear Nix store and rebuild
nix-collect-garbage -d
nix flake update
./switch.sh
```

### Environment Not Loading
```bash
# Ensure direnv is allowed
direnv allow

# Manually reload
nix develop
```

## Security Best Practices

### Secret Management
- **Never commit secrets** to this repository
- Use environment variables for API keys and tokens
- Store secrets in 1Password and use the CLI integration (already configured)
- For persistent secrets, consider:
  - `.env` files (git-ignored)
  - macOS Keychain
  - 1Password CLI: `op read "op://vault/item/field"`

### Flake Configuration Trust
When first using this flake, you'll be prompted to trust the cache configuration. Accept with:
```bash
nix flake metadata --accept-flake-config
```

### Missing Commands
```bash
# Check if in Nix shell
which <command>

# If not found, ensure you're in nix develop
exit
nix develop
```

## Platform-Specific Notes

### macOS
- Homebrew handles GUI applications
- System Integrity Protection may affect some tools
- Use `mas` for Mac App Store apps

### Linux
- GUI apps would use apt/snap/flatpak
- Home directory is automatically detected
- Some macOS-specific tools won't be available

### Multi-User/Multi-System Support
- Configuration automatically detects:
  - Current username via `$USER` environment variable
  - Home directory via `$HOME` environment variable
  - System architecture (aarch64-darwin, x86_64-linux)
- No need to edit configuration files when switching between machines
- Works seamlessly across different usernames and home directory locations
- Just run `./switch.sh` on any machine

## CI/CD Integration

This repository includes GitHub Actions workflows that:
- Run on every push to `main` and on pull requests
- Check flake validity across macOS and Linux
- Verify code formatting
- Build the development shell for both platforms

The CI uses [Determinate Systems' Nix actions](https://github.com/DeterminateSystems) for optimal performance.
