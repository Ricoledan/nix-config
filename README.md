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

## Strategy

- **Nix** (flake.nix): Cross-platform CLI tools, dev environments
- **Home Manager** (home/home.nix): User-specific configurations and dotfiles
- **macOS**: Homebrew GUI apps (Brewfile)
- **Ubuntu**: APT for system packages, Snap/Flatpak for GUI apps

## Files

- `flake.nix` - Cross-platform Nix dev shell and Home Manager configurations
- `home/home.nix` - Home Manager configuration for user-specific settings
- `Brewfile` - macOS GUI applications (Homebrew)
- `setup.sh` - Platform-aware setup script

## Commands

```bash
# Setup
./setup.sh                    # Detects platform, installs accordingly

# Development  
nix develop                   # Enter development shell

# Home Manager
home-manager switch --flake . # Apply Home Manager configuration

# Updates
nix flake update              # Update Nix packages
brew bundle                   # Update macOS apps
sudo apt update && sudo apt upgrade  # Update Ubuntu packages
```

## Platform Distribution

**Both Systems (Nix)**: git, docker, nodejs, python, CLI utilities  
**macOS (Homebrew)**: ghostty, alfred, discord, creative apps  
**Ubuntu (APT/Snap)**: GUI apps, system packages

## Cross-Platform Usage

Same `nix develop` command works on both macOS and Ubuntu. Platform-specific GUI apps handled by native package managers.