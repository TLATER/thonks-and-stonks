{
  stdenv,
  lib,
  src,
  zip,
}:
stdenv.mkDerivation {
  inherit src;
  pname = "faithless-fixes";
  version = "1.0";

  noCC = true;
  buildInputs = [zip];

  buildPhase = ''
    (cd 'Faithless1.18 Fixes' && zip -r '../Faithless1.18 Fixes.zip' .)
  '';

  installPhase = ''
    mkdir -p $out
    cp 'Faithless1.18 Fixes.zip' $out/
  '';
}
