{ pkgs }:

with pkgs.lib;

{
  # CLI tools that should be available in home environment
  packages = with pkgs; [
    # Nix Tools
    nixpkgs-fmt
    nix-direnv

    # Shell
    zsh
    zoxide

    # Version Control & Development
    git
    gh
    vscode

    # Container & DevOps
    podman
    podman-compose

    # Programming Languages & Runtimes
    nodejs_22
    python3
    python3Packages.pip
    pre-commit

    # Text Processing & Search
    jq
    ripgrep
    bat
    fd
    fzf

    # System Utilities
    curl
    xh
    tree
    yt-dlp
    claude-code
    openssh
  ];
}
