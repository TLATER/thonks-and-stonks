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
    (cd datapack && zip -X ../thonk-stonk-balance-datapack.zip $(find . | sort))
  '';

  installPhase = ''
    mkdir -p $out
    cp thonk-stonk-balance-datapack.zip $out/
  '';
}
