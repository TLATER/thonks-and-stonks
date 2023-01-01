{
  stdenv,
  lib,
  src,
  zip,
}:
stdenv.mkDerivation {
  inherit src;
  pname = "elytrant";
  version = "1.0";

  noCC = true;
  buildInputs = [zip];

  buildPhase = ''
    (cd datapack && zip -r ../thonk-stonk-balance-datapack.zip .)
  '';

  installPhase = ''
    mkdir -p $out
    cp thonk-stonk-balance-datapack.zip $out/
  '';
}
