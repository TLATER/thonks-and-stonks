{
  description = "Simple Minecraft datapack to remove elytras from the game";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
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
    packages.${system} = import ./nix {inherit self pkgs packwiz;};

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        packwiz.packages.${system}.default

        unzip
        zip
      ];
    };
  };
}
