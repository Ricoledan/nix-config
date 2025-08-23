{ config, pkgs, lib, ... }:

{
  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # Shell integrations
    enableBashIntegration = true;
    enableZshIntegration = false; # We manually add this after P10k instant prompt in zsh.nix

    # Direnv configuration
    config = {
      global = {
        # Suppress verbose output
        warn_timeout = "30s";
        hide_env_diff = false;
        strict_env = false;
      };

      # Whitelist specific directories if needed
      whitelist = {
        prefix = [
          "$HOME/projects"
          "$HOME/dev"
          "$HOME/nix-config"
        ];
      };
    };

    # Standard library extensions
    stdlib = ''
      # Custom direnv functions can go here

      # Example: layout for Python projects with venv
      layout_python() {
        local python=''${1:-python3}
        [[ $# -gt 0 ]] && shift
        unset PYTHONHOME
        if [[ -n $VIRTUAL_ENV ]]; then
          VIRTUAL_ENV=$(realpath "''${VIRTUAL_ENV}")
        else
          local python_version
          python_version=$(''${python} -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
          if [[ -z $python_version ]]; then
            log_error "Could not determine Python version"
            return 1
          fi
          VIRTUAL_ENV=$PWD/.venv
          if [[ ! -d $VIRTUAL_ENV ]]; then
            log_status "Creating virtualenv"
            ''${python} -m venv "$VIRTUAL_ENV"
          fi
        fi
        export VIRTUAL_ENV
        PATH_add "$VIRTUAL_ENV/bin"
      }

      # Use nix-shell for projects
      use_nix() {
        local path="''${1:-shell.nix}"
        if [[ ! -f "$path" ]]; then
          path="default.nix"
        fi
        if [[ -f "$path" ]]; then
          eval "$(nix-shell --run 'declare -x' "$path")"
        fi
      }
    '';
  };

  # Ensure nix-direnv package is available
  home.packages = with pkgs; [
    nix-direnv
  ];
}
