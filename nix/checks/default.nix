{
  self,
  pkgs,
}: let
  callPackage = pkgs.lib.callPackageWith (pkgs
    // {
      mkCheck = {
        name,
        inputs,
        check,
        ...
      } @ args:
        pkgs.stdenv.mkDerivation ({
            inherit name check;
            src = pkgs.lib.sources.cleanSource self;

            noCC = true;
            doCheck = true;
            dontBuild = true;
            dontConfigure = true;
            dontFixup = true;

            buildInputs = inputs;

            checkPhase = ''
              echo "Running checks"

              mkdir -p $out

              runHook preCheck
              runHook check
              runHook postCheck

              cp check.log $out/
            '';
          }
          // pkgs.lib.filterAttrs (n: v:
            builtins.any (e: e == n) [
              "name"
              "buildInputs"
              "checkPhase"
              "installPhase"
            ])
          args);
    });
in {
  check-hashes = callPackage ./check-hashes.nix {};
}
