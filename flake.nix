{
  description = "Rico's personal development environment";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  
  outputs = { self, nixpkgs }: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
	_1password-cli
	git
	docker
	docker-compose
	vscode
	obsidian
	yt-dlp
	jq
	ripgrep
	curl
	nodejs_22
	python3
	gh
	tree
	bat
	fd
	claude-code
	openssh	
      ];
    };
  };
}
