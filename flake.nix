{
  description = "Rico's personal cross-platform Nix environment";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, home-manager }: let
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
	        nix-direnv
          yt-dlp
          claude-code

          # System & Network
          openssh
        ];
        
        shellHook = ''
          echo "Nix development environment loaded"
        '';
      };
    });

    homeConfigurations = {
      "ricoledan@aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "aarch64-darwin";
        modules = [ ./home/home.nix ];
      };

      "ricoledan@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        modules = [ ./home/home.nix ];
      };
    };
  };
}
