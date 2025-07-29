# Rico's Development Environment

Cross-platform Nix + platform-specific package managers with Home Manager integration.

## Quick Start

```bash
# One-time setup
./setup.sh

# Enter development shell
nix develop

# Apply Home Manager configuration
home-manager switch --flake .#ricoledan@aarch64-darwin  # macOS
# or
home-manager switch --flake .#ricoledan@x86_64-linux     # Linux
```

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

### macOS Applications (via Homebrew)
- **Development**: Ghostty (terminal), JetBrains Toolbox
- **Productivity**: Alfred, Todoist, Fantastical, Notion, Bear, Obsidian
- **Utilities**: 1Password, Magnet, CleanMyMac, Caffeine
- **Media**: Plex, VLC
- **Communication**: Discord
- **Creative**: Adobe Creative Cloud
- **Research**: Zotero
- **Browser**: Zen Browser

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
home-manager switch --flake .#ricoledan@aarch64-darwin

# For Brewfile changes
brew bundle
```

### Updating Packages
```bash
# Update all Nix packages
nix flake update
home-manager switch --flake .#ricoledan@aarch64-darwin

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
├── flake.nix                 # Main Nix configuration
├── flake.lock               # Locked dependencies
├── home/
│   ├── home.nix            # Home Manager entry point
│   └── modules/
│       ├── packages.nix    # Nix packages for home
│       ├── zsh.nix        # Shell configuration
│       └── neovim.nix     # Neovim config (if present)
├── dotfiles/
│   └── .p10k.zsh          # Powerlevel10k config
├── Brewfile               # macOS applications
├── setup.sh              # Initial setup script
└── README.md            # This file
```

## Troubleshooting

### Zsh/P10k Issues
```bash
# Reconfigure p10k if needed
p10k configure
```

### Nix Build Failures
```bash
# Clear Nix store and rebuild
nix-collect-garbage -d
nix flake update
home-manager switch --flake .
```

### Environment Not Loading
```bash
# Ensure direnv is allowed
direnv allow

# Manually reload
nix develop
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
- Adjust home directory path in home.nix
- Some macOS-specific tools won't be available