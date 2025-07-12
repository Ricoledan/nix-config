# Rico's Development Environment

Cross-platform Nix + platform-specific package managers.

## Quick Start

```bash
# One-time setup
./setup.sh

# Daily development
nix develop
```

## Strategy

- **Nix** (flake.nix): Cross-platform CLI tools, dev environments
- **macOS**: Homebrew GUI apps (Brewfile)
- **Ubuntu**: APT for system packages, Snap/Flatpak for GUI apps

## Files

- `flake.nix` - Cross-platform Nix dev shell (macOS + Linux)
- `Brewfile` - macOS GUI applications (Homebrew)
- `setup.sh` - Platform-aware setup script

## Commands

```bash
# Setup
./setup.sh                    # Detects platform, installs accordingly

# Development  
nix develop                   # Works on both macOS and Ubuntu

# Updates
nix flake update              # Update Nix packages (both systems)
brew bundle                   # Update macOS apps
sudo apt update && sudo apt upgrade  # Update Ubuntu packages
```

## Platform Distribution

**Both Systems (Nix)**: git, docker, nodejs, python, CLI utilities  
**macOS (Homebrew)**: ghostty, alfred, discord, creative apps  
**Ubuntu (APT/Snap)**: GUI apps, system packages

## Cross-Platform Usage

Same `nix develop` command works on both macOS and Ubuntu. Platform-specific GUI apps handled by native package managers.