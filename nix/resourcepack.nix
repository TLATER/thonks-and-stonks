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
    (cd 'Faithless1.18 Fixes' && zip -X '../Faithless1.18 Fixes.zip' $(find . | sort))
  '';

  installPhase = ''
    mkdir -p $out
    cp 'Faithless1.18 Fixes.zip' $out/
  '';
}
