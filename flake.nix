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
    packages.${system}.datapack = pkgs.stdenv.mkDerivation {
      pname = "elytrant";
      version = "1.0";

      src = pkgs.lib.sources.cleanSource self;

      noCC = true;
      buildInputs = with pkgs; [zip];

      buildPhase = ''
        (cd datapack && zip -r ../thonk-stonk-balance-datapack.zip .)
      '';

      installPhase = ''
        mkdir -p $out
        cp thonk-stonk-balance-datapack.zip $out/
      '';
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        packwiz.packages.${system}.default

        unzip
        zip
      ];
    };
  };
}
