{ pkgs }:

with pkgs.lib;

{
  # CLI tools that should be available in home environment
  packages = with pkgs; [
    # Nix Tools
    nixpkgs-fmt

    # Shell and terminal tools
    zoxide
    tmux

    # Development Tools
    # Note: VSCode is managed by Homebrew on macOS
    # See DECISIONS.md for details

    # Container & DevOps
    # Note: Podman and podman-compose are managed by Homebrew on macOS
    # See docs/podman.md for details

    # Programming Languages & Runtimes
    nodejs_22
    (python3.withPackages (ps: with ps; [
      pip
      jupyterlab
      notebook
      matplotlib
      pandas
      numpy
    ]))
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
    ffmpeg
    claude-code
    openssh
  ];
}
