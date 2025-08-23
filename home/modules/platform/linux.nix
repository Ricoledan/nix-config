{ config, pkgs, lib, ... }:

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
    ];

    # Linux-specific shell configuration
    programs.zsh.initExtra = lib.mkAfter ''
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
          "text/html" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "text/plain" = [ "nvim.desktop" ];
        };
      };
    };
  };
}
