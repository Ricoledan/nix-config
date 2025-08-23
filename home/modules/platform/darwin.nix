{ config, pkgs, lib, ... }:

{
  # Import Homebrew module (it has its own platform check)
  imports = [
    ../homebrew.nix
  ];

  config = lib.mkIf pkgs.stdenv.isDarwin {
    # macOS-specific configuration

    # AeroSpace window manager config
    home.file.".aerospace.toml".source = ../../../config/aerospace.toml;

    # macOS-specific environment variables
    home.sessionVariables = {
      # Add macOS-specific environment variables here
    };

    # macOS-specific packages
    home.packages = with pkgs; [
      # macOS-specific CLI tools
      # Most GUI apps are managed through Homebrew
    ];

    # macOS-specific shell configuration
    programs.zsh.initExtra = lib.mkAfter ''
      # macOS-specific zsh configuration

      # Enable macOS-specific completions
      if [ -d "/Applications/Docker.app" ]; then
        # Docker Desktop completions if installed
        :
      fi
    '';

    # macOS keyboard and trackpad settings can be managed here
    # Though typically these are better handled through System Preferences
  };
}
