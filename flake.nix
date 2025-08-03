{
  description = "Rico's personal cross-platform Nix environment";

  # Semantic versioning for this flake
  # Update when making breaking changes, features, or fixes
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      systems = [ "aarch64-darwin" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in
    {
      # Formatter for `nix fmt`
      formatter = forAllSystems (system: (pkgsFor system).nixpkgs-fmt);

      # Checks for `nix flake check`
      checks = forAllSystems (system: {
        format = (pkgsFor system).runCommand "check-format"
          {
            buildInputs = [ (pkgsFor system).nixpkgs-fmt ];
          } ''
          nixpkgs-fmt --check ${./.}
          touch $out
        '';
      });
      # Development shells - minimal since packages are managed by home-manager
      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          buildInputs = with (pkgsFor system); [
            # Only essentials needed before home-manager is activated
            git
            nixpkgs-fmt
          ];

          shellHook = ''
            echo "Nix development environment loaded"
            echo "Run './switch.sh' to activate home-manager configuration"
          '';
        };
      });

      # Create a generic homeConfiguration that works for any user
      homeConfigurations =
        let
          mkHomeConfig = system: home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor system;
            modules = [
              ./home/home.nix
            ];
            # Allow passing username and homeDirectory at runtime
            extraSpecialArgs = {
              inherit system;
            };
          };
        in
        {
          # Generic configurations for each system
          "user@aarch64-darwin" = mkHomeConfig "aarch64-darwin";
          "user@x86_64-linux" = mkHomeConfig "x86_64-linux";
        };
    };
}
