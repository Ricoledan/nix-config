{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isDarwin {
  # Homebrew integration for macOS
  # This module manages Homebrew installation and Brewfile syncing
  # Some tools are better managed through Homebrew on macOS due to system integration requirements

  home.activation.brewBundle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Set up Homebrew paths for activation script
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
      echo "Homebrew is not installed. Please install it first:"
      echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      exit 1
    fi

    # Install or update packages from Brewfile
    if [ -f "$HOME/nix-config/Brewfile" ]; then
      echo "Running brew bundle..."
      (cd "$HOME/nix-config" && brew bundle)
    else
      echo "Warning: Brewfile not found at $HOME/nix-config/Brewfile"
    fi
  '';

  # Add Homebrew to PATH and set up environment
  home.sessionVariables = {
    # Homebrew paths for Apple Silicon Macs
    PATH = lib.mkBefore "/opt/homebrew/bin:/opt/homebrew/sbin:$PATH";
  };

  # Shell integration for Homebrew
  programs.zsh.initContent = lib.mkBefore ''
    # Homebrew shell integration
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  '';

  programs.bash.initExtra = lib.mkBefore ''
    # Homebrew shell integration
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  '';
}
