{
  self,
  system,
  version,
  stdenv,
  lib,
  src,
  dasel,
  pandoc,
}:
stdenv.mkDerivation {
  inherit version src;
  pname = "elytrant-page";

  noCC = true;
  buildInputs = [
    dasel
    pandoc
  ];

  buildPhase = ''
    # Add the actual bootstrap zip to the pack so people can download it
    cp '${self.packages.${system}.bootstrap}/Thonks & Stonks-${version}.zip' src/

    # Create the README file for the main page from the repo readme by
    # substituting the bootstrap link and converting it to html
    sed 's|https://.*/Thonks & Stonks-.*.zip|./Thonks \& Stonks-${version}.zip|' -i README.md
    pandoc -f markdown -t html README.md > src/index.html

    # Double check that the resourcepack is up to date; if not, complain!
    resource_hash="$(dasel -f src/index.toml 'files.(file=resourcepacks/Faithless1.18 Fixes.zip).hash')"
    pack_hash="$(sha256sum '${self.packages.${system}.resourcepack}/Faithless1.18 Fixes.zip')"

    if [ $resource_hash -ne $pack_hash ]; then
        echo 'Please update the resource pack zip and then refresh the modpack index' > /dev/stderr
        exit 1
    fi

    # Finally, add the texture pack
    cp '${self.packages.${system}.resourcepack}/Faithless1.18 Fixes.zip' src/resourcepacks/
  '';

  installPhase = ''
    mkdir -p $out
    cp -r src/ $out/${version}
  '';
}
