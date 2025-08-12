{ config, pkgs, lib, ... }:

{
  # Environment variables for Podman
  home.sessionVariables = lib.mkIf pkgs.stdenv.isDarwin {
    DOCKER_HOST = "unix://${config.home.homeDirectory}/.local/share/containers/podman/machine/podman.sock";
  };

  # Install podman and create the necessary symlinks
  home.packages = lib.mkIf pkgs.stdenv.isDarwin (with pkgs; [
    podman
    qemu
    gvproxy
    podman-desktop

    # Create a wrapper script that ensures Podman is in PATH
    (pkgs.writeShellScriptBin "podman-desktop-wrapped" ''
      export PATH="${pkgs.podman}/bin:$PATH"
      exec ${pkgs.podman-desktop}/bin/podman-desktop "$@"
    '')
  ]);

  # Create symlinks in paths where Podman Desktop looks
  home.activation.setupPodman = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Podman Desktop checks these specific paths
    PODMAN_PATHS=(
      "/usr/local/bin"
      "/opt/homebrew/bin"
      "/opt/podman/bin"
    )

    echo "Setting up Podman CLI for Podman Desktop detection..."

    # Check if we can create symlinks without sudo first
    for dir in "''${PODMAN_PATHS[@]}"; do
      if [[ -d "$dir" ]] && [[ -w "$dir" ]]; then
        echo "Creating podman symlinks in $dir (no sudo needed)..."
        ln -sf ${pkgs.podman}/bin/podman "$dir/podman" 2>/dev/null || true
        ln -sf ${pkgs.podman}/bin/podman-remote "$dir/podman-remote" 2>/dev/null || true
        ln -sf ${pkgs.gvproxy}/bin/gvproxy "$dir/gvproxy" 2>/dev/null || true
        break
      fi
    done

    # If no writable directory found, provide instructions
    if ! command -v podman &> /dev/null || ! /opt/podman/bin/podman --version &> /dev/null 2>&1; then
      echo ""
      echo "⚠️  Podman Desktop may not detect Podman CLI!"
      echo ""
      echo "Please run ONE of these commands with sudo:"
      echo ""
      echo "  Option 1 (recommended for Nix users):"
      echo "  sudo mkdir -p /opt/podman/bin && sudo ln -sf ${pkgs.podman}/bin/podman /opt/podman/bin/podman"
      echo ""
      echo "  Option 2 (if you have Homebrew):"
      echo "  sudo ln -sf ${pkgs.podman}/bin/podman /opt/homebrew/bin/podman"
      echo ""
      echo "  Option 3 (traditional location):"
      echo "  sudo ln -sf ${pkgs.podman}/bin/podman /usr/local/bin/podman"
      echo ""
    fi

    # Also ensure it's in user's local bin
    mkdir -p $HOME/.local/bin
    ln -sf ${pkgs.podman}/bin/podman $HOME/.local/bin/podman
    ln -sf ${pkgs.podman}/bin/podman-remote $HOME/.local/bin/podman-remote
    ln -sf ${pkgs.gvproxy}/bin/gvproxy $HOME/.local/bin/gvproxy
  '';
}
