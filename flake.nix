{
  description = "Rico's personal Cross-platform Nix environment";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  
  outputs = { self, nixpkgs }: let
    systems = [ "aarch64-darwin" "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    pkgsFor = system: import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
  in {
    devShells = forAllSystems (system: {
      default = (pkgsFor system).mkShell {
        buildInputs = with (pkgsFor system); [
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

          # CLI Utilities
          jq
          ripgrep
          curl
          tree
          bat
          fd
          yt-dlp
          claude-code

          # System & Network
          openssh

          # Productivity
          obsidian
        ];
        
        shellHook = ''
          exec zsh
        '';
      };
    });
  };
}
