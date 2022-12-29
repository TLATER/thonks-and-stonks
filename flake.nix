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
    packages.${system} = {
      default = self.packages.${system}.modpack;

      modpack = pkgs.stdenv.mkDerivation rec {
        pname = "thonks-and-stonks";
        version = "4.1.0";

        src = pkgs.lib.sources.cleanSource self;

        noCC = true;
        buildInputs = with pkgs; [
          dasel
          zip
          packwiz.packages.${system}.default
        ];

        buildPhase = ''
          # Double check that the resourcepack is up to date; if not, complain!
          resource_hash="$(dasel -f src/index.toml 'files.(file=resourcepacks/Faithless1.18 Fixes.zip).hash')"
          pack_hash="$(sha256sum '${self.packages.${system}.resourcepack}/Faithless1.18 Fixes.zip')"

          if [ $resource_hash -ne $pack_hash ]; then
              echo 'Please update the resource pack zip and then refresh the modpack index' > /dev/stderr
              exit 1
          fi

          cp '${self.packages.${system}.resourcepack}/Faithless1.18 Fixes.zip' src/resourcepacks/
          (cd src && packwiz curseforge export)
        '';

        installPhase = ''
          mkdir -p $out
          cp 'src/Thonks & Stonks-${version}.zip' $out/
        '';
      };

      datapack = pkgs.stdenv.mkDerivation {
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

      resourcepack = pkgs.stdenv.mkDerivation {
        pname = "faithless-fixes";
        version = "1.0";

        src = pkgs.lib.sources.cleanSource self;
        noCC = true;
        buildInputs = with pkgs; [zip];

        buildPhase = ''
          (cd 'Faithless1.18 Fixes' && zip -r '../Faithless1.18 Fixes.zip' .)
        '';

        installPhase = ''
          mkdir -p $out
          cp 'Faithless1.18 Fixes.zip' $out/
        '';
      };
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
