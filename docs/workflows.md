# Common Workflows

This guide covers typical tasks and workflows when using this Nix configuration.

## Table of Contents

- [Daily Usage](#daily-usage)
- [Package Management](#package-management)
- [Configuration Updates](#configuration-updates)
- [Development Workflows](#development-workflows)
- [Maintenance Tasks](#maintenance-tasks)
- [Collaboration](#collaboration)

## Daily Usage

### Applying Configuration Changes

After making any changes to your Nix configuration:

```bash
# Quick sync (most common)
./sync-hm.sh

# Manual sync with specific system
home-manager switch --flake .#user@aarch64-darwin --impure

# Dry run to preview changes
home-manager build --flake .#user@aarch64-darwin --impure
```

### Quick Edits

Common configuration files you might edit frequently:

```bash
# Add a new package
nvim home/modules/packages.nix

# Add a git alias
nvim home/modules/tools/git.nix

# Add a shell alias
nvim home/modules/shell/zsh.nix

# After editing, apply changes
./sync-hm.sh
```

## Package Management

### Adding Packages

#### Nix Packages

1. Find the package:

```bash
# Search for packages
nix search nixpkgs package-name

# Get package info
nix eval nixpkgs#package-name.meta.description
```

1. Add to `home/modules/packages.nix`:

```nix
packages = with pkgs; [
  existing-package
  new-package  # Add your package here
];
```

1. Apply changes:

```bash
./sync-hm.sh
```

#### Homebrew Packages (macOS)

1. Search for package:

```bash
brew search package-name
```

1. Add to `Brewfile`:

```ruby
# For CLI tools
brew "package-name"

# For GUI applications
cask "application-name"

# From Mac App Store
mas "App Name", id: 123456789
```

1. Apply changes:

```bash
brew bundle
# Or just run sync-hm.sh which includes brew bundle
./sync-hm.sh
```

### Removing Packages

#### Nix Packages

1. Remove from `home/modules/packages.nix`
2. Apply and clean up:

```bash
./sync-hm.sh
# Optional: garbage collect old generations
home-manager expire-generations "-7 days"
nix-collect-garbage -d
```

#### Homebrew Packages

1. Remove from `Brewfile`
2. Clean up:

```bash
brew bundle cleanup
brew bundle --force cleanup  # Actually remove packages
```

### Updating Packages

#### Update All Nix Packages

```bash
# Update flake inputs
nix flake update

# Or update specific input
nix flake lock --update-input nixpkgs

# Apply updates
./sync-hm.sh
```

#### Update Homebrew Packages

```bash
# Update Homebrew itself
brew update

# Upgrade all packages
brew upgrade

# Upgrade specific package
brew upgrade package-name

# Regenerate Brewfile
brew bundle dump --force
```

## Configuration Updates

### Adding a New Module

1. Create the module file:

```bash
# Choose appropriate category
touch home/modules/tools/new-tool.nix
```

1. Write the module:

```nix
{ config, pkgs, lib, ... }:

{
  programs.new-tool = {
    enable = true;
    # Configuration here
  };
}
```

1. Import in `home/home.nix`:

```nix
imports = [
  # ... existing imports
  ./modules/tools/new-tool.nix
];
```

1. Test and apply:

```bash
# Validate syntax
nix-instantiate --parse home/modules/tools/new-tool.nix

# Apply configuration
./sync-hm.sh
```

### Modifying Existing Modules

1. Edit the module:

```bash
nvim home/modules/category/module.nix
```

1. Test changes:

```bash
# Build without switching
home-manager build --flake .#user@$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]') --impure

# If successful, apply
./sync-hm.sh
```

### Platform-Specific Changes

For macOS-only changes:

```nix
# In home/modules/platform/darwin.nix
config = lib.mkIf pkgs.stdenv.isDarwin {
  # macOS-specific configuration
};
```

For Linux-only changes:

```nix
# In home/modules/platform/linux.nix
config = lib.mkIf pkgs.stdenv.isLinux {
  # Linux-specific configuration
};
```

## Development Workflows

### Setting Up a New Project

1. Create project directory:

```bash
mkdir ~/projects/new-project
cd ~/projects/new-project
```

1. Create `.envrc` for direnv:

```bash
# For Nix projects
echo "use nix" > .envrc

# For Python projects
echo "layout python" > .envrc

# Allow direnv
direnv allow
```

1. Create `shell.nix` or `flake.nix`:

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    yarn
    # Add project dependencies
  ];
}
```

### Working with Different Languages

#### Python Development

1. Create virtual environment (automatic with direnv):

```bash
echo "layout python" > .envrc
direnv allow
```

1. Or use Nix shell:

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.pytest
  ];
}
```

#### Node.js Development

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_22
    yarn
    nodePackages.npm
  ];
}
```

#### Rust Development

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
  ];
}
```

## Maintenance Tasks

### Regular Maintenance

Weekly tasks:

```bash
# Update dependencies
nix flake update
./sync-hm.sh

# Update Homebrew packages (macOS)
brew update && brew upgrade

# Clean up old generations
home-manager expire-generations "-7 days"
```

Monthly tasks:

```bash
# Deep clean
nix-collect-garbage -d
nix-store --optimise

# Check for large files
du -sh ~/.config/* | sort -h
du -sh /nix/store | head -20
```

### Troubleshooting Performance

```bash
# Check Nix store size
du -sh /nix/store

# List generations
home-manager generations

# Remove all but current generation
home-manager expire-generations "-0 seconds"

# Aggressive garbage collection
nix-collect-garbage -d
nix-store --optimise
```

### Backing Up Configuration

```bash
# Full backup
cp -r ~/nix-config ~/nix-config.backup.$(date +%Y%m%d)

# Git backup (recommended)
git add -A
git commit -m "Backup: $(date +%Y-%m-%d)"
git push origin main
```

### Rollback Changes

```bash
# List available generations
home-manager generations

# Rollback to previous generation
home-manager rollback

# Or switch to specific generation
home-manager switch-generation 142
```

## Collaboration

### Sharing Configuration

1. Fork or clone the repository
2. Customize for your needs:

```bash
# Update git configuration
nvim home/modules/tools/git.nix
# Change userName and userEmail

# Update any personal preferences
nvim home/modules/packages.nix
```

1. Test locally:

```bash
./sync-hm.sh
```

### Contributing Changes

1. Create a feature branch:

```bash
git checkout -b feature/your-feature
```

1. Make changes and test:

```bash
# Make your changes
nvim home/modules/...

# Test locally
./sync-hm.sh

# Verify no issues
nix flake check --impure
```

1. Commit with conventional commits:

```bash
git add -A
git commit -m "feat: add new feature

- Detailed description
- What was changed
- Why it was changed"
```

1. Push and create PR:

```bash
git push origin feature/your-feature
# Create PR on GitHub
```

### Syncing with Upstream

```bash
# Add upstream remote
git remote add upstream https://github.com/original/repo.git

# Fetch and merge updates
git fetch upstream
git checkout main
git merge upstream/main

# Update your fork
git push origin main

# Update dependencies
nix flake update
./sync-hm.sh
```

## Advanced Workflows

### Creating Custom Flake Outputs

Add to `flake.nix`:

```nix
{
  outputs = { self, nixpkgs, ... }: {
    # Custom packages
    packages.aarch64-darwin.my-script = pkgs.writeScriptBin "my-script" ''
      #!/usr/bin/env bash
      echo "Hello from Nix!"
    '';

    # Custom development shells
    devShells.aarch64-darwin.python = pkgs.mkShell {
      buildInputs = with pkgs; [ python3 poetry ];
    };
  };
}
```

Use them:

```bash
# Run custom package
nix run .#my-script

# Enter custom shell
nix develop .#python
```

### Multi-Machine Setup

1. Create host-specific configurations:

```nix
# flake.nix
homeConfigurations = {
  "user@work" = mkHomeConfig "aarch64-darwin" {
    extraModules = [ ./home/work.nix ];
  };
  "user@personal" = mkHomeConfig "aarch64-darwin" {
    extraModules = [ ./home/personal.nix ];
  };
};
```

1. Switch based on machine:

```bash
# On work machine
home-manager switch --flake .#user@work

# On personal machine
home-manager switch --flake .#user@personal
```

### CI/CD Integration

The repository includes GitHub Actions workflows:

1. **On every push:** Flake checks and builds
2. **On PRs:** Full validation and testing
3. **Weekly:** Automated dependency updates

To skip CI on a commit:

```bash
git commit -m "feat: something [skip ci]"
```

To manually trigger workflows:

- Go to Actions tab on GitHub
- Select workflow
- Click "Run workflow"

## CI/CD Workflows

### Available GitHub Actions

The repository includes several automated workflows:

1. **ci.yml** - Main CI pipeline with security scanning
2. **ci-simple.yml** - Alternative CI without security features (use if permission issues)
3. **update-deps.yml** - Weekly dependency updates
4. **pr-validation.yml** - Pull request validation

### Workflow Status

Check the Actions tab on GitHub to see workflow runs and status.

### Troubleshooting CI Issues

If you see "Resource not accessible by integration" errors:

- Use the `ci-simple.yml` workflow instead
- Or enable GitHub Advanced Security in repository settings
- See `.github/workflows/README.md` for detailed fixes

## Quick Reference

### Essential Commands

```bash
# Apply configuration
./sync-hm.sh

# Update everything
nix flake update && ./sync-hm.sh

# Search packages
nix search nixpkgs keyword

# Clean up
nix-collect-garbage -d

# Rollback
home-manager rollback

# Check status
home-manager generations
git status
brew list
```

### File Locations

- Configuration: `~/nix-config/`
- Home Manager files: `~/.config/home-manager/`
- Nix store: `/nix/store/`
- Symlinked configs: `~/.config/`, `~/.*rc`
- Brewfile: `~/nix-config/Brewfile`

### Environment Variables

Set in your shell or `.envrc`:

```bash
# Override user/home detection
export USER="different-user"
export HOME="/different/home"

# Nix options
export NIX_CONFIG="experimental-features = nix-command flakes"
```
