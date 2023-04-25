{
  description = "Simple Minecraft datapack to remove elytras from the game";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    packwiz = {
      url = "github:packwiz/packwiz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    packwiz,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    apps.${system} = import ./nix/scripts {inherit self pkgs;};

    checks.${system} = import ./nix/checks {inherit self pkgs;};

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        packwiz.packages.${system}.default

        unzip
        zip

        (python311.withPackages (ppkgs:
          with ppkgs; [
            python-lsp-server
            pylsp-mypy
            python-lsp-black
            pyls-isort
            pycodestyle
            pydocstyle
            pylint
          ]))
      ];
    };
  };
}
