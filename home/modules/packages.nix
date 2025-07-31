{ pkgs }:

{
  # CLI tools that should be available in home environment
  packages = with pkgs; [
    # Nix Tools
    home-manager
    
    # Version Control
    git
    gh
    
    # Text Processing & Search
    jq
    ripgrep
    bat
    fd
    
    # System Utilities
    curl
    tree
    yt-dlp
  ];
}