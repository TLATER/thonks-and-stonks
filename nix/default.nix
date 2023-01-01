{
  self,
  pkgs,
  packwiz,
}: let
  pack-meta = fromTOML (builtins.readFile ../src/pack.toml);
  version = pack-meta.version;

  callPackage = pkgs.lib.callPackageWith (pkgs
    // {
      inherit pack-meta version self;
      packwiz = packwiz.packages.${pkgs.system}.default;
      src = pkgs.lib.sources.cleanSource self;
    });
in {
  bootstrap = callPackage ./bootstrap.nix {};
  curseforge-modpack = callPackage ./curseforge-modpack.nix {};
  datapack = callPackage ./datapack.nix {};
  page = callPackage ./page.nix {};
  resourcepack = callPackage ./resourcepack.nix {};
}
