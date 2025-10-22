# Module Documentation

This document provides detailed information about each module in the Nix configuration.

## Table of Contents

- [Core Modules](#core-modules)
- [Shell Modules](#shell-modules)
- [Editor Modules](#editor-modules)
- [Tool Modules](#tool-modules)
- [Platform Modules](#platform-modules)

## Core Modules

### home/home.nix

The main entry point for Home Manager configuration.

**Features:**

- Dynamic user and home directory detection
- Module imports orchestration
- Core Home Manager settings

**Key Configuration:**

```nix
home.username = builtins.getEnv "USER";
home.homeDirectory = builtins.getEnv "HOME";
home.stateVersion = "24.05";
```

**Usage:**
This module is automatically loaded by the flake configuration.

### home/modules/packages.nix

Manages the core set of packages available in the user environment.

**Categories:**

- Nix tools (nixpkgs-fmt)
- Shell and terminal tools (zoxide, tmux)
- Development tools (vscode)
- Programming languages (nodejs, python3)
- Text processing (jq, ripgrep, bat, fd, fzf)
- System utilities (curl, tree, ffmpeg)

**Adding Packages:**

```nix
home.packages = with pkgs; [
  package-name
];
```

## Shell Modules

### home/modules/shell/zsh.nix

Configures Zsh shell with Powerlevel10k theme and various plugins.

**Features:**

- Powerlevel10k instant prompt
- Oh My Zsh integration
- Syntax highlighting and autosuggestions
- Atuin for enhanced history
- Custom aliases and functions
- Zoxide integration for smart directory jumping

**Key Integrations:**

- Direnv (manual hook after P10k prompt)
- 1Password CLI plugins
- Terraform completions
- Podman/Docker aliases

**Customization:**

- P10k configuration: `~/.p10k.zsh`
- Add aliases in the `shellAliases` section
- Add startup commands in `loginExtra`

## Editor Modules

### home/modules/editors/neovim.nix

Configures Neovim with LazyVim distribution.

**Features:**

- LazyVim starter configuration
- LSP support for multiple languages
- Treesitter for syntax highlighting
- Git integration
- Telescope fuzzy finder
- Auto-formatting and linting

**Language Servers Included:**

- Lua (lua-language-server)
- Nix (nil)
- TypeScript/JavaScript
- HTML/CSS/JSON

**Customization:**

- Add custom plugins in `~/.config/nvim/lua/plugins/`
- Modify LazyVim settings in the `extraConfig` section
- Add new language servers in `extraPackages`

## Tool Modules

### home/modules/tools/git.nix

Comprehensive Git configuration with aliases and settings.

**Features:**

- User configuration with sensible defaults
- Extensive alias collection
- Global gitignore patterns
- GitHub CLI integration
- Pull/push strategies
- Diff improvements

**Key Aliases:**

- `git st` - status
- `git lg` - pretty log graph
- `git cob` - checkout new branch
- `git cleanup` - remove merged branches

**Configuration:**

```nix
programs.git.userName = lib.mkDefault "Your Name";
programs.git.userEmail = lib.mkDefault "your@email.com";
```

### home/modules/tools/direnv.nix

Automatic environment loading for projects.

**Features:**

- Nix-direnv integration
- Custom Python virtual environment layout
- Whitelist configuration for trusted directories
- Shell integration (Bash and Zsh)

**Usage:**

1. Create `.envrc` in project root
2. Add `use nix` or `layout python`
3. Run `direnv allow`

**Custom Layouts:**

- `layout_python` - Python virtual environment
- `use_nix` - Nix shell environment

## Platform Modules

### home/modules/platform/darwin.nix

macOS-specific configurations.

**Features:**

- Homebrew integration via homebrew.nix
- AeroSpace window manager configuration
- macOS-specific shell completions
- Platform-specific environment variables

**Homebrew Integration:**

- Automatically runs `brew bundle` on activation
- Manages GUI applications via Brewfile
- Handles macOS-specific tools

### home/modules/platform/linux.nix

Linux-specific configurations.

**Features:**

- Wayland support configuration
- XDG desktop integration
- Clipboard utilities (X11 and Wayland)
- SSH agent setup
- Font configuration
- MIME type associations

**Desktop Integration:**

- Sets default applications
- Configures XDG directories
- Enables fontconfig for better rendering

### home/modules/homebrew.nix

Manages Homebrew installation and packages on macOS.

**Features:**

- Automatic Brewfile syncing
- Homebrew path configuration
- Shell integration setup
- Installation check and guidance

**How It Works:**

1. Checks for Homebrew installation
2. Sets up proper PATH
3. Runs `brew bundle` to sync packages
4. Integrates with shell configurations

**Managing Packages:**
Edit the `Brewfile` in the repository root to add/remove Homebrew packages.

## Module Development Guidelines

### Creating a New Module

1. **Choose the appropriate directory:**
   - `shell/` for shell-related configs
   - `editors/` for text editors
   - `tools/` for development tools
   - `platform/` for OS-specific configs

2. **Module structure template:**

```nix
{ config, pkgs, lib, ... }:

{
  # Module options
  options = {
    # Define custom options if needed
  };

  # Module configuration
  config = {
    # Your configuration here
  };
}
```

1. **Add to imports in home.nix:**

```nix
imports = [
  ./modules/category/your-module.nix
];
```

### Best Practices

1. **Use `lib.mkDefault` for overridable defaults**
2. **Use `lib.mkIf` for conditional configuration**
3. **Use `lib.mkBefore` and `lib.mkAfter` for ordering**
4. **Document complex configurations with comments**
5. **Keep platform-specific code in platform modules**
6. **Test changes with `./sync-hm.sh` before committing**

### Common Patterns

**Conditional Configuration:**

```nix
config = lib.mkIf pkgs.stdenv.isDarwin {
  # macOS-only configuration
};
```

**Merging Configurations:**

```nix
programs.zsh.initContent = lib.mkMerge [
  (lib.mkBefore "# Early initialization")
  "# Normal initialization"
  (lib.mkAfter "# Late initialization")
];
```

**Optional Features:**

```nix
programs.git.delta = {
  enable = lib.mkDefault false;
  options = { ... };
};
```

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for common issues and solutions.
