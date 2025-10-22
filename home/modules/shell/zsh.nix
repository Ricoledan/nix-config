{ config, pkgs, lib, ... }:

{
  # Enable Atuin
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      update_check = false;
      style = "compact";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # Will be overridden by p10k
      plugins = [
        "git"
        "podman"
      ];
    };

    # Initialize zsh with powerlevel10k instant prompt first
    # Note: Using initContent instead of initExtra (though initExtra still works)
    # This addresses the deprecation warning in newer home-manager versions
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Suppress Powerlevel10k instant prompt warnings
        typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      ''
        # Hook direnv after instant prompt to avoid console output issues
        # This is done here instead of through enableZshIntegration to avoid P10k instant prompt issues
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

        # Source powerlevel10k theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

        # Load p10k config if it exists
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # Podman completions
        if command -v podman &> /dev/null; then
          # Podman completion is handled automatically by the shell
          :
        fi

        # 1Password CLI plugins
        [[ -f ~/.config/op/plugins.sh ]] && source ~/.config/op/plugins.sh

        # Terraform completions
        if command -v terraform &> /dev/null; then
          autoload -U +X bashcompinit && bashcompinit
          complete -o nospace -C $(which terraform) terraform
        fi

        # Initialize Zoxide
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      ''

    ];

    # Run commands on login shell (after P10k instant prompt)
    loginExtra = ''
      # Run fastfetch on startup
      if [[ $SHLVL -eq 1 ]]; then
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';

    # History configuration
    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # Environment variables
    sessionVariables = {
      # Add any persistent environment variables here
      # Podman-specific settings
      DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
    };

    # Aliases
    shellAliases = {
      # File system
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";

      # Replace cd with zoxide
      cd = "z";

      # Podman aliases for Docker compatibility
      docker = "podman";
      docker-compose = "podman-compose";
    };
  };

  # Additional packages needed for the zsh config
  home.packages = with pkgs; [
    zsh-powerlevel10k
    fastfetch
    zoxide
  ];

  # Ensure p10k config persists
  home.file.".p10k.zsh" = {
    source = ../../../dotfiles/.p10k.zsh;
  };
}
