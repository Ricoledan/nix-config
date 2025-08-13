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
    # Note: Podman and podman-compose are managed by Homebrew on macOS
    # See docs/podman.md for details

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
    asciidoctor
    pandoc

    # System Utilities
    curl
    xh
    tree
    yt-dlp
    claude-code
    openssh
  ];
}
