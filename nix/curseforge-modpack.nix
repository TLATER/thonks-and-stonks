{
  self,
  version,
  system,
  stdenv,
  lib,
  src,
  dasel,
  packwiz,
  zip,
}:
stdenv.mkDerivation {
  inherit version src;
  pname = "thonks-and-stonks-curseforge";

  noCC = true;
  buildInputs = [
    dasel
    packwiz
    zip
  ];

  buildPhase = ''
    # Double check that the resourcepack is up to date; if not, complain!
    resource_hash="$(dasel -f src/index.toml 'files.(file=resourcepacks/Faithless1.18 Fixes.zip).hash')"
    pack_hash="$(sha256sum '${self.packages.${system}.resourcepack}/Faithless1.18 Fixes.zip' | cut -d' ' -f1)"

    if [ "$resource_hash" != "$pack_hash" ]; then
        echo 'Resource pack hash does not match:'
        echo "index: $resource_hash"
        echo "pack: $pack_hash"
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
}
