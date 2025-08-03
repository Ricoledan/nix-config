{ pkgs }:

{
  # CLI tools that should be available in home environment
  packages = with pkgs; [
    # Nix Tools
    home-manager
    nixpkgs-fmt
    nix-direnv
    
    # Shell
    zsh
    
    # Version Control & Development
    git
    gh
    vscode
    neovim
    
    # Container & DevOps
    docker
    docker-compose
    
    # Programming Languages & Runtimes
    nodejs_22
    python3
    
    # Text Processing & Search
    jq
    ripgrep
    bat
    fd
    
    # System Utilities
    curl
    tree
    yt-dlp
    claude-code
    openssh
  ];
}