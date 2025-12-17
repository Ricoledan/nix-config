{ config, pkgs, lib, zen-browser, ... }:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    # Linux-specific configuration

    # Linux-specific environment variables
    home.sessionVariables = {
      # Wayland support
      MOZ_ENABLE_WAYLAND = "1";
      # XDG directories
      XDG_DATA_DIRS = "$HOME/.nix-profile/share:$XDG_DATA_DIRS";
    };

    # Linux-specific packages
    home.packages = with pkgs; [
      # Linux-specific tools
      xclip # X11 clipboard support
      wl-clipboard # Wayland clipboard support
      zen-browser # Zen Browser (managed via Homebrew on macOS)

      # Container tools (managed via Homebrew on macOS)
      podman
      podman-compose
    ];

    # Linux-specific shell configuration
    programs.zsh.initContent = lib.mkAfter ''
      # Linux-specific zsh configuration

      # Set up ssh-agent if not already running
      if ! pgrep -x ssh-agent > /dev/null; then
        eval "$(ssh-agent -s)"
      fi
    '';

    # Fontconfig for better font rendering on Linux
    fonts.fontconfig.enable = true;

    # Linux desktop integration
    xdg = {
      enable = true;
      mime.enable = true;

      # Set default applications
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [ "zen.desktop" ];
          "x-scheme-handler/http" = [ "zen.desktop" ];
          "x-scheme-handler/https" = [ "zen.desktop" ];
          "text/plain" = [ "nvim.desktop" ];
        };
      };
    };
  };
}
